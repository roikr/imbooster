#import <Foundation/Foundation.h>
#import "CacheResource.h"


typedef NSUInteger IminentAssetType; 


@interface Asset : NSObject{
@private
   
	NSUInteger number;
    NSUInteger section;
	NSUInteger category;
    
	NSString *identifier;
	CacheResourceType contentType;
	
	NSString * productIdentifier;
	NSString * purchaseID;
	
	unichar charCode;
	NSString * originalID;
	
	BOOL bNew;
	BOOL bChanged;
	
	BOOL bLocked;
		
	UIImage *thumbImage;
	BOOL bThumbCached;
	BOOL bContentCached;
}

@property NSUInteger number;
//@property NSUInteger page;
@property NSUInteger section;
@property NSUInteger category;
@property (nonatomic, retain) NSString *identifier;
@property CacheResourceType	contentType;
@property (nonatomic, retain) NSString *productIdentifier;
@property (nonatomic, retain) NSString *purchaseID;
@property unichar charCode;
@property BOOL bNew;
@property BOOL bChanged;
@property (nonatomic, retain) NSString *originalID;

@property BOOL bLocked;
@property (nonatomic,retain) UIImage *thumbImage;
@property BOOL bThumbCached;
@property BOOL bContentCached;

-(id) initWithNumber:(NSUInteger)num withSection:(NSUInteger)sec withCategory:(NSUInteger)cat withIdentifier:(NSString *)aid withCharCode:(unichar)ch
			withType:(unichar)t withProductIdentifier:(NSString *)pidfr withPurchaseID:(NSString *)pid withNew:(BOOL)assetNew withChanged:(BOOL)assetChanged withOriginalID:(NSString *)oid;

- (void)copyResources;

@end