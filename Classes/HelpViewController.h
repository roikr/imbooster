#import <UIKit/UIKit.h>
#import "ZoozzADBannerView.h"


@interface HelpViewController : UIViewController<UIWebViewDelegate,UIAlertViewDelegate,ZoozzADBannerViewDelegate>
{
	UIWebView *webView;
	UIBarButtonItem *backItem;
	
	UIBarButtonItem *restoreItem;
	ZoozzADBannerView *adView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *restoreItem;
@property (nonatomic, retain) IBOutlet ZoozzADBannerView *adView;

- (IBAction)back:(id)sender;
- (IBAction)restore:(id)sender;
- (void)showBanner:(ZoozzADBannerView *)bannerView;
- (void)hideBanner:(ZoozzADBannerView *)bannerView;

@end
