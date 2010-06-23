//
//  Section.h
//  IMBooster
//
//  Created by Roee Kremer on 11/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Section : NSObject {
	NSMutableArray *categories;
	NSMutableArray *assets;
	
}

@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) NSMutableArray *assets;

@end
