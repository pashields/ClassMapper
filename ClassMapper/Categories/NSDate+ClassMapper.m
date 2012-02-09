//
//  NSDate+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 2/7/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import "NSDate+ClassMapper.h"

@implementation NSDate (ClassMapper)
- (NSDate *)_cm_serialize {
    return self;
}

+ (NSDate *)_cm_inst_from:(NSDate *)serialized withClass:(Class)class {
    return serialized;
}

- (NSDate *)_cm_update_with:(NSDate *)serialized withClass:(Class)class {
    return serialized;
}
@end
