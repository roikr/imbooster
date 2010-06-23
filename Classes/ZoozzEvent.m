//
//  ZoozzEvent.m
//  IMBooster
//
//  Created by Roee Kremer on 1/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ZoozzEvent.h"
#import "Asset.h"

unsigned char getZoozzViewChar(ZoozzViewType view) {
	return view==ZoozzViewKeyboard ? 'k' : view == ZoozzViewGallery ? 'g' : view == ZoozzViewHelp ? 'h' : 's';
}

NSString *  getZoozzNotificationAction(ZoozzNotificationActionType action) {
	return action == ZoozzNotificationActionRecieved ? @"apn-received" : @"apn-view";
}

@implementation ZoozzEvent

@synthesize eventMsg;
@synthesize eventType;

+ (ZoozzEvent *)enterWithParameter:(ZoozzParameterType)param withToken:(NSString *)token WithAssetID:(NSString *)aid {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzEnterEvent;
	
	
	switch (param) {
		case ZoozzParameterWelcome:
			instance.eventMsg = [NSString stringWithFormat:@"<e msg='enter' props='source: welcome'/>"];
			break;
		case ZoozzParameterContent:
			instance.eventMsg = [NSString stringWithFormat:@"<e msg='enter' props='source: content; token: %@; aid: %@'/>",token,aid];
			break;
		case ZoozzParameterReply:
			instance.eventMsg = [NSString stringWithFormat:@"<e msg='enter' props='source: reply; token: %@'/>",token];
			break;
		default:
			break;
	}
	
	
	
	[instance autorelease];
	return instance;
}

+ (ZoozzEvent *)restore {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzRestoreEvent;
	
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='restore'/>"];
	
	[instance autorelease];
	return instance;
}

+ (ZoozzEvent *)gotoView:(ZoozzViewType)view toSection:(NSUInteger)sec subSection:(NSUInteger)sub {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzGotoEvent;
	
	switch (view) {
		case ZoozzViewKeyboard:
			instance.eventMsg = [NSString stringWithFormat:@"<e msg='goto' props='scr: k; sec: %u; pg: %u'/>",sec,sub];
			break;
		case ZoozzViewGallery:
			instance.eventMsg = [NSString stringWithFormat:@"<e msg='goto' props='scr: g; sec: %u; cat: %u'/>",sec,sub];
			break;
	}
	
	[instance autorelease];
	return instance;
	
}

+ (ZoozzEvent *)gotoHelpView {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzGotoEvent;
	
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='goto' props='scr: h'/>"];
	
	[instance autorelease];
	return instance;
	
}

+ (ZoozzEvent *)gotoStoreWithProduct:(NSString *)identifier {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzGotoEvent;
	
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='goto' props='scr: s; pidfr: %@'/>",identifier];
	
	[instance autorelease];
	return instance;
	
	
}

+ (ZoozzEvent *)navigateView:(ZoozzViewType)view toSection:(NSUInteger)sec subSection:(NSUInteger)sub {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzNavigateEvent;
	
	switch (view) {
		case ZoozzViewKeyboard:
			instance.eventMsg = [NSString stringWithFormat:@"<e msg='nav' props='scr: k; sec: %u; pg: %u'/>",sec,sub];
			break;
		case ZoozzViewGallery:
			instance.eventMsg = [NSString stringWithFormat:@"<e msg='nav' props='scr: g; sec: %u; cat: %u'/>",sec,sub];

			break;
	}
	
	[instance autorelease];
	return instance;
}



+ (ZoozzEvent *)useInGalleryViewWithAsset:(Asset *)asset {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzUseEvent;
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='use' props='scr: g; sec: %u; cat: %u; aid: %@; locked: %u'/>",asset.section,asset.category,asset.identifier,asset.bLocked];
	[instance autorelease];
	return instance;
	
}

+ (ZoozzEvent *)useInKeyboardViewWithAsset:(Asset *)asset inPage:(NSUInteger)pg {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzUseEvent;
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='use' props='scr: k; sec: %u; pg: %u; aid: %@; locked: %u'/>",asset.section,pg,asset.identifier,asset.bLocked];
	[instance autorelease];
	return instance;
}


+ (ZoozzEvent *)galleryPreviewWithAsset:(Asset *)asset {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzPreviewEvent;
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='preview' props='sec: %u; cat: %u; aid: %@; locked: %u'/>",asset.section,asset.category,asset.identifier,asset.bLocked];
	[instance autorelease];
	return instance;
}

+ (ZoozzEvent *)storePreviewWithAsset:(Asset *)asset {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzPreviewEvent;
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='preview' props='pidfr: %@; aid: %@'/>",asset.productIdentifier,asset.identifier];
	[instance autorelease];
	return instance;
}

+ (ZoozzEvent *)send {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzSendEvent;
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='send'/>"];
	[instance autorelease];
	return instance;
}

+ (ZoozzEvent *)sendWithToken:(NSString *)token {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzSendEvent;
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='send' props='token: %@'/>",token];
	[instance autorelease];
	return instance;
}


+ (ZoozzEvent *)buyWithProduct:(NSString *)pid {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzBuyEvent;
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='buy' props='pid: %@'/>",pid];
	[instance autorelease];
	return instance;
}

+ (ZoozzEvent *)buyWithProduct:(NSString *)pid withTransaction:(NSString*)tidfr withCurrency:(NSString *)cur withPrice:(NSDecimalNumber *)prc {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzBuyEvent;
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='buy-done' props='pidfr: %@; tidfr: %@; currency: %@; price: %1.2f'/>",pid,tidfr,cur,[prc doubleValue]];
	[instance autorelease];
	return instance;
}

+ (ZoozzEvent *)notificationWithAction:(ZoozzNotificationActionType)action inView:(ZoozzViewType)view inSection:(NSUInteger)sec subSection:(NSUInteger)sub withIdentifier:(NSString*)nid {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzNotificationEvent;
	
	switch (view) {
		case ZoozzViewKeyboard:
			instance.eventMsg = [NSString stringWithFormat:@"<e msg='%@' props='scr: k; sec: %u; pg: %u; nid: %@; source: in'/>",getZoozzNotificationAction(action),sec,sub, nid];
			break;
		case ZoozzViewGallery:
			instance.eventMsg = [NSString stringWithFormat:@"<e msg='%@' props='scr: g; sec: %u; pg: %u; nid: %@; source: in'/>",getZoozzNotificationAction(action),sec,sub, nid];
			
			break;
	}
	
	[instance autorelease];
	return instance;
}

+ (ZoozzEvent *)notificationWithAction:(ZoozzNotificationActionType)action inView:(ZoozzViewType)view withIdentifier:(NSString*)nid
 {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzNotificationEvent;
	
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='%@' props='scr: %c; nid: %@; source: in'/>",getZoozzNotificationAction(action),getZoozzViewChar(view), nid];
	
	[instance autorelease];
	return instance;
}

+ (ZoozzEvent *)notificationWithAction:(ZoozzNotificationActionType)action withIdentifier:(NSString*)nid {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzNotificationEvent;
	
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='%@' props='nid: %@; source: ex'/>",getZoozzNotificationAction(action), nid];
	
	[instance autorelease];
	return instance;
}

+ (ZoozzEvent *)notificationRecieved {
	ZoozzEvent *instance = [[self alloc] init];
	instance.eventType = ZoozzNotificationEvent;
	
	instance.eventMsg = [NSString stringWithFormat:@"<e msg='%@' props='source: ex'/>",getZoozzNotificationAction(ZoozzNotificationActionRecieved)];
	
	[instance autorelease];
	return instance;
}



- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self != nil) {
		self.eventMsg = [coder decodeObjectForKey:@"eventMsg"];
		self.eventType = [coder decodeIntegerForKey:@"eventType"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.eventMsg forKey:@"eventMsg"];
	[coder encodeInteger:self.eventType forKey:@"eventType"];
}

- (void)dealloc {
	[eventMsg release];
	
	[super dealloc];
}
@end
