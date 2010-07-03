#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface HelpViewController : UIViewController<UIWebViewDelegate,UIAlertViewDelegate>
{
	UIWebView *webView;
	UIBarButtonItem *backItem;
	
	UIBarButtonItem *restoreItem;
	ADBannerView *adView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *restoreItem;
@property (nonatomic, retain) IBOutlet ADBannerView *adView;

- (IBAction)back:(id)sender;
- (IBAction)restore:(id)sender;

@end
