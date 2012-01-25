ClassMapper
===========
ClassMapper is a simple obj-c library for converting classes which follow Key-Value Coding (KVC) conventions to NSDictionaries and back. It was inspired by [RestKit](https://github.com/RestKit/RestKit), which contains similar functionality. But where RestKit most certainly falls on the framework side of things, ClassMapper is meant to be used in connection with other libraries. It's a little trifle of code you would have written yourself, but now we can all share one version.

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
ClassMapper officially supports [CocoaPods](https://github.com/CocoaPods/CocoaPods). We aren't hosted there yet, but once we reach 0.0.1, we can submit.

You can also add ClassMapper manually, either as source or (preferably) a static library. It is important to note two things:

* ClassMapper uses ARC, so if you don't use ARC, your best option is to include as a static library.
* If you are using the static library, the -ObjC flag must be added to "Other Linker Flags" in your xcodeproj.  See [this apple Q&A](http://developer.apple.com/library/mac/#qa/qa1490/_index.html) about categories to better understand why you need this linker flag.

Status
------
So far this is a just a little project of mine. The long term goal is to build myself a little stack of libraries that can be used to interact painlessly with RESTful APIs. I hope to write as few of those libraries as possible. The API has been very unstable, though I expect that to lessen as time goes on. We do have a fairly large test suite, though I do not think it covers all possible cases/semantics.

I am utilizing this in a personal project of mine (integrated into AFNetworking and consuming JSON). If you are interested in more immediate access to this work, feel free to ping me.

For more info, you can look at the ClassMapper.org file (emacs org-mode).

License
-------
BSD, to the max. See LICENSE file for the details.
