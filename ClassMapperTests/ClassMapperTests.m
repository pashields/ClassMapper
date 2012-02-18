//
//  ClassMapperTests.m
//  ClassMapperTests
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import "ClassMapperTests.h"

#import "NSDate+ClassMapper.h"

@implementation ClassMapperTests
- (void)tearDown {
    [super tearDown];
    [[MapperConfig sharedInstance] clearConfig];
}

#pragma mark dict to class
- (void)testDictToSimpleObj {
    /* {"aString":"hi", "aNumber":10} -> Foo */
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"hi", @"aString", [NSNumber numberWithInt:10], 
                          @"aNumber", nil];
    
    Foo *foo = [ClassMapper deserialize:dict toClass:[Foo class]];
    STAssertEqualObjects(foo.aString, @"hi", @"String property not set. Expected: hi, got: %@", foo.aString);
    STAssertEqualObjects(foo.aNumber, [NSNumber numberWithInt:10], @"NSNumber property not set. Expect 10, got: %@", 
                         foo.aNumber);
}

- (void)testDictToObjSimpleArray {
    /* {"anArray":[" "]} -> Foo */
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:@" "] forKey:@"anArray"];
    Foo *foo = [ClassMapper deserialize:dict toClass:[Foo class]];
    int count = [foo.anArray count];
    STAssertTrue(count > 0, @"There are no items in the array: %@", foo.anArray);
    STAssertEqualObjects([foo.anArray lastObject], @" ", @"Contents of the array were not deserialized properly: %@", 
                         [foo.anArray lastObject]);
}

- (void)testDictToObjComplexArray {
    /* {"anArray":[ {"aString":"MOTORHEAD"} ]} -> Foo */
    NSDictionary *subObj = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSMutableArray *array = [NSMutableArray arrayWithObject:subObj];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:array forKey:@"anArray"];
    
    [[MapperConfig sharedInstance] mapKey:@"anArray" toClass:[Bar class]];
    
    Foo *foo = [ClassMapper deserialize:dict toClass:[Foo class]];
    
    int count = [foo.anArray count];
    STAssertTrue(count > 0, @"There are no items in the array: %@", foo.anArray);
    Bar *bar = [foo.anArray lastObject];
    STAssertEqualObjects(bar.aString, @"MOTORHEAD", @"Contents of the array were not deserialized properly: %@", 
                         [foo.anArray lastObject]);
}

- (void)testDictToDictComplexArray {
    /* {"anArray":[ {"aString":"MOTORHEAD"} ]} -> NSDictionary */
    NSDictionary *subObj = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSMutableArray *array = [NSMutableArray arrayWithObject:subObj];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:array forKey:@"anArray"];
    
    [[MapperConfig sharedInstance] mapKey:@"anArray" toClass:[Bar class]];
    
    NSDictionary *foo = [ClassMapper deserialize:dict toClass:[NSDictionary class]];
    
    int count = [[foo objectForKey:@"anArray"] count];
    STAssertTrue(count > 0, @"There are no items in the array: %@", [foo objectForKey:@"anArray"]);
    Bar *bar = [[foo objectForKey:@"anArray"] lastObject];
    STAssertEqualObjects(bar.aString, @"MOTORHEAD", @"Contents of the array were not deserialized properly: %@", 
                         [[foo objectForKey:@"anArray"] lastObject]);
}

- (void)testDictToObjComplexUnMappedArray {
    /* {"anArray":[ {"aString":"MOTORHEAD"} ]} -> Foo */
    NSDictionary *subObj = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSMutableArray *array = [NSMutableArray arrayWithObject:subObj];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:array forKey:@"anArray"];
    
    Foo *foo = [ClassMapper deserialize:dict toClass:[Foo class]];
    
    int count = [foo.anArray count];
    STAssertTrue(count > 0, @"There are no items in the array: %@", foo.anArray);
    NSDictionary *unmapped = [foo.anArray lastObject];
    STAssertEqualObjects([unmapped objectForKey:@"aString"], @"MOTORHEAD", 
                         @"Contents of the array were not deserialized properly: %@", 
                         [foo.anArray lastObject]);
}

- (void)testDictToObjNestedObj {
    /* {"aBar":{"aString":"MOTORHEAD"}} -> Foo */
    NSDictionary *subObj = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:subObj forKey:@"aBar"];
    
    [[MapperConfig sharedInstance] mapKey:@"aBar" toClass:[Bar class]];
    
    Foo *foo = [ClassMapper deserialize:dict toClass:[Foo class]];
    
    Bar *bar = foo.aBar;
    STAssertNotNil(bar, @"Nested obj not deserialized, is nil: %@", bar);
    STAssertEqualObjects(bar.aString, @"MOTORHEAD", @"Nested obj not deserialized properly: %@", bar);
}

- (void)testDictToObjWithDict {
    /* {"aDict":{"bar":"foo", "nums":1} } -> Zip */
    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:@"foo", @"bar", 
                           [NSNumber numberWithInt:1], @"nums", nil];
    NSDictionary *zipDict = [NSDictionary dictionaryWithObject:aDict forKey:@"aDict"];
    
    Zip *zip = [ClassMapper deserialize:zipDict toClass:[Zip class]];
    
    STAssertNotNil(zip.aDict, @"Obj element not deseriailized, is nil: %@", zipDict);
    STAssertEquals([[aDict allKeys] count], [[zip.aDict allKeys] count], 
                   @"Deserialized dictionaries have different key sets. Ori: %@, post: %@", aDict, zip.aDict);
}

- (void)testDictToObjWithDictArray {
    /* {"anArray":[ {"aString":"MOTORHEAD"} ]} -> ArrayHolder */
    NSDictionary *subObj = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSMutableArray *array = [NSMutableArray arrayWithObject:subObj];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:array forKey:@"anArray"];
    
    Foo *foo = [ClassMapper deserialize:dict toClass:[Foo class]];
    
    int count = [foo.anArray count];
    STAssertTrue(count > 0, @"There are no items in the array: %@", foo.anArray);
    NSDictionary *dictionary = [foo.anArray lastObject];
    STAssertEqualObjects([dictionary objectForKey:@"aString"], @"MOTORHEAD", 
                         @"Contents of the array were not deserialized properly: %@", 
                         [foo.anArray lastObject]);
}

- (void)testDictWithExtraDictToObj {
    /* {"aDict":{"key":"stuff"}, "aString":"foo"} -> Bar */
    NSDictionary *wontBeDeserialized = [NSDictionary dictionaryWithObject:@"stuff" forKey:@"key"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:wontBeDeserialized, @"aDict",
                          @"foo", @"aString", nil];
    
    Bar *bar = [ClassMapper deserialize:dict toClass:[Bar class]];
    STAssertEquals(@"foo", bar.aString, @"Dict not properly deserialized: %@", dict);
}
#pragma mark array to classarray
- (void)testArrayToArray {
    /* [{"aString":"MOTORHEAD"}, {"aString":"BLACK SABBATH"}] -> [Bar, Bar] */
    NSDictionary *dict1 = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObject:@"BLACK SABBATH" forKey:@"aString"];
    NSArray *ray = [NSArray arrayWithObjects:dict1, dict2, nil];
    
    NSArray *bars = [ClassMapper deserialize:ray toClass:[Bar class]];
    
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

- (void)testArrayNestedToNestedArray {
    /* [[{"aString":"MOTORHEAD"}], [{"aString":"BLACK SABBATH"}]] -> [[Bar], [Bar]] */
    NSDictionary *dict1 = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObject:@"BLACK SABBATH" forKey:@"aString"];
    NSArray *ray = [NSArray arrayWithObjects:[NSArray arrayWithObject:dict1],
                    [NSArray arrayWithObject:dict2], nil];
    
    NSArray *bars = [ClassMapper deserialize:ray toClass:[Bar class]];
    
    STAssertNotNil(bars, @"Array of dicts not deserialized, is nil");
    STAssertTrue([bars count] == 2, @"Incorrect number of elements in deserialized array: %@", bars);
    
    Bar *first = [[bars objectAtIndex:0] lastObject];
    Bar *second = [[bars objectAtIndex:1] lastObject];
    
    // Not chronological
    STAssertEqualObjects(first.aString, @"MOTORHEAD", 
                         @"Array obj not deserialized properly: %@", first);
    STAssertEqualObjects(second.aString, @"BLACK SABBATH", 
                         @"Array obj not deserialized properly: %@", second);
}

- (void)testArrayNestedToObjWithNestedArray {
    /* {"anArray":[ [{"aString":"Scala sucks. I read it on HN"}] ]} -> ArrayHolder */
    NSDictionary *barDict = [NSDictionary dictionaryWithObject:@"Scala sucks. I read it on HN" 
                                                        forKey:@"aString"];
    NSArray *barRay = [NSArray arrayWithObject:barDict];
    NSArray *rayRay = [NSArray arrayWithObject:barRay]; // RayRay ain't had no job for some time...
    NSDictionary *ahDict = [NSDictionary dictionaryWithObject:rayRay forKey:@"anArray"];
    
    [[MapperConfig sharedInstance] mapKey:@"anArray" toClass:[Bar class]];
    ArrayHolder *holder = [ClassMapper deserialize:ahDict toClass:[ArrayHolder class]];
    
    STAssertTrue([[[holder.anArray lastObject] lastObject] isKindOfClass:[Bar class]], 
                 @"Class not being propogated through nested arrays");
}

#pragma mark to instance
- (void)testDictToInstance {
    /* {"aString":"hi", "aNumber":10} -> Foo, Foo.aString=@"bye" */
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"hi", @"aString", [NSNumber numberWithInt:10], 
                          @"aNumber", nil];
    
    Foo *foo = [Foo new];
    foo.aString = @"bye";
    [ClassMapper deserialize:dict toInstance:foo];
    
    STAssertEqualObjects(foo.aString, @"hi", @"String property not set. Expected: hi, got: %@", foo.aString);
    STAssertEqualObjects([NSNumber numberWithInt:10], foo.aNumber, @"NSNumber property not set. Expect 10, got: %@", 
                         foo.aNumber);
}

- (void)testDictToInstanceWithId {
    /* {"stuff":{"aString":"bleh"}} -> IdHolder, IdHolder.stuff=Bar */
    NSDictionary *barDict = [NSDictionary dictionaryWithObject:@"bleh" forKey:@"aString"];
    NSDictionary *IdDict = [NSDictionary dictionaryWithObject:barDict forKey:@"stuff"];
    
    IdHolder *idHolder = [IdHolder new];
    idHolder.stuff = [Bar new];
    [ClassMapper deserialize:IdDict toInstance:idHolder];
    
    STAssertTrue([idHolder.stuff isKindOfClass:[Bar class]], @"id sub-instance lost class type");
    Bar *stuff = idHolder.stuff;
    STAssertEqualObjects(stuff.aString, @"bleh", @"id sub-instance not properly deserialized into");
}

- (void)testArrayToInstances {
    /* [{"aString":"MOTORHEAD"}, {"aString":"BLACK SABBATH"}] -> [Bar, Bar], Bar.aString="NickelBack" */
    NSDictionary *dict1 = [NSDictionary dictionaryWithObject:@"MOTORHEAD" forKey:@"aString"];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObject:@"BLACK SABBATH" forKey:@"aString"];
    NSArray *ray = [NSArray arrayWithObjects:dict1, dict2, nil];
    
    NSArray *bars = [NSArray arrayWithObjects:[Bar new], [Bar new], nil];
    for (Bar *bar in bars) {
        bar.aString = @"Nickelback";
    }
    [ClassMapper deserialize:ray toInstance:bars];
    
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

- (void)testNestedArrayToNestedInstances {
    /* [[{"aString":"Fantome"}], [{"aString":"Pabst"}]] -> [[Bar], [Bar]], Bar.aString="Bud Select" */
    NSDictionary *dict1 = [NSDictionary dictionaryWithObject:@"Fantome" forKey:@"aString"];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObject:@"Pabst" forKey:@"aString"];
    NSArray *ray = [NSArray arrayWithObjects:[NSArray arrayWithObject:dict1], 
                    [NSArray arrayWithObject:dict2], nil];
    
    Bar *bar1 = [Bar new];
    bar1.aString = @"Bud Select";
    Bar *bar2 = [Bar new];
    bar2.aString = @"Bud Select";
    NSArray *barRay = [NSArray arrayWithObjects:[NSArray arrayWithObject:bar1],
                       [NSArray arrayWithObject:bar2], nil];
    
    NSArray *barPost = [ClassMapper deserialize:ray toInstance:barRay];
    
    STAssertEquals(bar1.aString, @"Fantome", @"Nested array to nested array not working");
    STAssertEquals(bar2.aString, @"Pabst", @"Nested array to nested array not working");
    
    STAssertEquals(bar1, [[barPost objectAtIndex:0] lastObject], 
                   @"Returned array from nested array to nested array is incorrect: %@", barPost);
    STAssertEquals(bar2, [[barPost objectAtIndex:1] lastObject], 
                   @"Returned array from nested array to nested array is incorrect: %@", barPost);
}

- (void)testDictToPartialInstance {
    /* {"aBar":{"aString":"Bleh"}, "aNumber":42} -> Foo, Foo.bar=nil */
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:42], @"aNumber",
                          [NSDictionary dictionaryWithObject:@"Bleh" forKey:@"aString"], @"aBar", nil];
    
    Foo *foo = [Foo new];
    foo.aString = @"Still alive";
    
    [ClassMapper deserialize:dict toInstance:foo];
    
    STAssertNotNil(foo.aBar, @"Subobject not automatically created during deserialization");
    STAssertEquals(foo.aBar.aString, @"Bleh", @"Automatically created subobject incomplete, should be Bleh: %@",
                   foo.aBar.aString);
    STAssertEquals(foo.aNumber, [dict objectForKey:@"aNumber"], 
                   @"Failed to deserialize NSNumber to partial instance: %@", foo.aNumber);
    STAssertEquals(foo.aString, @"Still alive", @"Existing values in partial instance were overwritten", 
                   foo.aString);
}

- (void)testDictToPartialSubInstance {
    /* {"aBar":{"aString":"Bleh"}} -> Foo, Foo.bar.aNumber=42 */
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObject:@"Bleh" 
                                                                                                forKey:@"aString"], 
                          @"aBar", nil];
    
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    foo.aBar = bar;
    NSNumber *aNumber = [NSNumber numberWithInt:42];
    foo.aBar.aNumber = aNumber;
    
    [ClassMapper deserialize:dict toInstance:foo];
    
    STAssertEquals(foo.aBar, bar, @"Deserialization overwrote existing partial subobject");
    STAssertEquals(foo.aBar.aString, @"Bleh", @"Deserialization into existing subobject failed, should be Bleh: %@",
                   foo.aBar.aString);
    STAssertEquals(foo.aBar.aNumber, aNumber, 
                   @"Deserialization to partial subobject failed: %@", foo.aNumber);
}

- (void)testDictWithArrayToPartialInstance {
    /* {"anArray":[{"aString":"Modal Editing is Doomed!"}]} -> ArrayHolder, ArrayHolder.anArray=[{"aNumber":42}] */
    NSArray *rayForDict = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:@"Modal Editing is Doomed!" forKey:@"aString"]];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:rayForDict forKey:@"anArray"];
    
    ArrayHolder *arrayHolder = [ArrayHolder new];
    Bar *barOrig = [Bar new];
    barOrig.aNumber = [NSNumber numberWithInt:42];
    NSArray *rayForObj = [NSArray arrayWithObject:barOrig];
    arrayHolder.anArray = rayForObj;
    
    
    [[MapperConfig sharedInstance] mapKey:@"anArray" toClass:[Bar class]];
    [ClassMapper deserialize:dict toInstance:arrayHolder];
    
    STAssertEquals(arrayHolder.anArray, rayForObj, @"Array from partial object was removed");
    STAssertNotNil([arrayHolder.anArray lastObject], @"Array from partial object was not filled");
    Bar *bar = [arrayHolder.anArray lastObject];
    STAssertEquals(bar.aString, @"Modal Editing is Doomed!", @"Object in array from instance was not deserialed properly");
    STAssertEquals(bar, barOrig, @"Partial subobject in array was overwritten");
    STAssertEquals(bar.aNumber, barOrig.aNumber, 
                   @"Attribute of partial subobject in array was overwritten. Should be 42: %@", bar.aNumber);
}

- (void)testDictWithDictToPartialInstance {
    /* {"aDict":{"bar":{"aString":"Pabst"}}} -> Zip, Zip.aDict = {"bar":Bar} */
    NSDictionary *barDict = [NSDictionary dictionaryWithObject:@"Pabst" forKey:@"aString"];
    NSDictionary *aDict = [NSDictionary dictionaryWithObject:barDict forKey:@"bar"];
    NSDictionary *zipDict = [NSDictionary dictionaryWithObject:aDict forKey:@"aDict"];
    
    Zip *zip = [Zip new];
    Bar *bar = [Bar new];
    bar.aString = @"Chimay";
    zip.aDict = [NSDictionary dictionaryWithObject:bar forKey:@"bar"];
    
    [ClassMapper deserialize:zipDict toInstance:zip];
    
    Bar *barCopy = [zip.aDict objectForKey:@"bar"];
    STAssertEquals(bar, barCopy, @"Object inside immutable dict recreated (somehow?)");
    STAssertEquals(@"Pabst", barCopy.aString, @"Instance inside immutable dict not updated. Should be Pabst, is %@", barCopy.aString);
}

- (void)testDictWithArrayToEmptyMutableArray {
    /* {"anArray":[{"aString":"Modal Editing is Doomed!"}]} -> ArrayHolder, ArrayHolder.anArray=[] */
    NSArray *rayForDict = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:@"Modal Editing is Doomed!" forKey:@"aString"]];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:rayForDict forKey:@"anArray"];
    
    ArrayHolder *arrayHolder = [ArrayHolder new];
    NSArray *rayForObj = [NSMutableArray array];
    arrayHolder.anArray = rayForObj;
    
    [[MapperConfig sharedInstance] mapKey:@"anArray" toClass:[Bar class]];
    [ClassMapper deserialize:dict toInstance:arrayHolder];
    
    STAssertEquals(arrayHolder.anArray, rayForObj, @"Array from partial object was removed");
    STAssertTrue([rayForObj count] == 1, @"Mutable array was not reset");
    STAssertNotNil([arrayHolder.anArray lastObject], @"Array from partial object was not filled");
    Bar *bar = [arrayHolder.anArray lastObject];
    STAssertEquals(bar.aString, @"Modal Editing is Doomed!", @"Object in array from instance was not deserialed properly");
}

- (void)testDictWithArrayToPartialMutableArray {
    /* {"anArray":[{"aString":"Modal Editing is Doomed!"}]} -> ArrayHolder, ArrayHolder.anArray=["foo"] */
    NSArray *rayForDict = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:@"Modal Editing is Doomed!" forKey:@"aString"]];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:rayForDict forKey:@"anArray"];
    
    ArrayHolder *arrayHolder = [ArrayHolder new];
    NSMutableArray *rayForObj = [NSMutableArray array];
    [rayForObj addObject:@"foo"];
    arrayHolder.anArray = rayForObj;
    
    [[MapperConfig sharedInstance] mapKey:@"anArray" toClass:[Bar class]];
    [ClassMapper deserialize:dict toInstance:arrayHolder];
    
    STAssertEquals(arrayHolder.anArray, rayForObj, @"Array from partial object was removed");
    STAssertTrue([rayForObj count] == 1, @"Mutable array was not reset");
    STAssertNotNil([arrayHolder.anArray lastObject], @"Array from partial object was not filled");
    Bar *bar = [arrayHolder.anArray lastObject];
    STAssertEquals(bar.aString, @"Modal Editing is Doomed!", @"Object in array from instance was not deserialed properly");
}

- (void)testDictWithDictToEmptyMutableDict {
    /* {"aDict":{"bar":{"aString":"Pabst"}}} -> Zip, Zip.aDict = {} */
    NSDictionary *barDict = [NSDictionary dictionaryWithObject:@"Pabst" forKey:@"aString"];
    NSDictionary *aDict = [NSDictionary dictionaryWithObject:barDict forKey:@"bar"];
    NSDictionary *zipDict = [NSDictionary dictionaryWithObject:aDict forKey:@"aDict"];
    
    Zip *zip = [Zip new];
    zip.aDict = [NSMutableDictionary dictionary];
    
    [[MapperConfig sharedInstance] mapKey:@"bar" toClass:[Bar class]];
    [ClassMapper deserialize:zipDict toInstance:zip];
    
    Bar *bar = [zip.aDict objectForKey:@"bar"];
    STAssertEquals(@"Pabst", bar.aString, @"Instance inside immutable dict not updated. Should be Pabst, is %@", bar.aString);
}

- (void)testDictWithDictToPartialMutableDict {
    /* {"aDict":{"bar":{"aString":"Pabst"}}} -> Zip, Zip.aDict = {"foo":"bar"} */
    NSDictionary *barDict = [NSDictionary dictionaryWithObject:@"Pabst" forKey:@"aString"];
    NSDictionary *aDict = [NSDictionary dictionaryWithObject:barDict forKey:@"bar"];
    NSDictionary *zipDict = [NSDictionary dictionaryWithObject:aDict forKey:@"aDict"];
    
    Zip *zip = [Zip new];
    zip.aDict = [NSMutableDictionary dictionaryWithObject:@"bar" forKey:@"foo"];
    
    [[MapperConfig sharedInstance] mapKey:@"bar" toClass:[Bar class]];
    [ClassMapper deserialize:zipDict toInstance:zip];
    
    STAssertTrue([[zip.aDict allKeys] count] == 1, @"Partial mutable array not cleared during instance serialization");
    Bar *bar = [zip.aDict objectForKey:@"bar"];
    STAssertEquals(@"Pabst", bar.aString, @"Instance inside immutable dict not updated. Should be Pabst, is %@", bar.aString);
}

#pragma mark serialization
- (void)testSerializeString {
    NSString *foo = @"foo";
    STAssertEquals(foo, [foo _cm_serialize], @"Serializing strings not working");
}
- (void)testSerializeNumber {
    NSNumber *foo = [NSNumber numberWithInt:1];
    STAssertEquals(foo, [foo _cm_serialize], @"Serializing numbers not working");
}
- (void)testSerializeDict {
    Foo *foo = [Foo new];
    foo.aString = @"Yob is wicked heavy, dude";
    foo.aNumber = [NSNumber numberWithInt:100];
    foo.anArray = [NSArray arrayWithObjects:@"no really, atma rules.", @"and that guitar is so fuzzy...", nil];
    
    Bar *bar = [Bar new];
    bar.aString = @"Of course, quantum mystic is still the gold standard";
    
    foo.aBar = bar;
    
    NSDictionary *dict = [ClassMapper serialize:foo];
    STAssertNotNil(dict, @"Serialization failed");
    
    [[MapperConfig sharedInstance] mapKey:@"aBar" toClass:[Bar class]];
    
    Foo *fooCopy = [ClassMapper deserialize:dict toClass:[Foo class]];
    STAssertNotNil(fooCopy, @"Deserialization of serialized object failed for dict: %@", dict);
    
    // Scalar cocoa classes
    STAssertEqualObjects(foo.aString, fooCopy.aString, @"String values do not match. original: %@, copy: %@", 
                         foo.aString, fooCopy.aString);
    STAssertEqualObjects(foo.aNumber, fooCopy.aNumber, @"Number values do not match. original: %@, copy: %@", 
                         foo.aNumber, fooCopy.aNumber);
    
    // Array Check
    STAssertTrue([fooCopy.anArray isKindOfClass:[NSArray class]], @"Array copy failed. original: %@, copy: %@", 
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
    
    NSArray *dictArray = [ClassMapper serialize:objs];
    STAssertNotNil(dictArray, @"Serialization failed");
    STAssertTrue([dictArray count] == 1, @"Serialized array has wrong lenth: %@", dictArray);
    
    [[MapperConfig sharedInstance] mapKey:@"aBar" toClass:[Bar class]];
    
    Foo *fooCopy = [ClassMapper deserialize:[dictArray objectAtIndex:0] toClass:[Foo class]];
    STAssertNotNil(fooCopy, @"Deserialization of serialized object failed for dict: %@", [dictArray objectAtIndex:0]);
    
    // Scalar cocoa classes
    STAssertEqualObjects(foo.aString, fooCopy.aString, @"String values do not match. original: %@, copy: %@", 
                         foo.aString, fooCopy.aString);
    STAssertEqualObjects(foo.aNumber, fooCopy.aNumber, @"Number values do not match. original: %@, copy: %@", 
                         foo.aNumber, fooCopy.aNumber);
    
    // Array Check
    STAssertTrue([fooCopy.anArray isKindOfClass:[NSArray class]], @"Array copy failed. original: %@, copy: %@", 
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

#pragma mark runtime tests
- (void)testRuntime {
    STAssertTrue([ClassMapper _descClass:[NSMutableArray class] isKindOf:[NSArray class]], 
                 @"NSMutableArray is not considered a subclass of NSArray");
    STAssertFalse([ClassMapper _descClass:[NSArray class] isKindOf:[NSMutableArray class]], 
                 @"NSArray is considered a subclass of NSMutableArray");
    STAssertTrue([ClassMapper _descClass:[NSMutableArray class] isKindOf:[NSObject class]], 
                 @"NSMutableArray is not considered a subclass of NSObject");
}

#pragma mark key <-> key mapping test 
- (void)testKeyNameMapping {
    [[MapperConfig sharedInstance] mapPropertyName:@"aString" toOtherName:@"a_string"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"I might be a monkey..." forKey:@"a_string"];
    Bar *bar = [ClassMapper deserialize:dict toClass:[Bar class]];
    STAssertEquals([dict objectForKey:@"a_string"], bar.aString, @"Key mapping failed");
    
    NSDictionary *dictCopy = [ClassMapper serialize:bar];
    STAssertEqualObjects(dict, dictCopy, @"Round trip with key mapping failed. Original: %@, copy: %@", dict, dictCopy);
}

#pragma mark property preproc blocks
- (void)testStringToNumber {
    [[MapperConfig sharedInstance] preProcBlock:^id(id propertyValue) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        return [formatter numberFromString:propertyValue];
    } forPropClass:[NSNumber class]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"1.5" forKey:@"aNumber"];
    Bar *bar = [ClassMapper deserialize:dict toClass:[Bar class]];
    
    STAssertEquals(1.5, [bar.aNumber doubleValue], @"Mapping to a number doesn't work");
}
- (void)testStringToDate {
    [[MapperConfig sharedInstance] preProcBlock:^id(id propertyValue) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd zzzz"];
        return [df dateFromString:propertyValue];
    } forPropClass:[NSDate class]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"2001-01-01 GMT" forKey:@"date"];
    DateHolder *dateHolder = [ClassMapper deserialize:dict toClass:[DateHolder class]];
    
    STAssertEquals(978307200.0, [dateHolder.date timeIntervalSince1970], @"Mapping to a date doesn't work");
}
@end
