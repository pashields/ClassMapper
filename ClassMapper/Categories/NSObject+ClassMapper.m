//
//  NSObject+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2012, Patrick Shields
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  The names of its contributors may not be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
        
        if ([MapperConfig sharedInstance].includeNullValues && prop == nil) {
            prop = [NSNull null];
        }
        
        [serialized setValue:[ClassMapper serialize:prop] forKey:propName];
    }
    
    return serialized;
}
- (NSDictionary *)_cm_properties {
    NSMutableDictionary *propToAttr = [NSMutableDictionary dictionary];
    Class currentClass = [self class];
    while (currentClass != [NSObject class]) {
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList(currentClass, &outCount);
        for (int i=0; i<outCount; i++) {
            objc_property_t property = properties[i];
            NSString *propName = [NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
            NSString *propAttr = [NSString stringWithCString:property_getAttributes(property) encoding:NSASCIIStringEncoding];
            [propToAttr setValue:propAttr forKey:propName];
        }
        
        free(properties);
        currentClass = [currentClass superclass];
    }
    
    return propToAttr;
}
- (NSObject *)_cm_update_with:(NSDictionary *)serialized withClass:(Class)class {
    NSDictionary *propToAttr = [self _cm_properties];
    /* All property keys for the instance */
    NSArray *classKeys = [propToAttr allKeys];
    
    CM_SAFE_WRITE_SETUP(queue)
    
    NSEnumerationOptions options = RUN_CONCURRENT ? NSEnumerationConcurrent : 0;
    [serialized enumerateKeysAndObjectsWithOptions:options
                                        usingBlock:^(id preKey, id preVal, BOOL *stop) {
                                            /* Update the key according to config, might swap */
                                            NSString *key = [[MapperConfig sharedInstance] _trueKey:preKey];
                                            
                                            /* Check if key is in source object only */
                                            if (![classKeys containsObject:key]) {
                                                if (LOG_KEY_MISSING) {
                                                    NSLog(@"Property %@ does not exist in class %@, but is found in source object %@",
                                                          key, [self class], serialized);
                                                }
                                                return;
                                            }
                                            
                                            /* Get class specified by property */
                                            Class propClass = [NSObject classFromAttribute:[propToAttr objectForKey:key] withKey:key];
                                            /* Update val if we have a preproc block */
                                            id val = [[MapperConfig sharedInstance] preProcessProperty:preVal
                                                                                               ofClass:propClass];
                                            
                                            /* Create the instance, by Mappable protocol if possible */
                                            id obj;
                                            if (![self valueForKey:key]) {
                                                Class toClass = [NSObject classWithAttributeClass:propClass andAttrKey:key];
                                                
                                                if (toClass == nil) { // Property is id, do not recurse
                                                    obj = val;
                                                } else {
                                                    obj = [ClassMapper deserialize:val toClass:toClass];
                                                }
                                            } else {
                                                /* Update existing instance */
                                                id subInst = [self valueForKey:key];
                                                obj = [subInst _cm_update_with:val withClass:[[MapperConfig sharedInstance] classFromKey:key]];
                                            }
                                            CM_SAFE_WRITE(queue, [self setValue:obj forKey:key];)
                                        }];
    CM_SAFE_WRITE_TEARDOWN(queue);
    
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+ (Class)classFromAttribute:(NSString *)attr withKey:(NSString *)key {
    if ([attr hasPrefix:@"T@,"]) {
        if (LOG_ID_OBJ) {
            NSLog(@"Warning: Property %@ appears to be of type id, it will not be deserialized", key);
        }
        return nil;
    } else if (![attr hasPrefix:@"T@\""]) {
        if (LOG_UNREADABLE_KEY) {
            NSLog(@"Warning: Cannot map sub-object with format: %@", attr);
        }
    }
    
    NSArray *components = [attr componentsSeparatedByString:@"\""];
    
    /* This is not an object */
    if ([components count] == 1) {
        return nil;
    }
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
