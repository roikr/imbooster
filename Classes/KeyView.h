//
//  KeyView.h
//  IMBooster
//
//  Created by Roee Kremer on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CacheAsset.h"


@class Asset;
@interface KeyView : UIView { // <CacheAssetDelegate>
	UIButton *keyboardButton;
	UIImageView *lockedBadgeView;
	UIImageView *newBadgeView;
	//UIActivityIndicatorView *activityView;
	
	Asset *asset;
	//CacheAsset *cacheAsset;
	
	//BOOL bThumbAdded;
	
}

@property (nonatomic, retain) UIButton *keyboardButton;
@property (nonatomic, retain) UIImageView *lockedBadgeView;
@property (nonatomic, retain) UIImageView *newBadgeView;
@property (nonatomic, retain) Asset *asset;
//@property (nonatomic, retain) CacheAsset *cacheAsset;
//@property (nonatomic, retain) UIActivityIndicatorView *activityView;

- (id)initWithAsset:(Asset*)theAsset;
//- (void)cancelLoad;
- (void)addThumb;
- (void)updateThumbView;
//- (void)loadResources;

//- (void)startActivity;
//- (void)stopActivity;

@end
