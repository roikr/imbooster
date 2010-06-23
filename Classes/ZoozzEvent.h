//
//  ZoozzEvent.h
//  IMBooster
//
//  Created by Roee Kremer on 1/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	ZoozzEnterEvent = 1,
	ZoozzGotoEvent = 2,
	ZoozzNavigateEvent = 3,
    ZoozzUseEvent = 4,
	ZoozzPreviewEvent = 5,
	ZoozzBuyEvent = 6,
	ZoozzNotificationEvent = 7,
	ZoozzSendEvent = 8,
	ZoozzRestoreEvent = 10
	
};

typedef NSUInteger ZoozzEventType; 

enum { 
	ZoozzViewKeyboard = 1,
	ZoozzViewGallery = 2,
	ZoozzViewStore = 3,
	ZoozzViewHelp = 4
};

typedef NSUInteger ZoozzViewType;

enum { 
	ZoozzParameterWelcome = 1,
	ZoozzParameterContent = 2,
	ZoozzParameterReply = 3
};

typedef NSUInteger ZoozzParameterType;

enum { 
	ZoozzNotificationActionRecieved = 1,
	ZoozzNotificationActionBeenViewed = 2
};

typedef NSUInteger ZoozzNotificationActionType;

@class Asset;

@interface ZoozzEvent : NSObject<NSCoding> {
	ZoozzEventType eventType;
	NSString *eventMsg;
}

@property ZoozzEventType eventType;
@property (nonatomic, retain) NSString *eventMsg;

+ (ZoozzEvent *)enterWithParameter:(ZoozzParameterType)param withToken:(NSString *)token WithAssetID:(NSString *)aid;
+ (ZoozzEvent *)restore;

+ (ZoozzEvent *)gotoView:(ZoozzViewType)view toSection:(NSUInteger)sec subSection:(NSUInteger)sub;
+ (ZoozzEvent *)gotoHelpView; 
+ (ZoozzEvent *)gotoStoreWithProduct:(NSString *)identifier;

+ (ZoozzEvent *)navigateView:(ZoozzViewType)view toSection:(NSUInteger)sec subSection:(NSUInteger)sub;

+ (ZoozzEvent *)useInGalleryViewWithAsset:(Asset *)asset;
+ (ZoozzEvent *)useInKeyboardViewWithAsset:(Asset *)asset inPage:(NSUInteger)pg;

+ (ZoozzEvent *)galleryPreviewWithAsset:(Asset *)asset;
+ (ZoozzEvent *)storePreviewWithAsset:(Asset *)asset;

+ (ZoozzEvent *)send;
+ (ZoozzEvent *)sendWithToken:(NSString *)token;

+ (ZoozzEvent *)buyWithProduct:(NSString *)pid;
+ (ZoozzEvent *)buyWithProduct:(NSString *)pid withTransaction:(NSString*)tidfr withCurrency:(NSString *)cur withPrice:(NSDecimalNumber *)prc;

+ (ZoozzEvent *)notificationWithAction:(ZoozzNotificationActionType)action inView:(ZoozzViewType)view inSection:(NSUInteger)sec subSection:(NSUInteger)sub withIdentifier:(NSString*)nid;
+ (ZoozzEvent *)notificationWithAction:(ZoozzNotificationActionType)action inView:(ZoozzViewType)view withIdentifier:(NSString*)nid;
+ (ZoozzEvent *)notificationWithAction:(ZoozzNotificationActionType)action withIdentifier:(NSString*)nid;
+ (ZoozzEvent *)notificationRecieved;

@end
