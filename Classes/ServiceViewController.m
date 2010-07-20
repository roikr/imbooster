//
//  ServiceViewController.m
//  IMBooster
//
//  Created by Roee Kremer on 10/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceViewController.h"
#import "GalleryViewController.h"
#import "IminentAppDelegate.h"
#import "LocalStorage.h"
#import "CatalogViewController.h"
#import "Asset.h"
#import "Section.h"
#import "ZoozzEvent.h"

@interface ServiceViewController (PrivateMethods) 
- (void)loadScrollViewWithPage:(int)page;

@end


@implementation ServiceViewController

@synthesize pageControl;
@synthesize scrollView;
@synthesize viewControllers;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithSectionNumber:(int)sec{
    if (self = [super initWithNibName:@"ServiceViewController" bundle:nil]) {
        sectionNumber = sec;
		
		IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		Section * sec = [appDelegate.localStorage.sections objectAtIndex:sectionNumber];
		numberOfPages = [sec.categories count];
		
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < numberOfPages; i++) {
			[controllers addObject:[NSNull null]];
		}
		self.viewControllers = controllers;
		[controllers release];
	}
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad]; 
	
	scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
	scrollView.directionalLockEnabled = YES;
	
	//[self populateAndViewWithPage:0];
	int page = 0;
	
	
	
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numberOfPages, scrollView.frame.size.height);
    
	pageControl.numberOfPages = numberOfPages;
    pageControl.currentPage = page;
	
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
	
	
	//for (uint i=0; i<numberOfPages;i++)
	//	[self loadScrollViewWithPage:i];
	
	[self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	
	

	
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

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	self.scrollView = nil;
	self.pageControl = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark pageControl

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= numberOfPages) return;
	
    // replace the placeholder if necessary
    GalleryViewController *controller = [viewControllers objectAtIndex:page];
	
	
	if ((NSNull *)controller == [NSNull null]) {
		controller = [[GalleryViewController alloc] initWithSectionNumber:sectionNumber withCategoryNumber:page];
		[viewControllers replaceObjectAtIndex:page withObject:controller];
		[controller release];
	}
		
    // add the controller's view to the scroll view
    if (nil == controller.tableView.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;//64;
        controller.tableView.frame = frame;
		//controller.tableView.delegate = self;
		//scrollView.backgroundColor=[UIColor blueColor];
        [scrollView addSubview:controller.tableView];
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
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.catalog deselectAsset];
	
	//[self cancelLoadOfCategory:pageControl.currentPage];
	
    pageControl.currentPage = page;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    
	[self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	
	//[self setTitleWithPage:page];
	
	
	self.currentCategory = page;
	[appDelegate addEvent:[ZoozzEvent navigateView:ZoozzViewGallery toSection:sectionNumber subSection:self.currentCategory]];
	
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
	//[self loadCurrentGalleryViewAssets];
}

- (IBAction)changePage:(id)sender {
    
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.catalog deselectAsset];

	
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
	
	
}
  
/*

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.localStorage.backgroundLoad = NO;
}
*/



- (void)clear {
	numberOfPages = 0;
	self.pageControl.numberOfPages = 0;
	while ([self.viewControllers count]) {
		GalleryViewController * category = [self.viewControllers lastObject];
		if ((NSNull *)category != [NSNull null]) {
			[category.view removeFromSuperview];
		}
		[self.viewControllers removeLastObject];
	}
	
}

- (NSUInteger)currentCategory {
	return pageControl.currentPage;
}

- (void)setCurrentCategory:(NSUInteger)cat {
	
	//GalleryViewController *category = [viewControllers objectAtIndex:cat];
	//IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[category performSelector:@selector(loadAssets) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
	ZoozzLog(@"CatalogViewController - setCurrentCategory: %u (sec: %u)",cat,sectionNumber);
}

/*
- (void)cancelLoadOfCategory:(NSUInteger)cat {
	GalleryViewController *category = [viewControllers objectAtIndex:cat];
	if ((NSNull *)category != [NSNull null]) {
		//IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		//[category performSelector:@selector(cancelLoadAssets) onThread:appDelegate.secondaryThread withObject:nil waitUntilDone:NO];
	}
	ZoozzLog(@"ServiceViewController - cancelLoadOfPage: %u (sec: %u)",cat,sectionNumber);
	
	
}

*/


@end
