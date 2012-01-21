//
//  MapperConfig.h
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 Patrick Shields. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSDictionary*(^PreProcBlock)(NSDictionary*);

@interface MapperConfig : NSObject {
    NSMutableDictionary *classMappings_;
    NSMutableDictionary *propNameMappings_;
    PreProcBlock preProcBlock_;
}
/*
 * A block of code used to strip out transmission metadata
 * from any dict that might be passed. This is mostly a
 * conveinance for when you might want to hook ClassMapper
 * into a networking library setup.
 */
@property(nonatomic,copy)PreProcBlock preProcBlock;
/*
 * Returns an instance of the mapper config that will
 * be used globaly.
 */
+ (MapperConfig*)sharedInstance;
/*
 * Set a class type for a given key. When a a dictionary
 * or array is discovered with the top level object dictionary
 * during a mapping, ClassMapper will look up that dict/array's
 * key that has been set using this function.
 */
- (void)mapKey:(NSString*)key toClass:(Class)class;
/*
 * A dictionary of the current key -> class mappings.
 */
- (NSDictionary*)classMappings;
/*
 * Create a bidirectional mapping between two key names. During
 * serialization or deserialization, if a mapping is found, the
 * new name will be substituted. So if you create a "foo" <-> "bar"
 * mapping, anytime the key "foo" is found, it will be swapped with "bar"
 * and vice-versa.
 */
- (void)mapPropertyName:(NSString*)name toOtherName:(NSString*)other;
/*
 * A dictionary of the current key <-> key mappings.
 */
- (NSDictionary*)propertyMappings;
/*
 * Clear any mappings or blocks.
 */
- (void)clearConfig;

#pragma mark protected
- (NSString*)_trueKey:(NSString*)key;
@end
