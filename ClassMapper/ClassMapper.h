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
#define LOG_UNREADABLE_KEY NO
@protocol Serializable;
@protocol Mappable;

/**
 `ClassMapper` is a simple obj-c library for converting classes which follow Key-Value Coding (KVC) conventions to other objects. By convention, these objects are `Foundation` objects, such as `NSDictionary` and `NSArray`. It is highly extensible, with just enough batteries included to do your average JSON -> Model conversion. For more information, please see the `ClassMapper` [wiki on github](https://github.com/pashields/ClassMapper/wiki/).
 
 The `ClassMapper` class contains static methods that offer a convenient entry point into the library's facilities.
 */
@interface ClassMapper : NSObject
/** 
 Updates an existing Key Value Compliant (KVC) object with new serialized data. 
 
 The serialized data must be inside a collection that implements the complete mappable interface. The instance will be mutated to contain the new data.
 
 @param serialized A serialized representation of the object.
 @param instance An existing instance of the class that will be updated with the data inside `serialized`.
 
 @return the updated object.
 */
+ (id)deserialize:(id<Mappable>)serialized toInstance:(id)instance;

/**
 Creates a new instance of a class and populates it with the data from the serialized object.
 
  In general, this is a shorthand for creating a new instance and then deserializing it using the above. In the case the serialized data is an array, this will create a new NSArray instance populated with objects of class classType.
 
 @param serialized A serialized representation of the object.
 @param classType The class of the destination object.
 
 @return the deserialized object.
 */
+ (id)deserialize:(id<Mappable>)serialized toClass:(Class)classType;

/**
 Converts an object to a JSON-compatible dictionary.
 
 Requires the object to implement the serializable protocol, or be KVC compliant.
 
 @param obj The object to be deserialized.
 
 @return the serialized representation of the object.
 */
+ (id)serialize:(id<Serializable>)obj;
@end
