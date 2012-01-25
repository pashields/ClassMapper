//
//  NSNumber+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "NSNumber+ClassMapper.h"

@implementation NSNumber (ClassMapper)
- (NSNumber *)_cm_serialize {
    return self;
}
+ (NSNumber *)_cm_inst_from:(NSNumber *)serialized withClass:(Class)class {
    return serialized;
}
- (NSNumber *)_cm_update_with:(NSNumber *)serialized withClass:(Class)class {
    return serialized;
}
@end
