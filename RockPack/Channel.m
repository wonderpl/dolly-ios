#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDictionary+Validation.h"
#import "SYNActivityManager.h"
#import "SYNAppDelegate.h"
#import "VideoInstance.h"
#import "NSString+Utils.h"

@interface Channel ()

// Private interface goes here.

@end


@implementation Channel

@synthesize hasChangedSubscribeValue;
@synthesize autoplayId;

#pragma mark - Object factory

+ (Channel *) instanceFromChannel: (Channel *) channel
                        andViewId: (NSString *) viewId
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
              ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    if (!channel)
    {
        return nil;
    }
    
    Channel *copyChannel = [Channel insertInManagedObjectContext: managedObjectContext];
    
    copyChannel.uniqueId = channel.uniqueId;
    copyChannel.categoryId = channel.categoryId;
    copyChannel.position = channel.position;
    copyChannel.title = channel.title;
    copyChannel.lastUpdated = channel.lastUpdated;
    copyChannel.subscribersCount = channel.subscribersCount;
    copyChannel.subscribedByUserValue = channel.subscribedByUserValue;
    copyChannel.totalVideosValue = channel.totalVideosValue;
    copyChannel.favouritesValue = channel.favouritesValue;
    copyChannel.resourceURL = channel.resourceURL;
    copyChannel.channelDescription = channel.channelDescription;
    copyChannel.eCommerceURL = channel.eCommerceURL;
    copyChannel.public = channel.public;
    copyChannel.viewId = viewId;
    copyChannel.datePublished = channel.datePublished;
    
    if (!(ignoringObjects & kIgnoreChannelOwnerObject))
    {
        copyChannel.channelOwner = [ChannelOwner instanceFromChannelOwner: channel.channelOwner
                                                                andViewId: viewId
                                                usingManagedObjectContext: managedObjectContext
                                                      ignoringObjectTypes: kIgnoreChannelObjects | kIgnoreSubscriptionObjects];
    }
    
    if (!(ignoringObjects & kIgnoreVideoInstanceObjects))
    {
        for (VideoInstance *videoInstance in channel.videoInstances)
        {
            VideoInstance *copyVideoInstance = [VideoInstance instanceFromVideoInstance: videoInstance
                                                              usingManagedObjectContext: managedObjectContext
                                                                    ignoringObjectTypes: kIgnoreChannelObjects];
            
            copyVideoInstance.viewId = viewId;
            
            [copyChannel.videoInstancesSet addObject: copyVideoInstance];
        }
    }
    
    return copyChannel;
}


+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    return [Channel instanceFromDictionary: dictionary
                 usingManagedObjectContext: managedObjectContext
                       ignoringObjectTypes: kIgnoreNothing];
}


+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        return nil;
    }
    
    NSString *uniqueId = dictionary[@"id"];
    
    if (!uniqueId || ![uniqueId isKindOfClass: [NSString class]])
    {
        return nil;
    }
    
    Channel *instance = [Channel insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    [instance setAttributesFromDictionary: dictionary
                      ignoringObjectTypes: ignoringObjects];
    
    // Update video starred & viewed

    return instance;
}


+ (NSDictionary *)channelsFromDictionaries:(NSArray *)dictionaries
					inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSArray *channelIds = [dictionaries valueForKey:@"id"];
	
	NSArray *channelOwnersDictionaries = [dictionaries valueForKey:@"owner"];
	
	NSDictionary *channelOwners = [ChannelOwner channelOwnersFromDictionaries:channelOwnersDictionaries
													   inManagedObjectContext:managedObjectContext];
	
	NSMutableDictionary *existingChannels = [[self existingChannelsWithIds:channelIds
													inManagedObjectContext:managedObjectContext] mutableCopy];
	
	NSMutableDictionary *channels = [NSMutableDictionary dictionary];
	for (NSDictionary *dictionary in dictionaries) {
		NSString *channelId = dictionary[@"id"];
		NSString *channelOwnerId = dictionary[@"owner"][@"id"];
		
		Channel *channel = existingChannels[channelId];
		if (!channel) {
			channel = [self insertInManagedObjectContext:managedObjectContext];
			
			channel.uniqueId = channelId;
			
			existingChannels[channelId] = channel;
		}
		
		[channel setBasicAttributesFromDictionary:dictionary];
		
		channel.channelOwner = channelOwners[channelOwnerId];
		
		channels[channelId] = channel;
	}

	return channels;
}

+ (NSDictionary *)existingChannelsWithIds:(NSArray *)videoIds
				   inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uniqueId IN %@", videoIds]];
	
	NSArray *videos = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
	
	return [NSDictionary dictionaryWithObjects:videos forKeys:[videos valueForKey:@"uniqueId"]];
}

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    BOOL hasVideoInstances = YES;
    
    NSDictionary *videosDictionary = dictionary[@"videos"];
    
    if (!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
    {
        hasVideoInstances = NO;
    }
    
    NSArray *itemArray = videosDictionary[@"items"];
    
    if (!itemArray || ![itemArray isKindOfClass: [NSArray class]])
    {
        hasVideoInstances = NO;
    }
    
    if (!(ignoringObjects & kIgnoreVideoInstanceObjects) && hasVideoInstances)
    {
        
        //needed?
        if (![videosDictionary[@"total"] isKindOfClass: [NSNull class]])
        {
            self.totalVideosValue = videosDictionary[@"total"];
        }
        else
        {
            self.totalVideosValue = @([itemArray count]); // if the 'total' value was not returned then pass the existing numbers fetched
        }
        
        NSMutableDictionary *videoInsanceByIdDictionary = [[NSMutableDictionary alloc] initWithCapacity: self.videoInstances.count];
        
        for (VideoInstance *vi in self.videoInstances)
        {
            videoInsanceByIdDictionary[vi.uniqueId] = vi;
        }
        
        NSString *newUniqueId;
        VideoInstance *videoInstance;
        
        NSFetchRequest *videoFetchRequest = [[NSFetchRequest alloc] init];
        [videoFetchRequest setEntity: [NSEntityDescription entityForName: @"Video"
                                                  inManagedObjectContext: self.managedObjectContext]];
        
        NSArray *existingVideos = nil;
        
        NSMutableArray *videoIds = [NSMutableArray array];
        
        for (NSDictionary *itemDictionary in itemArray)
        {
            id uniqueId = (itemDictionary[@"video"])[@"id"];
            
            if (uniqueId)
            {
                [videoIds addObject: uniqueId];
            }
        }
        
        if ([videoIds count] > 0)
        {
            NSPredicate *videoPredicate = [NSPredicate predicateWithFormat: @"uniqueId IN %@", videoIds];
            
            videoFetchRequest.predicate = videoPredicate;
            
            existingVideos = [self.managedObjectContext
                              executeFetchRequest: videoFetchRequest
                              error: nil];
        }
        
        NSMutableArray *importArray = [[NSMutableArray alloc] initWithCapacity: itemArray.count];
        
        for (NSDictionary *channelDictionary in itemArray)
        {
            newUniqueId = channelDictionary[@"id"];
            
            if (!newUniqueId || ![newUniqueId isKindOfClass: [NSString class]])
            {
                continue;
            }
            
            videoInstance = videoInsanceByIdDictionary[newUniqueId];
            
            if (!videoInstance)
            {
                videoInstance = [VideoInstance instanceFromDictionary: channelDictionary
                                            usingManagedObjectContext: self.managedObjectContext
                                                  ignoringObjectTypes: kIgnoreChannelObjects
                                                       existingVideos: existingVideos];
            }
            else
            {
                [videoInsanceByIdDictionary removeObjectForKey: newUniqueId];
            }
            
            if (!videoInstance)
            {
                continue;
            }
            
            // viewId is probably @"ChannelDetails" because that is the only case where videos are passed to channels
            
            videoInstance.viewId = self.viewId;
            
            // all other properties of videoInstance like Video and Title are considered constant at the moment
            
            NSNumber *newPosition = channelDictionary[@"position"];
            
            if (newPosition && [newPosition isKindOfClass: [NSNumber class]])
            {
                videoInstance.position = newPosition;
            }
			
			if (!videoInstance.originator) {
				videoInstance.originator = self.channelOwner;
			}
            
            // Starres
            
            SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
            if(self.favouritesValue && [self.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId])
                videoInstance.starredByUserValue = YES;
            
            [importArray addObject: videoInstance];
        }
        
        // Add VideoInstances to channel's NSOrderedSet
        [self.videoInstancesSet removeAllObjects];
        [self.videoInstancesSet addObjectsFromArray: importArray];

        // Empty the temporary array
        [importArray removeAllObjects];
        importArray = nil;

        // Clean the remaining //
        
        for (id key in videoInsanceByIdDictionary)
        {
            VideoInstance *vi = videoInsanceByIdDictionary[key];
            
            if (!vi)
            {
                continue;
            }
            
            [self.managedObjectContext
             deleteObject: vi];
        }
    }
    
    [self setBasicAttributesFromDictionary: dictionary];
    
    NSDictionary *ownerDictionary = dictionary[@"owner"];
    
    if (!(ignoringObjects & kIgnoreChannelOwnerObject) && ownerDictionary)
    {
        self.channelOwner = [ChannelOwner instanceFromDictionary: ownerDictionary
                                       usingManagedObjectContext: self.managedObjectContext
                                             ignoringObjectTypes: ignoringObjects | kIgnoreChannelObjects];
    }
    
    self.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:self.uniqueId];
}


- (void) setBasicAttributesFromDictionary: (NSDictionary *) dictionary
{
    
    
    NSNumber *categoryNumber = dictionary[@"category"];
    
    self.categoryId = (categoryNumber && [categoryNumber isKindOfClass: [NSNumber class]]) ? [categoryNumber stringValue] : @"";
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: @0];
    
    self.title = [dictionary objectForKey: @"title"
                                       withDefault: @""];
    
    self.lastUpdated = [dictionary dateFromISO6801StringForKey: @"last_updated"
                                                   withDefault: [NSDate date]];
    
    self.datePublished = [dictionary dateFromISO6801StringForKey: @"date_published"
                                                     withDefault: [NSDate date]];
    
    self.subscribersCount = [dictionary objectForKey: @"subscriber_count"
                                         withDefault: @0];
    

    // this field only comes back for the favourites channel
    NSNumber *favourites = dictionary[@"favourites"];
    
    self.favouritesValue = ![favourites isKindOfClass: [NSNull class]] ? [favourites boolValue] : NO;
    
    
    self.resourceURL = [dictionary objectForKey: @"resource_url"
                                    withDefault: @"http://localhost"];
    
    self.channelDescription = [dictionary objectForKey: @"description"
                                           withDefault: @""];
    
    
    self.public = [dictionary objectForKey: @"public"
                               withDefault: @YES]; // default is public
    
    self.eCommerceURL = [dictionary objectForKey: @"ecommerce_url"
                                     withDefault: @""];
    
    NSDictionary *videos = [dictionary objectForKey:@"videos"];
    
    if ([[videos objectForKey:@"total"] isKindOfClass:[NSNumber class]])
    {
        self.totalVideosValue = [videos objectForKey:@"total"];
        
    }
    else
    {
        self.totalVideosValue = @0; // if the 'total' value was not returned then pass the existing numbers fetched
    }

 
}

- (NSString *)title {
	if (self.favouritesValue) {
        SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        if ([appDelegate.currentUser.uniqueId isEqualToString:self.channelOwner.uniqueId]) {
            return [NSString stringWithFormat:@"My %@", NSLocalizedString(@"Favorites", nil)];
        } else {
			NSString *displayName = [self.channelOwner.displayName apostrophisedString];
			return [NSString stringWithFormat:@"%@ %@", displayName, NSLocalizedString(@"Favorites", nil)];
        }
    }
	return self.primitiveTitle;
}


#pragma mark - Adding Video Instances

- (void) addVideoInstancesFromDictionary: (NSDictionary *) videosInstancesDictionary
{
    
    BOOL hasVideoInstances = YES;
    
    NSDictionary *videosDictionary = videosInstancesDictionary[@"videos"];
    
    if (!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
    {
        hasVideoInstances = NO;
    }
    
    NSArray *itemArray = videosDictionary[@"items"];
    
    if (!itemArray || ![itemArray isKindOfClass: [NSArray class]])
    {
        hasVideoInstances = NO;
    }
    
    if (!hasVideoInstances)
    {
        return;
    }
    
//    NSFetchRequest *videoFetchRequest = [[NSFetchRequest alloc] init];
//    
//    [videoFetchRequest setEntity: [NSEntityDescription entityForName: @"Video"
//                                              inManagedObjectContext: self.managedObjectContext]];
//    
    NSArray *existingVideos = nil;
//	NSArray *videoIds = [itemArray valueForKeyPath:@"video.id"];
//    
//    
//    
//    if ([videoIds count] > 0) {
//        NSPredicate *videoPredicate = [NSPredicate predicateWithFormat: @"uniqueId IN %@", videoIds];
//        
//        videoFetchRequest.predicate = videoPredicate;
//        
//        existingVideos = [self.managedObjectContext executeFetchRequest: videoFetchRequest
//                                                                  error: nil];
//    }
//	
    
    NSMutableDictionary *videoIdDictionary = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i<self.videoInstancesSet.count; i++) {
        VideoInstance *tmpInstance = [self.videoInstancesSet objectAtIndex:i];
        
        [videoIdDictionary setValue:tmpInstance forKey:tmpInstance.uniqueId];
        
    }
    
    for (NSDictionary *channelDictionary in itemArray)
    {
        
        VideoInstance *videoInstance = [VideoInstance instanceFromDictionary: channelDictionary
												   usingManagedObjectContext: self.managedObjectContext
														 ignoringObjectTypes: kIgnoreChannelObjects
															  existingVideos: existingVideos];
        
        if (!videoInstance)
        {
            continue;
        }
        
        videoInstance.viewId = self.viewId;
		
        for (int i = 0; i<self.videoInstancesSet.count; i++) {
            VideoInstance *tmpInstance = [self.videoInstancesSet objectAtIndex:i];
            
            if ([tmpInstance.uniqueId isEqualToString:videoInstance.uniqueId]) {
                [self.videoInstancesSet removeObject:tmpInstance];
            }
        }
        
        [self.videoInstancesSet addObject: videoInstance];
    }


}


- (void) addVideoInstancesObject: (VideoInstance *) value_
{
    [self.videoInstancesSet addObject: value_];
}


- (void) removeVideoInstancesObject: (VideoInstance *) value_
{
    [self.videoInstancesSet removeObject: value_];
}

#pragma mark - Object reference counting

// This is very important, we need to set the delete rule to 'Nullify' and then custom delete our connected NSManagedObjects
// dependent on whether they are only referenced by us

// Not sure if we should delete connected Channel/ChannelInstances at the same time
- (void) prepareForDeletion
{
    // Delete any channelOwners that are only associated with this channel
    if (self.channelOwner.channels.count == 1)
    {
        [self.managedObjectContext deleteObject: self.channelOwner];
    }
    
    // Delete any VideoInstances that are associated with this channel (I am assuming that as they only have a to-one relationship
    // with a channel, then they are only associated with that particular channel and can't exist independently
    for (VideoInstance *videoInstance in self.videoInstances)
    {
        [self.managedObjectContext deleteObject: videoInstance];
    }
}

-(void)setMarkedForDeletionValue:(BOOL)value_
{
    self.markedForDeletion = @(value_);
    self.channelOwner.markedForDeletionValue = value_;
}

@end
