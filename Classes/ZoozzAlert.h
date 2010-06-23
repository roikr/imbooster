//
//  ZoozzAlert.h
//  IMBooster
//
//  Created by Roee Kremer on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    ZoozzNotificationAlert = 1,
	ZoozzProductNotificationAlert = 2
	
};

typedef NSUInteger ZoozzAlertType; 

@interface ZoozzAlert : NSObject<UIAlertViewDelegate> {
	ZoozzAlertType alertType;
}

@property ZoozzAlertType alertType;

+ (void)alertWithType:(ZoozzAlertType)type withTitle:(NSString *)title withMessage:(NSString *)msg withCancel:(NSString *)cancel;
+ (void)alertWithType:(ZoozzAlertType)type withTitle:(NSString *)title withMessage:(NSString *)msg withCancel:(NSString *)cancel withButton:(NSString*)button;

@end
