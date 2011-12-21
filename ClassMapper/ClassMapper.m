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
    NSMutableSet *propSet = [NSMutableSet set];
    for (int i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        [propSet addObject:[NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding]];
    }
    
    for (NSString *key in [dict allKeys]) {
        if (![propSet containsObject:key]) {
            [NSException raise:@"Property does not exist" 
                        format:@"Property %@ does not exist in class %@, but is found in source object %@",
             key, classType, dict];
        }
        id val = [dict objectForKey:key];
        /* Key is an array, recursive search for nested objects */
        if ([val isKindOfClass:[NSArray class]]) {
            for (int i=0; i<[val count]; i++) {
                if ([[val objectAtIndex:i] isKindOfClass:[NSMutableDictionary class]]) {
                    [val replaceObjectAtIndex:i withObject:[ClassMapper _dict:[val objectAtIndex:i] toMappedName:key]];
                }
            }
        } 
        /* Key is a subobject */
        else if ([val isKindOfClass:[NSDictionary class]]) {
            val = [ClassMapper _dict:val toMappedName:key];
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
+ (NSDictionary*)objToDict:(id)object {
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    NSMutableSet *propSet = [NSMutableSet set];
    for (int i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        [propSet addObject:[NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding]];
    }
    
    return [object dictionaryWithValuesForKeys:[propSet allObjects]];
}
+ (NSArray*)objsToDictArray:(NSArray*)objs {
    NSMutableArray *dicts = [NSMutableArray arrayWithCapacity:[objs count]];
    for (id obj in objs) {
        [dicts addObject:[ClassMapper objToDict:obj]];
    }
    return dicts;
}

#pragma mark private
+ (id)_dict:(NSDictionary *)dict toMappedName:(NSString*)key {
    MapperConfig *config = [MapperConfig sharedInstance];
    
    Class subClass = [config.mappings objectForKey:key];
    return [ClassMapper dict:dict toClass:subClass];
}
@end
