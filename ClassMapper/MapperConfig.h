//
//  MapperConfig.h
//  ClassMapper
//
//  Created by Patrick Shields on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapperConfig : NSObject {
    NSMutableDictionary *mappings_;
}
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
 * A dictionary of the current mappings.
 */
- (NSDictionary*)mappings;
/*
 * Remove all currently set mappings
 */
- (void)clearMappings;
@end
