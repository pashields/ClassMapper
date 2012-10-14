//
//  ClassMapper.h
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
#define RUN_CONCURRENT 1

#if RUN_CONCURRENT == 0
#define CM_SAFE_WRITE_SETUP(queueName)
#define CM_SAFE_WRITE(queueName, write) write
#define CM_SAFE_WRITE_TEARDOWN(queueName)
#elif RUN_CONCURRENT == 1
#define CM_SAFE_WRITE_SETUP(queueName) dispatch_queue_t queueName = dispatch_queue_create(NULL, 0);
#define CM_SAFE_WRITE(queueName, write) dispatch_sync(queueName, ^{write;});
#define CM_SAFE_WRITE_TEARDOWN(queueName) dispatch_release(queueName);
#endif

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
 Creates a new instance of a class and populates it with the data from the serialized object asynchronously.
 
 In general, this is a shorthand for creating a new instance and then deserializing it using the above. In the case the serialized data is an array, this will create a new NSArray instance populated with objects of class classType.
 
 @param serialized A serialized representation of the object.
 @param classType The class of the destination object.
 @param completionBlock A block that will be called (on the main thread) with the deserialized object.
 */
+ (void)deserializeAsync:(id<Mappable>)serialized toClass:(Class)classType completion:(void(^)(id deserialized))completionBlock;

/**
 Converts an object to a JSON-compatible dictionary.
 
 Requires the object to implement the serializable protocol, or be KVC compliant.
 
 @param obj The object to be deserialized.
 
 @return the serialized representation of the object.
 */
+ (id)serialize:(id<Serializable>)obj;

/**
 Converts an object to a JSON-compatible dictionary asynchronously.
 
 Requires the object to implement the serializable protocol, or be KVC compliant.
 
 @param obj The object to be deserialized.
 @param completionBlock A block that will be called (on the main thread) with the serialized representation of the object.
 */
+ (void)serializeAsync:(id<Serializable>)obj completion:(void(^)(id serialized))completionBlock;
@end
