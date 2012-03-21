//
//  NSObject+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "NSObject+ClassMapper.h"
#import "MapperConfig.h"
#import "ClassMapper.h"
/* Reflection */
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

@interface NSObject ()
+ (Class)classFromAttribute:(NSString *)attr withKey:(NSString *)key;
+ (Class)classWithAttributeClass:(Class)attrClass andAttrKey:(NSString *)key;
@end
@implementation NSObject (ClassMapper)
- (NSDictionary *)_cm_serialize {
    NSDictionary *propToAttr = [self _cm_properties];
    
    NSMutableDictionary *serialized = [NSMutableDictionary dictionaryWithCapacity:[propToAttr count]];
    
    /* propName is strong in case we need to change it */
    for (__strong NSString *propName in propToAttr) {
        id<Serializable> prop = [self valueForKey:propName];
        Class propClass = [NSObject classFromAttribute:[propToAttr objectForKey:propName]
                                               withKey:propName];
        prop = [[MapperConfig sharedInstance] postProcessProperty:prop
                                                          ofClass:propClass];
        propName = [[MapperConfig sharedInstance] _trueKey:propName];
        [serialized setValue:[prop _cm_serialize] forKey:propName];
    }
    
    return serialized;
}
- (NSDictionary *)_cm_properties {
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableDictionary *propToAttr = [NSMutableDictionary dictionary];
    for (int i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propName = [NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
        NSString *propAttr = [NSString stringWithCString:property_getAttributes(property) encoding:NSASCIIStringEncoding];
        [propToAttr setValue:propAttr forKey:propName];
    }
    
    free(properties);
    
    return propToAttr;
}
- (NSObject *)_cm_update_with:(NSDictionary *)serialized withClass:(Class)class {
    NSDictionary *propToAttr = [self _cm_properties];
    /* All property keys for the instance */
    NSArray *classKeys = [propToAttr allKeys];
    
    /* key is strong so we can swap it if need be */
    for (__strong NSString *key in serialized) {
        /* The value */
        id val = [serialized objectForKey:key];
        /* Update the key according to config, might swap */
        key = [[MapperConfig sharedInstance] _trueKey:key];

        /* Check if key is in source object only */
        if (![classKeys containsObject:key]) {
            if (LOG_KEY_MISSING) {
                NSLog(@"Property %@ does not exist in class %@, but is found in source object %@",
                      key, [self class], serialized);
            }
            continue;
        }
        
        /* Get class specified by property */
        Class propClass = [NSObject classFromAttribute:[propToAttr objectForKey:key] withKey:key];
        /* Update val if we have a preproc block */
        val = [[MapperConfig sharedInstance] preProcessProperty:val
                                                        ofClass:propClass];
        
        /* Create the instance, by Mappable protocol if possible */
        if (![self valueForKey:key]) {            
            Class toClass = [NSObject classWithAttributeClass:propClass andAttrKey:key];
            
            [self setValue:[ClassMapper deserialize:val toClass:toClass]
                    forKey:key];
        } else {
            /* Update existing instance */
            id subInst = [self valueForKey:key];
            [self setValue:[subInst _cm_update_with:val withClass:[[MapperConfig sharedInstance] classFromKey:key]] 
                    forKey:key];
        }
    }
    
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+ (Class)classFromAttribute:(NSString *)attr withKey:(NSString *)key {
    if ([attr hasPrefix:@"T@,"]) {
        if (LOG_ID_OBJ) {
            NSLog(@"Warning: Property %@ appears to be of type id", key);
        }
        return [NSObject class];
    } else if (![attr hasPrefix:@"T@\""]) {
        [NSException raise:@"Cannot determine class of sub-object" 
                    format:@"Cannot map sub-object with format: %@", attr];
    }
    
    NSArray *components = [attr componentsSeparatedByString:@"\""];
    return NSClassFromString([components objectAtIndex:1]);
}

+ (Class)classWithAttributeClass:(Class)attrClass andAttrKey:(NSString *)key {
    if ([attrClass isSubclassOfClass:[NSArray class]]) {
        return [[MapperConfig sharedInstance] classFromKey:key];
    } else {
        return attrClass;
    }
}
#pragma clang diagnostic pop
@end
