//
//  MapperConfig.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "MapperConfig.h"

#define DEFAULT_PREPROC ^(NSDictionary* dict) {return dict;}

@interface MapperConfig ()
@property(nonatomic, retain)NSMutableDictionary *nameMappings;
@end

@implementation MapperConfig
@synthesize nameMappings=mappings_;
@synthesize preProcBlock=preProcBlock_;

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
        self.preProcBlock = DEFAULT_PREPROC;
    }
    
    return self;
}
- (void)mapKey:(NSString*)key toClass:(Class)class {
    [self.nameMappings setObject:class forKey:key];
}
- (NSDictionary*)mappings {
    return self.nameMappings;
}
- (void)clearConfig {
    self.nameMappings = [NSMutableDictionary dictionary];
    self.preProcBlock = DEFAULT_PREPROC;
}
@end
