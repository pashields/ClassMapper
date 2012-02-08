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
- (NSMutableArray *)_cm_update_with:(NSArray *)serialized withClass:(Class)class {
    Class instanceClass;
    if (!class && [self count] > 0) {
        instanceClass = [[self lastObject] class];
    }
    [self removeAllObjects];
    for (id cereal in serialized) {
        class = FIRST_NOT_NULL(instanceClass, class, [cereal class], nil);
        [self addObject:[ClassMapper deserialize:cereal toClass:class]];
    }
    
    return self;
}
@end
