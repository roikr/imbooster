/*

File: URLCacheConnection.m
Abstract: The NSURL connection class for the URLCache sample.

Version: 1.0

*/

#import "URLCacheConnection.h"
#import "URLCacheAlert.h"
#import "ZoozzConnection.h"

@implementation URLCacheConnection

@synthesize delegate;
@synthesize receivedData;
@synthesize lastModified;


/* This method initiates the load request. The connection is asynchronous, 
 and we implement a set of delegate methods that act as callbacks during 
 the load. */

- (id) initWithURL:(NSURL *)theURL delegate:(id<URLCacheConnectionDelegate>)theDelegate
{
	if (self = [super init]) {

		self.delegate = theDelegate;

		/* Create the request. This application does not use a NSURLCache 
		 disk or memory cache, so our cache policy is to satisfy the request
		 by loading the data from its source. */
		
		NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
		[request setAllHTTPHeaderFields:[ZoozzConnection requestHeaderWithLogin:NO]]; 
		[request setHTTPMethod:@"POST"];
				
		/* create the NSMutableData instance that will hold the received data */
		receivedData = [[NSMutableData alloc] initWithLength:0];

		/* Create the connection with the request and start loading the
		 data. The connection object is owned both by the creator and the
		 loading system. */
			
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request 
																	  delegate:self 
															  startImmediately:YES];
		if (connection == nil) {
			/* inform the user that the connection failed */
			NSString *message = NSLocalizedString (@"Unable to initiate request.", 
												   @"NSURLConnection initialization method failed.");
			URLCacheAlertWithMessage(message);
		}
	}

	return self;
}


- (void)dealloc
{
	[receivedData release];
	[lastModified release];
	[super dealloc];
}


#pragma mark NSURLConnection delegate methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /* This method is called when the server has determined that it has
	 enough information to create the NSURLResponse. It can be called
	 multiple times, for example in the case of a redirect, so each time
	 we reset the data. */
	
    [self.receivedData setLength:0];
	
	/* Try to retrieve last modified date from HTTP header. If found, format  
	 date so it matches format of cached image file modification date. */
	
	if ([response isKindOfClass:[NSHTTPURLResponse self]]) {
		NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
		NSString *modified = [headers objectForKey:@"Last-Modified"];
		if (modified) {
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
			self.lastModified = [dateFormatter dateFromString:modified];
			[dateFormatter release];
		}
		else {
			/* default if last modified date doesn't exist (not an error) */
			self.lastModified = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
		}
	}
}


- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /* Append the new data to the received data. */
    [self.receivedData appendData:data];
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	//URLCacheAlertWithError(error); // roikr I don't want allerts
	[self.delegate connectionDidFail:self];
	[connection release];
}


- (NSCachedURLResponse *) connection:(NSURLConnection *)connection 
				   willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	/* this application does not use a NSURLCache disk or memory cache */
    return nil;
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.delegate connectionDidFinish:self];
	[connection release];
}


@end
