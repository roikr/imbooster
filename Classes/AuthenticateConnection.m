//
//  AuthenticateConnection.h
//  IMBooster
//
//  Created by Roee Kremer on 01/01/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "AuthenticateConnection.h"
#import <StoreKit/StoreKit.h>
#import "ZoozzConnection.h"
#import "IminentAppDelegate.h"
#import "LocalStorage.h"
#import "Utilities.h"



@interface AuthenticateConnection (PrivateMethods)

@end

@implementation AuthenticateConnection

@synthesize delegate;
@synthesize connection;
@synthesize transaction;


- (id) initWithTransaction:(SKPaymentTransaction *)theTransaction delegate:(id<AuthenticateConnectionDelegate>)theDelegate {
	if (self = [super init]) {
		self.delegate = theDelegate;
		self.transaction = theTransaction;
		NSString *receipt = [[NSString alloc] initWithData:encode((const uint8_t*)[[transaction transactionReceipt] bytes],[[transaction transactionReceipt] length]) encoding:NSASCIIStringEncoding];
		//ZoozzLog(@"encoded receipt: %@",receipt);
		self.connection = [[ZoozzConnection alloc] initWithRequestType:ZoozzAuthenticateTransaction withString:receipt delegate:self];
		[receipt release];
	}
	
	return self;
}

- (id) initWithProductIdentifier:(NSString *)identifier delegate:(id<AuthenticateConnectionDelegate>)theDelegate {
	if (self = [super init]) {
		self.delegate = theDelegate;
		self.connection = [[ZoozzConnection alloc] initWithRequestType:ZoozzAuthenticateTrial withString:[NSString stringWithFormat:@"(%@)",identifier] delegate:self];
	}
	
	return self;
}

- (id) initWithDelegate:(id<AuthenticateConnectionDelegate>)theDelegate {
	if (self = [super init]) {
		self.delegate = theDelegate;
		IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.connection = [[ZoozzConnection alloc] initWithRequestType:ZoozzLogin withString:appDelegate.localStorage.purchases delegate:self];
	}
	return self;
}

#pragma mark ZoozzConnection delegate methods

- (void) connectionDidFail:(ZoozzConnection *)theConnection
{	
	[self.delegate AuthenticateConnectionDidFailLoading:self];
	
	[connection release];
	self.connection = nil;
	
}


- (void) connectionDidFinish:(ZoozzConnection *)theConnection {
	
	
	NSInteger statusCode = [theConnection.theResponse statusCode];
	IminentAppDelegate *appDelegate = (IminentAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	switch (theConnection.requestType) {
		case ZoozzLogin: {
			switch (statusCode) {
				case HTTPStatusCodeOK: {
					NSString *dataString = [[NSString alloc] initWithData:theConnection.receivedData encoding:NSASCIIStringEncoding];
					ZoozzLog(@"connectionDidFinish - ZoozzLogin: %@ (%u bytes)",dataString,[theConnection.receivedData length] );
					appDelegate.localStorage.purchases = dataString;
					[dataString release];
					[appDelegate.localStorage archive];
				} break;
				case HTTPStatusCodeNoContent: {
					ZoozzLog(@"connectionDidFinish - authenticate - no purchases");
					appDelegate.localStorage.purchases = nil;
					[appDelegate.localStorage archive];
				} break;
			}
		} break;
			
		case ZoozzAuthenticateTransaction:
		case ZoozzAuthenticateTrial:
		{
			switch (statusCode) {
				case HTTPStatusCodeOK: {
					NSString *dataString = [[NSString alloc] initWithData:theConnection.receivedData encoding:NSASCIIStringEncoding];
					ZoozzLog(@"connectionDidFinish - ZoozzAuthenticateTransaction / ZoozzAuthenticateTrial: %@ (%u bytes)",dataString,[theConnection.receivedData length] );
					
					if (appDelegate.localStorage.purchases) {
						appDelegate.localStorage.purchases = [appDelegate.localStorage.purchases stringByAppendingString:@"\n"];
					} else {
						appDelegate.localStorage.purchases = @"";
					}
					
					
					appDelegate.localStorage.purchases = [appDelegate.localStorage.purchases stringByAppendingString:dataString];
					// check that new line add with the purchased cache.
					
					[dataString release];
					[appDelegate.localStorage archive];
										
				} break;
				case HTTPStatusCodeNoContent: {
					ZoozzLog(@"connectionDidFinish - ZoozzAuthenticateTransaction - purchase didn't authorized");
				} break;
			}
			
			
		} break;
	}
	
	[self.delegate AuthenticateConnectionDidFinishLoading:self];
	[connection release];
	self.connection = nil;
}





- (void)dealloc {
	//no need to release connection because it released on its delegate ?
	if (connection) {
		connection.delegate = nil;
	}
	
	[transaction release];
	
	[super dealloc];
}

@end
