#import "HelpViewController.h"
#import "IminentAppDelegate.h"
#import "VideoPlayer.h"

#pragma mark -

@interface HelpViewController (PrivateMethods) 
@end

@implementation HelpViewController

@synthesize webView;
@synthesize backItem;
@synthesize restoreItem;
@synthesize adView;


- (void)dealloc
{
	[webView release];
	[backItem release];
	[restoreItem release];
	[adView release];
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	
	//self.navigationItem.leftBarButtonItem = backItem;
	//self.navigationItem.rightBarButtonItem = movieItem;
	//self.title = NSLocalizedString(@"HelpViewTitle", @"Title of the help view page");
	
	
	//NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pages/imbooster/help?l=%@",kZoozzURL,[[NSLocale currentLocale] localeIdentifier]]];
	//NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/help/%@?l=%@",kZoozzURL,kAppVersionID,[[NSLocale preferredLanguages] objectAtIndex:0]]];
	NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/help.html",kZoozzURL]];
	
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	
	self.adView = [[ZoozzADBannerView alloc] initWithDelegate:self];
	
}


// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	
	self.backItem= nil;	
	self.webView = nil;
	self.restoreItem = nil;
	self.adView = nil;
}

- (IBAction)back:(id)sender {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)restore:(id)sender {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate restoreTransactions];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		if ([[[request URL] host] isEqualToString:@"restore"]) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RestoreTitle",@"Restore Purchases") message:NSLocalizedString(@"RestoreMessage",@"your purchases are being restored") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		} else {
			[[UIApplication sharedApplication] openURL:request.URL];
		}
        return NO;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	//IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate restoreTransactions];
}

- (void)showBanner:(ZoozzADBannerView *)bannerView {
	if (bannerView!=nil) {
		[self.view addSubview:bannerView];
	}
	
	webView.frame = CGRectMake(0, 50, 320, 366);
	
}

- (void)hideBanner:(ZoozzADBannerView *)bannerView {
	if (bannerView!=nil) {
		[bannerView removeFromSuperview]; 
	}
	webView.frame = CGRectMake(0, 0, 320, 416);
}



@end

