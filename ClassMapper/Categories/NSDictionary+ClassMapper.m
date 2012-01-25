//
//  NSDictionary+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "NSDictionary+ClassMapper.h"
#import "MapperConfig.h"

@implementation NSDictionary (ClassMapper)
- (NSDictionary *)_cm_serialize {
    NSMutableDictionary *copy = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    for (NSString *key in [self allKeys]) {
        id<Serializable> val = [self objectForKey:key];
        [copy setValue:[val _cm_serialize] forKey:key];
    }
    
    return copy;
}
+ (NSDictionary *)_cm_inst_from:(NSDictionary *)serialized withClass:(Class)class {
    return [[NSMutableDictionary new] _cm_update_with:serialized withClass:class];
}
@end
