//
//  BigScalarArrayBenchmark.m
//  ClassMapper
//
//  Created by Patrick Shields on 9/23/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import "BigScalarArrayBenchmark.h"
#import "ClassMapper.h"

#define NUM_ELEMENTS 1000000
//#define NUM_ELEMENTS 1
@implementation BigScalarArrayBenchmark
- (void)runWithCompletionBlock:(void (^)(CFTimeInterval))completion
{
    NSArray *array = [self genArray];
    BENCH(NSArray *copy __attribute__((unused)) = [ClassMapper deserialize:array toClass:[NSArray class]])
    completion(duration);
}

- (NSArray *)genArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:NUM_ELEMENTS];
    for (int i=0; i < NUM_ELEMENTS; i++) {
        [array addObject:@(i)];
    }
    return array;
}
@end
