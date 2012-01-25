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

@interface MapperConfig ()
@property(nonatomic, strong)NSMutableDictionary *classMappings;
@property(nonatomic, strong)NSMutableDictionary *propNameMappings;
@end

@implementation MapperConfig
@synthesize classMappings=classMappings_;
@synthesize propNameMappings=propNameMappings_;

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
    [self.classMappings setObject:class forKey:key];
}
- (NSDictionary *)classMappings {
    return classMappings_;
}
- (void)mapPropertyName:(NSString *)name toOtherName:(NSString *)other {
    [self.propNameMappings setObject:name forKey:other];
    [self.propNameMappings setObject:other forKey:name];
}
- (NSDictionary *)propertyMappings {
    return propNameMappings_;
}
- (void)clearConfig {
    self.classMappings = [NSMutableDictionary dictionary];
    self.propNameMappings = [NSMutableDictionary new];
}
- (Class)classFromKey:(NSString *)key {
    return [self.classMappings objectForKey:key] != nil ? 
    [self.classMappings objectForKey:key] :
    nil;
}

#pragma mark protected
/* Give us the mapped key, else the original */
- (NSString *)_trueKey:(NSString *)key {
    NSString *potKey = [self.propNameMappings objectForKey:key];
    return potKey ? potKey : key;
}
@end
