//
//  ClassMapper.m
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
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
#import "ClassMapper.h"
#import "MapperConfig.h"
/* Reflection */
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

@implementation ClassMapper
#pragma mark deserialize
+ (id)deserialize:(id)serialized toInstance:(id)instance {
    /* We can't turn null into anything else, so just return it */
    if (serialized == [NSNull null]) {
        return serialized;
    }
    
    return [instance _cm_update_with:serialized withClass:nil];
}

+ (id)deserialize:(id)serialized toClass:(Class)classType {
    /* We can't turn null into anything else, so just return it */
    if (serialized == [NSNull null]) {
        return serialized;
    }
    
    /* Generally we want to treat class information at the collection level
       if the collection is not pair oriented. Dicitionaries sort of lie
       about the fast enumeration (you just get keys), so we explicitly
       throw them out. But otherwise, this makes it a lot easier to do
       something like use a set.
     */
    if (![serialized isKindOfClass:[NSDictionary class]] &&
        [serialized conformsToProtocol:@protocol(NSFastEnumeration)]) {
        return [[serialized class] _cm_inst_from:serialized withClass:classType];
    } else if ([classType respondsToSelector:@selector(_cm_inst_from:withClass:)]) {
        return [classType _cm_inst_from:serialized withClass:classType];
    } else {
        return [[classType new] _cm_update_with:serialized withClass:classType];
    }
}

#pragma mark serialize
+ (id)serialize:(id<Serializable>)object {
    return [object _cm_serialize];
}
@end
