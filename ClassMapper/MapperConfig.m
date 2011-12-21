//
//  MapperConfig.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MapperConfig.h"
@interface MapperConfig ()
@property(nonatomic, retain)NSMutableDictionary *nameMappings;
@end

@implementation MapperConfig
@synthesize nameMappings=mappings_;

#pragma mark singleton
+ (MapperConfig*)sharedInstance {
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
        self.nameMappings = [NSMutableDictionary dictionary];
    }
    
    return self;
}
- (void)mapKey:(NSString*)key toClass:(Class)class {
    [self.nameMappings setObject:class forKey:key];
}
- (NSDictionary*)mappings {
    return self.nameMappings;
}
- (void)clearMappings {
    self.nameMappings = [NSMutableDictionary dictionary];
}
@end
