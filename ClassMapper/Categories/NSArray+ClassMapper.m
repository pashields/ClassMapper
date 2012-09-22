//
//  NSArray+ClassMapper.m
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
#import "NSArray+ClassMapper.h"
#import "ClassMapper.h"

@implementation NSArray (ClassMapper)
- (NSArray *)_cm_serialize {
    NSMutableArray *copy = [NSMutableArray arrayWithCapacity:[self count]];
    for (id<Serializable> obj in self) {
        [copy addObject:[ClassMapper serialize:obj]];
    }
    
    return copy;
}
+ (NSArray *)_cm_inst_from:(NSArray *)serialized withClass:(Class)class {
    return [[NSMutableArray new] _cm_update_with:serialized withClass:class];
}
- (NSArray *)_cm_update_with:(NSArray *)serialized withClass:(Class)class {
    for (int i=0; i<[self count]; i++) {
        [[self objectAtIndex:i] _cm_update_with:[serialized objectAtIndex:i] withClass:class];
    }
    
    return self;
}
@end
