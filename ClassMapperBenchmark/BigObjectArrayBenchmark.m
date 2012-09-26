//
//  BigObjectArray.m
//  ClassMapper
//
//  Created by Patrick Shields on 9/23/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import "BigObjectArrayBenchmark.h"
#import "ClassMapper.h"

@interface Obj : NSObject
@property(nonatomic, strong)NSString *string;
@property(nonatomic, strong)NSNumber *number;
@end

@implementation Obj
- (id)initWithString:(NSString *)string andNumber:(NSNumber *)number
{
    self = [super init];
    if (self) {
        self.string = string;
        self.number = number;
    }
    return self;
}
@end

#define NUM_ELEMENTS 10000
//#define NUM_ELEMENTS 1
@implementation BigObjectArrayBenchmark
- (void)runWithCompletionBlock:(void (^)(CFTimeInterval))completion
{
    NSArray *array = [self genArray];
    BENCH(NSArray *copy __attribute__((unused)) = [ClassMapper deserialize:array toClass:[Obj class]])
    completion(duration);
}
- (NSArray *)genArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:NUM_ELEMENTS];
    for (int i=0; i < NUM_ELEMENTS; i++) {
        [array addObject:@{@"string" : [NSString stringWithFormat:@"%d", i], @"number" : @(i)}];
    }
    return array;
}
@end
