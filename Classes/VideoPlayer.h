//
//  VideoPlayer.h
//  IMBooster
//
//  Created by Roee Kremer on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPMoviePlayerController;

@interface VideoPlayer : NSObject {
	MPMoviePlayerController *moviePlayer;
}

@property (readwrite, retain) MPMoviePlayerController *moviePlayer;

- (void)initAndPlayMovie:(NSURL *)movieURL;
- (void)stopMovie;
- (void)playIMBooster;

@end
