#import "Channel.h"
#import "NSDictionary+Validation.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNAppDelegate.h"
#import "ChannelOwner.h"
#import "SYNActivityManager.h"

@implementation VideoInstance

@synthesize starredByUser = _starredByUser;
@synthesize selectedForVideoQueue;

// Store our date formatter as a static for optimization purposes
static NSDateFormatter *dateFormatter = nil;

+ (VideoInstance *) instanceFromVideoInstance: (VideoInstance *) existingInstance
                    usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                          ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    VideoInstance *instance = [VideoInstance insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = existingInstance.uniqueId;
    instance.position = existingInstance.position;
    instance.dateAdded = existingInstance.dateAdded;
    instance.dateOfDayAdded = existingInstance.dateOfDayAdded;
    instance.title = existingInstance.title;
    instance.commentCount = existingInstance.commentCount;
    instance.commentCountValue = existingInstance.commentCountValue;
    instance.starredByUserValue = existingInstance.starredByUserValue;
    instance.video = [Video	instanceFromVideo: existingInstance.video
                    usingManagedObjectContext: managedObjectContext];
	instance.originator = [ChannelOwner instanceFromChannelOwner:existingInstance.originator
													   andViewId:existingInstance.viewId
									   usingManagedObjectContext:managedObjectContext
											 ignoringObjectTypes:kIgnoreNothing];
	
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        instance.channel = [Channel	instanceFromChannel: existingInstance.channel
                                              andViewId: instance.viewId
                              usingManagedObjectContext: managedObjectContext
                                    ignoringObjectTypes: ignoringObjects | kIgnoreChannelOwnerObject | kIgnoreVideoInstanceObjects];
    }
    
    return instance;
}

+ (NSDictionary *)videoInstancesFromDictionaries:(NSArray *)dictionaries
						  inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSArray *videoInstanceIds = [dictionaries valueForKey:@"id"];
	NSArray *videosDictionaries = [dictionaries valueForKey:@"video"];
	NSArray *channelsDictionaries = [dictionaries valueForKey:@"channel"];
	
	NSArray *originatorsDictionaries = [dictionaries valueForKey:@"original_channel_owner"];
	
	NSPredicate *notNullPredicate = [NSPredicate predicateWithFormat:@"self != NULL"];
	originatorsDictionaries = [originatorsDictionaries filteredArrayUsingPredicate:notNullPredicate];
	
	NSMutableDictionary *existingVideoInstances = [[self existingVideoInstancesWithIds:videoInstanceIds
															   inManagedObjectContext:managedObjectContext] mutableCopy];
	
	NSDictionary *videos = [Video videosFromDictionaries:videosDictionaries inManagedObjectContext:managedObjectContext];
	NSDictionary *channels = [Channel channelsFromDictionaries:channelsDictionaries inManagedObjectContext:managedObjectContext];
	NSDictionary *originators = [ChannelOwner channelOwnersFromDictionaries:originatorsDictionaries inManagedObjectContext:managedObjectContext];
	
	NSMutableDictionary *videoInstances = [NSMutableDictionary dictionary];
	for (NSDictionary *dictionary in dictionaries) {
		NSString *videoInstanceId = dictionary[@"id"];
		NSString *videoId = dictionary[@"video"][@"id"];
		NSString *channelId = dictionary[@"channel"][@"id"];
		NSString *originatorId = dictionary[@"original_channel_owner"][@"id"];
		
		VideoInstance *videoInstance = existingVideoInstances[videoInstanceId];
		if (!videoInstance) {
			videoInstance = [self insertInManagedObjectContext:managedObjectContext];
			
			videoInstance.uniqueId = videoInstanceId;
			
			existingVideoInstances[videoInstanceId] = videoInstance;
		}
		
		[videoInstance setAttributesFromDictionary:dictionary];
		
		videoInstance.video = videos[videoId];
		videoInstance.channel = channels[channelId];
		videoInstance.originator = originators[originatorId] ?: videoInstance.channel.channelOwner;
		
		videoInstances[videoInstanceId] = videoInstance;
	}
	
	return videoInstances;
}


#pragma mark - Object factory

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    return [VideoInstance instanceFromDictionary: dictionary
                       usingManagedObjectContext: managedObjectContext
                                  existingVideos: nil];
}

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                            existingVideos: (NSArray *) existingVideos
{
    return [VideoInstance instanceFromDictionary: dictionary
                       usingManagedObjectContext: managedObjectContext
                             ignoringObjectTypes: kIgnoreNothing
                                  existingVideos: existingVideos];
}


+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                       ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                            existingVideos: (NSArray *) existingVideos
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
    
    VideoInstance *instance = [VideoInstance insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    [instance setAttributesFromDictionary: dictionary
                usingManagedObjectContext: managedObjectContext
                      ignoringObjectTypes: ignoringObjects
                           existingVideos: existingVideos];
    
    return instance;
}

- (void)setAttributesFromDictionary:(NSDictionary *)dictionary {
    self.position = [dictionary objectForKey: @"position" withDefault: @0];
    
    self.dateAdded = [dictionary dateFromISO6801StringForKey: @"date_added"
                                                 withDefault: [NSDate date]];
	
	self.label = [dictionary objectForKey:@"label" withDefault:@""];
    
    NSString *dateAdded = [dictionary objectForKey: @"source_date_uploaded"];
    
    NSString *dayAdded = [dateAdded substringToIndex: [dateAdded rangeOfString: @"T"].location];
    self.dateOfDayAdded = [[VideoInstance DayOfDateFormatter] dateFromString: dayAdded];
    
    self.title = [dictionary objectForKey: @"title" withDefault: @""];
	
	self.starredByUserValue = [[SYNActivityManager sharedInstance] isRecentlyStarred:self.uniqueId];
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                      existingVideos: (NSArray *) existingVideos
{
	[self setAttributesFromDictionary:dictionary];
    
	NSArray *filteredVideos;
    if(existingVideos)
    {
        NSString *videoId = [dictionary[@"video"] objectForKey: @"id"];
        filteredVideos = [existingVideos filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"uniqueId = %@", videoId]];
    }
    
    
    
    if (filteredVideos && [filteredVideos count] > 0)
    {
        self.video = filteredVideos[0];
    }
    else
    {
        self.video = [Video instanceFromDictionary: dictionary[@"video"]
                         usingManagedObjectContext: managedObjectContext
                               ignoringObjectTypes: ignoringObjects];
    }
    

    
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        self.channel = [Channel instanceFromDictionary: dictionary[@"channel"]
                             usingManagedObjectContext: managedObjectContext
                                   ignoringObjectTypes: ignoringObjects | kIgnoreVideoInstanceObjects];
    }
	
	self.originator = [ChannelOwner instanceFromDictionary:dictionary[@"original_channel_owner"]
								 usingManagedObjectContext:managedObjectContext
									   ignoringObjectTypes:kIgnoreNothing];
	if (!self.originator) {
		self.originator = self.channel.channelOwner;
	}
    
    NSArray* starrersArray = dictionary[@"starring_users"];
    if ([starrersArray isKindOfClass:[NSArray class]])
    {
        ChannelOwner* starringChannelOwner;
        for (NSDictionary* starringDictionary in starrersArray)
        {
            starringChannelOwner = [ChannelOwner instanceFromDictionary:starringDictionary
                                              usingManagedObjectContext:self.managedObjectContext
                                                    ignoringObjectTypes:kIgnoreChannelObjects];
            
            // the method addStarrersObject has been overriden so as to copy the CO, do not use unless in need of a copy
            // ex. when passing the currentUser to the video instance
            
            
            [self.starrersSet addObject:starringChannelOwner];
            
        }
        
    }
    
}

+ (NSDictionary *)existingVideoInstancesWithIds:(NSArray *)videoIds
						 inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uniqueId IN %@", videoIds]];
	
	NSArray *videoInstances = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
	
	return [NSDictionary dictionaryWithObjects:videoInstances forKeys:[videoInstances valueForKey:@"uniqueId"]];
}


#pragma mark - Object reference counting

// This is very important, we need to set the delete rule to 'Nullify' and then custom delete our connected NSManagedObjects
// dependent on whether they are only referenced by us
- (void) prepareForDeletion
{
    if (self.video.videoInstances.count == 1)
    {
        [self.managedObjectContext deleteObject: self.video];
    }
}


#pragma mark - Helper methods

- (NSDateComponents *) timeAgo
{
    NSCalendarUnit flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |NSCalendarUnitHour | kCFCalendarUnitMinute;
    return [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] components:flags
                                                                                  fromDate:self.dateAdded
                                                                                    toDate:NSDate.date
                                                                                   options:0];
    
}


// Used for dates in the following format "2012-12-14T09:59:46.000Z"
// 2013-01-30T15:43:18.806454+00:00
+ (NSDateFormatter *) DayOfDateFormatter
{
    if (dateFormatter == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^
                      {
                          dateFormatter = [[NSDateFormatter alloc] init];
                          [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName: @"UTC"]];
                          [dateFormatter setDateFormat: @"yyyy-MM-dd"];
                      });
    }
    
    return dateFormatter;
}

#pragma mark - Starrers

-(void)addStarrersObject:(ChannelOwner *)value_
{
    // avoid double entries
    
    for (ChannelOwner* co in self.starrers)
        if([co.uniqueId isEqualToString:value_.uniqueId])
            return;
    
    
    ChannelOwner* copyOfChannelOwner = [ChannelOwner instanceFromChannelOwner:value_
                                                                    andViewId:self.viewId
                                                    usingManagedObjectContext:self.managedObjectContext
                                                          ignoringObjectTypes:kIgnoreAll];
    
    if(!copyOfChannelOwner)
        return;
    
    [self.starrersSet addObject:copyOfChannelOwner];
    
}

-(void)removeStarrersObject:(ChannelOwner *)value_
{
    if(!value_)
        return;
    
    for (ChannelOwner* starrer in self.starrers)
    {
        if([starrer.uniqueId isEqualToString:value_.uniqueId])
        {
            [self.starrersSet removeObject:starrer];
            [starrer.managedObjectContext deleteObject:starrer];
            
            break;
        }
    }
}

- (void)awakeFromFetch {
	[super awakeFromFetch];
	
	self.starredByUserValue = [[SYNActivityManager sharedInstance] isRecentlyStarred:self.uniqueId];
}

#pragma mark - Starred By User Props

- (void)setStarredByUserValue:(BOOL)value {
	self.starredByUser = @(value);
}

-(BOOL)starredByUserValue {
    return [self.starredByUser boolValue];
}

-(void)setMarkedForDeletionValue:(BOOL)value_
{
    self.markedForDeletion = [NSNumber numberWithBool:value_];
    self.channel.markedForDeletionValue = value_;
    self.channel.channelOwner.markedForDeletionValue = value_;
}

-(NSString*)thumbnailURL
{
    return self.video.thumbnailURL;
}

@end
