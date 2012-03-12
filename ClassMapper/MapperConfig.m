//
//  MapperConfig.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "MapperConfig.h"
/* Reflection */
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

@interface MapperConfig () {
    NSMutableDictionary *classMappings_;
    NSMutableDictionary *propNameMappings_;
    NSMutableDictionary *preProcBlockMappings_;
    NSMutableDictionary *postProcBlockMappings_;
}
@property(nonatomic, strong)NSMutableDictionary *mutableClassMappings;
@property(nonatomic, strong)NSMutableDictionary *mutablePropNameMappings;
@property(nonatomic, strong)NSMutableDictionary *preProcBlockMappings;
@property(nonatomic, strong)NSMutableDictionary *postProcBlockMappings;
@end

@implementation MapperConfig
@synthesize mutableClassMappings=classMappings_;
@synthesize mutablePropNameMappings=propNameMappings_;
@synthesize preProcBlockMappings=preProcBlockMappings_;
@synthesize postProcBlockMappings=postProcBlockMappings_;

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
    id (^block)(id) = [self.preProcBlockMappings objectForKey:NSStringFromClass(class)];
    if (block) {
        return block(property);
    }
    
    return property;
}
- (id)postProcessProperty:(id)property ofClass:(Class)class {
    id (^block)(id) = [self.postProcBlockMappings objectForKey:NSStringFromClass(class)];
    if (block) {
        return block(property);
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
