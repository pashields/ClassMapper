//
//  NSDate+ClassMapper.h
//  ClassMapper
//
//  Created by Patrick Shields on 2/7/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serializable.h"
#import "Mappable.h"

@interface NSDate (ClassMapper) <Serializable, Mappable>
@end
