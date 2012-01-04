//
//  Serializable.h
//  ClassMapper
//
//  Created by Patrick Shields on 12/28/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Serializable
- (id)_cm_serialize;
@end
