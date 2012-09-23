//
//  NSMutableDictionary+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 1/26/12.
//  Copyright (c) 2012, Patrick Shields
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  The names of its contributors may not be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSMutableDictionary+ClassMapper.h"
#import "NSNumber+ClassMapper.h"
#import "MapperConfig.h"
#import "ClassMapper.h"
#define FIRST_NOT_NULL(x,y,z,a) (x?x:(y?y:(z?z:a)))

@implementation NSMutableDictionary (ClassMapper)
/* Class determination rules for any given k/v pair:
 - If the key has been mapped to a class explicitly using MapperConfig, we will use that class.
 - If the dict is not empty, we will look at an element of the dictionary and use the class of
   that element.
 - Otherwise, we will default to the type of the serialized data.
 */
- (NSDictionary *)_cm_update_with:(NSDictionary *)serialized withClass:(Class)class {
    /* Because of class clusters (on iOS 5), we have to handle both the mutable and immutable cases here */
    if ([self classForCoder] == [NSDictionary class]) {
        for (NSString *key in serialized) {
            NSAssert([self objectForKey:key] != nil, @"Cannot add an entry to an immutable NSDictionary");
            id instance = [self valueForKey:key];
            [instance _cm_update_with:[serialized objectForKey:key] 
                            withClass:[[MapperConfig sharedInstance] classFromKey:key]];
        }
    } else {
        Class instanceClass;
        if (!class && [self count] > 0) {
            instanceClass = [[self objectForKey:[[self allKeys] lastObject]] class];
        }
        [self removeAllObjects];
        for (NSString *key in serialized) {
            id cereal = [serialized objectForKey:key];
            class = FIRST_NOT_NULL([[MapperConfig sharedInstance] classFromKey:key], 
                                   instanceClass, [cereal class], nil);
            
            /* Pass the buck up to main classmapper to handle arrays */
            id obj = [ClassMapper deserialize:cereal toClass:class];
            [self setValue:obj forKey:key];
        }
    }
    return self;
}
@end
