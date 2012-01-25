//
//  NSArray+ClassMapper.h
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serializable.h"
#import "Mappable.h"

@interface NSArray (ClassMapper) <Serializable, Mappable>
@end
