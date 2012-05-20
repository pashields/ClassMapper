//
//  MapperConfig.h
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSDictionary*(^PreProcBlock)(NSDictionary*);

/**
 The `MapperConfig` class contains all the configuration information for the `ClassMapper` library.
 
 For examples and more information on configuring `MapperConfig`, see the `ClassMapper` [wiki on github](https://github.com/pashields/ClassMapper/wiki/Configuration-Options).
 */
@interface MapperConfig : NSObject 
/**
 Used to access a singleton of the mapperconfig.
 
 The singleton will be created by default if it does not currently exist.
 
 @return the shared singleton of the mapperconfig.
 */
+ (MapperConfig *)sharedInstance;

/**
 Set a class type for a given key.
 
 When a dictionary or array is discovered with the top level object dictionary during a mapping, ClassMapper will look up that dict/array's key that has been set using this function.
 
 @param key The key that will be matched upon
 @param class The class that the data in `key` will deserialized into.
 */
- (void)mapKey:(NSString *)key toClass:(Class)class;

/**
 Allows access the current class mappings.
 
 @return A dictionary of the current key -> class mappings.
 */
- (NSDictionary *)classMappings;

/*
 * Create a bidirectional mapping between two key names. During serialization or deserialization, if a mapping is found, the new name will be substituted. So if you create a "foo" <-> "bar" mapping, anytime the key "foo" is found, it will be swapped with "bar" and vice-versa.
 */

/**
 Create a bidirectional mapping between two key names.
 
 During serialization or deserialization, if a mapping is found, the new name will be substituted. So if you create a "foo" <-> "bar" mapping, anytime the key "foo" is found, it will be swapped with "bar" and vice-versa.
 
 @param name The first name in the swappable pair.
 @param other The second name in the swappable pair.
 */
- (void)mapPropertyName:(NSString *)name toOtherName:(NSString *)other;

/*
 Allows access to the current key mappings.
 
 @return A dictionary of the current key <-> key mappings.
 */
- (NSDictionary *)propertyMappings;

/**
 Clears any mappings or blocks.
 */
- (void)clearConfig;

/*
 Finds the class associated with a given key.
 
 @param key The key to use in the lookup.
 
 @return The class associated with the key, or nil if that key has not been mapped to a class.
 */
- (Class)classFromKey:(NSString *)key;

/**
 Sets the block to be run on the serialized version of any property of a given class.
 
 @param block A block that takes the serialized data and returns a value that will deserialize into an object of class `class`.
 @param class The class that will be processed using the block.
 */
- (void)preProcBlock:(id (^)(id propertyValue))block forPropClass:(Class)class;

/**
 Sets the block to be run on the deserialized version of any property of a given class.
 
 @param block A block that takes an object of class `class` and returns a serializeable version of that object.
 @param class The class that will be processed using the block.
 */
- (void)postProcBlock:(id (^)(id propertyValue))block forPropClass:(Class)class;

/**
 Process a serialized property using a stored preProcBlock.
 
 @param property The data to be pre-processed.
 @param class The class that is associated with the preProcBlock.
 
 @return the processed property.
 */
- (id)preProcessProperty:(id)property ofClass:(Class)class;

/**
 Process a deserialized property using a stored postProcBlock.
 
 @param property The data to be post-processed.
 @param class The class that is associated with the postProcBlock.
 
 @return the processed property.
 */
- (id)postProcessProperty:(id)property ofClass:(Class)class;
#pragma mark protected
- (NSString *)_trueKey:(NSString *)key;
@end
