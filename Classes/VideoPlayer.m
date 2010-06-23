//
//  VideoPlayer.m
//  IMBooster
//
//  Created by Roee Kremer on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "IminentAppDelegate.h"
#import "MyOverlayView.h"



@implementation VideoPlayer

@synthesize moviePlayer;


-(id) init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(moviePreloadDidFinish:) 
													 name:MPMoviePlayerContentPreloadDidFinishNotification 
												   object:nil];
		
		// Register to receive a notification when the movie has finished playing. 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(moviePlayBackDidFinish:) 
													 name:MPMoviePlayerPlaybackDidFinishNotification 
												   object:nil];
		
		// Register to receive a notification when the movie scaling mode has changed. 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(movieScalingModeDidChange:) 
													 name:MPMoviePlayerScalingModeDidChangeNotification 
												   object:nil];
	}
	
	return self;
}

-(void)initAndPlayMovie:(NSURL *)movieURL
{
	// Initialize a movie player object with the specified URL
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
	if (mp)
	{
		// save the movie player object
		self.moviePlayer = mp;
		[mp release];
		self.moviePlayer.movieControlMode =  MPMovieControlModeHidden;
		self.moviePlayer.backgroundColor = [UIColor blackColor];
		// Apply the user specified settings to the movie player object
		//[self setMoviePlayerUserSettings];
		
		// Play the movie!
		[self.moviePlayer play];
		
		NSArray *windows = [[UIApplication sharedApplication] windows];
		if ([windows count] > 1)
		{
			// Locate the movie player window
			UIWindow *moviePlayerWindow = [[UIApplication sharedApplication] keyWindow];
			// Add our overlay view to the movie player's subviews so it is 
			// displayed above it.
			IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
			
			[moviePlayerWindow addSubview:appDelegate.overlayView];
		}
		 
	}
}

-(void)stopMovie {
	[self.moviePlayer stop];
}

//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	/* 
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */
	
	
		
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
	
	MPMoviePlayerController* moviePlayerObj=[notification object];
	
	moviePlayerObj = nil;
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[appDelegate.overlayView removeFromSuperview];

}

//  Notification called when the movie scaling mode has changed.
- (void) movieScalingModeDidChange:(NSNotification*)notification
{
    /* 
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */
}


- (void)playIMBooster {
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle) 
	{
		NSString *moviePath = [bundle pathForResource:@"IMBooster" ofType:@"m4v"];
		if (moviePath)
		{
			[self initAndPlayMovie:[NSURL fileURLWithPath:moviePath]];
		}
	}
}
	
 





@end
