//
//  ContentView.m
//  IMBooster
//
//  Created by Roee Kremer on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContentView.h"
#import "IminentAppDelegate.h"
#import "VideoPlayer.h"
#import "LocalStorage.h"
#import "Asset.h"
#import "ZoozzEvent.h"

@implementation ContentView

@synthesize contentButton;
@synthesize preview;
@synthesize activityView;
@synthesize asset;
@synthesize cacheAsset;


- (id)initWithAsset:(Asset*)theAsset {
	if (self = [super init]) {
		
		self.asset = theAsset;
		
		self.contentButton = [UIButton buttonWithType:UIButtonTypeCustom];
		contentButton.frame = CGRectMake(0,0, 50, 50);
		contentButton.tag = asset.charCode;
		contentButton.backgroundColor=[UIColor whiteColor];
		contentButton.clipsToBounds = YES;
		[contentButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:contentButton];
		bThumbAdded = NO;
		
		IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
		[self performSelector:@selector(updateThumbView) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
		// I don't want to call subsequent pages because I don't see them, so no need to load from server - in the gallery it is different
		//[self performSelector:@selector(loadResources) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
				
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
	
	[appDelegate addEvent:[ZoozzEvent storePreviewWithAsset:self.asset]];
	
	
	switch (asset.contentType) {
		case CacheResourceWink: {
			// double check because I check before enabling the button
			if (asset.bContentCached) {
				[appDelegate.videoPlayer initAndPlayMovie:[NSURL fileURLWithPath:[CacheResource cacheResourcePathWithResourceType:asset.contentType WithIdentifier:asset.identifier]]];
			}
		} break;
		case CacheResourceEmoticon: {
			if (asset.bContentCached) {
				button.userInteractionEnabled = NO;
				if (!preview) {
					UIWebView *webView = [[UIWebView alloc] initWithFrame:button.frame];
					webView.opaque = NO;
					webView.backgroundColor = [UIColor clearColor];
					self.preview = webView;
					[webView release];
					[self addSubview:preview];
				}
				
				
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString * dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"]; 
				
				
				[preview loadHTMLString:[@"<html><body style='margin-left:0px;margin-top:0px;background-color:white'><img style='width:50px;height:50px;background-color:transparent' src='content/" stringByAppendingString:
										 [asset.identifier stringByAppendingString:@"'/></body></html>"]] baseURL:[NSURL fileURLWithPath:dataPath isDirectory:YES]];
				
				contentButton.hidden = YES;
				
				
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
	
	contentButton.hidden = NO;
	preview.hidden = YES;	
	
}

- (void)addThumb {
	[contentButton setImage:asset.thumbImage forState:UIControlStateNormal];
}



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


- (void)updateThumbView {
	
	// this function can be called several times so I want to check I didn't add the thumb yet
	if (asset.bThumbCached && !bThumbAdded)  {
		if (asset.thumbImage==nil) {
			
			NSData * data = [NSData dataWithContentsOfFile:[CacheResource cacheResourcePathWithResourceType:CacheResourceThumb WithIdentifier:asset.identifier]];
			[asset performSelectorOnMainThread:@selector(setThumbImage:) withObject:[UIImage imageWithData:data] waitUntilDone:YES];
		}
		
		[self performSelectorOnMainThread:@selector(addThumb) withObject:nil waitUntilDone:NO];
		bThumbAdded = YES;
	}
	
	
	
	if (asset.bThumbCached && asset.bContentCached)  {
		if (activityView != nil) {
			//[self stopActivity];
			[self performSelectorOnMainThread:@selector(stopActivity) withObject:nil waitUntilDone:NO];
		}
		
	} 
	
	
}


- (void)startActivity {
	self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	//activityView.frame = CGRectMake(0,0, 50, 50);
	CGRect frame = activityView.frame;
	frame.origin.x = 25 - activityView.bounds.size.width/2;
	frame.origin.y = 25 - activityView.bounds.size.height/2;
	activityView.frame = frame;
	[activityView startAnimating];
	[self addSubview:activityView];
	contentButton.userInteractionEnabled = NO;
}

- (void)stopActivity {
	[activityView removeFromSuperview];
	[activityView stopAnimating];
	[activityView release];
	self.activityView = nil;
	contentButton.userInteractionEnabled = YES;
}






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
		/*
		 if ([self activity]) {
		 [self performSelectorOnMainThread:@selector(stopActivity) withObject:nil waitUntilDone:NO];
		 }
		 */
	}
}

- (void)dealloc {
	// if thumb or content didn't release before, let them finish loading but nil their delegate
	// do I need to release it here or on the thread ?
	
	[contentButton release];
	[preview release];
	[activityView release];
	
	if (cacheAsset)
		cacheAsset.delegate = nil;
	
    [super dealloc];
}


@end
