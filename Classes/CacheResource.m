//
//  CacheResource.m
//  IMBooster
//
//  Created by Roee Kremer on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CacheResource.h"
//#import "ZoozzConnection.h"
#import "IminentAppDelegate.h"
#import "LocalStorage.h"


@interface CacheResource (PrivateMethods)

@end

@implementation CacheResource

@synthesize delegate;
@synthesize filePath;
@synthesize resourceType;
@synthesize connection;
@synthesize identifier;
//@synthesize transaction;


- (id) initWithResouceType:(CacheResourceType)aResourceType withObject:(id)object delegate:(id<CacheResourceDelegate>)theDelegate {
	if (self = [super init]) {
		self.delegate = theDelegate;
		resourceType = aResourceType;
		
		
		switch (resourceType) {
			case CacheResourceThumb:
			case CacheResourceEmoticon:
			//case CacheResourceWink:
			case CacheResourceUpdate:
				self.identifier = object;
				break;
			//case CacheResourceLibrary:
			//	self.transaction = object;
			//	break;
			
			default:
				break;
		}
		 
		
		
		
		//NSString *relativePath = [CacheResource resourceRelativePathWithResourceType:aResourceType WithIdentifier:identifier];
		self.filePath = [CacheResource cacheResourcePathWithResourceType:aResourceType WithIdentifier:identifier];
				
		
		
		switch (resourceType) {
			/*
			case CacheResourceThumb:
			case CacheResourceEmoticon:
			case CacheResourceWink:
				self.connection = [[ZoozzConnection alloc] initWithRequestType:ZoozzAsset withString:relativePath delegate:self];
				break;
			case CacheResourceLibrary:
				self.connection = [[ZoozzConnection alloc] initWithRequestType:ZoozzLibrary withString:nil delegate:self];
				break;
			*/
			case CacheResourceUpdate:
				
				self.connection = [[ZoozzConnection alloc] initWithRequestType:ZoozzAsset withString:[NSString stringWithFormat:@"zip/data_%@.zip",identifier] delegate:self];
			default:
				break;
		}
		
	}
	
	return self;
}


/*

+ (void) copyWithResourceType:(CacheResourceType)aResourceType withIdentifier:(NSString*)identifier {
		
	NSString * precache = [CacheResource preCacheResourcePathWithResourceType:aResourceType WithIdentifier:identifier];	
	
	if (precache) {
		
		NSString * cache = [CacheResource cacheResourcePathWithResourceType:aResourceType WithIdentifier:identifier];
		
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:cache]) {
			NSError * error = nil;
			if (![[NSFileManager defaultManager] copyItemAtPath:precache toPath:cache error:&error]) {
				//URLCacheAlertWithError(error);
			}
			//ZoozzLog(@"precache asset at: %@ copied to: %@",cache,filePath);
			//ZoozzLog(@"precache asset to: %@",cache);
		}
	}



}


+ (NSString*)resourceRelativePathWithResourceType:(CacheResourceType)aResourceType WithIdentifier:(NSString *)identifier {
	NSString *relativePath = nil;
	
	switch (aResourceType) {
		case CacheResourceLibrary:
			break;
		case CacheResourceThumb: 
			relativePath = [@"content/t" stringByAppendingPathComponent:identifier];
			break;
		case CacheResourceEmoticon: 
			relativePath = [@"content" stringByAppendingPathComponent:identifier];
			break;
		case CacheResourceWink: 
			relativePath = [@"content/ipw" stringByAppendingPathComponent:identifier];
			
			break;
		case CacheResourceStreaming: 
			relativePath = [@"content/d" stringByAppendingPathComponent:identifier];
			break;
			
		default:
			break;
	}
	
	return relativePath;
	
}

+ (NSString*)preCacheResourcePathWithResourceType:(CacheResourceType)aResourceType WithIdentifier:(NSString *)identifier {
	NSString * precache = nil;	
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle) 
	{
		switch (aResourceType) {
			case CacheResourceLibrary:
				precache = [bundle pathForResource:@"library" ofType:@"xml" inDirectory:@"PRECache"];
				break;
			case CacheResourceThumb: 
				precache = [bundle pathForResource:identifier ofType:@"gif" inDirectory:@"PRECache/thumb"];
				break;
			case CacheResourceEmoticon: 
				precache = [bundle pathForResource:identifier ofType:@"gif" inDirectory:@"PRECache/content"];
				break;
			case CacheResourceWink: 
				precache = [bundle pathForResource:identifier ofType:@"m4v" inDirectory:@"PRECache/content"];
				break;
			default:
				break;
		}
		
	}
	
	return precache;
}

*/
+ (NSString*)cacheResourcePathWithResourceType:(CacheResourceType)aResourceType WithIdentifier:(NSString *)identifier {
	NSString * theFilePath = nil;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	switch (aResourceType) {
		case CacheResourceLibrary:
			theFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"data/library.xml"];
			break;
			
		case CacheResourceThumb: 
			theFilePath = [NSString stringWithFormat:@"%@/data/thumb/%@.gif",[paths objectAtIndex:0],identifier];
			//theFilePath = [path stringByAppendingPathComponent:[@"thumb" stringByAppendingPathComponent:identifier]];
			break;
		case CacheResourceEmoticon: 
			theFilePath = [NSString stringWithFormat:@"%@/data/content/%@.gif",[paths objectAtIndex:0],identifier];
			//theFilePath = [path stringByAppendingPathComponent:[@"content" stringByAppendingPathComponent:identifier]];
			break;
		case CacheResourceUpdate:
			theFilePath = [NSString stringWithFormat:@"%@/data_%@.zip",[paths objectAtIndex:0],identifier];
			ZoozzLog(@"cacheResourcePathWithResourceType CacheResourceUpdate %@",theFilePath);
		default:
			break;
	}
	
	return theFilePath;
}


/*
+ (NSString*)cacheResourcePathWithResourceType:(CacheResourceType)aResourceType WithIdentifier:(NSString *)identifier {
	NSString * theFilePath = nil;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"];
	
	switch (aResourceType) {
		case CacheResourceLibrary:
			theFilePath = [path stringByAppendingPathComponent:@"library.xml"];
			break;
		case CacheResourceThumb: 
			theFilePath = [path stringByAppendingPathComponent:[@"thumb" stringByAppendingPathComponent:identifier]];
			break;
		case CacheResourceEmoticon: 
			theFilePath = [path stringByAppendingPathComponent:[@"content" stringByAppendingPathComponent:identifier]];
			break;
		case CacheResourceWink: {
			theFilePath = [path stringByAppendingPathComponent:[@"content" stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:@"m4v"]]];
			//ZoozzLog(@"requesting wink: %@",theFilePath);
		} break;
		default:
			break;
	}
	
	return theFilePath;
}
*/


+ (BOOL) doesAssetCachedWithResourceType:(CacheResourceType)aResourceType withIdentifier:(NSString*)identifier {
	
	NSString * theFilePath = [CacheResource cacheResourcePathWithResourceType:aResourceType WithIdentifier:identifier];
		
	return  [[NSFileManager defaultManager] fileExistsAtPath:theFilePath];
	
}






// ------------------------------------------------------------------------
// URLCacheConnectionDelegate protocol methods
// ------------------------------------------------------------------------
 

#pragma mark -
#pragma mark ZoozzConnectionDelegate methods

- (void) connectionDidFail:(ZoozzConnection *)theConnection
{	
	
	
	[self.delegate CacheResourceDidFailLoading:self];
	
	[connection release];
	self.connection = nil;
	
}


- (void) connectionDidFinish:(ZoozzConnection *)theConnection
{	
	
	NSInteger statusCode = [theConnection.theResponse statusCode];
	
	switch (theConnection.requestType) {
			
		/*
		case ZoozzLibrary: {
			switch (statusCode) {
				case HTTPStatusCodeOK:
					ZoozzLog(@"CacheResource - connectionDidFinish - library loaded");
					//ZoozzLog(@"%@",dataString);
					break;
				case HTTPStatusCodeNotModified:
					ZoozzLog(@"CacheResource - connectionDidFinish - library did not modified");
					break;
					
					
				default:
					break;
			}
			
		} break;
		*/	
			
		case ZoozzAsset: {
			switch (statusCode) {
				case HTTPStatusCodeOK:
					ZoozzLog(@"connectionDidFinish - ZoozzAsset: HTTPStatusCodeOK, data length: %u",[theConnection.receivedData length]);
					break;
				default:
					break;
			}
			
		}
			
		default:
			break;
	}
	
	
	// the resource is cached if it is an asset or ( it is a new library )
	if (statusCode == HTTPStatusCodeOK) {
		
		
		[[NSFileManager defaultManager] createFileAtPath:filePath contents:theConnection.receivedData  attributes:nil];
//		
//		if (resourceType==CacheResourceLibrary) {
//			NSString * date = [[theConnection.theResponse allHeaderFields] objectForKey:@"Z-Date"];
//			IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
//			appDelegate.localStorage.libraryDate = date;
//			[appDelegate.localStorage archive];
//			ZoozzLog(@"CacheResource - connectionDidFinish - CacheResourceLibrary - Z-Date: %@",date);
//		}
		 
		
	}
	
//	else if ([theConnection.theResponse statusCode] != HTTPStatusCodeNotModified) {
//		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
//			NSError * error = nil;
//			if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
//				//URLCacheAlertWithError(error);
//			}
//		}
//	}
	 
	
	[self.delegate CacheResourceDidFinishLoading:self];
	
	[connection release];
	self.connection = nil;
	
}
/*
- (void)cancel {
	if (connection) {
		[connection cancel];
		connection.delegate = nil;
		[connection release];
		self.connection = nil;
	}
}
*/
- (void)dealloc {
	//no need to release connection because it released on its delegate ?
	if (connection) {
		connection.delegate = nil;
	}
	[filePath release];
	[identifier release];
	//[transaction release];
	[super dealloc];
}

@end
