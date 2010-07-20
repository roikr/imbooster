//
//  AssetView.m
//  IMBooster
//
//  Created by Roee Kremer on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AssetView.h"
#import "IminentAppDelegate.h"
#import "CatalogViewController.h"
#import "VideoPlayer.h"
#import "LocalStorage.h"
#import "Asset.h"
#import "ZoozzEvent.h"

@implementation AssetView

@synthesize galleryButton;
@synthesize imageView;
@synthesize lockedBadgeView;
@synthesize newBadgeView;
@synthesize preview;
//@synthesize activityView;
@synthesize asset;
//@synthesize cacheAsset;


- (id)initWithAsset:(Asset*)theAsset {
	if (self = [super init]) {
		
		self.asset = theAsset;
		NSArray * pins = [NSArray arrayWithObjects:@"Blue pin.png",@"Red pin.png",@"Yellow pin.png",@"Green2 pin.png",nil];
		NSArray * pins_selected = [NSArray arrayWithObjects:@"Blue pin-selected.png",@"Red pin-selected.png",@"Yellow pin-selected.png",@"Green2 pin-selected.png",nil];
		//float rotations[4]= {-4.3,-3,2.6,5.8};
		
		uint k = arc4random() % 4;
		
		self.galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[galleryButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
		galleryButton.frame= CGRectMake(0, 0 , 80, 104);
		
		[galleryButton setBackgroundImage:[UIImage imageNamed:[pins objectAtIndex:k]] forState:UIControlStateNormal];
		[galleryButton setBackgroundImage:[UIImage imageNamed:[pins_selected objectAtIndex:k]] forState:UIControlStateSelected];
		
		//[galleryButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%u-normal.png",k+1]] forState:UIControlStateNormal];
		//[galleryButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%u-touch.png",k+1]] forState:UIControlStateHighlighted];
		//[galleryButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%u-selected.png",k+1]] forState:UIControlStateSelected];
		galleryButton.tag =  asset.charCode; //j*2;
		[self addSubview:galleryButton];
		
		
		//UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(13+i*80, 23, 50, 50)];
		UIImageView * theView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 24, 50, 50)];
		//image.transform = CGAffineTransformRotate(image.transform, (   M_PI * rotations[k] / 180.0));
		self.imageView = theView;
		[theView release];
		[self addSubview:imageView];
		
		//IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
		// here I call to load from server because it is only the requested cells - the update is in the end of loadResources
		//[self performSelector:@selector(loadResources) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
		[self updateThumbView];
		
		if (theAsset.bLocked) {
			UIImageView * newItemView = [[UIImageView alloc] initWithFrame:CGRectMake(13,24, 50, 50)];
			newItemView.image = [UIImage imageNamed:@"gallery-lock.png"];
			self.lockedBadgeView = newItemView;
			[newItemView release];
			[self addSubview:lockedBadgeView];
		}
		
		if (theAsset.bNew) {
			UIImageView * newItemView = [[UIImageView alloc] initWithFrame:CGRectMake(13,24, 50, 50)];
			newItemView.image = [UIImage imageNamed:@"new.png"];
			self.newBadgeView = newItemView;
			[newItemView release];
			[self addSubview:newBadgeView];
		}
		 
			
	}
	return self;
}



- (void)action:(id)sender
{
	//ZoozzLog(@"UIButton was clicked");
	
	UIButton * button = (UIButton *)sender;
	
	//NSInteger clickedButton = [self.tableView indexPathForCell:(UITableViewCell*)button.superview].row*4+button.tag-1;
	
	
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	//[appDelegate playClickSound];
	
	//Asset * theAsset = [appDelegate.localStorage.assetsByUnichar objectForKey:[NSString stringWithFormat:@"%u",button.tag]];
	
	[appDelegate.catalog deselectAsset];
	
	// enable selection for locked items only if store is accessible via connection
	if (!asset.bLocked ) {  // || appDelegate.bLoggedIn
		[appDelegate.catalog selectAsset:self.asset withButton:button];
	}
	
	
	[appDelegate addEvent:[ZoozzEvent galleryPreviewWithAsset:self.asset]];
	
	switch (asset.contentType) {
		//case CacheResourceWink: {
//			// double check because I check before enabling the button
//			if (asset.bContentCached) {
//				[appDelegate.videoPlayer initAndPlayMovie:[NSURL fileURLWithPath:[CacheResource cacheResourcePathWithResourceType:asset.contentType WithIdentifier:asset.identifier]]];
//			}
//		} break;
		case CacheResourceEmoticon: {
			if (asset.bContentCached) {
				button.userInteractionEnabled = NO;
				if (!preview) {
					UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(13, 24, 50, 50)];
					webView.opaque = NO;
					webView.backgroundColor = [UIColor clearColor];
					
					self.preview = webView;
					[webView release];
					[self addSubview:preview];
				}
				
				
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString * dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"data"]; 
				
				[preview loadHTMLString:[@"<html><body style='margin-left:0px;margin-top:0px;background-color:transparent'><img style='width:50px;height:50px;background-color:transparent' src='content/" stringByAppendingString:
										 [asset.identifier stringByAppendingString:@".gif'/></body></html>"]] baseURL:[NSURL fileURLWithPath:dataPath isDirectory:YES]];
				
				preview.hidden = NO;
				imageView.hidden = YES;
				if (lockedBadgeView) {
					lockedBadgeView.hidden = YES;
				}
				
				if (newBadgeView) {
					newBadgeView.hidden = YES;
				}
				
				[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(stopPreview:) userInfo:nil repeats:NO];	
					
			}
			
		} break;
		default:
			break;
	}
	
	//if (clickedButton >= [assetsList count]  )
	//	return;
}


- (void)stopPreview:(NSTimer*)theTimer {
	
	galleryButton.userInteractionEnabled = YES;
	preview.hidden = YES;	
	imageView.hidden = NO;
	if (lockedBadgeView) {
		lockedBadgeView.hidden = NO;
	}
	if (newBadgeView) {
		newBadgeView.hidden = NO;
	}
}

- (void)addThumb {
	imageView.image = asset.thumbImage;
}


/*
- (void)loadResources {
	if (!asset.bThumbCached || !asset.bContentCached) {
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
	if (asset.bThumbCached && imageView.image==nil)  {
		if (asset.thumbImage==nil) {
			
			NSData * data = [NSData dataWithContentsOfFile:[CacheResource cacheResourcePathWithResourceType:CacheResourceThumb WithIdentifier:asset.identifier]];
			[asset performSelectorOnMainThread:@selector(setThumbImage:) withObject:[UIImage imageWithData:data] waitUntilDone:YES];
		}
		
		[self performSelectorOnMainThread:@selector(addThumb) withObject:nil waitUntilDone:NO];
	}
	
	/*
	if (asset.bThumbCached && asset.bContentCached)  {
		if (activityView != nil) {
			[self performSelectorOnMainThread:@selector(stopActivity) withObject:nil waitUntilDone:NO];
			//[self stopActivity];
		}
		
	} 
	*/
	
}


/*
- (void)startActivity {
	self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	//activityView.frame = CGRectMake(0,0, 50, 50);
	CGRect frame = activityView.frame;
	frame.origin.x = 25+13 - activityView.bounds.size.width/2;
	frame.origin.y = 25+24 - activityView.bounds.size.height/2;
	activityView.frame = frame;
	[activityView startAnimating];
	[self addSubview:activityView];
	galleryButton.userInteractionEnabled = NO;
}

- (void)stopActivity {
	[activityView removeFromSuperview];
	[activityView stopAnimating];
	[activityView release];
	self.activityView = nil;
	galleryButton.userInteractionEnabled = YES;
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
		
		 //if ([self activity]) {
//		 [self performSelectorOnMainThread:@selector(stopActivity) withObject:nil waitUntilDone:NO];
//		 }
		 
	}
}
*/
- (void)dealloc {
	// if thumb or content didn't release before, let them finish loading but nil their delegate
	// do I need to release it here or on the thread ?
	
	[galleryButton release];
	[imageView release];
	[lockedBadgeView release];
	[newBadgeView release];
	[preview release];
	//[activityView release];
	
	//if (cacheAsset)
//		cacheAsset.delegate = nil;
	
    [super dealloc];
}


@end
