//
//  KeyboardViewController.m
//  IMBooster
//
//  Created by Roee Kremer on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KeyboardViewController.h"
#import "MessagesViewController.h"
#import "Asset.h"
#import "IminentAppDelegate.h"
#import "LocalStorage.h"
#import "Section.h"
#import "KeyView.h"

@implementation KeyboardViewController

@synthesize overlay;
@synthesize keys;

- (id)initWithSectionNumber:(int) sec withPageNumber:(int)page {
    if (self = [super init]) {
		sectionNumber = sec;
        pageNumber = page;
		self.overlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard-overlay.png"]];
		
	}
		
    return self;
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 156)];
	self.view = aView;
	[aView release];
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	Section * sec = [appDelegate.localStorage.sections objectAtIndex:sectionNumber];
	self.keys = [NSMutableArray array];
	for(int i=0;i<18;i++) {
		if (pageNumber*18+i>=[sec.assets count]) 
			break;
		
		Asset *asset = [sec.assets objectAtIndex:pageNumber*18+i];
		KeyView *key = [[KeyView alloc] initWithAsset:asset];
		key.frame = CGRectMake(2+i%6*53,(i%18)/6*53, 50, 50);
		[self.view addSubview:key];
		[keys addObject:key];
		[key release];
	}
	
	[self.view addSubview:overlay];	
	
	//appDelegate.messages.currentPage = pageNumber;
}

/*
- (void)loadKeys {
	for (KeyView *key in keys) {
		[key loadResources];
	}
}

- (void)cancelLoadKeys {
	for (KeyView *key in keys) {
		[key cancelLoad];
	}
}

*/



/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	ZoozzLog(@"KeyboardViewController - viewDidUnload - section: %u, page: %u",sectionNumber,pageNumber );
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	
	[keys removeAllObjects];
	self.keys = nil;
	/*
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	 
	Section * sec = [appDelegate.localStorage.sections objectAtIndex:sectionNumber];
	for(int i=0;i<18;i++) {
		if (pageNumber*18+i>=[sec.assets count]) 
			break;
		
		Asset * asset = (Asset*)[sec.assets objectAtIndex:pageNumber*18+i];
		//asset.keyboardButton = nil;
	}
	 */
	 
}


- (void)dealloc {
	//ZoozzLog(@"KeyboardViewController - dealloc - section: %u, page: %u",sectionNumber,pageNumber );
	[keys release];
	[overlay release];
    [super dealloc];
}


@end
