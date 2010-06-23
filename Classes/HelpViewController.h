#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController<UIWebViewDelegate,UIAlertViewDelegate>
{
	UIWebView *webView;
	UIBarButtonItem *backItem;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backItem;

- (IBAction)back:(id)sender;

@end
