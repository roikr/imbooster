//
//  IminentAppDelegate.h
//  Messages
//
//  Created by Roee Kremer on 10/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import	"CacheResource.h"
//#import "AuthenticateConnection.h"
#import "XMLParser.h"
#include <AudioToolbox/AudioToolbox.h>
#import "ZoozzMacros.h"
#import "ZoozzEvent.h"


extern NSString * const kZoozzSecuredURL;
extern NSString * const kZoozzURL;
extern NSString *const kAppVersionID;
extern NSString *const kPaidAppVersionID;

extern NSString *const kUpgradeProductIdentifier;


@class Asset,XMLParser,LocalStorage,MyOverlayView,VideoPlayer;
@class CatalogViewController,MessagesViewController,HelpViewController,StoreViewController;
@class ZoozzEvent;



@interface IminentAppDelegate : NSObject <UIApplicationDelegate,XMLParserDelegate,UINavigationControllerDelegate> { //AuthenticateConnectionDelegate,SKPaymentTransactionObserver,CacheResourceDelegate
	UIWindow *window;
	
	UINavigationController *navigationController;

	CatalogViewController *catalog;
	MessagesViewController *messages;
	HelpViewController *help;
	LocalStorage *localStorage;
		
	UIImageView *imageView;

	//MyOverlayView *overlayView;
	//VideoPlayer *videoPlayer;
	
	//BOOL bLoggedIn;
	BOOL bDisplayed;
	//BOOL bStartCacheWinks;
	
	SystemSoundID	soundFileObject;
	
	//NSThread *secondaryThread;
	
	//NSMutableArray *cacheWinks;
	//NSMutableArray *cachingWinks;
	
	//StoreViewController *store;
	
	//BOOL bStoreObserved;
	
	//NSString *APNToken;
	
	//NSString *notifiedProduct;
	
	//NSString * lastNotificationIdentifier;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) IBOutlet MessagesViewController * messages;
@property (nonatomic, retain) CatalogViewController * catalog;
@property (nonatomic, retain) HelpViewController *help;

//@property BOOL bLoggedIn;
@property BOOL bDisplayed;


//@property (nonatomic, retain) IBOutlet MyOverlayView *overlayView;

@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@property (nonatomic, retain) LocalStorage * localStorage;
//@property (nonatomic, retain) VideoPlayer *videoPlayer;


@property (readonly)	SystemSoundID	soundFileObject;
//@property (nonatomic, retain) NSThread *secondaryThread;
//@property (nonatomic, retain) NSMutableArray *cacheWinks;
//@property (nonatomic, retain) NSMutableArray *cachingWinks;

//@property (nonatomic, retain) StoreViewController *store;

//@property (nonatomic, retain) NSString *APNToken;

//@property (nonatomic, retain) NSString *notifiedProduct;
//@property (nonatomic, retain) NSString *lastNotificationIdentifier;


- (void)playClickSound;
- (void)bringHelp;
- (void)gotoGallery;
- (void)gotoKeyboard;


//- (BOOL) launchVideo:(NSURL *)theUrl;

//- (void)purchaseWithProduct:(NSString *)identifier;
//- (void)closeStore;
//- (void)restoreTransactions;

- (void)addEvent:(ZoozzEvent*)event;
//- (void)sendEvents;

//- (ZoozzViewType) getCurrentView;
//- (void)notificationWithAction:(ZoozzNotificationActionType)action;


@end
