//
//  ClassMapperBenchmark.h
//  ClassMapper
//
//  Created by Patrick Shields on 9/23/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BENCH(x)     CFTimeInterval start = CFAbsoluteTimeGetCurrent(); \
                     x; \
                     CFTimeInterval stop = CFAbsoluteTimeGetCurrent(); \
                     CFTimeInterval duration = stop - start;

@protocol ClassMapperBenchmark <NSObject>
- (void)runWithCompletionBlock:(void(^)(CFTimeInterval time))completion;
@end
