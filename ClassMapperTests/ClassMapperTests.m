//
//  ClassMapperTests.m
//  ClassMapperTests
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClassMapperTests.h"

@implementation ClassMapperTests
- (void)tearDown {
    [super tearDown];
    [[MapperConfig sharedInstance] clearMappings];
}

#pragma mark dict to class
- (void)testDictToSimpleObj {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"hi", @"aString", [NSNumber numberWithInt:10], 
                          @"aNumber", nil];
    Foo *foo = [ClassMapper dict:dict toClass:[Foo class]];
    STAssertEqualObjects(foo.aString, @"hi", @"String property not set. Expected: hi, got: %@", foo.aString);
    STAssertEqualObjects([NSNumber numberWithInt:10], foo.aNumber, @"NSNumber property not set. Expect 10, got: %@", 
                         foo.aNumber);
}

- (void)testFailDictToSimpleObj {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"hi", @"astring", 
                          [NSNumber numberWithInt:10], @"anumber", nil];
    STAssertThrows([ClassMapper dict:dict toClass:[Foo class]], 
                   @"Dict contains non-existant props, but did not throw exception: %@", dict);
}

- (void)testDictToObjSimpleArray {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:@" "] forKey:@"anArray"];
    Foo *foo = [ClassMapper dict:dict toClass:[Foo class]];
    int count = [foo.anArray count];
    STAssertTrue(count > 0, @"There are no items in the array: %@", foo.anArray);
    STAssertEqualObjects([foo.anArray lastObject], @" ", @"Contents of the array were not deserialized properly: %@", 
                         [foo.anArray lastObject]);
}

- (void)testDictToObjComplexArray {
    NSDictionary *subObj = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSMutableArray *array = [NSMutableArray arrayWithObject:subObj];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:array forKey:@"anArray"];
    
    [[MapperConfig sharedInstance] mapKey:@"anArray" toClass:[Bar class]];
    
    Foo *foo = [ClassMapper dict:dict toClass:[Foo class]];
    
    int count = [foo.anArray count];
    STAssertTrue(count > 0, @"There are no items in the array: %@", foo.anArray);
    Bar *bar = [foo.anArray lastObject];
    STAssertEqualObjects(bar.aString, @"MOTORHEAD", @"Contents of the array were not deserialized properly: %@", 
                         [foo.anArray lastObject]);
}

- (void)testDictToObjNestedObj {
    NSDictionary *subObj = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:subObj forKey:@"aBar"];
    
    [[MapperConfig sharedInstance] mapKey:@"aBar" toClass:[Bar class]];
    
    Foo *foo = [ClassMapper dict:dict toClass:[Foo class]];
    
    Bar *bar = foo.aBar;
    STAssertNotNil(bar, @"Nested obj not deserialized, is nil: %@", bar);
    STAssertEqualObjects(bar.aString, @"MOTORHEAD", @"Nested obj not deserialized properly: %@", bar);
}

#pragma mark array to classarray
- (void)testArrayToArray {
    NSDictionary *dict1 = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObject:@"BLACK SABBATH" forKey:@"aString"];
    NSArray *ray = [NSArray arrayWithObjects:dict1, dict2, nil];
    
    NSArray *bars = [ClassMapper dictArray:ray toClass:[Bar class]];
    
    STAssertNotNil(bars, @"Array of dicts not deserialized, is nil");
    STAssertTrue([bars count] == 2, @"Incorrect number of elements in deserialized array: %@", bars);
    
    Bar *first = [bars objectAtIndex:0];
    Bar *second = [bars objectAtIndex:1];
    
    // Not chronological
    STAssertEqualObjects(first.aString, @"MOTORHEAD", 
                         @"Array obj not deserialized properly: %@", first);
    STAssertEqualObjects(second.aString, @"BLACK SABBATH", 
                         @"Array obj not deserialized properly: %@", second);
}

#pragma mark serialization
- (void)testSerializeDict {
    Foo *foo = [Foo new];
    foo.aString = @"Yob is wicked heavy, dude";
    foo.aNumber = [NSNumber numberWithInt:100];
    foo.anArray = [NSArray arrayWithObjects:@"no really, atma rules.", @"and that guitar is so fuzzy...", nil];
    
    Bar *bar = [Bar new];
    bar.aString = @"Of course, quantum mystic is still the gold standard";
    
    foo.aBar = bar;
    
    NSDictionary *dict = [ClassMapper objToDict:foo];
    STAssertNotNil(dict, @"Serialization failed");
    
    [[MapperConfig sharedInstance] mapKey:@"aBar" toClass:[Bar class]];
    
    Foo *fooCopy = [ClassMapper dict:dict toClass:[Foo class]];
    STAssertNotNil(fooCopy, @"Deserialization of serialized object failed for dict: %@", dict);
    
    // Scalar cocoa classes
    STAssertEqualObjects(foo.aString, fooCopy.aString, @"String values do not match. original: %@, copy: %@", 
                         foo.aString, fooCopy.aString);
    STAssertEqualObjects(foo.aNumber, fooCopy.aNumber, @"Number values do not match. original: %@, copy: %@", 
                         foo.aNumber, fooCopy.aNumber);
    
    // Array Check
    STAssertEqualObjects([foo.anArray class], [fooCopy.anArray class], @"Array copy failed. original: %@, copy: %@", 
                         foo.anArray, fooCopy.anArray);
    STAssertTrue([foo.anArray count] == [fooCopy.anArray count], @"Array copy produced mismatched lengths");
    for (int i=0; i<[foo.anArray count]; i++) {
        id ori = [foo.anArray objectAtIndex:i];
        id copy = [fooCopy.anArray objectAtIndex:i];
        STAssertEqualObjects(ori, copy, @"Nested arrays contain non-matching objs. original: %@, copy: %@", 
                             ori, copy);
    }
    
    // Nested obj
    STAssertEqualObjects([foo.aBar class], [fooCopy.aBar class], @"Nested obj class types do not match. original: %@, copy:%@", 
                         [foo.aBar class], [fooCopy.aBar class]);
    STAssertEqualObjects(foo.aBar.aString, fooCopy.aBar.aString, @"Nested objs do not match. original: %@, copy: %@", 
                         foo.aBar.aString, fooCopy.aBar.aString);
}
- (void)testSerializeRay {
    Foo *foo = [Foo new];
    foo.aString = @"Yob is wicked heavy, dude";
    foo.aNumber = [NSNumber numberWithInt:100];
    foo.anArray = [NSArray arrayWithObjects:@"no really, atma rules.", @"and that guitar is so fuzzy...", nil];
    
    Bar *bar = [Bar new];
    bar.aString = @"Of course, quantum mystic is still the gold standard";
    
    foo.aBar = bar;
    
    NSArray *objs = [NSArray arrayWithObject:foo];
    
    NSArray *dictArray = [ClassMapper objsToDictArray:objs];
    STAssertNotNil(dictArray, @"Serialization failed");
    STAssertTrue([dictArray count] == 1, @"Serialized array has wrong lenth: %@", dictArray);
    
    [[MapperConfig sharedInstance] mapKey:@"aBar" toClass:[Bar class]];
    
    Foo *fooCopy = [ClassMapper dict:[dictArray objectAtIndex:0] toClass:[Foo class]];
    STAssertNotNil(fooCopy, @"Deserialization of serialized object failed for dict: %@", [dictArray objectAtIndex:0]);
    
    // Scalar cocoa classes
    STAssertEqualObjects(foo.aString, fooCopy.aString, @"String values do not match. original: %@, copy: %@", 
                         foo.aString, fooCopy.aString);
    STAssertEqualObjects(foo.aNumber, fooCopy.aNumber, @"Number values do not match. original: %@, copy: %@", 
                         foo.aNumber, fooCopy.aNumber);
    
    // Array Check
    STAssertEqualObjects([foo.anArray class], [fooCopy.anArray class], @"Array copy failed. original: %@, copy: %@", 
                         foo.anArray, fooCopy.anArray);
    STAssertTrue([foo.anArray count] == [fooCopy.anArray count], @"Array copy produced mismatched lengths");
    for (int i=0; i<[foo.anArray count]; i++) {
        id ori = [foo.anArray objectAtIndex:i];
        id copy = [fooCopy.anArray objectAtIndex:i];
        STAssertEqualObjects(ori, copy, @"Nested arrays contain non-matching objs. original: %@, copy: %@", 
                             ori, copy);
    }
    
    // Nested obj
    STAssertEqualObjects([foo.aBar class], [fooCopy.aBar class], @"Nested obj class types do not match. original: %@, copy:%@", 
                         [foo.aBar class], [fooCopy.aBar class]);
    STAssertEqualObjects(foo.aBar.aString, fooCopy.aBar.aString, @"Nested objs do not match. original: %@, copy: %@", 
                         foo.aBar.aString, fooCopy.aBar.aString);
}
@end
