//
//  ZoozzAlert.m
//  IMBooster
//
//  Created by Roee Kremer on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ZoozzAlert.h"
#import "IminentAppDelegate.h"


@implementation ZoozzAlert

@synthesize alertType;

+ (void)alertWithType:(ZoozzAlertType)type withTitle:(NSString *)title withMessage:(NSString *)msg withCancel:(NSString *)cancel {
	ZoozzAlert *instance = [[self alloc] init];
	instance.alertType = type;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:instance cancelButtonTitle:cancel otherButtonTitles: nil];	
	[alert show];
	[alert release];
	
}

+ (void)alertWithType:(ZoozzAlertType)type withTitle:(NSString *)title withMessage:(NSString *)msg withCancel:(NSString *)cancel withButton:(NSString*)button {
	ZoozzAlert *instance = [[self alloc] init];
	instance.alertType = type;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:instance cancelButtonTitle:cancel otherButtonTitles: button,nil];	
	[alert show];
	[alert release];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (alertType == ZoozzProductNotificationAlert ) {
		if (buttonIndex != [alertView cancelButtonIndex]) {
			[appDelegate notificationWithAction:ZoozzNotificationActionBeenViewed];
			//[alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
			//[appDelegate performSelector:@selector(purchaseWithProduct:) withObject:[appDelegate.notificationPayload objectForKey:@"pid"] afterDelay:0.0];
			
			if (appDelegate.bDisplayed && appDelegate.bLoggedIn && !appDelegate.navigationController.modalViewController) { // (!appDelegate.store || appDelegate.navigationController.modalViewController!=(UIViewController*)appDelegate.store)
				[appDelegate purchaseWithProduct:appDelegate.notifiedProduct];
				appDelegate.notifiedProduct = nil;
			}
		} else {
			appDelegate.notifiedProduct = nil;
		}
		
		appDelegate.lastNotificationIdentifier = nil;
		
	}
	
	//[alertView release];
}


- (void)dealloc {
	[super dealloc];
}
@end
