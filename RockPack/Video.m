#import "NSDate-Utilities.h"
#import "NSDictionary+Validation.h"
#import "SYNActivityManager.h"
#import "Video.h"
#import <Foundation/Foundation.h>

@implementation Video

#pragma mark - Object factory

+ (Video *) instanceFromVideo: (Video *) video
    usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    Video *instance = instance = [Video insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = video.uniqueId;
    instance.categoryId = video.categoryId;
    instance.viewCount = video.viewCount;
    instance.dateUploaded = video.dateUploaded;
    instance.duration = video.duration;
    instance.source = video.source;
    instance.sourceId = video.sourceId;
    instance.sourceUsername = video.sourceUsername;
    instance.starCount = video.starCount;
    instance.starredByUserValue = video.starredByUserValue;
    instance.thumbnailURL = video.thumbnailURL;
    
    return instance;
}


+ (Video *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
               ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id"
                                      withDefault: @"Uninitialized Id"];
    
    Video *instance = [Video insertInManagedObjectContext: managedObjectContext];
    
    // As we have a new object, we need to set all the attributes (from the dictionary passed in)
    // We have already obtained the uniqueId, so pass it in as an optimisation
    [instance setAttributesFromDictionary: dictionary
                                   withId: uniqueId
                usingManagedObjectContext: managedObjectContext
                      ignoringObjectTypes: ignoringObjects];
    
    // Update video starred & viewed
    [SYNActivityManager.sharedInstance updateActivityForVideo: instance];
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog(@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    self.uniqueId = uniqueId;
    
    self.categoryId = [dictionary objectForKey: @"category_id"
                                   withDefault: @""];
    
    self.viewCount = [dictionary objectForKey: @"source_view_count"
                                  withDefault: @0];
    
    self.dateUploaded = [dictionary dateFromISO6801StringForKey: @"source_date_uploaded"
                                                    withDefault: [NSDate date]];
    
    self.duration = [dictionary objectForKey: @"duration"
                                 withDefault: @0];
    
    self.viewCount = [dictionary objectForKey: @"source_view_count"
                                  withDefault: @0];
    
    self.source = [dictionary objectForKey: @"source"
                               withDefault: @""];
    
    self.sourceId = [dictionary objectForKey: @"source_id"
                                 withDefault: @""];
    
    self.sourceUsername = [dictionary objectForKey: @"source_username"
                                       withDefault: @""];
    
    self.starCount = [dictionary objectForKey: @"star_count"
                                  withDefault: @0];
    
    self.starredByUserValue = NO;
    
    self.thumbnailURL = [dictionary objectForKey: @"thumbnail_url"
                                     withDefault: @""];
}


#pragma mark - Helper methods

- (UIImage *) thumbnailImage
{
    return [UIImage imageNamed: self.thumbnailURL];
}


- (NSURL *) localVideoURL
{
    return [NSURL fileURLWithPath: [NSHomeDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"/Documents/%@.mp4", self.sourceId, nil]]];
}


@end
