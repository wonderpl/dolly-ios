#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDictionary+Validation.h"


@implementation ChannelOwner

#pragma mark - Object factory

+ (ChannelOwner *) instanceFromChannelOwner: (ChannelOwner *) existingChannelOwner
                                  andViewId: (NSString *) viewId
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    
    
    ChannelOwner *copyChannelOwner = [ChannelOwner insertInManagedObjectContext: managedObjectContext];
    
    if(!existingChannelOwner || !copyChannelOwner)
        return nil;
    
    copyChannelOwner.uniqueId = existingChannelOwner.uniqueId;
    
    copyChannelOwner.thumbnailURL = existingChannelOwner.thumbnailURL;
    
    copyChannelOwner.displayName = existingChannelOwner.displayName;
    
    copyChannelOwner.channelOwnerDescription = existingChannelOwner.channelOwnerDescription;
    copyChannelOwner.followersTotalCount = existingChannelOwner.followersTotalCount;
    
    copyChannelOwner.viewId = viewId ? viewId : @"";
    
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        for (Channel *channel in existingChannelOwner.channels)
        {
            Channel *copyChannel = [Channel	 instanceFromChannel: channel
                                                       andViewId: viewId
                                       usingManagedObjectContext: existingChannelOwner.managedObjectContext
                                             ignoringObjectTypes: ignoringObjects | kIgnoreChannelOwnerObject];

            [copyChannelOwner.channelsSet
             addObject: copyChannel];
        }
    }
    
    if (!(ignoringObjects & kIgnoreSubscriptionObjects))
    {
        for (Channel *channel in existingChannelOwner.subscriptions)
        {
            Channel *copyChannel = [Channel	 instanceFromChannel: channel
                                                       andViewId: viewId
                                       usingManagedObjectContext: existingChannelOwner.managedObjectContext
                                             ignoringObjectTypes: ignoringObjects];
            
            
            [copyChannelOwner.subscriptionsSet
             addObject: copyChannel];
        }
    }
    
    return copyChannelOwner;
}


+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                      ignoringObjectTypes: (IgnoringObjects) ignoringObjects;
{
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
    {
        return nil;
    }
    
    NSString *uniqueId = dictionary[@"id"];
    
    if ([uniqueId isKindOfClass: [NSNull class]])
    {
        return nil;
    }
    
    ChannelOwner *instance = [ChannelOwner insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    
    [instance setAttributesFromDictionary: dictionary
                      ignoringObjectTypes: ignoringObjects];
    
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog(@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    self.thumbnailURL = [dictionary objectForKey: @"avatar_thumbnail_url"
                                     withDefault: @""];
    
    self.displayName = [dictionary objectForKey: @"display_name"
                                    withDefault: @""];
    
    self.username = [dictionary objectForKey: @"username"
                                 withDefault: @""];
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: @0];
    
    
//    NSLog(@"%@", dictionary);
    
//    self.channelOwnerDescription = [dictionary objectForKey: @"description"];
    
//self.followersTotalCount = [dictionary objectForKey: @"description"];

    
    BOOL hasChannels = YES;
    
    NSDictionary *channelsDictionary = dictionary[@"channels"];
    
    if ([channelsDictionary isKindOfClass: [NSNull class]])
    {
        hasChannels = NO;
    }
    
    NSArray *channelItemsArray = channelsDictionary[@"items"];
    
    if ([channelItemsArray isKindOfClass: [NSNull class]])
    {
        hasChannels = NO;
    }
    
    if (!(ignoringObjects & kIgnoreChannelObjects) && hasChannels)
    {
        // viewId is @"Profile" because this is the only place it is passed
        
        NSMutableDictionary *channelInsanceByIdDictionary = [[NSMutableDictionary alloc] initWithCapacity: self.channels.count];
        
        for (Channel *ch in self.channels)
        {
            channelInsanceByIdDictionary[ch.uniqueId] = ch;
        }
        
        [self.channelsSet removeAllObjects];
        
        NSString *newUniqueId;
        
        for (NSDictionary *channelDictionary in channelItemsArray)
        {
            Channel *channel;
            
            newUniqueId = [channelDictionary objectForKey: @"id"
                                              withDefault: @""];
            
            channel = channelInsanceByIdDictionary[newUniqueId];
            
            if (!channel)
            {
                channel = [Channel instanceFromDictionary: channelDictionary
                                usingManagedObjectContext: self.managedObjectContext
                                      ignoringObjectTypes: ignoringObjects | kIgnoreChannelOwnerObject];
            }
            else
            {
                [channelInsanceByIdDictionary removeObjectForKey: newUniqueId];
            }
            
            if (!channel)
            {
                continue;
            }
            
            channel.viewId = self.viewId;
            
            channel.markedForDeletionValue = NO;
            
            channel.position = [dictionary objectForKey: @"position"
                                            withDefault: @0];

            [self.channelsSet addObject: channel];
        }
        
        for (id key in channelInsanceByIdDictionary)
        {
            Channel *ch = channelInsanceByIdDictionary[key];
            
            if (!ch)
            {
                continue;
            }
            
            [self.managedObjectContext deleteObject: ch];
        }
    }
}


#pragma mark - Channels

- (void) setSubscriptionsDictionary: (NSDictionary *) subscriptionsDictionary
{
    NSDictionary *channeslDictionary = subscriptionsDictionary[@"channels"];
    
    if (!channeslDictionary)
    {
        return;
    }
    
    NSArray *itemsArray = channeslDictionary[@"items"];
    
    if (!itemsArray)
    {
        return;
    }
    
    NSMutableDictionary *subscriptionInsancesByIdDictionary = [[NSMutableDictionary alloc] initWithCapacity: self.subscriptions.count];
    
    for (Channel *su in self.subscriptions)
    {
        subscriptionInsancesByIdDictionary[su.uniqueId] = su;
    }
    
    [self.subscriptionsSet removeAllObjects];
    
    for (NSDictionary *subscriptionChannel in itemsArray)
    {
        NSString *uniqueId = subscriptionChannel[@"id"];
        
        if (!uniqueId || ![uniqueId isKindOfClass: [NSString class]])
        {
            continue;
        }
        
        Channel *channel = subscriptionInsancesByIdDictionary[uniqueId];
        
        if (!channel)
        {
            channel = [Channel instanceFromDictionary: subscriptionChannel
                            usingManagedObjectContext: self.managedObjectContext
                                  ignoringObjectTypes: kIgnoreVideoInstanceObjects];
        }
        else
        {
            [subscriptionInsancesByIdDictionary removeObjectForKey: uniqueId];
        }
        
        if (!channel)
        {
            continue;
        }
        
        [self addSubscriptionsObject: channel];
        
        channel.viewId = self.viewId;
    }
    
    for (id key in subscriptionInsancesByIdDictionary)
    {
        Channel *su = subscriptionInsancesByIdDictionary[key];
        
        if (!su)
        {
            continue;
        }
        
        [self.managedObjectContext
         deleteObject: su];
    }
}


- (void) addChannelsObject: (Channel *) newChannel
{
    [self.channelsSet addObject: newChannel];
}


- (void) removeChannelsObject: (Channel *) oldChannel
{
    [self.channelsSet removeObject: oldChannel];
}


#pragma mark - Accessors

- (void) addSubscriptionsObject: (Channel *) value_
{
    [self.subscriptionsSet addObject: value_];
}


- (void) removeSubscriptions: (NSOrderedSet *) value_
{
    [self.subscriptionsSet removeObject: value_];
}


#pragma mark - Helper methods

- (NSDictionary *) channelsDictionary
{
    NSMutableDictionary *cDictionary = [NSMutableDictionary dictionary];
    
    for (Channel *channel in self.channels)
    {
        cDictionary[channel.uniqueId] = channel;
    }
    
    return [NSDictionary dictionaryWithDictionary: cDictionary];
}


- (NSString *) description
{
    NSMutableString *ownerDescription = [NSMutableString stringWithFormat: @"ChannelOwner id:%i, username: '%@'", [self.uniqueId intValue], self.displayName];
    
    [ownerDescription appendFormat: @"has %i channels owned", self.channels.count];
    
    if (self.channels.count == 0)
    {
        [ownerDescription appendString: @"."];
    }
    else
    {
        [ownerDescription appendString: @":"];
        
        for (Channel *channel in self.channels)
        {
            [ownerDescription appendFormat:@"\n%@ (%@)",
             [channel.subscribedByUser boolValue] ? @"+" : @"-",  [channel.title isEqualToString:@""] ? channel.title : @"No Title"];
        }
    }
    
    return ownerDescription;
}


- (NSString *) thumbnailSmallUrl
{
    return [self.thumbnailURL stringByReplacingOccurrencesOfString: kImageSizeStringReplace
                                                        withString: @"thumbnail_small"];
}


- (NSString *) thumbnailMediumUrl
{
    return self.thumbnailURL; // by default it is set for medium
}


- (NSString *) thumbnailLargeUrl
{
    return [self.thumbnailURL stringByReplacingOccurrencesOfString: kImageSizeStringReplace
                                                        withString: @"thumbnail_large"];
}

@end
