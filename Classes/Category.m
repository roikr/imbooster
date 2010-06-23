//
//  Category.m
//  IMBooster
//
//  Created by Roee Kremer on 11/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Category.h"

@implementation Category

@synthesize assets;

- (id)init {
	if (self = [super init]) {
		self.assets = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc
{
	[assets release];
	[super dealloc];
}

 

@end
