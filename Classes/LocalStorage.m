//
//  LocalStorage.m
//  PropertyListExample
//
//  Created by Roee Kremer on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocalStorage.h"
#import "Asset.h"
#import "Section.h"
#import "Category.h"
#import "Utilities.h"
#import "ZoozzMacros.h"
#import "ZipArchive.h"

@implementation LocalStorage

//@synthesize sessionID;
//@synthesize libraryDate;
//@synthesize tried;
@synthesize message;
//@synthesize tokenNumber;
//@synthesize firstLaunch;
//@synthesize cookieInstalled;
@synthesize purchases;
@synthesize transactions;
@synthesize events;

@synthesize backgroundLoad;

@synthesize sections;
@synthesize assetsByUnichar;
@synthesize assetsByIdentifier;

+ (void) unzip:(NSString *)src to:(NSString *)dest {
	ZipArchive *zip = [[ZipArchive alloc] init];
	[zip UnzipOpenFile:src];
	[zip UnzipFileTo:dest overWrite:YES];
	[zip UnzipCloseFile];
}

	



+ (LocalStorage*) localStorage 
{
	
	//NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
//#ifdef _SETTINGS
//	if ([defaults boolForKey:@"clear_cache_identifier"]) 
//		[LocalStorage clearCache];
//#endif 
	
	//[LocalStorage initCache];
	/*	
	 if ([defaults boolForKey:@"delete_user_identifier"]) 
	 [LocalStorage delete];
	 */
	
	
	
	LocalStorage* retVal = NULL;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		ZoozzLog(@"Documents directory not found!");
		return NULL;
	}
	
	
	
	
	
	NSString * appFile = [documentsDirectory stringByAppendingPathComponent:@"local"];
	
	retVal = (LocalStorage *)[NSKeyedUnarchiver unarchiveObjectWithFile:appFile];
	
	if (!retVal) {
		NSString *oldFile = [documentsDirectory stringByAppendingPathComponent:@"data"];
		BOOL isDir;
		if ([[NSFileManager defaultManager] fileExistsAtPath:oldFile isDirectory:&isDir] && !isDir) {
			
			ZoozzLog(@"LocalStorage: no archive, trying old one");
			
			retVal = (LocalStorage *)[NSKeyedUnarchiver unarchiveObjectWithFile:oldFile];
			
			if (retVal.purchases) {
				ZoozzLog(@"old purchases: %@",retVal.purchases);
				if (!retVal.transactions) {
					retVal.transactions = [NSMutableArray array];
				}
				 
				
				[retVal.transactions addObject:retVal.purchases];
				[retVal archive];
				
				
				
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WelcomeTitle",@"Welcome to Emoji2010";)
																message:NSLocalizedString(@"BuyersMessage",@"Welcome to Emoji2010 update, you will enjoy no ad")
															   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];	
				[alert show];
				[alert release];
				
								
				
			}
			
			ZoozzLog(@"deleting old archive");

			
			NSError * error = nil;
			if (![[NSFileManager defaultManager] removeItemAtPath:oldFile error:&error]) {
				URLCacheAlertWithError(error);
				ZoozzLog(@"deleting old archive - failed");
			} 
			 
			
			
		} else
			retVal= [[[self alloc] init] autorelease];
	}
	
	
	
	/*
	 if ([defaults boolForKey:@"delete_sessionID_identifier"])
	 localStorage.sessionID = nil;
	
	if ([defaults boolForKey:@"delete_libraryDate_identifier"]) {
		retVal.libraryDate = nil;
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *path= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"];
		NSString * appFile = [path stringByAppendingPathComponent:@"library.xml"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
			NSError * error = nil;
			if (![[NSFileManager defaultManager] removeItemAtPath:appFile error:&error]) 
				ZoozzLog(@"can't delete %@: %@",appFile,[error localizedDescription]);
			else
				ZoozzLog(@"%@ deleted",appFile);
		}
		 
	}
	*?
	
	/*
	 if ([defaults boolForKey:@"delete_tried_identifier"])
	 localStorage.tried = NO;
	 
	 if ([defaults boolForKey:@"delete_purchases_identifier"])
	 localStorage.purchases = nil;
	 */
	
	

	return retVal;
}
	
	
- (BOOL)archive {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		ZoozzLog(@"Documents directory not found!");
		return NO;
	}
	
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"local"];
	return [NSKeyedArchiver archiveRootObject:self toFile:appFile];
}
	
	
	
+ (void)delete {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		ZoozzLog(@"Documents directory not found!");
		return ;
	}
	
	
	NSError * error = nil;
	NSString * appFile = [documentsDirectory stringByAppendingPathComponent:@"local"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:appFile error:&error]) 
			ZoozzLog(@"can't delete %@: %@",appFile,[error localizedDescription]);
		else
			ZoozzLog(@"%@ deleted",appFile);
	}
	
}
	
	

- (id)init {
	
	if (self = [super init]) {
		
		backgroundLoad = NO;
		//tokenNumber = 1;
		//firstLaunch = NO;
		//cookieInstalled = NO;
		//tried = NO;
	}
	return self;
}




- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self != nil) {
		//self.sessionID = [coder decodeObjectForKey:@"sessionID"];
		//self.libraryDate = [coder decodeObjectForKey:@"libraryDate"];
		self.message = [coder decodeObjectForKey:@"message"];
		//self.tokenNumber = [coder decodeIntegerForKey:@"tokenNumber"];
		//self.firstLaunch = [coder decodeBoolForKey:@"firstLaunch"];
		//self.cookieInstalled = [coder decodeBoolForKey:@"cookieInstalled"];
		//self.tried = [coder decodeBoolForKey:@"tried"];
		self.purchases = [coder decodeObjectForKey:@"purchases"];
		self.transactions = [coder decodeObjectForKey:@"transactions"];
		//self.events	= [coder decodeObjectForKey:@"events"]; // doesn't archive events
		backgroundLoad = NO;
	}
	return self;
}



- (void)dealloc
{
	[assetsByUnichar release];
	[assetsByIdentifier release];
	//[sessionID release];
	[message release];
	[purchases release];
	[transactions release];
	[sections release];
	[events release];
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    //[coder encodeObject:self.sessionID forKey:@"sessionID"];
	//[coder encodeObject:self.libraryDate forKey:@"libraryDate"];
	[coder encodeObject:self.message forKey:@"message"];
	//[coder encodeInteger:self.tokenNumber forKey:@"tokenNumber"];
	//[coder encodeBool:self.firstLaunch forKey:@"firstLaunch"];
	//[coder encodeBool:self.cookieInstalled forKey:@"cookieInstalled"];
	//[coder encodeBool:self.tried forKey:@"tried"];
	[coder encodeObject:self.purchases forKey:@"purchases"];
	[coder encodeObject:self.transactions forKey:@"transactions"];
	//[coder encodeObject:self.events forKey:@"events"]; // // doesn't archive events
}


/*
- (Page*)getPage:(NSUInteger)page withSection:(NSUInteger)sec {
	return nil;
}
 */

/*


+ (void) initCache
{
	// create path to cache directory inside the application's Documents directory 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"]; 
	
	
	
//	NSString * xmlPath = [dataPath stringByAppendingPathComponent:@"library.xml"];
//	if (![[NSFileManager defaultManager] removeItemAtPath:xmlPath error:&error]) {
//		URLCacheAlertWithError(error);
//		return;
//	} 
	 
	
	NSError * error = nil;
	// check for existence of cache directory 
	if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
			URLCacheAlertWithError(error);
			return;
		}
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[dataPath stringByAppendingPathComponent:@"thumb"]]) {
		if (![[NSFileManager defaultManager] createDirectoryAtPath:[dataPath stringByAppendingPathComponent:@"thumb"] withIntermediateDirectories:NO attributes:nil error:&error]) {
			URLCacheAlertWithError(error);
			return;
		}
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[dataPath stringByAppendingPathComponent:@"content"]]) {
		if (![[NSFileManager defaultManager] createDirectoryAtPath:[dataPath stringByAppendingPathComponent:@"content"] withIntermediateDirectories:NO attributes:nil error:&error]) {
			URLCacheAlertWithError(error);
			return;
		}
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[dataPath stringByAppendingPathComponent:@"preview"]]) {
		if (![[NSFileManager defaultManager] createDirectoryAtPath:[dataPath stringByAppendingPathComponent:@"preview"] withIntermediateDirectories:NO attributes:nil error:&error]) {
			URLCacheAlertWithError(error);
			return;
		}
	}
	
}
*/

/* removes every file in the cache directory */


//+ (void) clearCache
//{
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString * dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"]; 
//	NSError * error = nil;
//	
//	/* remove the cache directory and its contents */
//	if (![[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error]) {
//		URLCacheAlertWithError(error);
//		return;
//	}
//	
//}	




- (void)arrangeAssets:(NSArray *)assets; {
	
	self.sections = nil;
	self.assetsByUnichar = nil;
	self.assetsByIdentifier = nil;
	
	
	self.sections = [NSMutableArray array];
	self.assetsByUnichar = [NSMutableDictionary dictionaryWithCapacity:[assets count]];
	self.assetsByIdentifier = [NSMutableDictionary dictionaryWithCapacity:[assets count]];
	
	Section * section = [[Section alloc] init];
	[self.sections addObject:section];
	[section release];
	Category * category = [[Category alloc] init];
	[section.categories addObject:category];
	[category release];
	int sec = 0;
	int cat = 0;

	
	for (Asset * asset in assets) {
		
		if (asset.section>sec) {
			section = [[Section alloc] init];
			[sections addObject:section];
			[section release];
			category = [[Category alloc] init];
			[section.categories addObject:category];
			[category release];
			cat = 0;
			sec++;
		} else if (asset.category>cat) {
			category = [[Category alloc] init];
			[section.categories addObject:category];
			[category release];
			cat++;
		}
		
		//if (!asset.bLocked) 
		[section.assets addObject:asset];			
		
		[category.assets addObject:asset];
		[assetsByUnichar setObject:asset forKey:[NSString stringWithFormat:@"%u",asset.charCode]];
		[assetsByIdentifier setObject:asset forKey:asset.identifier];
		
		//Asset * asset = [assetsList objectAtIndex:ch-0xE900];
		
		//ZoozzLog(@"arrange asset - section: %u(%u), category: %u(%u), identifier: %@",asset.section,sec,asset.category,cat,asset.identifier);
		
	}
	
	ZoozzLog(@"arrangeAssets ended");
}

/*
- (NSArray *)productAssetsWithIdentifier:(NSString *)identifier {
	NSMutableArray *assets;
	assets = [NSMutableArray array];
	for (Section *sec in sections) {
		for (Category *cat in sec.categories) {
			for (Asset *asset in cat.assets) {
				if ([asset.productIdentifier isEqualToString:identifier]) {
					[assets addObject:asset];
				}
			}
		}
		
	}
				 
	return assets;
}
*/

/*
- (void)removeAssets{
	
	for (Section * section in self.sections) {
		[section.assets removeAllObjects];
		while ([section.categories count]) {
			Category * category = [section.categories lastObject];
			[category.assets removeAllObjects];
			[section.categories removeLastObject];
		}
	}
	 
	[self.sections removeAllObjects];
	
	
}



*/

- (unsigned char) cycleChar:(unsigned char)ch times:(int)n{
	
	for (int i=0;i<n % 16;i++)
		switch (ch) {
			case 57:
				ch = 65;
				break;
			case 70:
				ch = 48;
				break;
			default:
				ch++;
				break;
		}
	
	
	return ch;
}

- (unsigned char) hexDigit:(int)n {
	return n<10 ? n+48 : n+55;	
}

- (NSString*) encode:(NSString *)str number:(uint8_t) number
{
	NSData * srcData = [str dataUsingEncoding:NSASCIIStringEncoding];
	int length = [srcData length];
	const uint8_t* input = [srcData bytes];
	NSMutableData* data = [NSMutableData dataWithLength:length+2];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
	int i;
	
	for (i=0; i<length; i++) {
		uint8_t src = input[i];
		uint8_t res = [self cycleChar:src times:number];
		int j = 1+(i+number+1)%length;
        output[j ] = res;
	}
	
	output[0] = [self hexDigit:number / 16];
	output[length+1] = [self hexDigit:number % 16];
	//ZoozzLog(@"%@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	
    return  [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

/*
- (NSString *)token {
	ZoozzLog(@"create token for sessionID: %@",self.sessionID);
	if (self.sessionID== nil) 
		return nil;
		
	return [self encode:self.sessionID number:self.tokenNumber];
}
*/
+ (NSString *)bundleVersion {
	
	NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
	NSString *str = [dict objectForKey:(NSString*)kCFBundleVersionKey];
	
	//ZoozzLog(@"bundle version: %@",str);
	return str;
	
}


@end
