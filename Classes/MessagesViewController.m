//
//  MessagesViewController.m
//  Messages
//
//  Created by Roee Kremer on 10/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MessagesViewController.h"
#import "Asset.h"
#import "IminentAppDelegate.h"
#import "CatalogViewController.h"
#import "SubCategoryViewController.h"
#import "KeyboardViewController.h"
#import "KeyView.h"
#import "LocalStorage.h"

#import "Utilities.h"
#import "ZoozzEvent.h"

#import <MobileCoreServices/UTCoreTypes.h> // for kUTTypeGIF and kUTTypePNG

@interface MessagesViewController (PrivateMethods)
//- (void)cancelLoadOfSection:(NSUInteger)sec;
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (void) updateWebViewWithString:(NSString*)str;
//- (NSString *)stringToWeb:(NSString *)str;
- (NSString*)fix:(NSString*)str;

- (NSString *) getMessage;
//- (NSString *) pasteMessageToPasteboard;


@end


@implementation MessagesViewController

@synthesize containerView;
@synthesize messagesView;
@synthesize keyboardView;
@synthesize webView;
@synthesize viewControllers;

@synthesize emoji;

@synthesize keybToEmosButton;
@synthesize currentSection;
@synthesize toolbar;
@synthesize adView;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
       
    }
    return self;
}
*/


/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	messagesView.font=[messagesView.font fontWithSize:25];
	
	if (self.viewControllers == nil) {
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < [appDelegate.localStorage.sections count]; i++) {
			[controllers addObject:[NSNull null]];
		}
		self.viewControllers = controllers;
		[controllers release];
	}
	
	
	
	
	//webView = [[UIWebView alloc] initWithFrame:messagesView.frame];
	//webView.opaque = NO;
	webView.backgroundColor = [UIColor clearColor];
	//webView.userInteractionEnabled = NO;
	//[messagesView.superview addSubview:webView];
	//[messagesView.superview bringSubviewToFront:webView];
	if (emoji==nil) 
		self.emoji = [NSCharacterSet characterSetWithRange:NSMakeRange(0xE900, 0xEFFF)];
	
	
	
	if (appDelegate.localStorage.message == nil || ![appDelegate.localStorage.message length]) {
		self.messagesView.text=  @"Tap here to start typing." ;
		selection = NSMakeRange(0, 0);
		[webView loadHTMLString:@"<html><body style='background-color: transparent'></body></html>" baseURL:nil];		
	} else {
		self.messagesView.text= appDelegate.localStorage.message ;
		selection = NSMakeRange(0, [appDelegate.localStorage.message length]);
		self.messagesView.textColor = [UIColor blackColor];
		[self loadAssetInMessage];
		[self updateWebViewWithString:messagesView.text];
	}

	
	for (int i=0; i<7; i++) {
		UIButton * button = (UIButton*)[self.toolbar viewWithTag:i];
		[button addTarget:self action:@selector(selectSection:) forControlEvents:UIControlEventTouchDown];
	}
	UIButton * button = (UIButton*)[self.toolbar viewWithTag:7];
	[button addTarget:appDelegate action:@selector(bringHelp) forControlEvents:UIControlEventTouchDown];
	//[button addTarget:self action:@selector(clearView) forControlEvents:UIControlEventTouchDown];
	
	
	//self.messagesView.textColor = [UIColor lightGrayColor];
	
	
	self.currentSection = self.currentSection; // // need for reload current subviews after unload - for memory warning, currentSection will call setCurrentPage;
	
	if (![appDelegate checkPurchases]) {
		self.adView = [[ZoozzADBannerView alloc] initWithDelegate:self];
		[self.view addSubview:adView.zoozzAdView];	
		
	}
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	
	
	self.messagesView = nil;
	self.keyboardView = nil;
	self.webView = nil;
	self.keybToEmosButton = nil;
	self.toolbar = nil;
	self.containerView = nil;
	self.adView = nil;
	
	
}


- (void)dealloc {
	[viewControllers release];
	[messagesView release];
	[keyboardView release];
	[adView release];
	[webView release];
	[emoji release];
	[keybToEmosButton release];
	[toolbar release];
	[containerView release];
	[super dealloc];
}


- (void)removeBanner {
	
	if (adView!=nil) {
		[self hideBanner:adView];
		[adView.zoozzAdView removeFromSuperview]; 
		self.adView = nil;
	}
}

- (void)showBanner:(ZoozzADBannerView *)bannerView {
	
	containerView.frame = CGRectMake(0, 50, 320, 200);
	
}

- (void)hideBanner:(ZoozzADBannerView *)bannerView {
	
	containerView.frame = CGRectMake(0, 0, 320, 200);
}


- (void)selectSection:(id)sender {
	UIButton * button = (UIButton *)sender;
	self.currentSection = button.tag;
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	SubCategoryViewController *controller = [viewControllers objectAtIndex:currentSection];
	[appDelegate addEvent:[ZoozzEvent navigateView:ZoozzViewKeyboard toSection:currentSection subSection:controller.currentPage]];
						  
	
}

/*
- (void)cancelLoadOfSection:(NSUInteger)sec {
	SubCategoryViewController *controller = [viewControllers objectAtIndex:sec];
    if ((NSNull *)controller != [NSNull null]) {
		[controller cancelLoadOfPage:controller.currentPage];
	}
}	
 */

- (void)setCurrentSection:(NSUInteger)sec {
	//[self cancelLoadOfSection:currentSection];
	    
	currentSection = sec;
	
	for (int i=0; i<7; i++) {
		UIButton * button = (UIButton*)[self.toolbar viewWithTag:i];
		button.selected = i==currentSection;
	}
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.localStorage.backgroundLoad = NO;
	
    
    // replace the placeholder if necessary
	
    SubCategoryViewController *controller = [viewControllers objectAtIndex:currentSection];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[SubCategoryViewController alloc] initWithSectionNumber:currentSection];
		[viewControllers replaceObjectAtIndex:currentSection withObject:controller];
        [controller release];
    }
	
	if ([self.keyboardView.subviews count])
		[[self.keyboardView.subviews objectAtIndex:0] removeFromSuperview];
	[self.keyboardView addSubview:controller.view];
	
	controller.currentPage = controller.currentPage; // calling the setter
	
	
}



- (void)clearView {
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (self.viewControllers != nil) {
		for (unsigned i = 0; i < [appDelegate.localStorage.sections count]; i++) {
			SubCategoryViewController *controller = [viewControllers objectAtIndex:i];
			if ((NSNull *)controller != [NSNull null]) {
				[controller retain];
				[viewControllers replaceObjectAtIndex:i withObject:[NSNull null]];
				[controller.view removeFromSuperview];
				[controller release];
			}
			
		}
		
	}
}


- (IBAction)keybToEmos:(id)sender
{
	//enterEditing = NO;
	if (keybToEmosButton.selected) { 
		[messagesView resignFirstResponder];
		self.keybToEmosButton.selected = NO;
	} else {
		[messagesView becomeFirstResponder];
		self.keybToEmosButton.selected = YES;
		
	}

	//self.navigationItem.rightBarButtonItem = emosToKeybButton;
	
}


- (IBAction)gotoGallery:(id)sender {
	//[self cancelLoadOfSection:currentSection];
	[messagesView resignFirstResponder];
	self.keybToEmosButton.selected = NO;
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate gotoGallery];
	
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)loadAssetInMessage {
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (!appDelegate.localStorage.message) 
		return;
		
	NSArray * arr = [appDelegate.localStorage.message componentsSeparatedByCharactersInSet:emoji];
	int j=0;
	for (int i=0; i<[arr count]-1; i++) {
		j+= [[arr objectAtIndex:i] length];
		[[appDelegate.localStorage.assetsByUnichar objectForKey:[NSString stringWithFormat:@"%u",[appDelegate.localStorage.message characterAtIndex:j]]] copyResources];
	}
}



- (NSString*)fix:(NSString*)str {
	
	str = [str stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%C",0x200B] withString:@""];
	
	NSArray * arr = [str componentsSeparatedByCharactersInSet:emoji];
	NSString * text = @"";
	
	
	if ([arr count] >0 ) {
		int j = 0;
		NSString * temp = [arr objectAtIndex:0];
		text = [text stringByAppendingString:temp];
		j+= [temp length];
		for (int i=1; i<[arr count]; i++) {
			text = [text stringByAppendingString:[NSString stringWithFormat:@"%C%C%C",0x200B,[str characterAtIndex:j],0x200B]];
			j++;
			NSString * temp = [arr objectAtIndex:i];
			
			text = [text stringByAppendingString:temp];
			j+= [temp length];
		}
		
	}	
	
	return text;
}


-(void) updateWebViewWithString:(NSString*)str {
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.localStorage.message = str;
	
	NSString * text = @"<html><head><style type='text/css'>img{width:25;height:25;margin-top:5px;vertical-align:text-top;background-color:white}</style></head><body style='margin-left:7px;width:304px;word-wrap:break-word;color:rgba(0,0,0,0);background-color: transparent;font-family:Helvetica;font-size:25px'>";
	
	str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
	NSArray * arr = [str componentsSeparatedByCharactersInSet:emoji];
	
	if ([arr count] >0 ) {
		int j = 0;
		NSString * temp = [arr objectAtIndex:0];
		text = [text stringByAppendingString:temp];
		j+= [temp length];
		for (int i=1; i<[arr count]; i++) {
			Asset * asset = [appDelegate.localStorage.assetsByUnichar objectForKey:[NSString stringWithFormat:@"%u",[str characterAtIndex:j]]];
			
			
			
			switch (asset.contentType) {
				case CacheResourceEmoticon: 
					text = [text stringByAppendingString:[NSString stringWithFormat:@"<img src='content/%@.gif'/>",asset.identifier]];
					break;
//				case CacheResourceWink: 
//					text = [text stringByAppendingString:[NSString stringWithFormat:@"<a><img src='thumb/%@.gif'/></a>",asset.identifier]];
//					break;
				default:
					break;
			}
			
			
			j++;
			NSString * temp = [arr objectAtIndex:i];
			
			text = [text stringByAppendingString:temp];
			j+= [temp length];
		}
		
	}	
	
	text = [text stringByAppendingString:@"</body></html>"];
	//ZoozzLog(@"%@",text);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	[webView loadHTMLString:text baseURL:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"data"] isDirectory:YES]];	
	
	
}	


-(void)resetView {
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];

	if (appDelegate.localStorage.message && [appDelegate.localStorage.message length]) 
		return;
	
	self.messagesView.text=@"";
	self.messagesView.textColor = [UIColor blackColor];
}


- (void)addEmoticon:(id)sender
{
	//ZoozzLog(@"UIButton was clicked");
	UIButton * button = (UIButton *)sender;
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate playClickSound];
	Asset *asset = [appDelegate.localStorage.assetsByUnichar objectForKey:[NSString stringWithFormat:@"%u",button.tag]];
	
	SubCategoryViewController *controller = [viewControllers objectAtIndex:currentSection];
	[appDelegate addEvent:[ZoozzEvent useInKeyboardViewWithAsset:asset inPage:controller.currentPage]];
	//[appDelegate addEvent:[ZoozzEvent useEventInView:ZoozzKeyboard withAsset:asset.identifier locked:YES]];
	
	if (asset.bLocked) {
		
		//[appDelegate  purchaseWithProduct:asset.productIdentifier];
	} else 
	 [self addAsset:asset];
	//ZoozzLog(@"button's rect: %f %f",button.bounds.size.width,button.bounds.size.height);
}


- (void)addAsset:(Asset*)asset
{
	[self resetView];
	
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (asset.bLocked) {
		//[appDelegate.storeManager purchaseWithAsset:asset];
		return;
	}
	 
	//unichar smile=0xE105;
	NSString * assetString;
	
	/*
	switch (asset.type) {
		
			
		case :
			assetString = [NSString stringWithFormat:@"\n%C\n",asset.charCode];
			break;
		case :
			assetString = [NSString stringWithFormat:@"%C",asset.charCode];
			break;
			
		default:
			break;
	}
	 */
	assetString = [NSString stringWithFormat:@"%C%C%C",0x200B,asset.charCode,0x200B];
	
	messagesView.text = [[[messagesView.text substringToIndex:selection.location] stringByAppendingString:assetString] 
						 stringByAppendingString:[messagesView.text substringFromIndex:selection.location+selection.length]];
	
	appDelegate.localStorage.message = messagesView.text;
	
	/*
	switch (asset.type) {
			
		case :
			selection.location+=3;
			break;
		case :
			selection.location++;
			break;
			
		default:
			break;
	}
	 */
	selection.location+=3;
	selection.length = 0;
	[self updateWebViewWithString:messagesView.text];
}


#pragma mark UITextViewDelegate 
/*
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	ZoozzLog(@"textViewShouldBeginEditing: textView.selectedRange(%u,%u) selection(%u,%u)",textView.selectedRange.location,textView.selectedRange.length,selection.location,selection.length);
	
	return YES; 
}
*/

-(void)textViewDidBeginEditing:(UITextView *)textView{
	//ZoozzLog(@"textViewDidBeginEditing: textView.selectedRange(%u,%u) selection(%u,%u)",textView.selectedRange.location,textView.selectedRange.length,selection.location,selection.length);
	messagesView.selectedRange = selection;
	[self resetView];
	self.keybToEmosButton.selected = YES;
	deleteMode = NO;
}





/*

- (void)textViewDidChangeSelection:(UITextView *)textView {
	ZoozzLog(@"textViewDidChangeSelection: textView.selectedRange(%u,%u) selection(%u,%u)",textView.selectedRange.location,textView.selectedRange.length,selection.location,selection.length);
}

*/
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	//ZoozzLog(@"shouldChangeTextInRange: textView.selectedRange(%u,%u) selection(%u,%u)",textView.selectedRange.location,textView.selectedRange.length,selection.location,selection.length);
	if ([textView.text length] && ![text length] && [textView.text characterAtIndex:range.location] == 0x200B) 
		deleteMode = YES;
		
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
	//ZoozzLog(@"textViewDidChange: textView.selectedRange(%u,%u) selection(%u,%u)",textView.selectedRange.location,textView.selectedRange.length,selection.location,selection.length);
	
	NSRange tempSelection = textView.selectedRange;
	
	if (deleteMode) { 
		if (tempSelection.location>0 && tempSelection.location <= [textView.text length]) {
			tempSelection.location--;
			textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(tempSelection.location, 1) withString:@""];
		}
		deleteMode = NO;
	}
	
	
	textView.text=[self fix:textView.text];

	
	if ( tempSelection.location > [textView.text length])
		tempSelection.location=[textView.text length];
		
	textView.selectedRange = tempSelection;
	
	
	[self updateWebViewWithString:textView.text];
		
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
 //ZoozzLog(@"textViewShouldEndEditing: textView.selectedRange(%u,%u) selection(%u,%u)",textView.selectedRange.location,textView.selectedRange.length,selection.location,selection.length);
	if (textView.selectedRange.location<=[textView.text length]) // the bug of wierd numbers
		selection = messagesView.selectedRange;
	return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView {
	//ZoozzLog(@"textViewDidEndEditing: textView.selectedRange(%u,%u) selection(%u,%u)",textView.selectedRange.location,textView.selectedRange.length,selection.location,selection.length);
	deleteMode = NO;
}

#pragma mark -
#pragma mark Compose Mail

-(void)action:(id)sender {
	
	[self sendEMail];
	
	/*
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate addEvent:[ZoozzEvent send]];
	if (appDelegate.localStorage.sessionID==nil) {
		if (isConnected()) {
			NoServerAlert();
			//[[ZoozzConnection alloc] initWithRequestType:ZoozzLogin withString:appDelegate.localStorage.purchases delegate:self];
		}
		else 
			NoInternetAlert();
	} else {
	 }
		*/
//	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"MMS",@"Email",nil];
//	[actionSheet showInView:self.view];
//	[actionSheet release];
	
}


/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
		case 0:
			[self sendText];
			break;
		case 1:
    		[self sendEMail];
			break;
		default:
			break;
	}
}
*/

- (NSString *) getMessage {
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	NSString * str = appDelegate.localStorage.message;// messagesView.text;
	if (!str)
		str=@"";
	
	//NSString * token = [appDelegate.localStorage token];
	
	str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
	NSArray * arr = [str componentsSeparatedByCharactersInSet:emoji];
	NSString * text = @"<font>";
	if ([arr count] >0 ) {
		int j = 0;
		NSString * temp = [arr objectAtIndex:0];
		text = [text stringByAppendingString:temp];
		j+= [temp length];
		for (int i=1; i<[arr count]; i++) {
			Asset * asset = [appDelegate.localStorage.assetsByUnichar objectForKey:[NSString stringWithFormat:@"%u",[str characterAtIndex:j]]];
			
			switch (asset.contentType) {
				case CacheResourceEmoticon: 
					//text = [text stringByAppendingString:[NSString stringWithFormat:@"<a href='%@/reply?%@'><img border='0' src='%@/content/%@?%@'/></a>",kZoozzURL,token,kZoozzURL,asset.identifier,token]];
					text = [text stringByAppendingString:[NSString stringWithFormat:@"<img border='0' src='%@/data/content/%@.gif'/>",kZoozzURL,asset.identifier]];
					ZoozzLog(@"<img border='0' src='%@/data/content/%@.gif'/>",kZoozzURL,asset.identifier);
					break;
//				case CacheResourceWink: {
//					
//					NSString *content = [NSString stringWithFormat:@"%@/content/%@?%@#IWBACNT%@",kZoozzURL,asset.identifier,token,asset.originalID];
//					NSString *thumb = [NSString stringWithFormat:@"%@/content/t/%@?%@",kZoozzURL,asset.identifier,token];
//					uint k = arc4random() % 3 + 1;
//					NSString *topImage = [NSString stringWithFormat:@"<img src='%@/pages/imbooster/img/email-pins-%u-top.png' style='display: block; margin: 0'/>",kZoozzURL,k];
//					NSString *leftImage = [NSString stringWithFormat:@"<img src='%@/pages/imbooster/img/email-pins-%u-left.png' style='display: block; margin: 0'/>",kZoozzURL,k];
//					NSString *contentLink = [NSString stringWithFormat:@"<a href='%@' style='display: block'><img border='0' style='display: block; width: 50px; height: 50px' src='%@' alt='click to play animation!'/></a>",content,thumb]; 
//					NSString *rightImage = [NSString stringWithFormat:@"<img src='%@/pages/imbooster/img/email-pins-%u-right.png' style='display: block; margin: 0'/>",kZoozzURL,k];
//					NSString *bottomLink = [NSString stringWithFormat:@"<a href='%@' style='display: block'><img border='0' src='%@/pages/imbooster/img/email-pins-%u-bottom.png' style='display: block; margin: 0'/></a>",content,kZoozzURL,k];
//					NSString *wink = [NSString stringWithFormat:@"<table width='80' height='104' cellpadding='0' cellspacing='0'><tr height='25'><td colspan='3'>%@</td></tr><tr height='50'><td width='11'>%@</td><td width='50'>%@</td><td width='19'>%@</td></tr><tr height='29'><td colspan='3'>%@</td></tr></table>",
//									  topImage,leftImage,contentLink,rightImage,bottomLink];
//					
//					text = [text stringByAppendingString:wink];
//					
//					
//					
//				}
//					break;
				default:
					break;
			}
			
			j++;
			NSString * temp = [arr objectAtIndex:i];
			
			text = [text stringByAppendingString:temp];
			j+= [temp length];
		}
		
	}
	
	//text = [text stringByAppendingString:[NSString stringWithFormat:@"<br/><br/><a href='%@/reply?%@'>Click here to reply with your own emoticons and winks!</a></font>",kZoozzURL,token]];
	//text = [text stringByAppendingString:[NSString stringWithFormat:@"<br/><br/><a href='%@/reply'>Click here to reply with your own emoticons and winks!</a></font>",kEmojiAppURL]];
	text = [text stringByAppendingString:[NSString stringWithFormat:@"<br/><br/><a href='%@'>Get tons of emoticons for your iPhone, iPad or iPod!</a></font>",kEmojiAppURL]];
	
	

	return text;
}



- (void)sendEMail {
	//appDelegate.toolbar.hidden = YES;
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			
			//[picker setSubject:@"Hello from Zoozz"];
			
			
			//ZoozzLog(text);
			
			[picker setMessageBody:[self getMessage] isHTML:YES];
			
			[self presentModalViewController:picker animated:YES];
			[picker release];
			
			
		}
		else
		{
			//[self launchMailAppOnDevice];
		}
	}
	else
	{
		//[self launchMailAppOnDevice];
	}
	//[[ (IminentAppDelegate *)[[UIApplication sharedApplication] delegate] navBar ]setHidden:NO];
	//[self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}




// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	//appDelegate.toolbar.hidden = NO;
	//message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent: {
			/*
			[[ZoozzConnection alloc] initWithRequestType:ZoozzEvents withString:[NSString stringWithFormat:
				@"<?xml version='1.0' encoding='utf-8'?><events><e msg='Token' props='token:%@'/></events>",appDelegate.localStorage.token] 
												delegate:nil];
			*/
//			[appDelegate addEvent:[ZoozzEvent sendWithToken:[appDelegate.localStorage token]]];
//			appDelegate.localStorage.tokenNumber=(appDelegate.localStorage.tokenNumber)%255+1; // cyclic from 1 to 255 (include)
			//message.text = @"Result: sent";
			selection = NSMakeRange(0, [appDelegate.localStorage.message length]);
		} break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
	//[[ (IminentAppDelegate *)[[UIApplication sharedApplication] delegate] navBar ]setHidden:NO];
}


/*
#pragma mark -
#pragma mark Compose Message 


-(NSString *) pasteMessageToPasteboard {
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	NSString * str = appDelegate.localStorage.message;// messagesView.text;
	if (!str)
		str=@"";
	
	//NSString * token = [appDelegate.localStorage token];
	
	str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
	NSArray * arr = [str componentsSeparatedByCharactersInSet:emoji];
	NSString * text = @"<font>";
	
	NSMutableArray *parr = [NSMutableArray array];
	
	if ([arr count] >0 ) {
		int j = 0;
		NSString * temp = [arr objectAtIndex:0];
		text = [text stringByAppendingString:temp];
		j+= [temp length];
		
		for (int i=1; i<[arr count]; i++) {
			Asset * asset = [appDelegate.localStorage.assetsByUnichar objectForKey:[NSString stringWithFormat:@"%u",[str characterAtIndex:j]]];
			
			switch (asset.contentType) {
				case CacheResourceEmoticon: {
					//text = [text stringByAppendingString:[NSString stringWithFormat:@"<a href='%@/reply?%@'><img border='0' src='%@/content/%@?%@'/></a>",kZoozzURL,token,kZoozzURL,asset.identifier,token]];
					
					NSString *path = [CacheResource cacheResourcePathWithResourceType:CacheResourceEmoticon WithIdentifier:asset.identifier];
					
					
					[parr addObject:[NSDictionary dictionaryWithObject:[UIImage imageWithContentsOfFile:path] forKey:(NSString *)kUTTypeGIF]];
					
					
					
					
					
				}break;
					//				case CacheResourceWink: {
					//					
					//					NSString *content = [NSString stringWithFormat:@"%@/content/%@?%@#IWBACNT%@",kZoozzURL,asset.identifier,token,asset.originalID];
					//					NSString *thumb = [NSString stringWithFormat:@"%@/content/t/%@?%@",kZoozzURL,asset.identifier,token];
					//					uint k = arc4random() % 3 + 1;
					//					NSString *topImage = [NSString stringWithFormat:@"<img src='%@/pages/imbooster/img/email-pins-%u-top.png' style='display: block; margin: 0'/>",kZoozzURL,k];
					//					NSString *leftImage = [NSString stringWithFormat:@"<img src='%@/pages/imbooster/img/email-pins-%u-left.png' style='display: block; margin: 0'/>",kZoozzURL,k];
					//					NSString *contentLink = [NSString stringWithFormat:@"<a href='%@' style='display: block'><img border='0' style='display: block; width: 50px; height: 50px' src='%@' alt='click to play animation!'/></a>",content,thumb]; 
					//					NSString *rightImage = [NSString stringWithFormat:@"<img src='%@/pages/imbooster/img/email-pins-%u-right.png' style='display: block; margin: 0'/>",kZoozzURL,k];
					//					NSString *bottomLink = [NSString stringWithFormat:@"<a href='%@' style='display: block'><img border='0' src='%@/pages/imbooster/img/email-pins-%u-bottom.png' style='display: block; margin: 0'/></a>",content,kZoozzURL,k];
					//					NSString *wink = [NSString stringWithFormat:@"<table width='80' height='104' cellpadding='0' cellspacing='0'><tr height='25'><td colspan='3'>%@</td></tr><tr height='50'><td width='11'>%@</td><td width='50'>%@</td><td width='19'>%@</td></tr><tr height='29'><td colspan='3'>%@</td></tr></table>",
					//														topImage,leftImage,contentLink,rightImage,bottomLink];
					//					
					//					text = [text stringByAppendingString:wink];
					//					
					//					
					//					
					//				}
					//					break;
				default:
					break;
			}
			
			j++;
			NSString * temp = [arr objectAtIndex:i];
			
			text = [text stringByAppendingString:temp];
			j+= [temp length];
			
			//[parr addObject:[NSDictionary dictionaryWithObject:[[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"] forKey:(NSString *)kUTTypePNG]];
			
		}
		
	}
	
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.items = parr;
	
	//text = [text stringByAppendingString:[NSString stringWithFormat:@"<br/><br/><a href='%@/reply?%@'>Click here to reply with your own emoticons and winks!</a></font>",kZoozzURL,token]];
	text = [text stringByAppendingString:[NSString stringWithFormat:@"<br/><br/><a href='%@/reply'>Click here to reply with your own emoticons and winks!</a></font>",kZoozzURL]];
	return text;
}




- (void)sendText {
	//appDelegate.toolbar.hidden = YES;
	Class textClass = (NSClassFromString(@"MFMessageComposeViewController"));
	if (textClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([textClass canSendText])
		{
			MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
			picker.messageComposeDelegate = self;
			
			//[picker setSubject:@"Hello from Zoozz"];
			
			
			//ZoozzLog(text);
			
			//[picker setMessageBody:[self getMessage] isHTML:YES];
			picker.body = [self pasteMessageToPasteboard];
			
			[self presentModalViewController:picker animated:YES];
			[picker release];
			
			
		}
		else
		{
			//[self launchMailAppOnDevice];
		}
	}
	else
	{
		//[self launchMailAppOnDevice];
	}
	//[[ (IminentAppDelegate *)[[UIApplication sharedApplication] delegate] navBar ]setHidden:NO];
	//[self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}



-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {	
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	//appDelegate.toolbar.hidden = NO;
	//message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		
		case MessageComposeResultSent: {
			
//			 [[ZoozzConnection alloc] initWithRequestType:ZoozzEvents withString:[NSString stringWithFormat:
//			 @"<?xml version='1.0' encoding='utf-8'?><events><e msg='Token' props='token:%@'/></events>",appDelegate.localStorage.token] 
//			 delegate:nil];
			 
//			[appDelegate addEvent:[ZoozzEvent sendWithToken:[appDelegate.localStorage token]]];
//			appDelegate.localStorage.tokenNumber=(appDelegate.localStorage.tokenNumber)%255+1; // cyclic from 1 to 255 (include)
			//message.text = @"Result: sent";
			selection = NSMakeRange(0, [appDelegate.localStorage.message length]);
		} break;
		case MessageComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
	//[[ (IminentAppDelegate *)[[UIApplication sharedApplication] delegate] navBar ]setHidden:NO];
}
*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGRect frame = webView.frame;
	frame.origin.y = -scrollView.contentOffset.y;
	frame.size.height = scrollView.contentSize.height;// scrollView.contentOffset.y+scrollView.frame.size.height;
	[webView setFrame:frame];
}


/*
- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {
	IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.catalog) {
		[appDelegate.catalog loadCurrentSectionViewAssets];
	}
}
 */

/*
#pragma mark ZoozzConnection delegate methods

- (void) connectionDidFail:(ZoozzConnection *)theConnection {
	NoServerAlert();
	[theConnection release];
}


- (void) connectionDidFinish:(ZoozzConnection *)theConnection {
	if (theConnection.theResponse.statusCode==HTTPStatusCodeOK || theConnection.theResponse.statusCode == HTTPStatusCodeNoContent) {
		IminentAppDelegate *appDelegate = (IminentAppDelegate*)[[UIApplication sharedApplication] delegate];
		if (appDelegate.localStorage.sessionID!=nil)
			[self sendEMail];
	} else 
		NoServerAlert();

	[theConnection release];
}
*/



@end
