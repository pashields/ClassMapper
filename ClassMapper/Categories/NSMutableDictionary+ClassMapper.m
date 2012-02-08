//
//  NSMutableDictionary+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 1/26/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import "NSMutableDictionary+ClassMapper.h"
#import "NSNumber+ClassMapper.h"
#import "MapperConfig.h"
#define FIRST_NOT_NULL(x,y,z,a) (x?x:(y?y:(z?z:a)))

@implementation NSMutableDictionary (ClassMapper)
- (NSDictionary *)_cm_update_with:(NSDictionary *)serialized withClass:(Class)class {
    /* Because of class clusters, we have to handle both the mutable and immutable cases here */
    if ([self classForCoder] == [NSDictionary class]) {
        for (NSString *key in serialized) {
            id instance = [self valueForKey:key];
            [instance _cm_update_with:[serialized objectForKey:key] 
                            withClass:[[MapperConfig sharedInstance] classFromKey:key]];
        }
    } else {
        Class instanceClass;
        if (!class && [self count] > 0) {
            instanceClass = [[self objectForKey:[[self allKeys] lastObject]] class];
        }
        [self removeAllObjects];
        for (NSString *key in serialized) {
            id cereal = [serialized objectForKey:key];
            class = FIRST_NOT_NULL([[MapperConfig sharedInstance] classFromKey:key], 
                                   instanceClass, [cereal class], class);
            
            id obj;
            if ([class respondsToSelector:@selector(_cm_inst_from:withClass:)]) {
                obj = [class _cm_inst_from:cereal withClass:class];
            } else {
                obj = [[class new] _cm_update_with:cereal withClass:class];
            }
            [self setValue:obj forKey:key];
        }
    }
    return self;
}
@end
