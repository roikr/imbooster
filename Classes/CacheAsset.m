//
//  CacheAsset.m
//  IMBooster
//
//  Created by Roee Kremer on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CacheAsset.h"
#import "IminentAppDelegate.h"
#import "Asset.h"

 
@implementation CacheAsset

@synthesize thumb;
@synthesize content;
@synthesize asset;
@synthesize delegate;

- (id)initWithAsset:(Asset*)theAsset delegate:(id<CacheAssetDelegate>)theDelegate {
	if (self = [super init]) {
		
		self.asset = theAsset;
		self.delegate = theDelegate;
		
				
		if (!asset.bThumbCached  ) {
			self.thumb = [[CacheResource alloc] initWithResouceType:CacheResourceThumb withObject:asset.identifier delegate:self];
		} 
		
		if (!asset.bContentCached) {
			if (asset.contentType!=CacheResourceWink) {
				self.content = [[CacheResource alloc] initWithResouceType:asset.contentType withObject:asset.identifier delegate:self];
			}
		}
		
		
	}
	return self;
}


- (void)CacheResourceDidFailLoading:(CacheResource *)cacheResource {
	ZoozzLog(@"KeyView - CacheResourceDidFailLoading");
	//ZoozzLog(@"asset %@(%@), section: %u, category: %u fail loading.",identifier,cacheResource.resourceType == CacheResourceThumb ? @"thumb" : @"content",section,category);	
	
	if (cacheResource.resourceType	== CacheResourceThumb) {
		self.thumb = nil;
		if (self.content==nil) {
			[self.delegate CacheAssetDidFailLoading:self];
		}
	}
	if (cacheResource.resourceType == CacheResourceEmoticon || cacheResource.resourceType == CacheResourceWink) {
		self.content = nil;
		if (self.thumb==nil) {
			[self.delegate CacheAssetDidFailLoading:self];
		}
	}
	
	[cacheResource release];
}


- (void)CacheResourceDidFinishLoading:(CacheResource *)cacheResource {
	if (cacheResource.resourceType == CacheResourceThumb) {
		asset.bThumbCached = YES;
		self.thumb = nil;
		//ZoozzLog(@"thumb loaded - number: %u, type: %@",number,type ==  ? @"wink" : @"emoticon");
		
	} 
	
	if (cacheResource.resourceType == CacheResourceEmoticon || cacheResource.resourceType == CacheResourceWink) {
		asset.bContentCached = YES;
		self.content = nil;
		//ZoozzLog(@"content loaded - number: %u, type: %@",number,type ==  ? @"wink" : @"emoticon");
	}	
	
	[self.delegate CacheAssetDidFinishLoading:self];
	
	[cacheResource release];
}

- (void)cancel {
	if (thumb) {
		[thumb cancel];
		thumb.delegate = nil;
		[thumb release];
		self.thumb = nil;
	}
	
	if (content) {
		[content cancel];
		content.delegate = nil;
		[content release];
		self.content = nil;
	}
}

- (void)dealloc {
	// if thumb or content didn't release before, let them finish loading but nil their delegate
	// do I need to release it here or on the thread ?
	if (thumb)
		thumb.delegate = nil;
	if (content) 
		content.delegate = nil;
    [super dealloc];
}
@end
