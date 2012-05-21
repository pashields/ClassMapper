ClassMapper
===========
`ClassMapper` is a simple obj-c library for converting classes which follow Key-Value Coding (KVC) conventions to other objects. By convention, these objects are `Foundation` objects, such as `NSDictionary` and `NSArray`. It is highly extensible, with just enough batteries included to do your average JSON -> Model conversion. It was inspired by [RestKit](https://github.com/RestKit/RestKit), which contains similar functionality. But where RestKit most certainly falls on the framework side of things, ClassMapper is meant to be used in connection with other libraries. It's a little trifle of code you would have written yourself, but now we can all share one version.

In the immortal words of [Stuart Sierra](https://twitter.com/#!/stuartsierra/statuses/20306437438): write libraries, not frameworks.

API
---
###ClassMapper
ClassMapper has two main methods, serialize and deserialize. Serialize is relatively straightforward:

``` objective-c
+ (id)serialize:(id<Serializable>)obj;
// e.g.
Foo *foo = [Foo new];
foo.aString = @"Woohoo";
[ClassMapper serialize:foo]; //NSDictionary, {"aString":"Woohoo"}
```

Of course, this wouldn't be any fun without the ability to deserialize:

``` objective-c
+ (id)deserialize:(id<Mappable>)serialized toInstance:(id)instance;
// e.g.
NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Woohoo" forKey:@"aString"];
Foo *foo = [Foo new];
foo.aString = @"NOOOOOO!!!";
[ClassMapper deserialize:dict toInstance:foo]; //Foo.aString == @"Woohoo";
```

For convenience, you can also allow ClassMapper to create the object for you:

``` objective-c
+ (id)deserialize:(id<Mappable>)serialized toClass:(Class)classType;
``` 

To learn more about these commands, visit the [wiki](https://github.com/pashields/ClassMapper/wiki).

###MapperConfig
The MapperConfig singleton allows you to modify portions of the serialization/deserialization process.

Check out MapperConfig options on the [wiki](https://github.com/pashields/ClassMapper/wiki/Configuration-Options).

Usage
------
ClassMapper officially supports [CocoaPods](https://github.com/CocoaPods/CocoaPods). You'll find our spec in the repo.

You can also add ClassMapper manually, either as source or (preferably) a static library. It is important to note two things:

* ClassMapper uses ARC, so if you don't use ARC, your best option is to include as a static library.
* If you are using the static library, the -ObjC flag must be added to "Other Linker Flags" in your xcodeproj.  See [this apple Q&A](http://developer.apple.com/library/mac/#qa/qa1490/_index.html) about categories to better understand why you need this linker flag.

Status
------
I've used ClassMapper across a number of projects and am fairly happy with it. There are a few things that we need to add support for, but if ClassMapper suits your needs now, I doubt there will be significant enough changes to the API that you will need to make big changes to your own code.

For more info, you can look at the ClassMapper.org file (emacs org-mode).

License
-------
BSD, to the max. See LICENSE file for the details.

Similar Projects
----------------
* [KeyValueObjectMapping](https://github.com/dchohfi/KeyValueObjectMapping) is a more convention over configuration system. I haven't dug too far into it, but it looks like a more batteries-included but less extensible approach. It's also available on cocoapods.
