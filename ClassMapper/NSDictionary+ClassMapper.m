//
//  NSDictionary+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+ClassMapper.h"

@implementation NSDictionary (ClassMapper)
- (id)_cm_serialize {
    NSMutableDictionary *copy = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    for (NSString *key in [self allKeys]) {
        id<Serializable> val = [self objectForKey:key];
        [copy setValue:[val _cm_serialize] forKey:key];
    }
    
    return copy;
}
@end
