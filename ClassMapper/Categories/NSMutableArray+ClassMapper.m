//
//  NSMutableArray+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 1/25/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import "NSMutableArray+ClassMapper.h"
#import "NSNumber+ClassMapper.h"
#import "MapperConfig.h"
#import "ClassMapper.h"
#define FIRST_NOT_NULL(x,y,z,a) (x?x:(y?y:(z?z:a)))

@implementation NSMutableArray (ClassMapper)
/* Class determination rules:
 - If the array is not empty, we will look at the class of an 
   element in the array and assume that is the class.
 - If the class passed in the withClass arg is not NSArray, we will use that.
 - Otherwise, we will default to the type of the serialized data.
 */
- (NSMutableArray *)_cm_update_with:(NSArray *)serialized withClass:(Class)class {
    Class instanceClass;
    if (!class && [self count] > 0) {
        instanceClass = [[self lastObject] class];
    }
    [self removeAllObjects];
    for (id cereal in serialized) {
        /* Generally, we want to chain class types. If someone has clearly specified
           the type of the container, however, we want to break the chain. */
        if ([class isSubclassOfClass:[NSArray class]]) {
            class = nil;
        }
        class = FIRST_NOT_NULL(instanceClass, class, [cereal class], nil);
        [self addObject:[ClassMapper deserialize:cereal toClass:class]];
    }
    
    return self;
}
@end
