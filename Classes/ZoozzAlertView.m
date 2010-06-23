//
//  ZoozzAlertView.m
//  IMBooster
//
//  Created by Roee Kremer on 11/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ZoozzAlertView.h"


@implementation ZoozzAlertView


- (id)initWithZoozzAlert:(NSUInteger)theAlert delegate:(id<ZoozzAlertViewDelegate>) theDelegate {
	if (self = [super init] ) {
		alert = theAlert;
		switch (alert) {
			case ZoozzAlertNoInternetConnection: {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet Connection",@"NoInternetConnection message") message:@"No Internet Connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				
			} break;
			default:
				break;
		}
		
	}
	return self;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	[self release];
	
}

- (void)dealloc {
    [super dealloc];
}

@end
