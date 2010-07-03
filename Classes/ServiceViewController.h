//
//  ServiceViewController.h
//  IMBooster
//
//  Created by Roee Kremer on 10/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ServiceViewController : UIViewController<UIScrollViewDelegate> {
	UIScrollView *scrollView;
	UIPageControl *pageControl;
	
	NSMutableArray *viewControllers;
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
	
	int sectionNumber;
	int numberOfPages;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;

@property (nonatomic, retain) NSMutableArray *viewControllers;
@property NSUInteger currentCategory;

- (id)initWithSectionNumber:(int)sec;
- (IBAction)changePage:(id)sender;
- (void)clear;
//- (void)cancelLoadOfCategory:(NSUInteger)cat;

@end
