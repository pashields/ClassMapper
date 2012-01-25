//
//  Serializable.h
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 * Must be implemented by any class that will be encountered by
 * ClassMapper (that is not KVC compliant). If the class is mutable,
 * copying is reccomended.
 */
@protocol Serializable
/*
 * Returns a serialized version of the instance.
 */
- (id)_cm_serialize;
@end
