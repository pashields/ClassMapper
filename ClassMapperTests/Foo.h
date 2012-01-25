//
//  Foo.h
//  RIP
//
//  Created by Patrick Shields on 8/21/11.
//  Copyright 2011 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bar.h"

@interface Foo : NSObject
@property(strong, nonatomic)NSString *aString;
@property(strong, nonatomic)NSNumber *aNumber;
@property(strong, nonatomic)NSArray *anArray;
@property(strong, nonatomic)Bar *aBar;
@end
