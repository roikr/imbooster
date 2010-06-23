//
//  SubCategoryViewController.h
//  IMBooster
//
//  Created by Roee Kremer on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SubCategoryViewController : UIViewController<UIScrollViewDelegate> {
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIPageControl *pageControl;
	
	NSMutableArray *viewControllers;
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
	
	int sectionNumber;
	int numberOfPages;
	
	NSMutableArray * assetsList;
	

}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;

@property (nonatomic, retain) NSMutableArray *viewControllers;
@property NSUInteger currentPage;

- (id)initWithSectionNumber:(int)sec;


- (IBAction)changePage:(id)sender;

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
//- (void)populateAndViewWithPage:(int)page;
- (void)clear;
- (void)cancelLoadOfPage:(NSUInteger)page;

@end
