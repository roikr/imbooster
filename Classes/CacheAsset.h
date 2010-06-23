//
//  CacheAsset.h
//  IMBooster
//
//  Created by Roee Kremer on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheResource.h"

@protocol CacheAssetDelegate;

@class Asset;
@interface CacheAsset : NSObject<CacheResourceDelegate> {
//@private
	
	id <CacheAssetDelegate> delegate;
	CacheResource *thumb;
	CacheResource *content;
	
	Asset *asset;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) CacheResource *thumb;
@property (nonatomic, retain) CacheResource *content;
@property (nonatomic, retain) Asset *asset;

- (id)initWithAsset:(Asset*)theAsset delegate:(id<CacheAssetDelegate>)theDelegate;
- (void)cancel;
@end


@protocol CacheAssetDelegate<NSObject>
- (void)CacheAssetDidFailLoading:(CacheAsset *)cacheAsset;
- (void)CacheAssetDidFinishLoading:(CacheAsset *)cacheAsset;
@end
