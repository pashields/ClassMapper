//
//  ViewController.m
//  ClassMapperBenchmark
//
//  Created by Patrick Shields on 9/23/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import "ViewController.h"
#import "BigScalarArrayBenchmark.h"
#import "BigObjectArrayBenchmark.h"
#import "BigNestedObjectArrayBenchmark.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSArray *benches = @[[BigScalarArrayBenchmark new], [BigObjectArrayBenchmark new],
    [BigNestedObjectArrayBenchmark new]];
    __block int i = 0;
    __block void (^runblock)() = ^{
        if (i < [benches count]) {
            [self runBench:[benches objectAtIndex:i++] completion:runblock];
        }
    };
    runblock();
}

- (void)runBench:(id<ClassMapperBenchmark, NSObject>)bench completion:(void (^)())completion
{
    @autoreleasepool {
        NSLog(@"Running benchmark: %@", NSStringFromClass([bench class]));
        [bench runWithCompletionBlock:^(CFTimeInterval time) {
            NSLog(@"%@ completed in %f seconds", NSStringFromClass([bench class]), time);
            completion();
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
