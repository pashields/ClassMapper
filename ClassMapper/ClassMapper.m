//
//  ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "ClassMapper.h"
#import "MapperConfig.h"
/* Reflection */
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

@implementation ClassMapper
#pragma mark deserialize
+ (id)deserialize:(id)serialized toInstance:(id)instance {
    return [instance _cm_update_with:serialized withClass:nil];
}

+ (id)deserialize:(id)serialized toClass:(Class)classType {
    /* Generally we want to treat class information at the collection level
       if the collection is not pair oriented. Dicitionaries sort of lie
       about the fast enumeration (you just get keys), so we explicitly
       throw them out. But otherwise, this makes it a lot easier to do
       something like use a set.
     */
    if (![serialized isKindOfClass:[NSDictionary class]] &&
        [serialized conformsToProtocol:@protocol(NSFastEnumeration)]) {
        return [NSArray _cm_inst_from:serialized withClass:classType];
    } else if ([classType respondsToSelector:@selector(_cm_inst_from:withClass:)]) {
        return [classType _cm_inst_from:serialized withClass:classType];
    } else {
        return [[classType new] _cm_update_with:serialized withClass:classType];
    }
}

#pragma mark serialize
+ (id)serialize:(id<Serializable>)object {
    return [object _cm_serialize];
}

#pragma mark helper
/*
 * This method functions similarly to isKindOfClass, but on class objects.
 */
+ (BOOL)_descClass:(Class)desc isKindOf:(Class)parent {
    Class current = desc;
    Class last;
    do {
        if (current == parent) {
            return true;
        }
        last = current;
        current = class_getSuperclass(current);
    } while (last != current);
    return FALSE;
}
@end
