//
//  NSNull+ClassMapper.h
//  ClassMapper
//
//  Created by Patrick Shields on 2/18/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serializable.h"
#import "Mappable.h"

@interface NSNull (ClassMapper) <Serializable, Mappable>
@end
