//
//  Section.m
//  IMBooster
//
//  Created by Roee Kremer on 11/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Section.h"


@implementation Section

@synthesize categories;
@synthesize assets;

- (id)init {
	if (self = [super init]) {
		self.categories = [NSMutableArray array];
		self.assets = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc
{
	[categories release];
	[assets release];
	[super dealloc];
}



@end
