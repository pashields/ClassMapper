//
//  Mappable.h
//  ClassMapper
//
//  Created by Patrick Shields on 1/26/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 The `Mappable` protocol must be implemented by any class that wants custom deserialization.
 
 This should only be necessary for non-kvc compliant classes.
 */
@protocol Mappable
@optional
/**
 Called when this instance should be updated with new data. This should mutate the instance.
 
 @param serialized The serialized data that should be used to fill the instance.
 @param class A class hint. This can be used in cases where the class is ambiguous, such as filling a collection.
 
 @return the updated instance.
 */
- (id)_cm_update_with:(id)serialized withClass:(Class)class;
/**
 Called when a new instance of class must be created using the serialized data.
 
 @param serialized The serialized data that the new instance will contain.
 @param class A class hint. This can be used in cases where the class is ambiguous, such as filling a collection.
 
 @return the new instance.
 */
+ (id)_cm_inst_from:(id)serialized withClass:(Class)class;
@end
