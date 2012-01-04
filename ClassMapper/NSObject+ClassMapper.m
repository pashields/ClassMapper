//
//  NSObject+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "NSObject+ClassMapper.h"

@implementation NSObject (ClassMapper)
- (id)_cm_serialize {
    unsigned int outCount;
    NSMutableSet *propSet = [NSMutableSet set];
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        [propSet addObject:[NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding]];
    }
    
    NSMutableDictionary *serialized = [NSMutableDictionary dictionaryWithCapacity:outCount];
    
    for (NSString *propName in propSet) {
        id<Serializable> prop = [self valueForKey:propName];
        [serialized setValue:[prop _cm_serialize] forKey:propName];
    }
    
    return serialized;
}
@end
