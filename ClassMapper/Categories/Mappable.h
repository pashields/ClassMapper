//
//  Mappable.h
//  ClassMapper
//
//  Created by Patrick Shields on 1/26/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 * Must be implemented by any (non-KVC) class that will exist in the
 * output of a ClassMapper deserialize operation.
 */
@protocol Mappable
@optional
/*
 * Update the instance with the data in serialized. If any extra
 * class information has been deduced higher up the tree, it will
 * be passed to the withClass arguement.
 */
- (id)_cm_update_with:(id)serialized withClass:(Class)class;
/*
 * Override on classes that require non-standard (not [class new])
 * instantiation before mapping. This is most commonly used to handle
 * immutable classes. See NSArray+ClassMapper.
 */
+ (id)_cm_inst_from:(id)serialized withClass:(Class)class;
@end
