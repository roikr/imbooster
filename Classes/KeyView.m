//
//  KeyView.m
//  IMBooster
//
//  Created by Roee Kremer on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KeyView.h"
#import "IminentAppDelegate.h"
#import "MessagesViewController.h"
#import "Asset.h"


@implementation KeyView

@synthesize keyboardButton;
@synthesize lockedBadgeView;
@synthesize newBadgeView;
@synthesize asset;
//@synthesize cacheAsset;
//@synthesize activityView;

- (id)initWithAsset:(Asset*)theAsset {
	if (self = [super init]) {
		IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.asset = theAsset;
		self.keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		keyboardButton.frame = CGRectMake(0,0, 50, 50);
		keyboardButton.tag = asset.charCode;
		keyboardButton.backgroundColor=[UIColor whiteColor];
		keyboardButton.clipsToBounds = YES;
		[keyboardButton addTarget:appDelegate.messages action:@selector(addEmoticon:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:keyboardButton];
		//bThumbAdded = NO;
		//[self performSelector:@selector(updateThumbView) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
		// I don't want to call subsequent pages because I don't see them, so no need to load from server - in the gallery it is different
		//[self performSelector:@selector(loadResources) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
		[self updateThumbView];
		
		if (asset.bLocked) {
			UIImage *image = [UIImage imageNamed:@"keyboard-lock.png"];
			
			//CGRect newFrame = CGRectMake(frame.origin.x+frame.size.width - image.size.width,frame.origin.y+frame.size.height - image.size.height, image.size.width, image.size.height);
			
			UIImageView * newItemView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 50, 50)];
			newItemView.image = image;
			self.lockedBadgeView = newItemView;
			[newItemView release];
			[self addSubview:lockedBadgeView];
		}
		
		if (asset.bNew) {
			UIImage *image = [UIImage imageNamed:@"new.png"];
			
			//CGRect newFrame = CGRectMake(frame.origin.x+frame.size.width - image.size.width,frame.origin.y+frame.size.height - image.size.height, image.size.width, image.size.height);
			
			UIImageView * newItemView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 50, 50)];
			newItemView.image = image;
			self.newBadgeView = newItemView;
			[newItemView release];
			[self addSubview:newBadgeView];
		}
		 
		
	}
	return self;
}

- (void)addThumb {
	[keyboardButton setImage:asset.thumbImage forState:UIControlStateNormal];
}



/*
- (void)loadResources {
	if (!asset.bThumbCached || (asset.contentType!=CacheResourceWink && !asset.bContentCached)) {
		IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		if (appDelegate.bLoggedIn && !self.cacheAsset) {
			self.cacheAsset = [[CacheAsset alloc] initWithAsset:asset delegate:self];
			if (activityView == nil) {
				[self performSelectorOnMainThread:@selector(startActivity) withObject:nil waitUntilDone:NO];
				//[self startActivity];
			}
		} 
		
		
	}
	[self updateThumbView];
}
*/
- (void)updateThumbView {
	
	// this function can be called several times so I want to check I didn't add the thumb yet
	if (asset.bThumbCached )  { // && !bThumbAdded
		if (asset.thumbImage==nil) {
			
			NSData * data = [NSData dataWithContentsOfFile:[CacheResource cacheResourcePathWithResourceType:CacheResourceThumb WithIdentifier:asset.identifier]];
			[asset performSelectorOnMainThread:@selector(setThumbImage:) withObject:[UIImage imageWithData:data] waitUntilDone:YES];
		}
		
		[self performSelectorOnMainThread:@selector(addThumb) withObject:nil waitUntilDone:NO];
		//bThumbAdded = YES;
	}
	
	
	/*
	if (asset.bThumbCached && (asset.bContentCached || asset.contentType==CacheResourceWink))  {
		if (activityView != nil) {
			//[self stopActivity];
			[self performSelectorOnMainThread:@selector(stopActivity) withObject:nil waitUntilDone:NO];
		}
				
	} 
	 */
	
	
}



/*
- (void)startActivity {
	self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	//activityView.frame = CGRectMake(0,0, 50, 50);
	CGRect frame = activityView.frame;
	frame.origin.x = 25 - activityView.bounds.size.width/2;
	frame.origin.y = 25 - activityView.bounds.size.height/2;
	activityView.frame = frame;
	[activityView startAnimating];
	[self addSubview:activityView];
	keyboardButton.userInteractionEnabled = NO;
}

- (void)stopActivity {
	[activityView removeFromSuperview];
	[activityView stopAnimating];
	[activityView release];
	self.activityView = nil;
	keyboardButton.userInteractionEnabled = YES;
}


*/



/*
- (void)CacheAssetDidFailLoading:(CacheAsset *)theCacheAsset {
	ZoozzLog(@"KeyView - CacheResourceDidFailLoading");
	//ZoozzLog(@"asset %@(%@), section: %u, category: %u fail loading.",identifier,cacheResource.resourceType == CacheResourceThumb ? @"thumb" : @"content",section,category);	
	
	[cacheAsset release];
	self.cacheAsset = nil;
	
}


- (void)CacheAssetDidFinishLoading:(CacheAsset *)theCacheAsset {
	
	[self updateThumbView];
	if (asset.bContentCached && asset.bThumbCached) {
		[cacheAsset release];
		self.cacheAsset = nil;
	}

	
}


- (void)cancelLoad {	
	if (cacheAsset) {
		[cacheAsset cancel];
		cacheAsset.delegate = nil;
		[cacheAsset release];
		self.cacheAsset = nil;
		//
//		 if ([self activity]) {
//		 [self performSelectorOnMainThread:@selector(stopActivity) withObject:nil waitUntilDone:NO];
//		 }
//		 
	}
}
 */

- (void)dealloc {
	// if thumb or content didn't release before, let them finish loading but nil their delegate
	// do I need to release it here or on the thread ?
	
	[keyboardButton release];
	[lockedBadgeView release];
	[newBadgeView release];
	//[activityView release];
	
	
	//if (cacheAsset)
//		cacheAsset.delegate = nil;
	
    [super dealloc];
}

@end
