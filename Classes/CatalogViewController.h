//
//  CatalogViewController.h
//  IMBooster
//
//  Created by Roee Kremer on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Asset;

@interface CatalogViewController : UIViewController {
		
	NSMutableArray *viewControllers;
	
	UIBarButtonItem *backItem;
	UIBarButtonItem *actionItem;
	UIButton * actionButton;
	
	Asset * selectedAsset;
	UIButton * selectedButton;
	
	NSUInteger currentSection;
	
	UIView *catalogView;
	UIView *toolbar;
}


@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) IBOutlet UIButton *actionButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * backItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * actionItem;
@property NSUInteger currentSection;
@property (nonatomic, retain) IBOutlet UIView * catalogView;
@property (nonatomic, retain) IBOutlet UIView * toolbar;

- (IBAction)action:(id)sender;
- (IBAction)gotoKeyboard:(id)sender;
-(void) selectAsset:(Asset *) asset withButton:(UIButton *)button;
-(void) deselectAsset;
//- (void)loadCurrentSectionViewAssets;
- (void)selectSection:(id)sender;
- (void)clearView;
- (void)updateWinksViews;

@end
