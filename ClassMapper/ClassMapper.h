//
//  ClassMapper.h
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapperConfig.h"
/* Reflection */
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>
/* Categories */
#import "NSString+ClassMapper.h"
#import "NSNumber+ClassMapper.h"
#import "NSArray+ClassMapper.h"
#import "NSDictionary+ClassMapper.h"
#import "NSObject+ClassMapper.h"

@interface ClassMapper : NSObject
/*
 * Converts a dictionary into an instance of a particular class.
 * Requires the class to follow KVC (Key-value coding) conventions.
 * Will fail if fields exist in the dict, but are not properties of the
 * class supplied by classType.
 *
 * Nested objects are handled by using the MapperConfig class to map
 * string names to class types. Nested objects can be in an array as well.
 */
+ (id)dict:(NSDictionary*)dict toClass:(Class)classType;
/*
 * Converts an array of dictionaries to an array of objects with
 * identical semantics.
 */
+ (NSArray*)dictArray:(NSArray*)dicts toClass:(Class)classType;
/*
 * Converts an object to a JSON-compatible dictionary. Requires the
 * object to implement the serializable protocol, or be KVC compliant.
 */
+ (id)serialize:(id<Serializable>)obj;

#pragma mark private
+ (Class)_classFromKey:(NSString*)key;
+ (Class)_classFromAttribute:(NSString*)attr;
@end
