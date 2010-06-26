//
//  AssetView.h
//  IMBooster
//
//  Created by Roee Kremer on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CacheAsset.h"


@class Asset;
@interface AssetView : UIView { //<CacheAssetDelegate>
	UIButton *galleryButton;
	UIImageView *imageView;
	UIImageView *lockedBadgeView;
	UIImageView *newBadgeView;
	UIWebView *preview;
	
	//UIActivityIndicatorView *activityView;
	Asset *asset;
	//CacheAsset *cacheAsset;
	
	
	
}

@property (nonatomic,retain) UIButton * galleryButton;
@property (nonatomic,retain) UIImageView *imageView;
@property (nonatomic,retain) UIImageView *lockedBadgeView;
@property (nonatomic,retain) UIImageView *newBadgeView;
@property (nonatomic,retain) UIWebView *preview;

@property (nonatomic, retain) Asset *asset;
//@property (nonatomic, retain) CacheAsset *cacheAsset;
//@property (nonatomic, retain) UIActivityIndicatorView *activityView;

- (id)initWithAsset:(Asset*)theAsset;
- (void)stopPreview:(NSTimer*)theTimer;
- (void)action:(id)sender;

- (void)addThumb;
- (void)updateThumbView;
//- (void)loadResources;
//- (void)cancelLoad;

//- (void)startActivity;
//- (void)stopActivity;

@end
