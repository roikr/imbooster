#import "Asset.h"
#import "ZoozzMacros.h"

//#include <stdlib.h>

enum {
    IminentWink = 1,
	IminentEmoticon = 2,
};

@interface NSObject (PrivateMethods)
-(void) updateViews;

@end

@implementation Asset

@synthesize number,section,category,charCode,bNew,bChanged;
@synthesize contentType;
@synthesize identifier;
@synthesize productIdentifier;
@synthesize purchaseID;
@synthesize originalID;
@synthesize bLocked;
@synthesize thumbImage;
@synthesize bThumbCached;
@synthesize bContentCached;

-(id) initWithNumber:(NSUInteger)num withSection:(NSUInteger)sec withCategory:(NSUInteger)cat withIdentifier:(NSString *)aid withCharCode:(unichar)ch
			withType:(unichar)t withProductIdentifier:(NSString *)pidfr withPurchaseID:(NSString *)pid withNew:(BOOL)assetNew withChanged:(BOOL)assetChanged withOriginalID:(NSString *)oid{
	if (self = [super init]) {
		number = num;
		charCode = ch; // 0xE900+number;
		section = sec;
		category = cat;
		self.identifier = aid;
		
		switch (t) {
			case IminentEmoticon:
				contentType = CacheResourceEmoticon;
				break;
			case IminentWink: 
				contentType = CacheResourceWink;
				break;
			default:
				ZoozzLog(@"Asset - initWithNumber error - error asset type");
				break;
		}
		
		self.productIdentifier = pidfr;
		self.purchaseID = pid;
		bNew = assetNew;
		bChanged = assetChanged;
		bLocked = productIdentifier == nil ? NO : purchaseID == nil;
		self.originalID = oid;
		//ZoozzLog(@"new asset - section: %u, category: %u, identifier: %@",sec,cat,identifier);
		bThumbCached = [CacheResource doesAssetCachedWithResourceType:CacheResourceThumb withIdentifier:identifier];
		bContentCached = [CacheResource doesAssetCachedWithResourceType:contentType withIdentifier:identifier];
		
	}
	return self;
}

- (void)copyResources {
	
	//[CacheResource copyWithResourceType:CacheResourceThumb withIdentifier:identifier];
	bThumbCached = [CacheResource doesAssetCachedWithResourceType:CacheResourceThumb withIdentifier:identifier];
	
	//[CacheResource copyWithResourceType:contentType withIdentifier:identifier];
	bContentCached = [CacheResource doesAssetCachedWithResourceType:contentType withIdentifier:identifier];
}


- (void)dealloc {
	[identifier release];
	[productIdentifier release];
	[purchaseID release];
	[originalID release];
    [super dealloc];
}

@end