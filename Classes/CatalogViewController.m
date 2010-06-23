//
//  CatalogViewController.m
//  IMBooster
//
//  Created by Roee Kremer on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CatalogViewController.h"
#import "ServiceViewController.h"
#import "GalleryViewController.h"
#import "MessagesViewController.h"
#import "IminentAppDelegate.h"
#import "Asset.h"
#import "LocalStorage.h"
#import "ZoozzEvent.h"


@interface CatalogViewController (PrivateMethods) 
- (void)cancelLoadOfSection:(NSUInteger)sec;
@end

@implementation CatalogViewController

@synthesize viewControllers;
@synthesize currentSection;
@synthesize actionButton;
@synthesize backItem;
@synthesize actionItem;
@synthesize catalogView;
@synthesize toolbar;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < [appDelegate.localStorage.sections count]; i++) {
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
	UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 372)];
	self.view = view;
	[view release];
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];	
	
	self.navigationItem.leftBarButtonItem = backItem;
	self.navigationItem.rightBarButtonItem = actionItem;
	
	for (int i=0; i<7; i++) {
		UIButton * button = (UIButton*)[self.toolbar viewWithTag:i];
		[button addTarget:self action:@selector(selectSection:) forControlEvents:UIControlEventTouchDown];
	}
	UIButton * button = (UIButton*)[self.toolbar viewWithTag:7];
	[button addTarget:appDelegate action:@selector(bringHelp) forControlEvents:UIControlEventTouchDown];
		 
	self.currentSection = self.currentSection; // need for reload subviews after unload - memory warning
	// so on first gotoGallery will be called twice
}
		 
- (void)selectSection:(id)sender {
	UIButton * button = (UIButton *)sender;
	self.currentSection = button.tag;
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	ServiceViewController *controller = [viewControllers objectAtIndex:currentSection];
	[appDelegate addEvent:[ZoozzEvent navigateView:ZoozzViewGallery toSection:currentSection subSection:controller.currentCategory]];
}

 
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
	self.backItem = nil;
	self.actionItem = nil;
	self.actionButton = nil;
	self.catalogView = nil;
	self.toolbar = nil;
}

- (void)dealloc {
	[viewControllers release];
	[backItem release];
	[actionItem release];
	[selectedAsset release];
	[selectedButton	release];
	[catalogView release];
	[toolbar release];
	[super dealloc];
}

- (void)cancelLoadOfSection:(NSUInteger)sec {
	ServiceViewController *controller = [viewControllers objectAtIndex:sec];
    if ((NSNull *)controller != [NSNull null]) {
		[controller cancelLoadOfCategory:controller.currentCategory];
	}
}

- (void)setCurrentSection:(NSUInteger)sec {
	
	[self cancelLoadOfSection:currentSection];
		
	currentSection = sec;	
	
	[self deselectAsset];
	
	for (int i=0; i<7; i++) {
		UIButton * button = (UIButton*)[self.toolbar viewWithTag:i];
		button.selected = i==currentSection;
	}
	
	if (currentSection==6) 
		self.title = @"Winks";
	else
		self.title = @"Emoticons";
		
	
	// replace the placeholder if necessary
    ServiceViewController *controller = [viewControllers objectAtIndex:currentSection];
    if ((NSNull *)controller == [NSNull null]) {
		
        controller = [[ServiceViewController alloc] initWithSectionNumber:currentSection];
        [viewControllers replaceObjectAtIndex:currentSection withObject:controller];
        [controller release];
    }
	if ([self.catalogView.subviews count])
		[[self.catalogView.subviews objectAtIndex:0] removeFromSuperview];
	[self.catalogView addSubview:controller.view];
	//[self loadCurrentSectionViewAssets];
	
	controller.currentCategory = controller.currentCategory;
}

- (void)updateWinksViews {
	
	if (currentSection == 6) {
		ServiceViewController *controller = [viewControllers objectAtIndex:currentSection];
		if ((NSNull *)controller != [NSNull null]) {
			controller.currentCategory = controller.currentCategory;
		}
		
		
	}
	
}


- (void)clearView {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (self.viewControllers != nil) {
		for (unsigned i = 0; i < [appDelegate.localStorage.sections count]; i++) {
			ServiceViewController *controller = [viewControllers objectAtIndex:i];
			if ((NSNull *)controller != [NSNull null]) {
				[controller retain];
				[viewControllers replaceObjectAtIndex:i withObject:[NSNull null]];
				[controller.view removeFromSuperview];
				[controller release];
			}
			
		}
		
	}
}

- (IBAction)action:(id)sender {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate addEvent:[ZoozzEvent useInGalleryViewWithAsset:selectedAsset]];
	
	if (selectedAsset.bLocked) {
		
		[appDelegate purchaseWithProduct:selectedAsset.productIdentifier];
	
	} else {
		[self cancelLoadOfSection:currentSection];
		[self.navigationController popToRootViewControllerAnimated:YES];
		
		appDelegate.messages.currentSection = currentSection;
		[appDelegate.messages addAsset:selectedAsset];
	}
	
	
}

-(void) selectAsset:(Asset *) asset withButton:(UIButton *)button{
	
	selectedAsset = asset;
	selectedButton = button;
	selectedButton.selected = YES;
	actionButton.enabled = YES;
	//button.selected = YES;
	//selectedAsset.galleryButton.selected = YES;
}

-(void) deselectAsset {
	
	if (selectedButton) {
		selectedButton.selected = NO;
		selectedButton = nil;
	}
	
	if (selectedAsset) {
		selectedAsset = nil;
	}
	
	actionButton.enabled = NO;
}

-(IBAction)gotoKeyboard:(id)sender {
	[self cancelLoadOfSection:currentSection];
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate gotoKeyboard];
	
}

/*
- (void)loadCurrentSectionViewAssets {
	ServiceViewController *controller = [viewControllers objectAtIndex:currentSection];
    if ((NSNull *)controller != [NSNull null]) {
		[controller loadCurrentGalleryViewAssets];
	}
}
 */

@end
