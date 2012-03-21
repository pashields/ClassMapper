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
    /* We can't turn null into anything else, so just return it */
    if (serialized == [NSNull null]) {
        return serialized;
    }
    
    return [instance _cm_update_with:serialized withClass:nil];
}

+ (id)deserialize:(id)serialized toClass:(Class)classType {
    /* We can't turn null into anything else, so just return it */
    if (serialized == [NSNull null]) {
        return serialized;
    }
    
    /* Generally we want to treat class information at the collection level
       if the collection is not pair oriented. Dicitionaries sort of lie
       about the fast enumeration (you just get keys), so we explicitly
       throw them out. But otherwise, this makes it a lot easier to do
       something like use a set.
     */
    if (![serialized isKindOfClass:[NSDictionary class]] &&
        [serialized conformsToProtocol:@protocol(NSFastEnumeration)]) {
        return [[serialized class] _cm_inst_from:serialized withClass:classType];
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
@end
