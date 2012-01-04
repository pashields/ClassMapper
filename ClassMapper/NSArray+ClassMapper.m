//
//  NSArray+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+ClassMapper.h"

@implementation NSArray (ClassMapper)
- (id)_cm_serialize {
    NSMutableArray *copy = [NSMutableArray arrayWithCapacity:[self count]];
    for (id<Serializable> obj in self) {
        [copy addObject:[obj _cm_serialize]];
    }
    
    return copy;
}
@end
