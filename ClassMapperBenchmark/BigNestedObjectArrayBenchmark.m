//
//  BigNestedObjectArrayBenchmark.m
//  ClassMapper
//
//  Created by Patrick Shields on 9/23/12.
//  Copyright (c) 2012 Patrick Shields. All rights reserved.
//

#import "BigNestedObjectArrayBenchmark.h"
#import "ClassMapper.h"

@class stats, photos, menu, checkin, venue, comments, source, contact, location, beenHere, likes;
@interface stats : NSObject
@property(nonatomic,strong)NSNumber *checkinsCount;
@property(nonatomic,strong)NSNumber *tipCount;
@property(nonatomic,strong)NSNumber *usersCount;
@end
@implementation stats
@end

@interface photos : NSObject
@property(nonatomic,strong)NSNumber *count;
@property(nonatomic,strong)NSArray *items;
@end
@implementation photos
@end

@interface menu : NSObject
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *mobileUrl;
@property(nonatomic,strong)NSString *type;
@end
@implementation menu
@end

@interface checkin : NSObject
@property(nonatomic,strong)NSNumber *like;
@property(nonatomic,strong)photos *photos;
@property(nonatomic,strong)venue *venue;
@property(nonatomic,strong)comments *comments;
@property(nonatomic,strong)source *source;
@property(nonatomic,strong)NSNumber *timeZoneOffset;
@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSString *id;
@property(nonatomic,strong)NSNumber *createdAt;
@property(nonatomic,strong)likes *likes;
@end
@implementation checkin
@end

@interface venue : NSObject
@property(nonatomic,strong)likes *likes;
@property(nonatomic,strong)NSNumber *verified;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)menu *menu;
@property(nonatomic,strong)contact *contact;
@property(nonatomic,strong)location *location;
@property(nonatomic,strong)beenHere *beenHere;
@property(nonatomic,strong)stats *stats;
@property(nonatomic,strong)NSString *id;
@property(nonatomic,strong)NSArray *categories;
@property(nonatomic,strong)NSNumber *like;
@end
@implementation venue
@end

@interface comments : NSObject
@property(nonatomic,strong)NSNumber *count;
@property(nonatomic,strong)NSArray *items;
@end
@implementation comments
@end

@interface source : NSObject
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *name;
@end
@implementation source
@end

@interface contact : NSObject
@property(nonatomic,strong)NSString *phone;
@property(nonatomic,strong)NSString *formattedPhone;
@end
@implementation contact
@end

@interface location : NSObject
@property(nonatomic,strong)NSString *city;
@property(nonatomic,strong)NSString *country;
@property(nonatomic,strong)NSNumber *lat;
@property(nonatomic,strong)NSString *state;
@property(nonatomic,strong)NSString *crossStreet;
@property(nonatomic,strong)NSString *address;
@property(nonatomic,strong)NSString *postalCode;
@property(nonatomic,strong)NSNumber *lng;
@end
@implementation location
@end

@interface beenHere : NSObject
@property(nonatomic,strong)NSNumber *count;
@property(nonatomic,strong)NSNumber *marked;
@end
@implementation beenHere
@end

@interface likes : NSObject
@property(nonatomic,strong)NSNumber *count;
@property(nonatomic,strong)NSArray *groups;
@end
@implementation likes
@end

#define NUM_ELEMENTS 10000
//#define NUM_ELEMENTS 1
@implementation BigNestedObjectArrayBenchmark
- (void)runWithCompletionBlock:(void (^)(CFTimeInterval))completion
{
    NSArray *array = [self genArray];
#pragma mark
    BENCH(NSArray *copy __attribute__((unused)) = [ClassMapper deserialize:array toClass:[checkin class]])
    completion(duration);
}
- (NSArray *)genArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:NUM_ELEMENTS];
    NSString *jsonStr = @"{\"id\":\"4fdde22ce4b01998033441d6\",\"createdAt\":1339941420,\"type\":\"checkin\",\"timeZoneOffset\":-240,\"venue\":{\"id\":\"4ad87ddef964a520c01121e3\",\"name\":\"Foster's Market\",\"contact\":{\"phone\":\"9194893944\",\"formattedPhone\":\"(919) 489-3944\"},\"location\":{\"address\":\"2694 Durham Chapel Hill Blvd\",\"crossStreet\":\"btwn Legion Ave & Bedford St\",\"lat\":35.97430008819881,\"lng\":-78.93154511729202,\"postalCode\":\"27707\",\"city\":\"Durham\",\"state\":\"NC\",\"country\":\"United States\"},\"categories\":[{\"id\":\"4bf58dd8d48988d1c5941735\",\"name\":\"Sandwich Place\",\"pluralName\":\"Sandwich Places\",\"shortName\":\"Sandwiches\",\"icon\":{\"prefix\":\"https://foursquare.com/img/categories_v2/food/sandwiches_\",\"suffix\":\".png\"},\"primary\":true}],\"verified\":false,\"stats\":{\"checkinsCount\":1989,\"usersCount\":1037,\"tipCount\":14},\"url\":\"http://fostersmarket.com/\",\"likes\":{\"count\":0,\"groups\":[]},\"like\":false,\"menu\":{\"type\":\"foodAndBeverage\",\"url\":\"https://foursquare.com/v/fosters-market/4ad87ddef964a520c01121e3/menu\",\"mobileUrl\":\"https://foursquare.com/v/4ad87ddef964a520c01121e3/device_menu\"},\"beenHere\":{\"count\":7,\"marked\":false}},\"likes\":{\"count\":0,\"groups\":[]},\"like\":false,\"photos\":{\"count\":0,\"items\":[]},\"comments\":{\"count\":0,\"items\":[]},\"source\":{\"name\":\"foursquare for iPhone\",\"url\":\"https://foursquare.com/download/#/iphone\"}}";
    for (int i=0; i < NUM_ELEMENTS; i++) {
        [array addObject:[NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:nil]];
    }
    return array;
}
@end
