
//
//  IminentAppDelegate.m
//  Messages
//
//  Created by Roee Kremer on 10/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "IminentAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "MessagesViewController.h"
#import "SubCategoryViewController.h"
#import "CatalogViewController.h"
#import "ServiceViewController.h"
#import "StoreViewController.h"
#import "HelpViewController.h"
#import "Asset.h"
#import "LocalStorage.h"
#import "VideoPlayer.h"

#import "ZoozzConnection.h"
#import "Utilities.h"

#import "Section.h"
#import "Category.h"


#import "ZoozzAlert.h"


#ifdef _DEVELOPMENT_SERVER
// DEVELOPMENT
NSString * const kZoozzHost=@"dev.zoozzmedia.com";
NSString * const kZoozzURL = @"http://dev.zoozzmedia.com";
NSString * const kZoozzSecuredURL = @"http://dev.zoozzmedia.com";
//NSString * const kZoozzHost=@"192.168.15.144";
//NSString * const kZoozzURL = @"http://192.168.15.144";
//NSString * const kZoozzSecuredURL = @"http://192.168.15.144";

#else
// PRODUCTION
NSString * const kZoozzHost=@"imbooster.zoozzmedia.com";
NSString * const kZoozzURL = @"http://imbooster.zoozzmedia.com";
NSString * const kZoozzSecuredURL = @"https://imbooster.zoozzmedia.com";
#endif



NSString * const kUpgradeProductIdentifier = @"com.iminent.IMBoosterFree.UpgradeToIMBooster";


#ifdef _IMBooster 
	NSString * const kAppVersionID = @"1";
	NSString * const kZoozzAppID = @"339715267"; // paid
#endif

#ifdef _IMBoosterFree 
	NSString * const kAppVersionID = @"2";
	NSString * const kZoozzAppID = @"339039054"; // free
#endif

#ifdef _IMBoosterPlus 
	NSString * const kAppVersionID = @"3";
	NSString * const kZoozzAppID = @"347615983"; // plus
#endif


@interface IminentAppDelegate (PrivateMethods)
- (void)login;
- (void)loginDidFailed;
- (void)loadLibraryWithTransaction:(SKPaymentTransaction *)transaction;
- (void)parseLibrary;
- (void)threadMain;
- (void)startCachingWinks;
- (void)stopCachingWinks;
- (void)updateCurrentViews;

- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (void)authenticateTransaction:(SKPaymentTransaction *)transaction;
- (void)authenticateTrial:(NSString *)identifier;


@end

@implementation IminentAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize catalog;
@synthesize messages;

@synthesize overlayView;
@synthesize videoPlayer;

@synthesize imageView;

@synthesize localStorage;

@synthesize bLoggedIn;
@synthesize bDisplayed;

@synthesize help;
@synthesize soundFileObject;
@synthesize secondaryThread;
@synthesize cacheWinks;
@synthesize cachingWinks;

@synthesize store;
@synthesize APNToken;
@synthesize notifiedProduct;
@synthesize lastNotificationIdentifier;


- (void)dealloc {
	[secondaryThread release];
	[videoPlayer release];
	[messages release];
	[catalog release];
	[help release];
	[navigationController release];
   	[window release];
	[cacheWinks release];
	[cacheWinks release];
	[APNToken release];
	[notifiedProduct release];
	AudioServicesDisposeSystemSoundID (self.soundFileObject);
		
	[super dealloc];
}

                                                                         
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	enableEmoji();
		
#ifdef _ADMOB
	[self performSelectorInBackground:@selector(reportAppOpenToAdMob) withObject:nil];
	ZoozzLog(@"admod started");
#endif
	
	[window makeKeyAndVisible];
	
	bLoggedIn = NO;
	bDisplayed = NO;
	bStoreObserved = NO;
	
	//notificationAlert = NO; // just to know if the alert is previewed to avoid store on notification on startup
	
	
	
	/* By default, the Cocoa URL loading system uses a small shared memory cache. 
	 We don't need this cache, so we set it to zero when the application launches. */
	
	/* turn off the NSURLCache shared cache */
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 
                                                            diskCapacity:0 
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
	
	/* prepare to use our own on-disk cache */
	
	
	self.localStorage = [LocalStorage localStorage];
	
#ifdef _SETTINGS
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"delete_purchases_identifier"]) {
		localStorage.purchases = nil;
		[localStorage archive];
	}
#endif
	
	// if I got no library but libraryDate valid
	if (![CacheResource doesAssetCachedWithResourceType:CacheResourceLibrary withIdentifier:nil]) {
		localStorage.libraryDate = nil;
		[localStorage archive];
	}
	
	
	if (isConnected() && !localStorage.cookieInstalled) {  
		localStorage.cookieInstalled = YES;
		[localStorage archive];
		[[UIApplication sharedApplication] openURL:
		 [NSURL URLWithString:[NSString stringWithFormat:@"%@/welcome/%@?l=%@",kZoozzURL,kAppVersionID,[[NSLocale preferredLanguages] objectAtIndex:0]]]];
		
		return YES;
	}
	
/*
#ifdef _IMBoosterFree
	if (!localStorage.firstLaunch) {
		firstLaunchAlert();
		localStorage.firstLaunch = YES;
		[localStorage archive];
	}
#endif
*/
	
	
	videoPlayer = [[VideoPlayer alloc] init];
		
	NSURL * url = (NSURL *)[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
	if (url && [[url host] isEqualToString:@"reply"]) {
		
		NSString *token = [url query];
		
		//alert(@"token", token);
		
		localStorage.message = nil;	
		[self addEvent:[ZoozzEvent enterWithParameter:ZoozzParameterReply withToken:token WithAssetID:nil]];
	}
	
	if (url && [[url host] isEqualToString:@"welcome"])
		[self addEvent:[ZoozzEvent enterWithParameter:ZoozzParameterWelcome withToken:nil WithAssetID:nil]];
	
	if (url && [[url host] isEqualToString:@"play"])
		[self launchVideo:url];
		
	
	if (url && [[url host] isEqualToString:@"restore"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"restore_transactions_identifier"]) 
		[self restoreTransactions];
	
	
	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
	
	if ([UIApplication sharedApplication].applicationIconBadgeNumber) {
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;	
		[self addEvent:[ZoozzEvent notificationRecieved]];
	}
	
	if (launchOptions) {
#ifdef _Debug
		//alert(@"launchOptions: ", [launchOptions description]);
#endif
		NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		
		
		if (userInfo && [userInfo objectForKey:@"nid"]) {
			self.lastNotificationIdentifier = [userInfo objectForKey:@"nid"];
			if ([userInfo objectForKey:@"pid"]) {
				self.notifiedProduct = [userInfo objectForKey:@"pid"];
			} else {
				[self addEvent:[ZoozzEvent notificationWithAction:ZoozzNotificationActionRecieved withIdentifier:self.lastNotificationIdentifier]];
				self.lastNotificationIdentifier = nil;
			}
			
		} 
		
	}
	
	
	return YES;
	
}

- (void)notificationWithAction:(ZoozzNotificationActionType)action {
	switch ([self getCurrentView]) {
		case ZoozzViewKeyboard: {
			SubCategoryViewController *controller = [messages.viewControllers objectAtIndex:messages.currentSection];
			[self addEvent:[ZoozzEvent notificationWithAction:action inView:[self getCurrentView] inSection:messages.currentSection subSection:controller.currentPage withIdentifier:self.lastNotificationIdentifier]];
		} break;
		case ZoozzViewGallery: {
			ServiceViewController *controller = [catalog.viewControllers objectAtIndex:catalog.currentSection];
			[self addEvent:[ZoozzEvent notificationWithAction:action inView:[self getCurrentView] inSection:catalog.currentSection subSection:controller.currentCategory withIdentifier:self.lastNotificationIdentifier]];
		} break;
		case ZoozzViewHelp:
		case ZoozzViewStore:
			[self addEvent:[ZoozzEvent notificationWithAction:action inView:[self getCurrentView] withIdentifier:self.lastNotificationIdentifier]];
			break;
	}
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
	NSDictionary *aps = [userInfo objectForKey:@"aps"];
	id alertValue = [aps objectForKey:@"alert"];
	if (!aps || !alertValue || ![alertValue isKindOfClass:[NSString self]]) {
		return;
	}
	
	if (!userInfo || ![userInfo objectForKey:@"nid"]) {
		return;
	}
	
	self.lastNotificationIdentifier =  [userInfo objectForKey:@"nid"];
	[self notificationWithAction:ZoozzNotificationActionRecieved];
	 
	if ([userInfo objectForKey:@"pid"]) {
		self.notifiedProduct = [userInfo objectForKey:@"pid"];
		
		[ZoozzAlert alertWithType:ZoozzProductNotificationAlert withTitle:NSLocalizedString(@"NotificationTitle",@"Remote Noticiation") 
					  withMessage:[aps objectForKey:@"alert"] withCancel:NSLocalizedString(@"CancelButton",@"No thanks") withButton:@"OK"];
	} else {
		
		self.lastNotificationIdentifier = nil;
		[ZoozzAlert alertWithType:ZoozzProductNotificationAlert withTitle:NSLocalizedString(@"NotificationTitle",@"Remote Noticiation") 
						  withMessage:alertValue withCancel:@"OK"];
	}
	
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	ZoozzLog(@"description: %@",[deviceToken description]);
	NSString *str = [[NSString alloc] initWithData:convertToHex(deviceToken) encoding:NSASCIIStringEncoding];
	self.APNToken = str;
	[str release];
	ZoozzLog(@"remote notification token: %@, length: %u",APNToken,[APNToken length]);
	
	if (isConnected()) {
		[self login];
	} else
		[self loginDidFailed];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if (isConnected()) {
		[self login];
	} else
		[self loginDidFailed];
}

#pragma mark Zoozz application states

-(void) login {
	//[self sendEvents]; // we don't send last session events
	[[AuthenticateConnection alloc] initWithDelegate:self];
}

- (void) loginDidFailed {
	if (!bDisplayed) {
		if ([CacheResource doesAssetCachedWithResourceType:CacheResourceLibrary withIdentifier:nil]) {
			[self parseLibrary];
		}
		else {
			NoConnectionAlert();
		}
	}
}

#pragma mark AuthenticateConnection delegate methods

- (void) AuthenticateConnectionDidFailLoading:(AuthenticateConnection *)authenticateConnection {
	switch (authenticateConnection.connection.requestType) {
		case ZoozzLogin:
			[self loginDidFailed];
			break;
		case ZoozzAuthenticateTransaction:
			[store purchaseFailed:@"zoozz server connection failed"];
			break;
		default:
			break;
	}
	
	[authenticateConnection release];
}


- (void) AuthenticateConnectionDidFinishLoading:(AuthenticateConnection *)authenticateConnection {
	
	NSInteger statusCode = [authenticateConnection.connection.theResponse statusCode];
	
	switch (authenticateConnection.connection.requestType) {
		case ZoozzLogin:
			[self loadLibraryWithTransaction:nil];
			break;
		case ZoozzAuthenticateTransaction:
		{
			switch (statusCode) {
				case HTTPStatusCodeOK: {
					if (authenticateConnection.transaction) {
						[self loadLibraryWithTransaction:authenticateConnection.transaction];
					}
					
				} break;
				case HTTPStatusCodeNoContent: {
					ZoozzLog(@"AuthenticateConnectionDidFinishLoading - ZoozzAuthenticateTransaction - purchase didn't authorized");
					[store purchaseFailed:@"zoozz server authentication failed"];
				} break;
			}
		} break;
		case ZoozzAuthenticateTrial: {
			switch (statusCode) {
				case HTTPStatusCodeOK: {
					[self loadLibraryWithTransaction:nil];
					
				} break;
				case HTTPStatusCodeNoContent: {
					ZoozzLog(@"AuthenticateConnectionDidFinishLoading - ZoozzAuthenticateTrial - trial didn't authorized");
				} break;
			}
		} break;
	}
	
	[authenticateConnection release];
}



- (void)loadLibraryWithTransaction:(SKPaymentTransaction *)transaction {
	/*
	if (!bDisplayed && [[NSUserDefaults standardUserDefaults] boolForKey:@"precache_library_identifier"]) {
		NSError * error = nil;
		NSString * appFile = [CacheResource cacheResourcePathWithResourceType:CacheResourceLibrary WithIdentifier:nil];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
			if (![[NSFileManager defaultManager] removeItemAtPath:appFile error:&error]) 
				ZoozzLog(@"can't delete %@: %@",appFile,[error localizedDescription]);
			else
				ZoozzLog(@"%@ deleted",appFile);
		}
		
		[CacheResource copyWithResourceType:CacheResourceLibrary withIdentifier:nil];	
		if ([CacheResource doesAssetCachedWithResourceType:CacheResourceLibrary withIdentifier:nil]) {
			[self parseLibrary];
			return;
		} else {
			ZoozzLog(@"could not precache library");
		}		
	}
	 */

#ifdef _SETTINGS
	if (!bDisplayed && [[NSUserDefaults standardUserDefaults] boolForKey:@"clear_library_identifier"]) {
		localStorage.libraryDate = nil;
	}
#endif
	 
	 
	
	[[CacheResource alloc] initWithResouceType:CacheResourceLibrary withObject:transaction delegate:self];
}



#pragma mark CacheResource delegate methods

- (void)CacheResourceDidFailLoading:(CacheResource *)cacheResource {
	switch (cacheResource.resourceType) {
		case CacheResourceLibrary: {
			[self loginDidFailed];
		} break;
			
		case CacheResourceWink: {
			[cachingWinks removeObject:cacheResource];
		} break;
			
		default:
			break;
	}
	
	
	ZoozzLog(@"IminentAppDelegate - CacheResourceDidFailLoading");
	
	[cacheResource release];
}

- (void)CacheResourceDidFinishLoading:(CacheResource *)cacheResource {
	
	switch (cacheResource.resourceType) {
		case CacheResourceLibrary: {
			
			if (cacheResource.transaction) {
				[[SKPaymentQueue defaultQueue] finishTransaction: cacheResource.transaction];
				if ( cacheResource.transaction.transactionState == SKPaymentTransactionStatePurchased && store) {
					if ([store.productIdentifier isEqualToString:cacheResource.transaction.payment.productIdentifier]) {
						
						SKProduct *product = store.product;
						NSString *cur = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
						[self addEvent:[ZoozzEvent buyWithProduct:store.productIdentifier withTransaction:cacheResource.transaction.transactionIdentifier withCurrency:cur withPrice:product.price]];
						[store purchaseSucceeded];
						
						
						
						
					}
				}
				
			}
						
			if (!bDisplayed) {
				[self parseLibrary];
			}
			else if ([cacheResource.connection.theResponse statusCode] == HTTPStatusCodeOK)  {
				[self parseLibrary];
			} 
			else {
				[self updateCurrentViews];
			}

		} break;
			
		case CacheResourceWink: {
			Asset *asset = [localStorage.assetsByIdentifier objectForKey:cacheResource.identifier];
			asset.bContentCached = YES;
			[cachingWinks removeObject:cacheResource];
			if (navigationController.modalViewController==store) {
				[store updateContentViews];
			}
			else if (navigationController.topViewController == catalog)
				[catalog updateWinksViews];
			
		} break;
			
		default:
			break;
	}
	
	
	
	[cacheResource release];
}


-(void) parseLibrary {
	[[XMLParser alloc] parse:[NSData dataWithContentsOfFile:[CacheResource cacheResourcePathWithResourceType:CacheResourceLibrary WithIdentifier:nil]] withDelegate:self];
}


#pragma mark XMLParser delegate methods

- (void) XMLParserDidFail:(XMLParser *)theParser {
	[theParser release];
}

- (void) XMLParserDidFinish:(XMLParser *)theParser {
	
	if (!bDisplayed) {
		bDisplayed = YES;

		[localStorage arrangeAssets:theParser.assets];
		AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Click" ofType:@"caf"]], &soundFileObject);
		//[self.imageView removeFromSuperview];
		
		[window sendSubviewToBack:imageView];
		imageView.hidden = YES;
		
		self.secondaryThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain) object:nil];
		[secondaryThread start];
	
		[window addSubview:[navigationController view]];
		
		
#ifdef _SETTINGS
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"reload_library_identifier"]) {
			localStorage.libraryDate = nil;
			[self loadLibraryWithTransaction:nil];
		}

		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"request_trial_identifier"]) {
			[self authenticateTrial:kUpgradeProductIdentifier];
		}
#endif
		
	} else {
		[messages clearView];
		[catalog clearView];
		[self performSelector:@selector(stopCachingWinks) onThread:secondaryThread withObject:nil waitUntilDone:YES];
		[localStorage arrangeAssets:theParser.assets];
		[self performSelector:@selector(startCachingWinks) onThread:secondaryThread withObject:nil waitUntilDone:NO];
		[self updateCurrentViews];
	}
	
	if (bLoggedIn && !bStoreObserved) {
		bStoreObserved = YES;
		// if we didn't restored transaction we put the observer here to get lost purchased
		
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
		
		if (notifiedProduct && self.lastNotificationIdentifier) {
			[self addEvent:[ZoozzEvent notificationWithAction:ZoozzNotificationActionRecieved withIdentifier:self.lastNotificationIdentifier]];
			[self addEvent:[ZoozzEvent notificationWithAction:ZoozzNotificationActionBeenViewed withIdentifier:self.lastNotificationIdentifier]];
			self.lastNotificationIdentifier = nil;
			[self purchaseWithProduct:self.notifiedProduct];
			self.notifiedProduct = nil;
			
		}

		/*
		if ([defaults boolForKey:@"restore_purchases_identifier"]) {
			[storeManager.observer restoreTransactions];
			
			[defaults setBool:NO forKey:@"restore_purchases_identifier"];
			[defaults synchronize];
			
		}
		 */
	}
	
	

	[theParser release];
}


/*
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
}
 */

- (void)updateCurrentViews {
	if (navigationController.topViewController == messages) {
		messages.currentSection = messages.currentSection; // messages.currentPage =.. will be called by setCurrentSection
	}
	else if (navigationController.topViewController == catalog)
		catalog.currentSection = catalog.currentSection;
	else 
		ZoozzLog(@"who is your daddy ?");
	
	
	
}

# pragma mark secondary Thread
- (void)doFireTimer:(NSTimer *)timer {
    
}

- (void)threadMain
{
	// The application uses garbage collection, so no autorelease pool is needed.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.cacheWinks = [NSMutableArray array];
	self.cachingWinks = [NSMutableArray array];
	
	[self startCachingWinks];
	
	
	
	NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
	/*
	 // Create a run loop observer and attach it to the run loop.
	 CFRunLoopObserverContext  context = {0, self, NULL, NULL, NULL};
	 CFRunLoopObserverRef    observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
	 kCFRunLoopAllActivities, YES, 0, &myRunLoopObserver, &context);
	 
	 if (observer)
	 {
	 CFRunLoopRef    cfLoop = [myRunLoop getCFRunLoop];
	 CFRunLoopAddObserver(cfLoop, observer, kCFRunLoopDefaultMode);
	 }
	 */
    // Create and schedule the timer.
    [NSTimer scheduledTimerWithTimeInterval:1 target:self
								   selector:@selector(doFireTimer:) userInfo:nil repeats:YES];
	
	
	
    BOOL done = NO;
    do
    {
       
		// Run the run loop 10 times to let the timer fire.
		
		if (!bLoggedIn && isConnected()) {
			[self performSelectorOnMainThread:@selector(login) withObject:nil waitUntilDone:NO];
		}
		
		if (bLoggedIn) {
			
			if ([cacheWinks count] && [cachingWinks count]<2 ) {
				Asset *asset = [cacheWinks objectAtIndex:0];
				
				ZoozzLog(@"loadWinks: %@",asset.identifier);
				CacheResource *cacheResource = [[CacheResource alloc] initWithResouceType:CacheResourceWink withObject:asset.identifier delegate:self];
				[cacheWinks removeObjectAtIndex:0];
				[cachingWinks addObject:cacheResource];
			}
		}
		
        [myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
		
		
    }
    while (!done);
	
	self.cacheWinks = nil;
	self.cachingWinks = nil;
	
	[pool release];
	ZoozzLog(@"IminentAppDelegate - threadMain had finished");
	
}

- (void)startCachingWinks {
	ZoozzLog(@"startCachingWinks");
	Section *winksSection = [localStorage.sections objectAtIndex:6];
	for (Category *cat in winksSection.categories) {
		for (Asset *asset in cat.assets) {
			if (![CacheResource doesAssetCachedWithResourceType:CacheResourceWink withIdentifier:asset.identifier]) {
				[cacheWinks addObject:asset];
			}
		}
	}
	
}

- (void)stopCachingWinks {
	ZoozzLog(@"stopCachingWinks");
	[cacheWinks removeAllObjects];
	for (CacheResource *wink in cachingWinks) {
		[wink cancel];
		wink.delegate = nil;
	}
	[cacheWinks removeAllObjects];
}



#pragma mark Store

- (void)purchaseWithProduct:(NSString *)identifier
{
		
	[self addEvent:[ZoozzEvent gotoStoreWithProduct:identifier]];
	[self sendEvents];
	self.store = [[StoreViewController alloc] initWithProductIdentifier:identifier];
	
	
	// Create a new render context of the UIView size, and set a scale so that the full stage will render to it
	UIView * myView = self.navigationController.view;
	UIGraphicsBeginImageContext( CGSizeMake( myView.bounds.size.width, myView.bounds.size.height ) );
	CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
	
	// Render the stage to the new context
	[myView.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	// Get an image from the context
	UIImage* viewImage = 0;
	viewImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// Kill the render context
	UIGraphicsEndImageContext();
	store.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	imageView.hidden = NO;
	[self.navigationController presentModalViewController:store animated:YES];
	
	//[store startProcess];
	[store loadContent];
	self.imageView.image = viewImage;
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
   	ZoozzLog(@"updatedTransactions");
	
	for (SKPaymentTransaction *transaction in transactions)
    {
        
		//ZoozzLog([NSString stringWithFormat:@"payment for: %@, transaction state: %u",transaction.payment.productIdentifier,transaction.transactionState]);
		
		switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
			case SKPaymentTransactionStateRestored:
				[self authenticateTransaction:transaction];
				break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
			default:
                break;
        }
    }
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	ZoozzLog(@"failedTransaction: %@",[transaction.error localizedDescription]);
	if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	
	if (store) {
		if ([store.productIdentifier isEqualToString:transaction.payment.productIdentifier]) {
			[store purchaseFailed:[transaction.error localizedDescription]];
		}
	}
}


- (void)authenticateTransaction:(SKPaymentTransaction *)transaction {
	
	if (store) {
		if ([store.productIdentifier isEqualToString:transaction.payment.productIdentifier]) {
			store.textView.text = NSLocalizedString(@"PurchaseAuthrizationMessage",@"Loading new content, this may take some time...");
			[store.cancelButton setTitle:NSLocalizedString(@"DoneButton",@"Done")];
		}
	}
	
	[[AuthenticateConnection alloc] initWithTransaction:transaction delegate:self];
}


/*
- (void)completeTransactions {
	NSArray *array = [localStorage.purchases componentsSeparatedByString:@"\n"];
	for (NSString *str in array) {
		if ([str length]) {
			SKPaymentTransaction *transaction = [receipts objectForKey:str];
			ZoozzLog(@"check transaction: %@",str);
			if (transaction) {
				ZoozzLog(@"transaction found");
				if (transaction.transactionState == SKPaymentTransactionStatePurchased && store) {
					if ([store.productIdentifier isEqualToString:transaction.payment.productIdentifier]) {
						[store purchaseSucceeded];
					}
					
				}
				
				[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
				
			}
		}
		
	}
	
	self.receipts = nil;
}

*/

- (void)restoreTransactions {
	localStorage.libraryDate = nil; // hack for ensure that server always return update library (even if we ONLY removed products)
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
	
}

- (void)authenticateTrial:(NSString *)identifier {
	[[AuthenticateConnection alloc] initWithProductIdentifier:identifier delegate:self];
}

- (void)closeStore {
	[store cancelLoadContent];
	[navigationController dismissModalViewControllerAnimated:YES];
	imageView.hidden = YES;
	[store release];
	self.store = nil;
}

#pragma mark Events

- (void)addEvent:(ZoozzEvent*)event {
	if (!localStorage.events) {
		localStorage.events = [NSMutableArray arrayWithCapacity:10];
	}
	
	[localStorage.events addObject:event];
	
	if ([localStorage.events count] >= 10 || event.eventType == ZoozzBuyEvent || event.eventType == ZoozzNotificationEvent || event.eventType == ZoozzSendEvent) {
		[self sendEvents];
	}
}

- (void)sendEvents {
	if (isConnected() && localStorage.events && [localStorage.events count]) {
		NSString *msg=@"<?xml version='1.0' encoding='utf-8' ?><events>\n";
		for (ZoozzEvent *event in localStorage.events) {
			msg = [msg stringByAppendingString:event.eventMsg];
			msg = [msg stringByAppendingString:@"\n"];
		}
		msg = [msg stringByAppendingString:@"</events>"];
		[[ZoozzConnection alloc] initWithRequestType:ZoozzEvents withString:msg delegate:nil];
		[localStorage.events removeAllObjects];
		//[localStorage archive]; // doesn't archive events
	}
}

#pragma mark more
- (void) playClickSound {
	AudioServicesPlaySystemSound (self.soundFileObject);
}



- (void)applicationWillTerminate:(UIApplication *)application {
	[localStorage archive];
}


- (void)gotoGallery {
	
	
	if (catalog == nil) {
		catalog = [[CatalogViewController alloc] initWithNibName:@"CatalogViewController" bundle:nil];
	}
	[self.navigationController pushViewController:catalog animated:YES];
	[self.catalog deselectAsset];
	catalog.currentSection = messages.currentSection;
	
	ServiceViewController *controller = [catalog.viewControllers objectAtIndex:catalog.currentSection];
	[self addEvent:[ZoozzEvent gotoView:ZoozzViewGallery toSection:catalog.currentSection subSection:controller.currentCategory]]; 
}

- (void)gotoKeyboard {
	[self.navigationController popToRootViewControllerAnimated:YES];
	messages.currentSection = catalog.currentSection;
	
	SubCategoryViewController *controller = [messages.viewControllers objectAtIndex:messages.currentSection];
	[self addEvent:[ZoozzEvent gotoView:ZoozzViewKeyboard toSection:messages.currentSection subSection:controller.currentPage]];
					
					
	
}


- (void)bringHelp {
	
	[self addEvent:[ZoozzEvent gotoHelpView]];	
	if (help == nil) {
		help = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
	}
	
	help.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self.navigationController presentModalViewController:help animated:YES];
	
	
}

- (ZoozzViewType) getCurrentView {
	
	if (navigationController.modalViewController) {
		if (navigationController.modalViewController == help) {
			return ZoozzViewHelp;
		}
		else {
			return ZoozzViewStore;
		}
	}
	
	if (navigationController.topViewController == messages) {
		return ZoozzViewKeyboard;
	} 
	
	return ZoozzViewGallery;
}

- (BOOL) launchVideo:(NSURL *)theUrl
{   
	//alert(@"url", [theUrl description]);
	NSString *identifier = [[theUrl relativePath] lastPathComponent];
	
	if (!identifier) {
		return NO;
	}
	
	NSString *token = [theUrl query];
	if (!token) {
		return NO;
	}
	//alert(@"token", token);
	
	[self addEvent:[ZoozzEvent enterWithParameter:ZoozzParameterContent	withToken:token	WithAssetID:identifier]];

	
	if ([CacheResource doesAssetCachedWithResourceType:CacheResourceWink withIdentifier:identifier]) {
		
		[videoPlayer initAndPlayMovie:[NSURL fileURLWithPath:[CacheResource cacheResourcePathWithResourceType:CacheResourceWink WithIdentifier:identifier]]];
	} else {
		
				
		NSString *resource = [NSString stringWithFormat:@"%@/content/d/%@?%@",kZoozzURL,identifier,token];
		//alert(@"resource", resource);
		[videoPlayer initAndPlayMovie:[NSURL URLWithString:resource]];
	}

	
	//[videoPlayer initAndPlayMovie:[NSURL fileURLWithPath:[CacheResource cacheResourcePathWithResourceType:CacheResourceWink WithIdentifier:@"5459AB23F7C3449F183837CDA50A6123"]]];
	
	
	//[videoPlayer initAndPlayMovie:[NSURL fileURLWithPath:[CacheResource cacheResourcePathWithResourceType:CacheResourceWink WithIdentifier:@"5459AB23F7C3449F183837CDA50A6123"]]];
	
	//[videoPlayer initAndPlayMovie:[NSURL URLWithString:@"http://imbooster.zoozzmedia.com/content/d/94CC06ED1BA626ACF2F4A4096F31D544?0F2AC4B17935A3073E7E04D994083C9A41"]];
	//[videoPlayer initAndPlayMovie:[NSURL URLWithString:@"http://imbooster.zoozzmedia.com/content/d/5459AB23F7C3449F183837CDA50A6123?001FEF6FBC0A1C39E073B083A10015CB51"]];
	//[videoPlayer initAndPlayMovie:[NSURL URLWithString:@"http://imbooster.zoozzmedia.com/content/d/3E5372347758EA88381631A13C31FF9A?02F2ABEF7BF6458B7E07B38897A6BB12D1"]];
	
		
	
	return YES;
}



#pragma mark AddMob

- (void)reportAppOpenToAdMob {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // we're in a new thread here, so we need our own autorelease pool
	// Have we already reported an app open?
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *appOpenPath = [documentsDirectory stringByAppendingPathComponent:@"admob_app_open"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:appOpenPath]) {
		// Not yet reported -- report now
		NSString *appOpenEndpoint = 
		[NSString stringWithFormat:@"http://a.admob.com/f0?isu=%@&app_id=%@", 
		 [[UIDevice currentDevice] uniqueIdentifier], kZoozzAppID];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:appOpenEndpoint]];
		NSURLResponse *response;
		NSError *error;
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && ([responseData length] > 0)) {
			[fileManager createFileAtPath:appOpenPath contents:nil attributes:nil]; // successful report, mark it as such
		}
	}
	[pool release];
}


@end
