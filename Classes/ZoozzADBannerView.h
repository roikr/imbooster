//
//  ZoozzADBannerView.h
//  IMBooster
//
//  Created by Roee Kremer on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@protocol ZoozzADBannerViewDelegate;


@interface ZoozzADBannerView : UIView<ADBannerViewDelegate> {
	id<ZoozzADBannerViewDelegate> delegate;
	ADBannerView *adBannerView;
	BOOL bannerIsVisible;
	
}

@property (nonatomic, assign) id delegate;
@property (nonatomic,retain) ADBannerView *adBannerView;

- (id)initWithDelegate:(id <ZoozzADBannerViewDelegate>)theDelegate;

@end




@protocol ZoozzADBannerViewDelegate<NSObject>

- (void)showBanner:(ZoozzADBannerView *)bannerView;
- (void)hideBanner:(ZoozzADBannerView *)bannerView;

@end
