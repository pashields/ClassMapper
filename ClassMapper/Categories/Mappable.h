//
//  Mappable.h
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

#import <Foundation/Foundation.h>
/**
 The `Mappable` protocol must be implemented by any class that wants custom deserialization.
 
 This should only be necessary for non-kvc compliant classes.
 */
@protocol Mappable
@optional
/**
 Called when this instance should be updated with new data. This should mutate the instance.
 
 @param serialized The serialized data that should be used to fill the instance.
 @param class A class hint. This can be used in cases where the class is ambiguous, such as filling a collection.
 
 @return the updated instance.
 */
- (id)_cm_update_with:(id)serialized withClass:(Class)class;
/**
 Called when a new instance of class must be created using the serialized data.
 
 @param serialized The serialized data that the new instance will contain.
 @param class A class hint. This can be used in cases where the class is ambiguous, such as filling a collection.
 
 @return the new instance.
 */
+ (id)_cm_inst_from:(id)serialized withClass:(Class)class;
@end
