//
//  ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "ClassMapper.h"
@interface ClassMapper ()
+ (NSArray*)handleArray:(NSArray*)val withKey:(NSString*)key;
+ (id)handleDictionary:(NSDictionary*)val withAttributeClass:(Class)attrClass andKeyClass:(Class)keyClass;
+ (Class)classFromKey:(NSString*)key;
+ (Class)classFromAttribute:(NSString*)attr;
+ (BOOL)descClass:(Class)desc isKindOf:(Class)parent;
@end
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
    
    /* Run preproc. Does nothing by default */
    dict = [MapperConfig sharedInstance].preProcBlock(dict);
    
    /* Note any missing keys */
    NSArray *dictKeys = [dict allKeys];
    NSArray *classKeys = [propToAttr allKeys];
    if (LOG_KEY_MISSING) {
        for (NSString *key in classKeys) {
            if (![dictKeys containsObject:key]) {
                NSLog(@"Property %@ does not exist in dictionary %@, but is found in class %@",
                      key, dict, classType);
            }
        }
    }
    
    /* key is strong so we can swap it if need be */
    for (__strong NSString *key in [dict allKeys]) {
        /* The value */
        id val = [dict objectForKey:key];
        /* Update the key according to config, might swap */
        key = [[MapperConfig sharedInstance] _trueKey:key];
        
        /* Check if key is in source object only */
        if (![classKeys containsObject:key]) {
            if (LOG_KEY_MISSING) {
                NSLog(@"Property %@ does not exist in class %@, but is found in source object %@",
                      key, classType, dict);
            }
            continue;
        }
        
        /* Key is an array, recursive search for nested objects */
        if ([ClassMapper descClass:[val class] isKindOf:[NSArray class]]) {
            val = [ClassMapper handleArray:val withKey:key];
        } 
        /* Key is a subobject or an NSDictionary. Don't care as both are KVC. */
        else if ([ClassMapper descClass:[val class] isKindOf:[NSDictionary class]]) {
            /* The class of the property */
            Class attributeClass = [ClassMapper classFromAttribute:[propToAttr objectForKey:key]];
            Class keyClass = [ClassMapper classFromKey:key];
            val = [ClassMapper handleDictionary:val withAttributeClass:attributeClass andKeyClass:keyClass];
        } 
        /* Otherwise make a copy, in case this is mutable */
        else {
            val = [val copy];
        }
        [obj setValue:val forKey:key];
    }
    return obj;
}

+ (NSArray*)handleArray:(NSArray*)val withKey:(NSString*)key {
    /* Create a new array so as not to mutate the obj */
    NSMutableArray *deserialized = [NSMutableArray arrayWithCapacity:[val count]];
    [val enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        /* Use key->class mapping to attempt to resolve type */
        Class arrayObjClass = [ClassMapper classFromKey:key];
        if ([ClassMapper descClass:[obj class] isKindOf:[NSDictionary class]]) {
            if (arrayObjClass && (arrayObjClass != [NSDictionary class])) {
                /* Array is full of a resolvable type based on key->class mapping */
                [deserialized addObject:[ClassMapper dict:obj toClass:arrayObjClass]];
            } else {
                [deserialized addObject:[ClassMapper handleDictionary:obj withAttributeClass:[NSDictionary class] andKeyClass:nil]];
            }
        } else if ([ClassMapper descClass:[obj class] isKindOf:[NSDictionary class]]) {
            [deserialized addObject:[ClassMapper handleDictionary:obj withAttributeClass:arrayObjClass andKeyClass:nil]];
        } else {
            /* Type of objs in array cannot be resolved, pass along the dictionaries */
            [deserialized addObject:obj];
        }
    }];
    return deserialized;
}

+ (id)handleDictionary:(NSDictionary*)val withAttributeClass:(Class)attrClass andKeyClass:(Class)keyClass {
    Class winnerClass = attrClass ? attrClass : keyClass;
    if (winnerClass && ![ClassMapper descClass:winnerClass isKindOf:[NSDictionary class]]) {
        return [ClassMapper dict:val toClass:winnerClass];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[val count]];
    [val enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        Class classOfKey = [ClassMapper classFromKey:key];
        if ([ClassMapper descClass:[obj class] isKindOf:[NSDictionary class]]) {
            [dict setValue:[ClassMapper handleDictionary:obj 
                                      withAttributeClass:nil 
                                             andKeyClass:classOfKey]
                            forKey:key];
        } else if ([ClassMapper descClass:[obj class] isKindOf:[NSArray class]]) {
            [dict setValue:[ClassMapper handleArray:obj withKey:key] forKey:key];
        } else {
            [dict setValue:obj forKey:key];
        }
    }];
    
    return dict;
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
+ (Class)classFromAttribute:(NSString*)attr {
    if (![attr hasPrefix:@"T@\""]) {
        [NSException raise:@"Cannot determine class of sub-object" 
                    format:@"Cannot map sub-object with format: %@", attr];
    }
    
    NSArray *components = [attr componentsSeparatedByString:@"\""];
    return NSClassFromString([components objectAtIndex:1]);
}
+ (Class)classFromKey:(NSString*)key {
    MapperConfig *config = [MapperConfig sharedInstance];
    
    return [config.classMappings objectForKey:key] != nil ? 
           [config.classMappings objectForKey:key] :
           nil;
}
+ (BOOL)descClass:(Class)desc isKindOf:(Class)parent {
    Class current = desc;
    Class last = current;
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
