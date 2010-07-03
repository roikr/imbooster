//
//  SubCategoryViewController.m
//  IMBooster
//
//  Created by Roee Kremer on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SubCategoryViewController.h"
#import "KeyboardViewController.h"
#import "Asset.h"
#import "IminentAppDelegate.h"
#import "LocalStorage.h"
#import "Section.h"
#import "MessagesViewController.h"
#import "ZoozzEvent.h"



@interface SubCategoryViewController (PrivateMethods) 
- (void)loadScrollViewWithPage:(int)page;

@end


@implementation SubCategoryViewController

@synthesize viewControllers;
@synthesize scrollView;
@synthesize pageControl;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Load the view nib and initialize the subCategoryNumber ivar.
- (id)initWithSectionNumber:(int)sec {
    if (self = [super initWithNibName:@"SubCategoryViewController" bundle:nil]) {
        sectionNumber=sec;
		
		IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		Section * sec = [appDelegate.localStorage.sections objectAtIndex:sectionNumber];
		numberOfPages = ([sec.assets count]-1) / 18+1;
		
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < numberOfPages; i++) {
			[controllers addObject:[NSNull null]];
		}
		self.viewControllers = controllers;
		[controllers release];
		
		
    }
	
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
	
	int page = 0;
	
	//[self populateAndViewWithPage:0];
	
		
	
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numberOfPages, scrollView.frame.size.height);
    pageControl.numberOfPages = numberOfPages;
    pageControl.currentPage = page;
	
	[self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];	
	
	//IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	//appDelegate.messages.currentPage = page;
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.scrollView = nil;
	self.pageControl = nil;
}

/*
- (void)populateAndViewWithPage:(int)page {
	
	
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




- (void)dealloc {
	[scrollView release];
	[pageControl release];
	
	[viewControllers release];
    [super dealloc];
}

#pragma mark pageControl

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= numberOfPages) return;
	
	// replace the placeholder if necessary
    KeyboardViewController *controller = [viewControllers objectAtIndex:page];
	
	if ((NSNull *)controller == [NSNull null]) {
		controller = [[KeyboardViewController alloc] initWithSectionNumber:sectionNumber withPageNumber:page];
		[viewControllers replaceObjectAtIndex:page withObject:controller];
		[controller release];
	}
	
	// add the controller's view to the scroll view
    if (nil == controller.view.superview) {
		CGRect frame = scrollView.frame;
		frame.origin.x = frame.size.width * page;
		frame.origin.y = 0;//64;
		controller.view.frame = frame;
		[scrollView addSubview:controller.view];
	}
}
	

   		

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	
	if (pageControl.currentPage == page || page < 0 || page >= numberOfPages) 
		return;
    
	//[self cancelLoadOfPage:pageControl.currentPage];
	
    pageControl.currentPage = page;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	//[self setTitleWithPage:page];
	
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
	
	
	self.currentPage = page;
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate addEvent:[ZoozzEvent navigateView:ZoozzViewKeyboard toSection:sectionNumber subSection:self.currentPage]];
						   
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
	
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
	
	//IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	//appDelegate.messages.currentPage = page;

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.localStorage.backgroundLoad = NO;
}

- (void)clear {
	numberOfPages = 0;
	self.pageControl.numberOfPages = 0;
	while ([self.viewControllers count]) {
		KeyboardViewController * keyboard = [self.viewControllers lastObject];
		if ((NSNull *)keyboard != [NSNull null]) {
			[keyboard.view removeFromSuperview];
		}
		[self.viewControllers removeLastObject];
	}
	
}


- (NSUInteger)currentPage {
	return pageControl.currentPage;
}

- (void)setCurrentPage:(NSUInteger)page {
	
	//KeyboardViewController *keyboard = [viewControllers objectAtIndex:page];
	//IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[keyboard performSelector:@selector(loadKeys) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
	ZoozzLog(@"SubCategoryViewController - setCurrentPage: %u (sec: %u)",page,sectionNumber);
}

/*
- (void)cancelLoadOfPage:(NSUInteger)page {
	KeyboardViewController *keyboard = [viewControllers objectAtIndex:page];
	if ((NSNull *)keyboard != [NSNull null]) {
		//IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		//[keyboard performSelector:@selector(cancelLoadKeys) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
	}
	ZoozzLog(@"SubCategoryViewController - cancelLoadOfPage: %u (sec: %u)",page,sectionNumber);
	
	
}
 */

@end
