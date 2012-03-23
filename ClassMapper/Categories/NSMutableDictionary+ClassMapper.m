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
#import "ClassMapper.h"
#define FIRST_NOT_NULL(x,y,z,a) (x?x:(y?y:(z?z:a)))

@implementation NSMutableDictionary (ClassMapper)
/* Class determination rules for any given k/v pair:
 - If the key has been mapped to a class explicitly using MapperConfig, we will use that class.
 - If the dict is not empty, we will look at an element of the dictionary and use the class of
   that element.
 - Otherwise, we will default to the type of the serialized data.
 */
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
                                   instanceClass, [cereal class], nil);
            
            /* Pass the buck up to main classmapper to handle arrays */
            id obj = [ClassMapper deserialize:cereal toClass:class];
            [self setValue:obj forKey:key];
        }
    }
    return self;
}
@end
