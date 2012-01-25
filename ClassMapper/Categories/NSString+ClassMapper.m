//
//  NSString+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "NSString+ClassMapper.h"

@implementation NSString (ClassMapper)
- (NSString *)_cm_serialize {
    return [self copy];
}
+ (NSString *)_cm_inst_from:(NSString *)serialized withClass:(Class)class {
    return [serialized _cm_serialize];
}
- (NSString *)_cm_update_with:(NSString *)serialized withClass:(Class)class {
    return [serialized _cm_serialize];
}
@end
