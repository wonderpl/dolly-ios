#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "FeedItem.h"
#import "VideoInstance.h"

@implementation FeedItem

@synthesize placeholder;


+ (FeedItem *) instanceFromResource: (AbstractCommon *) object
{
    FeedItem *instance = [FeedItem insertInManagedObjectContext: object.managedObjectContext];
    
    if (!instance)
    {
        return nil;
    }
    
    instance.uniqueId = [NSString stringWithString: object.uniqueId];
    instance.resourceId = [NSString stringWithString: object.uniqueId];
    instance.coverIndexes = [NSString stringWithString: object.uniqueId];

    // pass date according to type
    instance.itemTypeValue = FeedItemTypeLeaf;
    
    if ([object isKindOfClass: [VideoInstance class]])
    {
        VideoInstance *videoInstance = (VideoInstance *) object;
        instance.dateAdded = videoInstance.dateAdded;
        instance.resourceTypeValue = FeedItemResourceTypeVideo;
        instance.positionValue = videoInstance.positionValue;
    }
    else if ([object isKindOfClass: [Channel class]])
    {
        Channel *channel = (Channel *) object;
        instance.dateAdded = channel.datePublished;
        instance.resourceTypeValue = FeedItemResourceTypeChannel;
        instance.positionValue = channel.positionValue;
    }
    
    instance.itemCountValue = 1;
    instance.viewId = object.viewId;
    
    return instance;
}


+ (FeedItem *) instanceFromDictionary: (NSDictionary *) dictionary
                               withId: (NSString *) aid
            usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if (!aid || !dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
    {
        return nil;
    }
    
    FeedItem *instance = [FeedItem insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = aid;
    
    [instance setAttributesFromDictionary: dictionary];
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
{
    NSString *n_title = dictionary[@"title"];
    
    if (n_title && [n_title isKindOfClass: [NSString class]])
    {
        self.title = n_title;
    }
    
    self.itemTypeValue = FeedItemTypeAggregate;
    
    NSString *n_type = dictionary[@"type"]; // "type": "video" | "channel"
    
    if (n_type)
    {
        if ([n_type isEqualToString: @"video"])
        {
            self.resourceTypeValue = FeedItemResourceTypeVideo;
        }
        else if ([n_type isEqualToString: @"channel"])
        {
            self.resourceTypeValue = FeedItemResourceTypeChannel;
        }
    }
    
    NSNumber *n_count = dictionary[@"count"];
    
    if (n_count && [n_count isKindOfClass: [NSNumber class]])
    {
        self.itemCountValue = n_count.integerValue;
    }
    
    self.positionValue = INT_MAX; // heuristic, place it at the end
    
    self.dateAdded = [NSDate distantPast];
}


- (NSArray *) coverIndexArray
{
    return [self.coverIndexes componentsSeparatedByString: @":"];
}


- (void) addFeedItemsObject: (FeedItem *) value_
{
    [self.feedItemsSet addObject: value_];
    self.positionValue = MIN(self.positionValue, value_.positionValue);
    self.dateAdded = [self.dateAdded laterDate: value_.dateAdded];
}


- (NSString *) description
{
    NSString *typeString = self.itemTypeValue == FeedItemTypeAggregate ? @"AGR" : @"FDI";
    NSString *resourceString = self.resourceTypeValue == FeedItemResourceTypeChannel ? @"Channel" : @"VideoInstance";
    NSMutableString *responceString = [NSMutableString stringWithFormat: @"[FeedItem %@ (type:'%@', rsc:'%@', count:%i)]", self.uniqueId, typeString, resourceString, self.itemCountValue];
    
    return responceString;
}


@end
