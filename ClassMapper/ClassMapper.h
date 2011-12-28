//
//  ClassMapper.h
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>
#import "MapperConfig.h"

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
 * object's class to follow KVC conventions.
 */
+ (NSDictionary*)objToDict:(id)object;
/*
 * Converts an arrays of objects to an array of JSON-compatible
 * dictionaries. Requires the objects to follow KVC conventions.
 */
+ (NSArray*)objsToDictArray:(NSArray*)objs;

#pragma mark private
+ (Class)_classFromKey:(NSString*)key;
+ (Class)_classFromAttribute:(NSString*)attr;
@end
