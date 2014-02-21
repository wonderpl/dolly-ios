#import "Channel.h"
#import "NSDictionary+Validation.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNAppDelegate.h"
#import "ChannelOwner.h"

@implementation VideoInstance

@synthesize selectedForVideoQueue;

// Store our date formatter as a static for optimization purposes
static NSDateFormatter *dateFormatter = nil;

@synthesize starredByUser = _starredByUser;
@synthesize starredByUserValue;

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
    
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        instance.channel = [Channel	instanceFromChannel: existingInstance.channel
                                              andViewId: instance.viewId
                              usingManagedObjectContext: managedObjectContext
                                    ignoringObjectTypes: ignoringObjects | kIgnoreChannelOwnerObject | kIgnoreVideoInstanceObjects];
    }
    
    return instance;
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


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                      existingVideos: (NSArray *) existingVideos
{
    
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: @0];
    
    self.dateAdded = [dictionary dateFromISO6801StringForKey: @"date_added"
                                                 withDefault: [NSDate date]];
    
    NSString *dateAdded = [dictionary objectForKey: @"source_date_uploaded"];
    
    
    NSString *dayAdded = [dateAdded substringToIndex: [dateAdded rangeOfString: @"T"].location];
    self.dateOfDayAdded = [[VideoInstance DayOfDateFormatter] dateFromString: dayAdded];
    
    self.title = [dictionary objectForKey: @"title"
                              withDefault: @""];
    
    NSDictionary* commentsDictionary = [dictionary objectForKey:@"comments"];
        self.commentCount = [commentsDictionary objectForKey: @"total"
                                                 withDefault: @(-1)];
    
    
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
    
    // kIgnoreStarringObjects
    
    
    NSArray* starrersArray = dictionary[@"starring_users"];
    if (!(ignoringObjects & kIgnoreStarringObjects) && [starrersArray isKindOfClass:[NSArray class]])
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

#pragma mark - Starred By User Props
-(void)setStarredByUser:(NSNumber *)starredByUser
{
    if(starredByUser == nil) // nil is equivalent to NO
        starredByUser = @NO;
    
    if(_starredByUser && [starredByUser isEqualToNumber:_starredByUser])
        return;
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    if([starredByUser boolValue])
        [self addStarrersObject:appDelegate.currentUser]; // will copy the user into a new object
    else
        [self removeStarrersObject:appDelegate.currentUser]; // will remove the duplicate rather than the real user
    
    self.video.starredByUser = starredByUser;
    
    _starredByUser = starredByUser;
    
}
-(void)setStarredByUserValue:(BOOL)value
{
    // box the value into an NSNumber*
    self.starredByUser = @(value);
}
-(NSNumber*)starredByUser
{
    
    if(self.video.starredByUserValue == YES || (_starredByUser && ([_starredByUser boolValue] == YES))) // check ivar for "caching"
        return @YES;
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString* currentUserUniqueId = appDelegate.currentUser.uniqueId;
    for (ChannelOwner* co in self.starrers)
    {
        if([co.uniqueId isEqualToString:currentUserUniqueId])
        {
            self.video.starredByUserValue = YES; //preemptively set the flag
            return @YES;
        }
        
    }
    
    
    return @NO;
}
-(BOOL)starredByUserValue
{
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
