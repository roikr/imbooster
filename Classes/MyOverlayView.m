#import "MyOverlayView.h"
#import "IminentAppDelegate.h"
#import "VideoPlayer.h"

@implementation MyOverlayView


- (void)dealloc {
	[super dealloc];
}

// Handle any touches to the overlay view
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    if (touch.phase == UITouchPhaseBegan)
    {
		IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.videoPlayer stopMovie];

    }    
}


@end
