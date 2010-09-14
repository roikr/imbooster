//
//  ZoozzADBannerView.m
//  IMBooster
//
//  Created by Roee Kremer on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ZoozzADBannerView.h"
#include "ZoozzMacros.h"
#import "AdMobView.h"


#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
#endif

@implementation ZoozzADBannerView

@synthesize zoozzAdView;
@synthesize delegate;
//@synthesize bannerIsVisible;


- (id)initWithDelegate:(id <ZoozzADBannerViewDelegate>)theDelegate {
	if ((self = [super init])) {
		delegate = theDelegate;

		static NSString * const kADBannerViewClass = @"ADBannerView";
		
		if (NSClassFromString(kADBannerViewClass) != nil) {
			ADBannerView * adBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
			adBannerView.frame = CGRectOffset(adBannerView.frame, 0, -50);
			adBannerView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifier320x50];
			adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
			adBannerView.delegate = self;
			self.zoozzAdView = adBannerView;
		}
		
		if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iPhoneOS_4_0) {
			// Request an ad
			AdMobView * adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
			adMobAd.frame = CGRectMake(0, -48, 320, 48);
			self.zoozzAdView = adMobAd; // this will be released when it loads (or fails to load)
		}
		
		bannerIsVisible = NO;
		
		
		
    }
    return self;
	
}





//- (id)initWithFrame:(CGRect)frame {
//    if ((self = [super initWithFrame:frame])) {
//        // Initialization code
//    }
//    return self;
//}
 

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[zoozzAdView release];
	
    [super dealloc];
}




- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    ZoozzLog(@"bannerViewDidLoadAd");
	if (!bannerIsVisible)
    {
		[delegate showBanner:self];
		[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
		// assumes the banner view is offset 50 pixels so that it is not visible.
        banner.frame = CGRectOffset(banner.frame, 0, 50);
        [UIView commitAnimations];
        bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	ZoozzLog(@"bannerView didFailToReceiveAdWithError");

	if (bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -50);
        [UIView commitAnimations];
		[delegate hideBanner:self];
		bannerIsVisible = NO;
    }
	
		
}

#pragma mark -
#pragma mark AdMobDelegate methods

// Use this to provide a publisher id for an ad request. Get a publisher id
// from http://www.admob.com
- (NSString *)publisherIdForAd:(AdMobView *)adView 
{
	return @"a14c8f828e13f15"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView
{
	return (UIViewController *)delegate;
}

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView {
	
	ZoozzLog(@"AdMob: Did receive ad");
	if (!bannerIsVisible)
    {
		[delegate showBanner:self];
		[UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
		adView.frame = CGRectOffset(adView.frame, 0, 48);
		[UIView commitAnimations];
	}
	
	
	bannerIsVisible = YES;
    
	
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
	ZoozzLog(@"AdMob: Did fail to receive ad");
	if (bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
        adView.frame = CGRectOffset(adView.frame, 0, -48);
        [UIView commitAnimations];
		[delegate hideBanner:self];
		bannerIsVisible = NO;
    }
	
	//[adView removeFromSuperview];  // Not necessary since never added to a view, but doesn't hurt and is good practice
	//[adView release];
	//self.zoozzAdView = nil;
	// we could start a new ad request here, but in the interests of the user's battery life, let's not
	
	self.zoozzAdView = nil;
	AdMobView * adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
	adMobAd.frame = CGRectMake(0, -48, 320, 48);
	self.zoozzAdView = adMobAd; // this will be released when it loads (or fails to load)
	
	
}



@end
