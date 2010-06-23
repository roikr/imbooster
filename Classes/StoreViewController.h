//
//  StoreViewController.h
//  IMBooster
//
//  Created by Roee Kremer on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface StoreViewController : UIViewController<SKProductsRequestDelegate> {
	UIActivityIndicatorView * activityView;
	UILabel * label;
	UITextView *textView;
	UILabel *storeTitle;
	UIScrollView *scrollView;
	
	NSString *productIdentifier;
	NSMutableArray *content;
	
	UIBarButtonItem *buyButton;
	UIBarButtonItem *cancelButton;
	
	SKProduct *product;
	
	BOOL bUpgrade;
	
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *storeTitle;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSString *productIdentifier;
@property (nonatomic, retain) NSMutableArray *content;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buyButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;

@property (nonatomic, retain) SKProduct *product;

- (id)initWithProductIdentifier:(NSString*)identifier;
- (void)loadContent;
- (void)cancelLoadContent;
- (void)updateContentViews;
- (IBAction)cancel:(id)sender;
- (IBAction)buy:(id)sender;

- (void)purchaseSucceeded;
- (void)purchaseFailed:(NSString*)failure;



@end
