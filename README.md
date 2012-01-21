ClassMapper
===========
ClassMapper is a simple obj-c library for converting classes which follow Key-Value Coding (KVC) conventions to NSDictionaries and back. It was inspired by [RestKit](https://github.com/RestKit/RestKit), which contains similar functionality. But where RestKit most certainly falls on the framework side of things, ClassMapper is meant to be used in connection with other libraries. It's a little trifle of code you would have written yourself, but now we can all share one version.

API
---
###ClassMapper
The ClassMapper object contains two primary methods:

``` objective-c
+ (id)serialize:(id<Serializable>)obj;
```
The +serialize method behaves as expected. Arrays and Nested objects are handled using NSArray and NSDictionary respectively. The only primatives currently supported are NSString and NSNumber. All other objects will be serialized according to KVC. For custom behavior, you can add a category that causes the class to implement the Serializable protocol.

``` objective-c
+ (id)dict:(NSDictionary*)dict toClass:(Class)classType;
```
The +dict: toClass: method is a little bit more subtle. The mapper will work as expected, except when the class contains an NSArray containing Objects that have been converted into NSDictionaries and should be automatically converted into instances of a particular class. 

However, if we have an array à la

``` objective-c
@interface Foo : NSObject
@property (nonatomic, retain)NSString *str;
@end
@interface Bar : NSObject
@property (nonatomic, retain)NSArray *foos;
@end
/* -------------------------- */
Bar *bar = [Bar new];
Foo *fooA = [Foo new];
[bar.foos addObject:fooA];
Foo *fooB = [Foo new];
[bar.foos addObject:fooB];
```
We need to tell ClassMapper that when it encounters the NSDictionary key @"foos" with a value that is an NSArray, it should deserialize into a Foo object. To do this, we use a singleton MapperConfig object. 

###MapperConfig
To create the mapping we use the following method:

``` objective-c
- (void)mapKey:(NSString*)key toClass:(Class)class;
```

To continue with the example from above, we would add a mapping between the "foos" key and the Foo class.

``` objective-c
[[MapperConfig sharedInstance] mapKey:@"foos" toClass:[Foo class]];
```

Check out additional MapperConfig options on the [wiki](https://github.com/pashields/ClassMapper/wiki/Configuration-Options).
Usage
------
ClassMapper officially supports [CocoaPods](https://github.com/CocoaPods/CocoaPods). We aren't hosted there yet, but once we reach 0.0.1, we can submit.

You can also add ClassMapper manually, either as source or (preferably) a static library. It is important to note two things:

* ClassMapper uses ARC, so if you don't use ARC, your best option is to include as a static library.
* If you are using the static library, the -ObjC flag must be added to "Other Linker Flags" in your xcodeproj.  See [this apple Q&A](http://developer.apple.com/library/mac/#qa/qa1490/_index.html) about categories to better understand why we need this linker flag.

Status
------
So far this is a just a little toy project of mine. The long term goal is to build myself a little stack of libraries that can be used to interact painlessly with RESTful APIs. I hope to write as few of those libraries as possible. Consider this current version unstable and barely tested. The code is short and simple though, so you can evaluate it on your own.

For more info, you can look at ClassMapper.org (emacs org-mode).

License
-------
BSD, to the max. See LICENSE file for the details.
