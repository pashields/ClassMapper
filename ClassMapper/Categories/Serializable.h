//
//  Serializable.h
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The `Serializable` protocol must be implemented by any class that wants custom serialization.
 
 This should only be necessary for non-kvc compliant classes.
 
 @warning If the class is mutable, it is strongly reccomended that you make deep copies of data inside the class. This is not inherently necessary, but failure to do so followed by mutating the serialized instance and/or other deserialized copies will result in mutation. TL;DR; copy all instance vars.
 */
@protocol Serializable
/**
 Returns a serialized version of the instance. By convention, this will be an `NSArray` or `NSDictionary`, though your implementation may return any class of object.
 
 @return the serialized data.
 */
- (id)_cm_serialize;
@end
