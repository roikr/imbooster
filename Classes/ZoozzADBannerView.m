//
//  ZoozzADBannerView.m
//  IMBooster
//
//  Created by Roee Kremer on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ZoozzADBannerView.h"
#include "ZoozzMacros.h"


@implementation ZoozzADBannerView

@synthesize adBannerView;
@synthesize delegate;


- (id)initWithDelegate:(id <ZoozzADBannerViewDelegate>)theDelegate {
	if ((self = [super init])) {
		delegate = theDelegate;
		adBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
		adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		adBannerView.delegate = self;
		[self addSubview:adBannerView];
		bannerIsVisible = NO;
    }
    return self;
	
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[adBannerView release];
    [super dealloc];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    ZoozzLog(@"bannerViewDidLoadAd");
	if (!bannerIsVisible)
    {
		[delegate showBanner:self];
//		[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
//		// assumes the banner view is offset 50 pixels so that it is not visible.
//        banner.frame = CGRectOffset(banner.frame, 0, 50);
//        [UIView commitAnimations];
        bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	ZoozzLog(@"bannerView didFailToReceiveAdWithError");

	if (bannerIsVisible)
    {
//        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
//		// assumes the banner view is at the top of the screen.
//        banner.frame = CGRectOffset(banner.frame, 0, -50);
//        [UIView commitAnimations];
		[delegate hideBanner:self];
		bannerIsVisible = NO;
    }
}

@end
