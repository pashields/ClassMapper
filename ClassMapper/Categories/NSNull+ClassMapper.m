//
//  NSNull+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 2/18/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import "NSNull+ClassMapper.h"

@implementation NSNull (ClassMapper)
- (NSNull *)_cm_serialize {
    return self;
}
+ (NSNull *)_cm_inst_from:(NSNull *)serialized withClass:(Class)class {
    return serialized;
}
- (NSNull *)_cm_update_with:(NSNull *)serialized withClass:(Class)class {
    return serialized;
}
@end
