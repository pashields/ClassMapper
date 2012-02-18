//
//  ClassMapper.h
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>
/* Categories */
#import "NSString+ClassMapper.h"
#import "NSNumber+ClassMapper.h"
#import "NSArray+ClassMapper.h"
#import "NSDictionary+ClassMapper.h"
#import "NSObject+ClassMapper.h"
#import "NSMutableArray+ClassMapper.h"
#import "NSMutableDictionary+ClassMapper.h"
#import "NSNull+ClassMapper.h"

#define LOG_KEY_MISSING NO
#define LOG_ID_OBJ YES
@protocol Serializable;
@protocol Mappable;

@interface ClassMapper : NSObject
/* 
 * Updates an existing Key Value Compliant (KVC) object
 * with new serialized data. The serialized data must be inside
 * a collection that implements the complete mappable interface.
 */
+ (id)deserialize:(id<Mappable>)serialized toInstance:(id)instance;
/*
 * In general, this is a shorthand for creating a new instance and
 * then deserializing it using the above. In the case the serialized
 * data is an array, this will create a new NSArray instance populated
 * with objects of class classType.
 */
+ (id)deserialize:(id<Mappable>)serialized toClass:(Class)classType;
/*
 * Converts an object to a JSON-compatible dictionary. Requires the
 * object to implement the serializable protocol, or be KVC compliant.
 */
+ (id)serialize:(id<Serializable>)obj;
#pragma mark protected
+ (BOOL)_descClass:(Class)desc isKindOf:(Class)parent;
@end
