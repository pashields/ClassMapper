//
//  ClassMapperTests.h
//  ClassMapperTests
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ClassMapper.h"
#import "MapperConfig.h"
#import "Foo.h"
#import "Bar.h"
#import "Zip.h"
#import "ArrayHolder.h"

/* Private funcs being used in testing */
@interface ClassMapper ()
+ (BOOL)descClass:(Class)desc isKindOf:(Class)parent;
@end

@interface ClassMapperTests : SenTestCase

@end
