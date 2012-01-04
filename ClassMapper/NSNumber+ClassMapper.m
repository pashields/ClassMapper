//
//  NSNumber+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "NSNumber+ClassMapper.h"

@implementation NSNumber (ClassMapper)
- (id)_cm_serialize {
    return self;
}
@end
