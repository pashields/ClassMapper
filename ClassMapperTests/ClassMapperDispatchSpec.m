//
//  ClassMapperDispatchSpec.m
//  ClassMapper
//
//  Created by Patrick Shields on 9/23/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import "Kiwi.h"
#import "ClassMapper.h"
#import "Foo.h"
#import "Zip.h"
#import "ArrayHolder.h"

SPEC_BEGIN(ClassMapperDispatchSpec)
describe(@"Given a serialized dictionary", ^{
    context(@"that contains scalars only", ^{
        NSDictionary *dict = @{@"aString" : @"MOTORHEAD", @"aNumber" : @10};
        it(@"should deserialize into a class asynchronously", ^{
            __block Foo *foo;
            [ClassMapper deserializeAsync:dict
                                  toClass:[Foo class]
                               completion:^(id deserialized) {
                                   foo = deserialized;
                               }];
            [[expectFutureValue(foo.aString) shouldEventually] equal:@"MOTORHEAD"];
            [[expectFutureValue(foo.aNumber) shouldEventually] equal:@10];
        });
    });
    context(@"that contains an array of scalars", ^{
        NSDictionary *dict = @{@"anArray" : @[@"foo", @"bar"]};
        it(@"should deserialize into a class asynchronously", ^{
            __block Foo *foo;
            [ClassMapper deserializeAsync:dict
                                  toClass:[Foo class]
                               completion:^(id deserialized) {
                                   foo = deserialized;
                               }];
            [[expectFutureValue(foo.anArray) shouldEventually] beNonNil];
            [[expectFutureValue(foo.anArray) shouldEventually] containObjects:@"foo", @"bar", nil];
        });
    });
    context(@"that contains a dictionary of scalars", ^{
        NSDictionary *dict = @{@"aDict" : @{@"foo" : @"bar"}};
        it(@"should deserialize into a class asynchronously", ^{
            __block Zip *zip;
            [ClassMapper deserializeAsync:dict
                                  toClass:[Zip class]
                               completion:^(id deserialized) {
                                   zip = deserialized;
                               }];
            [[expectFutureValue(zip.aDict) shouldEventually] beNonNil];
            [[expectFutureValue(zip.aDict.allValues) shouldEventually] contain:@"bar"];
            [[expectFutureValue(zip.aDict.allKeys) shouldEventually] contain:@"foo"];
        });
    });
});
describe(@"Given a serialized array", ^{
    context(@"that contains scalars only", ^{
        NSArray *array = @[@0, @1, @2];
        it(@"should deserialize into an array of scalars asynchronously", ^{
            __block NSArray *laterArray;
            [ClassMapper deserializeAsync:array
                                  toClass:[NSArray class]
                               completion:^(id deserialized) {
                                   laterArray = deserialized;
                               }];
            [[expectFutureValue(laterArray) shouldEventually] beNonNil];
            [[expectFutureValue(laterArray) shouldEventually] containObjects:@0, @1, @2, nil];
        });
    });
    context(@"that contains dictionaries", ^{
        NSArray *array = @[@{@"aString" : @"Pat"}, @{@"aString" : @"Gandalf"}];
        it(@"should deserialize into an array of dictionaries asynchronously", ^{
            __block NSArray *laterArray;
            [ClassMapper deserializeAsync:array
                                  toClass:[NSArray class]
                               completion:^(id deserialized) {
                                   laterArray = deserialized;
                               }];
            [[expectFutureValue(laterArray) shouldEventually] beNonNil];
            [[expectFutureValue(laterArray) shouldEventually] containObjects:@{@"aString" : @"Pat"}, @{@"aString" : @"Gandalf"}, nil];
        });
        it(@"should deserialize into an array of objects asynchronously", ^{
            __block NSArray *laterArray;
            __block Foo *foo;
            [ClassMapper deserializeAsync:array
                                  toClass:[Foo class]
                               completion:^(id deserialized) {
                                   laterArray = deserialized;
                                   foo = [laterArray objectAtIndex:0];
                               }];
            [[expectFutureValue(laterArray) shouldEventually] beNonNil];
            [[expectFutureValue(laterArray) shouldEventually] haveAtLeast:2];
            [[expectFutureValue(foo.aString) shouldEventually] equal:@"Pat"];
        });
    });
});
describe(@"Given an object", ^{
    context(@"that contains another compound object", ^{
        Foo *foo = [Foo new];
        foo.aString = @"Hi test reader";
        foo.aNumber = @42;
        foo.aBar = [Bar new];
        foo.aBar.aString = @"You're still reading";
        it(@"should serialize into a nested dictionary", ^{
            __block NSDictionary *dictionary;
            [ClassMapper serializeAsync:foo
                             completion:^(id serialized) {
                                 dictionary = serialized;
                             }];
            [[expectFutureValue(dictionary) shouldEventually] beNonNil];
            [[expectFutureValue([dictionary objectForKey:@"aString"]) shouldEventually] equal:foo.aString];
            [[expectFutureValue([dictionary objectForKey:@"aNumber"]) shouldEventually] equal:foo.aNumber];
            [[expectFutureValue([dictionary objectForKey:@"aBar"]) shouldEventually] beKindOfClass:[NSDictionary class]];
            [[expectFutureValue([[dictionary objectForKey:@"aBar"] objectForKey:@"aString"]) shouldEventually] equal:foo.aBar.aString];
        });
    });
    context(@"that contains an array", ^{
        ArrayHolder *holder = [ArrayHolder new];
        Foo *foo1 = [Foo new];
        foo1.aNumber = @0;
        Foo *foo2 = [Foo new];
        foo2.aNumber = @1;
        holder.anArray = @[foo1, foo2];
        it(@"should serialize into a dict containing an array of dicts", ^{
            __block NSDictionary *dictionary;
            [ClassMapper serializeAsync:holder
                             completion:^(id serialized) {
                                 dictionary = serialized;
                             }];
            [[expectFutureValue(dictionary) shouldEventually] beNonNil];
            [[expectFutureValue([dictionary objectForKey:@"anArray"]) shouldEventually] beKindOfClass:[NSArray class]];
            for (NSNumber *num in @[@0, @1]) {
                                [[expectFutureValue([[dictionary objectForKey:@"anArray"] objectAtIndex:num.intValue]) shouldEventually] beKindOfClass:[NSDictionary class]];
                [[expectFutureValue([[[dictionary objectForKey:@"anArray"] objectAtIndex:num.intValue] objectForKey:@"aNumber"]) shouldEventually] equal:num];
            }
        });
    });
});
SPEC_END
