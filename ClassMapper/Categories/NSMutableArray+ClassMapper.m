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

@implementation NSMutableArray (ClassMapper)
- (NSMutableArray *)_cm_update_with:(NSArray *)serialized withClass:(Class)class {
    [self removeAllObjects];
    for (id cereal in serialized) {
        class = class ? class : [cereal class];
        [self addObject:[ClassMapper deserialize:cereal toClass:class]];
    }
    
    return self;
}
@end
