//
//  MessagesViewController.h
//  Messages
//
//  Created by Roee Kremer on 10/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "ZoozzConnection.h"

@class CatalogViewController,Asset;

@interface MessagesViewController : UIViewController<UINavigationBarDelegate,UITextViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIScrollViewDelegate,UIActionSheetDelegate> {
	
	UITextView *messagesView;
	UIView * keyboardView;
	
	NSMutableArray *viewControllers;
	
	UIWebView  *webView;
	NSCharacterSet *emoji;
	
	UIButton *keybToEmosButton;;
	
	NSUInteger currentSection;
	
	UIView * toolbar;
	
	NSRange selection;
	
	BOOL deleteMode;
	
	
	
}

@property (nonatomic, retain) IBOutlet UITextView * messagesView;
@property (nonatomic, retain) IBOutlet UIView * keyboardView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic,retain) IBOutlet UIButton *keybToEmosButton;
@property (nonatomic, retain) NSCharacterSet *emoji;
@property NSUInteger currentSection;
@property (nonatomic, retain) IBOutlet UIView * toolbar;

- (IBAction)keybToEmos:(id)sender;
- (IBAction)action:(id)sender;
- (IBAction)gotoGallery:(id)sender;
- (void)addAsset:(Asset*)asset;
- (void)selectSection:(id)sender;
- (void)loadAssetInMessage;
- (void)sendEMail;
- (void)sendText;
- (void)addEmoticon:(id)sender;
- (void)clearView;
- (NSString *) getMessage;

@end

