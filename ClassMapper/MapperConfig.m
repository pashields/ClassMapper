//
//  MapperConfig.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
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
#import "MapperConfig.h"
/* Reflection */
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

@interface MapperConfig ()
@property(nonatomic, strong)NSMutableDictionary *mutableClassMappings;
@property(nonatomic, strong)NSMutableDictionary *mutablePropNameMappings;
@property(nonatomic, strong)NSMutableDictionary *preProcBlockMappings;
@property(nonatomic, strong)NSMutableDictionary *postProcBlockMappings;
@end

@implementation MapperConfig
#pragma mark singleton
+ (MapperConfig *)sharedInstance {
    static MapperConfig *instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MapperConfig new];
    });
    return instance;
}

#pragma mark class
- (id)init {
    self = [super init];
    if (self) {
        [self clearConfig];
    }
    
    return self;
}
- (void)mapKey:(NSString *)key toClass:(Class)class {
    [self.mutableClassMappings setObject:class forKey:key];
}
- (NSDictionary *)classMappings {
    return self.mutableClassMappings;
}
- (void)mapPropertyName:(NSString *)name toOtherName:(NSString *)other {
    [self.mutablePropNameMappings setObject:name forKey:other];
    [self.mutablePropNameMappings setObject:other forKey:name];
}
- (NSDictionary *)propertyMappings {
    return self.mutablePropNameMappings;
}
- (void)clearConfig {
    self.mutableClassMappings = [NSMutableDictionary dictionary];
    self.mutablePropNameMappings = [NSMutableDictionary dictionary];
    self.preProcBlockMappings = [NSMutableDictionary dictionary];
    self.postProcBlockMappings = [NSMutableDictionary dictionary];
}
- (Class)classFromKey:(NSString *)key {
    return [self.mutableClassMappings objectForKey:key] != nil ? 
    [self.mutableClassMappings objectForKey:key] :
    nil;
}
- (void)preProcBlock:(id (^)(id))block forPropClass:(Class)class {
    [self.preProcBlockMappings setValue:block
                              forKey:NSStringFromClass(class)];
}
- (void)postProcBlock:(id (^)(id))block forPropClass:(Class)class {
    [self.postProcBlockMappings setValue:block
                                  forKey:NSStringFromClass(class)];
}
- (id)preProcessProperty:(id)property ofClass:(Class)class {
    return [self processProperty:property ofClass:class withBlockDict:self.preProcBlockMappings];
}
- (id)postProcessProperty:(id)property ofClass:(Class)class {
    return [self processProperty:property ofClass:class withBlockDict:self.postProcBlockMappings];
}
- (id)processProperty:(id)property ofClass:(Class)class withBlockDict:(NSDictionary *)blockDict {
    id (^block)(id);
    NSString *classString = NSStringFromClass(class);
    
    if (EXACT_CLASS_MATCH) {
        block = [blockDict objectForKey:classString];
        if (block) {
            property = block(property);
        }
    } else {
        for (NSString *blockClassString in [blockDict allKeys]) {
            Class blockClass = objc_getClass([blockClassString cStringUsingEncoding:NSUTF8StringEncoding]);
            if ([class isSubclassOfClass:blockClass] || 
                [classString isEqualToString:blockClassString]) {
                block = [blockDict objectForKey:blockClassString];
                property = block(property);
            }
        }
    }
    
    return property;
}

#pragma mark protected
/* Give us the mapped key, else the original */
- (NSString *)_trueKey:(NSString *)key {
    NSString *potKey = [self.mutablePropNameMappings objectForKey:key];
    return potKey ? potKey : key;
}
@end
