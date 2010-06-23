//
//  ZoozzAlertView.h
//  IMBooster
//
//  Created by Roee Kremer on 11/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZoozzAlertViewDelegate;

enum {
    ZoozzAlertNoInternetConnection = 1
};

typedef NSUInteger ZoozzAlert;

@interface ZoozzAlertView : NSObject<UIAlertViewDelegate> {
	id<ZoozzAlertViewDelegate> delegate;
	ZoozzAlert alert;
}

- (id)initWithZoozzAlert:(NSUInteger)theAlert delegate:(id<ZoozzAlertViewDelegate>) theDelegate;


@end

@protocol ZoozzAlertViewDelegate<NSObject>
- (void) alertFinished:(ZoozzAlertView *)alert;
@end



