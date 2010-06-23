//
//  StoreViewController.m
//  IMBooster
//
//  Created by Roee Kremer on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StoreViewController.h"
#import "IminentAppDelegate.h"
#import "LocalStorage.h"

#import "ContentView.h"
#import "Asset.h"
#import <math.h>
#import "ZoozzEvent.h"

@interface StoreViewController (PrivateMethods)
- (void)requestProductsData;
- (void)startProcess;
- (void)stopProcess;
@end

@implementation StoreViewController

@synthesize activityView;
@synthesize label;
@synthesize textView;
@synthesize storeTitle;
@synthesize scrollView;
@synthesize productIdentifier;
@synthesize content;
@synthesize buyButton;
@synthesize cancelButton;
@synthesize product;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Load the view nib and initialize the subCategoryNumber ivar.
- (id)initWithProductIdentifier:(NSString*)identifier {
	
    if (self = [super initWithNibName:@"StoreViewController" bundle:nil]) {
        self.productIdentifier=identifier;
		
		bUpgrade = NO;
		
#ifdef _IMBoosterFree
		bUpgrade = [identifier isEqualToString:kUpgradeProductIdentifier];
#endif
    }
	
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSArray *assets = [NSArray arrayWithArray:[appDelegate.localStorage productAssetsWithIdentifier:productIdentifier]];
	
	/*
	double root = sqrt([assets count]);
	int n = floor(root);
	int m = ceil([assets count] / n);
	 */
	
	
	if ([assets count] > 24) {
		int n = ceil([assets count] / 4.0);
		scrollView.contentSize = CGSizeMake(2+n*53, 4*53);
	}
	
	self.content = [NSMutableArray array];
	for(int i=0;i<[assets count];i++) {
		Asset *asset = [assets objectAtIndex:i];
		ContentView *aContent = [[ContentView alloc] initWithAsset:asset];
		if ([assets count] > 24)
			aContent.frame = CGRectMake(2+i/4*53,i%4*53, 50, 50);
		else
			aContent.frame = CGRectMake(2+i%6*53,i/6*53, 50, 50);
		
		[self.scrollView addSubview:aContent];
		[content addObject:aContent];
		[aContent release];
	}	
	
	buyButton.enabled = NO;
	
	// we ask for products details once we are in the gallery
	if ([SKPaymentQueue canMakePayments]) {
		[self requestProductsData];
	} 

	
	
}


- (void)requestProductsData {
	cancelButton.enabled = NO;
	textView.text = NSLocalizedString(@"ProductsRequestMessage",@"Requesting product information, this may take some time...");
	
	[self startProcess];
	SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productIdentifier]];
	request.delegate = self;
	[request start];
}

-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	cancelButton.enabled = YES;
	[self stopProcess];
	for (SKProduct * aProduct in response.products) {
		//ZoozzLog([NSString stringWithFormat:@"title: %@, desciption: %@, id: %@",[aProduct localizedTitle],[aProduct localizedDescription],[aProduct productIdentifier]]);
		ZoozzLog([aProduct productIdentifier]);
		if ([aProduct.productIdentifier isEqualToString:productIdentifier]) {
			//[self alertAppPurchaseActionWithProduct:product];
			self.product = aProduct;
			buyButton.enabled = YES;
			
			//ZoozzLog([NSString stringWithFormat:@"title: %@, desciption: %@, id: %@",[product localizedTitle],[product localizedDescription],[product productIdentifier]]);
			
			//NSString * message = @"IMBooster is locked, you can continue, try it for 3 days or buy it (we prefer the latter)";
			// open an alert with two custom buttons
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
			[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			[numberFormatter setLocale:product.priceLocale];
			NSString *formattedString = [numberFormatter stringFromNumber:product.price];
			
			storeTitle.text = product.localizedTitle;
			textView.text = [NSString stringWithFormat:@"%@\n%@",product.localizedDescription,NSLocalizedString(@"BuyProductMessage",@"buy this product?")];
			[cancelButton setTitle:NSLocalizedString(@"CancelButton",@"No thanks")];
			
			if (bUpgrade)
				[buyButton setTitle:[NSString stringWithFormat: NSLocalizedString(@"UpgradeButton",@"Upgrade for"),formattedString]];
			else
				[buyButton setTitle:[NSString stringWithFormat: NSLocalizedString(@"BuyButton",@"Buy for"),formattedString]];
			break;
		}
	}
	
	if (!product) {
		textView.text = NSLocalizedString(@"ProductNotAvailiableMessage",@"Sorry, this product is not availiable at the moment.");
		[cancelButton setTitle:NSLocalizedString(@"DoneButton",@"Done")];
	}
	
	[request autorelease];
	
}

- (void)updateStoreViews {
	
}


/*
- (BOOL)isProductAvailiable:(NSString *)identifier {
	if (products) {
		
		for (SKProduct * product in products) {
			ZoozzLog([NSString stringWithFormat:@"title: %@, desciption: %@, id: %@",[product localizedTitle],[product localizedDescription],[product productIdentifier]]);
			if ([product.productIdentifier isEqualToString:identifier]) {
				//[self alertAppPurchaseActionWithProduct:product];
				return YES;
			}
		}
	}
	
	return NO;
}
*/









/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.activityView = nil;
	self.label = nil;
}


- (void)dealloc {
	[activityView release];
	[label release];
	[textView release];
	[storeTitle release];
	[scrollView release];
	[buyButton release];
	[cancelButton release];
    [super dealloc];
}

- (void)startProcess {
	self.label.hidden = NO;
	[self.activityView startAnimating];
}

- (void)stopProcess {
	self.label.hidden = YES;
	[self.activityView stopAnimating];
}


- (void)loadContent {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	for (ContentView *contentView in content ) {
		[contentView performSelector:@selector(loadResources) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
	}
}

- (void)cancelLoadContent {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];	
	for (ContentView *contentView in content) {
		[contentView performSelector:@selector(cancelLoad) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
	}
}

- (void)updateContentViews {
	for (ContentView *contentView in content) {
		if (contentView.asset.contentType == CacheResourceWink) {
			[contentView updateThumbView];
		}
	}
}


	
- (IBAction)cancel:(id)sender {
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate closeStore];
	ZoozzLog(@"Purchase canceled");
}

- (IBAction)buy:(id)sender {
	buyButton.enabled = NO;
	
	textView.text = NSLocalizedString(@"StoreProcessMessage",@"processing your purchase");
	[self startProcess];
	
	SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
	ZoozzLog(@"StoreViewController - buy: %@",productIdentifier);
	//[self authenticateTrial];
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate addEvent:[ZoozzEvent buyWithProduct:productIdentifier]];
	
}

- (void)purchaseSucceeded {
	[self stopProcess];
	textView.text = @"";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"StoreConfirmationTitle",@"in app store")
													message:NSLocalizedString(@"StoreConfirmationMessage",@"wasted")
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];	
	[alert show];
	[alert release];
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate closeStore];
	
}

- (void)purchaseFailed:(NSString*)failure {
	[self stopProcess];
	buyButton.enabled = YES;
	textView.text = failure;
}


@end
