//
//  LocalStorage.h
//  PropertyListExample
//
//  Created by Roee Kremer on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalStorage : NSObject<NSCoding> {
	BOOL backgroundLoad;
	NSMutableArray *sections;
	NSMutableDictionary * assetsByUnichar;
	NSMutableDictionary * assetsByIdentifier;
	
	//NSString *sessionID;
	//NSString *libraryDate;
	NSString *message;
	//NSInteger tokenNumber;
	//BOOL firstLaunch;
	//BOOL cookieInstalled;
	//BOOL tried;
	NSMutableArray *transactions; 
	NSString *purchases;
	
	NSString *lastUpdate;
	
	//NSMutableArray *events;
}

//@property (retain, nonatomic) NSString * sessionID;
//@property (retain, nonatomic) NSString * libraryDate;
@property (retain, nonatomic) NSString *message;
//@property NSInteger tokenNumber;
//@property BOOL firstLaunch;
//@property BOOL cookieInstalled;
//@property BOOL tried;
@property (retain, nonatomic) NSString *purchases;
@property (retain, nonatomic) NSMutableArray *transactions;
@property (retain, nonatomic) NSString *lastUpdate;
//@property (retain, nonatomic) NSMutableArray *events;

@property BOOL backgroundLoad;
@property (nonatomic ,retain) NSMutableArray *sections;
@property (nonatomic, retain) NSMutableDictionary * assetsByUnichar;
@property (nonatomic, retain) NSMutableDictionary * assetsByIdentifier;


+ (LocalStorage*) localStorage;

+ (void)unzip:(NSString *)src to:(NSString *)dest;
//+ (void)initCache;
//+ (void)clearCache;
	
- (void)arrangeAssets:(NSArray *)assets;
//- (NSString *)token;
//- (void)removeAssets;
- (BOOL)archive;
+ (void)delete;
//- (NSArray *)productAssetsWithIdentifier:(NSString *)identifier;

+ (NSString *)bundleVersion;

@end
