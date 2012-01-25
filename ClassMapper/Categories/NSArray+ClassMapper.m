//
//  NSArray+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "NSArray+ClassMapper.h"

@implementation NSArray (ClassMapper)
- (NSArray *)_cm_serialize {
    NSMutableArray *copy = [NSMutableArray arrayWithCapacity:[self count]];
    for (id<Serializable> obj in self) {
        [copy addObject:[obj _cm_serialize]];
    }
    
    return copy;
}
+ (NSArray *)_cm_inst_from:(NSArray *)serialized withClass:(Class)class {
    return [[NSMutableArray new] _cm_update_with:serialized withClass:class];
}
- (NSArray *)_cm_update_with:(NSArray *)serialized withClass:(Class)class {
    for (int i=0; i<[self count]; i++) {
        [[self objectAtIndex:i] _cm_update_with:[serialized objectAtIndex:i] withClass:class];
    }
    
    return self;
}
@end
