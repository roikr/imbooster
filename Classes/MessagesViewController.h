//
//  MessagesViewController.h
//  Messages
//
//  Created by Roee Kremer on 10/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
//#import <MessageUI/MFMessageComposeViewController.h>
#import "ZoozzADBannerView.h"


//#import "ZoozzConnection.h"

@class CatalogViewController,Asset;

@interface MessagesViewController : UIViewController<UINavigationBarDelegate,UITextViewDelegate,MFMailComposeViewControllerDelegate,UIScrollViewDelegate,UIActionSheetDelegate,ZoozzADBannerViewDelegate> { //MFMessageComposeViewControllerDelegate
	
	
	
	NSMutableArray *viewControllers;
	UIView * keyboardView;
	
	NSCharacterSet *emoji;
	
	UIButton *keybToEmosButton;;
	
	NSUInteger currentSection;
	
	UIView * toolbar;
	
	NSRange selection;
	
	BOOL deleteMode;
	
	ZoozzADBannerView *adView;
	
	UITextView *messagesView;
	UIWebView  *webView;
	
	UIView *containerView;
	
}


@property (nonatomic,retain )IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UITextView * messagesView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;


@property (nonatomic, retain) IBOutlet UIView * keyboardView;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic,retain) IBOutlet UIButton *keybToEmosButton;
@property (nonatomic, retain) NSCharacterSet *emoji;
@property NSUInteger currentSection;
@property (nonatomic, retain) IBOutlet UIView * toolbar;
@property (nonatomic, retain) IBOutlet ZoozzADBannerView *adView;

- (IBAction)keybToEmos:(id)sender;
- (IBAction)action:(id)sender;
- (IBAction)gotoGallery:(id)sender;
- (void)addAsset:(Asset*)asset;
- (void)selectSection:(id)sender;
- (void)loadAssetInMessage;
- (void)sendEMail;
//- (void)sendText;
- (void)addEmoticon:(id)sender;
- (void)clearView;

- (void)removeBanner;
- (void)showBanner:(ZoozzADBannerView *)bannerView;
- (void)hideBanner:(ZoozzADBannerView *)bannerView;

@end

