//
//  NSMutableArray+ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 1/25/12.
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

#import "NSMutableArray+ClassMapper.h"
#import "NSNumber+ClassMapper.h"
#import "MapperConfig.h"
#import "ClassMapper.h"
#define FIRST_NOT_NULL(x,y,z,a) (x?x:(y?y:(z?z:a)))

@implementation NSMutableArray (ClassMapper)
/* Class determination rules:
 - If the array is not empty, we will look at the class of an 
   element in the array and assume that is the class.
 - If the class passed in the withClass arg is not NSArray, we will use that.
 - Otherwise, we will default to the type of the serialized data.
 */
- (NSMutableArray *)_cm_update_with:(NSArray *)serialized withClass:(Class)class {
    Class instanceClass;
    if (!class && [self count] > 0) {
        instanceClass = [[self lastObject] class];
    }
    [self removeAllObjects];
    for (id cereal in serialized) {
        /* Generally, we want to chain class types. If someone has clearly specified
           the type of the container, however, we want to break the chain. */
        if ([class isSubclassOfClass:[NSArray class]]) {
            class = nil;
        }
        class = FIRST_NOT_NULL(instanceClass, class, [cereal class], nil);
        [self addObject:[ClassMapper deserialize:cereal toClass:class]];
    }
    
    return self;
}
@end
