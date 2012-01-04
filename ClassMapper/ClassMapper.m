//
//  ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClassMapper.h"

@implementation ClassMapper
#pragma mark deserialize
+ (id)dict:(NSDictionary*)dict toClass:(Class)classType {
    NSObject *obj = [classType new];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(classType, &outCount);
    NSMutableDictionary *propToAttr = [NSMutableDictionary dictionary];
    for (int i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propName = [NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
        NSString *propAttr = [NSString stringWithCString:property_getAttributes(property) encoding:NSASCIIStringEncoding];
        [propToAttr setValue:propAttr forKey:propName];
    }
    
    for (NSString *key in [dict allKeys]) {
        if (![[propToAttr allKeys] containsObject:key]) {
            [NSException raise:@"Property does not exist" 
                        format:@"Property %@ does not exist in class %@, but is found in source object %@",
             key, classType, dict];
        }
        id val = [dict objectForKey:key];
        /* Key is an array, recursive search for nested objects */
        if ([val isKindOfClass:[NSArray class]]) {
            /* Create a new array so as not to mutate the obj */
            NSMutableArray *deserialized = [NSMutableArray arrayWithCapacity:[val count]];
            [val enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                /* Use key->class mapping to attempt to resolve type */
                Class arrayObjClass = [ClassMapper _classFromKey:key];
                if ([obj isKindOfClass:[NSDictionary class]] &&
                    (arrayObjClass != [NSDictionary class])) {
                    /* Array is full of a resolvable type based on key->class mapping */
                    [deserialized addObject:[ClassMapper dict:obj toClass:arrayObjClass]];
                } else {
                    /* Type of objs in array cannot be resolved, pass along the dictionaries */
                    [deserialized addObject:obj];
                }
            }];
            val = deserialized;
        } 
        /* Key is a subobject */
        else if ([val isKindOfClass:[NSDictionary class]]) {
            val = [ClassMapper dict:val toClass:[ClassMapper _classFromAttribute:[propToAttr objectForKey:key]]];
        }
        [obj setValue:val forKey:key];
    }
    return obj;
}
+ (NSArray*)dictArray:(NSArray*)dicts toClass:(Class)classType {
    NSMutableArray *objs = [NSMutableArray arrayWithCapacity:[dicts count]];
    for (NSDictionary *dict in dicts) {
        [objs addObject:[ClassMapper dict:dict toClass:classType]];
    }
    return objs;
}

#pragma mark serialize
+ (id)serialize:(id<Serializable>)object {
    return [object _cm_serialize];
}

#pragma mark private
+ (Class)_classFromAttribute:(NSString*)attr {
    if (![attr hasPrefix:@"T@\""]) {
        [NSException raise:@"Cannot determine class of sub-object" 
                    format:@"Cannot map sub-object with format: %@", attr];
    }
    
    NSArray *components = [attr componentsSeparatedByString:@"\""];
    return NSClassFromString([components objectAtIndex:1]);
}
+ (Class)_classFromKey:(NSString*)key {
    MapperConfig *config = [MapperConfig sharedInstance];
    
    return [config.mappings objectForKey:key] != nil ? 
           [config.mappings objectForKey:key] :
           [NSDictionary class];
}
@end
