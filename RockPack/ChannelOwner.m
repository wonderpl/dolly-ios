#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDictionary+Validation.h"
#import "SYNActivityManager.h"
#import "SYNAppDelegate.h"
#import "NSString+Utils.h"
#import "VideoInstance.h"
#import "SYNActivityManager.h"
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
    
    copyChannelOwner.totalVideosValueChannel = existingChannelOwner.totalVideosValueChannel;
    copyChannelOwner.totalVideosValueSubscriptions = existingChannelOwner.totalVideosValueSubscriptions;

    copyChannelOwner.displayName = existingChannelOwner.displayName;
	copyChannelOwner.username = existingChannelOwner.username;
    
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

+ (ChannelOwner *)channelOwnerWithUsername:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[ChannelOwner entityName]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"username ==[c] %@", username]];
	
	ChannelOwner *channelOwner = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] firstObject];
	if (!channelOwner) {
		channelOwner = [self instanceFromDictionary:@{ @"username" : username }
						  usingManagedObjectContext:managedObjectContext
								ignoringObjectTypes:kIgnoreNothing];
	}
	
	return channelOwner;
}

+ (NSDictionary *)channelOwnersFromDictionaries:(NSArray *)dictionaries
						 inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	
	NSArray *channelOwnerIds = [dictionaries valueForKey:@"id"];
	
	NSMutableDictionary *existingChannelOwners = [[self existingChannelOwnersWithIds:channelOwnerIds
															  inManagedObjectContext:managedObjectContext] mutableCopy];
	
	NSMutableDictionary *channelOwners = [NSMutableDictionary dictionary];
	for (NSDictionary *dictionary in dictionaries) {
        if ([dictionary isKindOfClass:[NSNull class]]) continue;
		NSString *channelOwnerId = dictionary[@"id"];

		ChannelOwner *channelOwner = existingChannelOwners[channelOwnerId];
		if (!channelOwner) {
			channelOwner = [self insertInManagedObjectContext:managedObjectContext];
			
			channelOwner.uniqueId = channelOwnerId;
			
			existingChannelOwners[channelOwnerId] = channelOwner;
		}
		
		[channelOwner setAttributesFromDictionary:dictionary];
		
		channelOwners[channelOwnerId] = channelOwner;
	}
	
	return channelOwners;
}

- (void)setAttributesFromDictionary:(NSDictionary *)dictionary {
	
    self.uniqueId = [dictionary objectForKey:@"id"
								 withDefault: @""];
    
    self.thumbnailURL = [dictionary objectForKey: @"avatar_thumbnail_url"
                                     withDefault: @""];
    
    self.displayName = [dictionary objectForKey: @"display_name"
                                    withDefault: @""];
    
    self.username = [dictionary objectForKey: @"username"
                                 withDefault: @""];
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: @0];

    self.subscriptionCount = [dictionary objectForKey:@"subscription_count"
                                          withDefault:@0];
    
    self.subscribersCount =[dictionary objectForKey:@"subscriber_count"
                                        withDefault:@0];
    
    self.coverPhotoURL = [dictionary objectForKey:@"profile_cover_url"
                                      withDefault:@""];
    
    self.channelOwnerDescription = [dictionary objectForKey:@"description"
                                                withDefault:@""];
    
    self.totalVideosValueSubscriptions = [dictionary objectForKey: @"subscription_count" withDefault:0];
}


+ (NSDictionary *)existingChannelOwnersWithIds:(NSArray *)videoIds
						inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uniqueId IN %@", videoIds]];
	
	NSArray *videos = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
	
	return [NSDictionary dictionaryWithObjects:videos forKeys:[videos valueForKey:@"uniqueId"]];
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
    
    self.uniqueId = [dictionary objectForKey:@"id"
                        withDefault: @""];
    
    self.thumbnailURL = [dictionary objectForKey: @"avatar_thumbnail_url"
                                     withDefault: @""];
    
    self.displayName = [dictionary objectForKey: @"display_name"
                                    withDefault: @""];
    
    self.username = [dictionary objectForKey: @"username"
                                 withDefault: @""];
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: @0];
    
    self.subscriptionCount = [dictionary objectForKey:@"subscription_count"
                                          withDefault:@0];
    
    self.subscribersCount =[dictionary objectForKey:@"subscriber_count"
                                        withDefault:@0];
    
    self.coverPhotoURL = [dictionary objectForKey:@"profile_cover_url"
                                      withDefault:@""];
    
    self.channelOwnerDescription = [dictionary objectForKey:@"description"
                                                withDefault:@""];
    
    if (dictionary[@"tracking_code"]) {
        [[SYNActivityManager sharedInstance] addObjectFromDict:dictionary];
    }
    self.totalVideosValueSubscriptions = [dictionary objectForKey: @"subscription_count" withDefault:0];

    BOOL hasChannels = YES;
    
    NSDictionary *channelsDictionary = dictionary[@"channels"];
    
    
    if ([channelsDictionary isKindOfClass: [NSNull class]])
    {
        hasChannels = NO;
    }
    
    NSArray *channelItemsArray = channelsDictionary[@"items"];
    
    
    self.totalVideosValueChannel =[channelsDictionary objectForKey: @"total" withDefault:@0];
    

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
                [[SYNActivityManager sharedInstance] addObjectFromDict:channelDictionary];
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
            
            channel.subscribersCount = [channelDictionary objectForKey:@"subscriber_count"
                                                         withDefault:@-1];
            
            channel.totalVideosValue = channelDictionary[@"videos"][@"total"];
            
            
            if (channel.favouritesValue)
            {
                SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                
                if ([appDelegate.currentUser.uniqueId isEqualToString:self.uniqueId])
                {
                    channel.title = [NSString stringWithFormat:@"My %@", NSLocalizedString(@"FAVORITES", nil)];
                }
                else
                {
					NSString *displayName = [dictionary[@"display_name"] apostrophisedString];
                    channel.title = [NSString stringWithFormat:@"%@ %@", displayName, NSLocalizedString(@"FAVORITES", nil)];
                }
            }

            channel.title = channelDictionary[@"title"];
            channel.channelDescription = channelDictionary[@"description"];

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
        
        self.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:self.uniqueId];
    }
}


#pragma mark - Channels

- (void) setSubscriptionsDictionary: (NSDictionary *) subscriptionsDictionary
{
    NSDictionary *channeslDictionary = subscriptionsDictionary[@"users"];
    
    if (!channeslDictionary)
    {
        return;
    }
    
    self.totalVideosValueSubscriptions = [channeslDictionary objectForKey: @"total"];
    
    
    NSArray *itemsArray = channeslDictionary[@"items"];
    
    if (!itemsArray)
    {
        return;
    }
    
    NSMutableDictionary *subscriptionInsancesByIdDictionary = [[NSMutableDictionary alloc] initWithCapacity: self.subscriptions.count];
    
    
    for (ChannelOwner *su in self.subscriptions)
    {
        subscriptionInsancesByIdDictionary[su.uniqueId] = su;
    }
    
    [self.userSubscriptionsSet removeAllObjects];
    
    for (NSDictionary *subscriptionChannel in itemsArray)
    {
        NSString *uniqueId = subscriptionChannel[@"id"];
        
        if (!uniqueId || ![uniqueId isKindOfClass: [NSString class]])
        {
            continue;
        }
        
        ChannelOwner *channelOwner = subscriptionInsancesByIdDictionary[uniqueId];
        
        if (!channelOwner)
        {
            channelOwner = [ChannelOwner instanceFromDictionary: subscriptionChannel
                                      usingManagedObjectContext: self.managedObjectContext
                                            ignoringObjectTypes: kIgnoreVideoInstanceObjects];
		}
        else
        {
            [subscriptionInsancesByIdDictionary removeObjectForKey: uniqueId];
        }
        
        if (!channelOwner)
        {
            continue;
        }
        
        channelOwner.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:channelOwner.uniqueId];
		
        [[SYNActivityManager sharedInstance] addObjectFromDict:subscriptionChannel];
        [self.userSubscriptionsSet addObject: channelOwner];
        
    }
    
    for (id key in subscriptionInsancesByIdDictionary)
    {
        ChannelOwner *su = subscriptionInsancesByIdDictionary[key];
        
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
    value_.subscribedByUserValue = NO;
    [self.subscriptionsSet addObject: value_];
}


- (void) removeSubscriptions: (NSOrderedSet *) value_
{
    for (Channel *tmpChannel in value_) {
        tmpChannel.subscribedByUserValue = NO;
    }
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
    NSMutableString *ownerDescription = [NSMutableString stringWithFormat: @"ChannelOwner id:%@, username: '%@'", self.uniqueId, self.displayName];
    
    [ownerDescription appendFormat: @"has %@ channels owned", @([self.channels count])];
    
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


- (NSString *) thumbnailLargeUrl
{
    return [self.thumbnailURL stringByReplacingOccurrencesOfString: kImageSizeStringReplace
                                                        withString: @"thumbnail_large"];
}


- (void) addChannelsFromDictionary : (NSDictionary *) channelsDictionary
{
    NSDictionary *itemDict = channelsDictionary[@"channels"];
    if (!itemDict || ![itemDict isKindOfClass: [NSDictionary class]])
    {
        return;
    }
    
    NSArray *items = [itemDict objectForKey:@"items"];
    
	
	NSMutableDictionary *channelsInsancesByIdDictionary = [[NSMutableDictionary alloc] initWithCapacity: self.subscriptions.count];
	
    for (ChannelOwner *chan in self.channels)
    {
        channelsInsancesByIdDictionary[chan.uniqueId] = chan;
    }

	
    for (NSDictionary *channelsDictionary in items) {
        
		Channel *channel = channelsInsancesByIdDictionary[channelsDictionary[@"id"]];
		
        
        if (channel) {
			[self.subscriptionsSet removeObject:channel];
		}
		
		channel = [Channel instanceFromDictionary: channelsDictionary
								  usingManagedObjectContext: self.managedObjectContext
										ignoringObjectTypes: kIgnoreVideoInstanceObjects];
				
        channel.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:self.uniqueId];
				
        [self.channelsSet addObject:channel];
    }
}

- (void) addSubscriptionsFromDictionary : (NSDictionary *) subscriptionsDictionary
{
    
    NSDictionary *itemDict = subscriptionsDictionary[@"users"];
    if (!itemDict || ![itemDict isKindOfClass: [NSDictionary class]])
    {
        return;
    }
    
    NSArray *items = [itemDict objectForKey:@"items"];
	NSMutableDictionary *subscriptionInsancesByIdDictionary = [[NSMutableDictionary alloc] initWithCapacity: self.subscriptions.count];
	
    for (ChannelOwner *su in self.subscriptions)
    {
        subscriptionInsancesByIdDictionary[su.uniqueId] = su;
    }
	
    for (NSDictionary *channelDictionary in items) {
		
		ChannelOwner *channelOwner = subscriptionInsancesByIdDictionary[channelDictionary[@"id"]];
		
        
        if (channelOwner) {
			[self.subscriptionsSet removeObject:channelOwner];
		}
		
		
		channelOwner = [ChannelOwner instanceFromDictionary: channelDictionary
						usingManagedObjectContext: self.managedObjectContext
							  ignoringObjectTypes: kIgnoreVideoInstanceObjects];
		
        [[SYNActivityManager sharedInstance] addObjectFromDict:channelDictionary];
        channelOwner.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:self.uniqueId];
		
		
		[self.userSubscriptionsSet addObject:channelOwner];
	}
}

- (void) setVideoInstancesFromDictionary : (NSDictionary *) videosDictionary {
    
    NSDictionary *itemDict = videosDictionary[@"videos"];
    if (!itemDict || ![itemDict isKindOfClass: [NSDictionary class]])
    {
        return;
    }
    
    NSArray *items = [itemDict objectForKey:@"items"];
    

    // Reset the set
    [self.userVideoInstancesSet removeAllObjects];
	
    for (NSDictionary *videoInstanceDictionary in items) {
		
		VideoInstance *videoInstance = [VideoInstance instanceFromDictionary:videoInstanceDictionary usingManagedObjectContext:self.managedObjectContext];
		
		[self.userVideoInstancesSet addObject:videoInstance];
	}

}

- (void) addVideoInstancesFromDictionary : (NSDictionary *) videosDictionary {
    NSDictionary *itemDict = videosDictionary[@"videos"];
    if (!itemDict || ![itemDict isKindOfClass: [NSDictionary class]])
    {
        return;
    }
    
    NSArray *items = [itemDict objectForKey:@"items"];
    
    
	NSMutableDictionary *videoInstanceByKeyDictionary = [[NSMutableDictionary alloc] initWithCapacity: self.userVideoInstances.count];
	
    for (ChannelOwner *su in self.subscriptions)
    {
        videoInstanceByKeyDictionary[su.uniqueId] = su;
    }
	
    for (NSDictionary *videoInstanceDictionary in items) {
		
		VideoInstance *videoInstance = videoInstanceByKeyDictionary[videoInstanceDictionary[@"id"]];
		
        if (videoInstance) {
			[self.userVideoInstancesSet removeObject:videoInstance];
		}
		
		videoInstance = [VideoInstance instanceFromDictionary:videoInstanceDictionary usingManagedObjectContext:self.managedObjectContext];
		
		[self.userVideoInstancesSet addObject:videoInstance];
	}
    
}

@end
