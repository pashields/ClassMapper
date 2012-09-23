//
//  NSDictionary+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
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
#import "NSDictionary+ClassMapper.h"
#import "ClassMapper.h"
#import "MapperConfig.h"

@implementation NSDictionary (ClassMapper)
- (NSDictionary *)_cm_serialize {
    NSMutableDictionary *copy = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    for (NSString *key in self) {
        id<Serializable> val = [self objectForKey:key];
        [copy setValue:[ClassMapper serialize:val] forKey:key];
    }
    
    return copy;
}
- (NSDictionary *)_cm_update_with:(NSDictionary *)serialized withClass:(Class)class
{
    for (NSString *key in serialized) {
        NSAssert([self objectForKey:key] != nil, @"Cannot add an entry to an immutable NSDictionary");
        id instance = [self valueForKey:key];
        [instance _cm_update_with:[serialized objectForKey:key]
                        withClass:[[MapperConfig sharedInstance] classFromKey:key]];
    }
    return self;
}
+ (NSDictionary *)_cm_inst_from:(NSDictionary *)serialized withClass:(Class)class {
    return [[NSMutableDictionary new] _cm_update_with:serialized withClass:class];
}
@end
