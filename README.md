ClassMapper
===========
ClassMapper is a simple obj-c library for converting classes which follow Key-Value Coding (KVC) conventions to NSDictionaries and back. It was inspired by [RestKit](https://github.com/RestKit/RestKit), which contains similar functionality. But where RestKit most certainly falls on the framework side of things, ClassMapper is meant to be used in connection with other libraries. It's a little trifle of code you would have written yourself, but now we can all share one version.

API
---
###ClassMapper
The ClassMapper object contains two primary methods:

``` objective-c
+ (NSDictionary*)objToDict:(id)object;
```
The +objToDict method behaves as expected. Arrays and Nested objects are handled using NSArray and NSDictionary respectively.

``` objective-c
+ (id)dict:(NSDictionary*)dict toClass:(Class)classType;
```
The +dict: toClass: method is a little bit more subtle. As long as the given class has no nesting, the mapper will handle cocoa objects and arrays without additional input. 

However, if we have nested objects à la

``` objective-c
@interface Foo : NSObject
@property (nonatomic, retain)NSString *str;
@end
@interface Bar : NSObject
@property (nonatomic, retain)Foo *foo;
@end
```
We need to tell ClassMapper that when it encounters the NSDictionary key @"foo" with a value that is an NSDictionary or NSArray, it should deserialize into a Foo object. To do this, we use a singleton MapperConfig object. 

###MapperConfig
To create the mapping we use the following method:

``` objective-c
- (void)mapKey:(NSString*)key toClass:(Class)class;
```

To continue with the example from above, we would add a mapping between the "foo" key and the Foo class.

``` objective-c
[[MapperConfig sharedInstance] mapKey:@"foo" toClass:[Foo class]];
```
Status
------
So far this is a just a little toy project of mine. The long term goal is to build myself a little stack of libraries that can be used to interact painlessly with RESTful APIs. I hope to write as few of those libraries as possible. Consider this current version unstable and barely tested. The code is short and simple though, so you can evaluate it on your own. Future work is:

* Add support to work in non-ARC projects, or at least instructions on how to deal with this.
* More thorough search for edge cases in the KVC system that we should be watching out for. Adding test cases to cover these new edge cases.
* Figuring out a better solution to the nested objects problem. The MapperConfig system is infinitely less than ideal, but does the job in simple cases. If a better solution cannot be found, there needs to be a way to override the MapperConfig for certain calls.
* Possibly refining the API to optimize the use of ClassMapper with other libraries. This is not inherently useful on it's own, but combined with a serialization mechanism (JSON, XML, ...) and good networking library, magic could happen. In particular, we need to prepare the classes to be used in a multi-threaded environment with GCD.

License
-------
BSD, to the max. See LICENSE file for the details.