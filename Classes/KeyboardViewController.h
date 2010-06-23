//
//  KeyboardViewController.h
//  IMBooster
//
//  Created by Roee Kremer on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KeyboardViewController : UIViewController {
	int sectionNumber;
	int pageNumber;
	UIImageView *overlay;
	NSMutableArray *keys;
}

@property (nonatomic, retain) UIImageView * overlay;
@property (nonatomic, retain) NSMutableArray *keys;

- (id)initWithSectionNumber:(int) sec withPageNumber:(int)page;
- (void)loadKeys;
- (void)cancelLoadKeys;

@end
