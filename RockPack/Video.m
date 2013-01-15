#import "NSDictionary+Validation.h"
#import "Video.h"

static NSEntityDescription *videoEntity = nil;

@interface Video ()

// Private interface goes here.

@end


@implementation Video

#pragma mark - Object factory

+ (Video *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;
{
    NSError *error = nil;
    
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id"];
    
    // Only create an entity description once, should increase performance
    if (videoEntity == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^
                      {
                          // Not entirely sure I shouldn't 'copy' this object before assigning it to the static variable
                          videoEntity = [NSEntityDescription entityForName: @"Video"
                                                      inManagedObjectContext: managedObjectContext];
                          
                      });
    }
    
    // Now we need to see if this object already exists, and if so return it and if not create it
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: videoEntity];
    
    // Search on the unique Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    [channelFetchRequest setPredicate: predicate];
    
    NSArray *matchingChannelEntries = [managedObjectContext executeFetchRequest: channelFetchRequest
                                                                          error: &error];
    
    if (matchingChannelEntries.count > 0)
    {
        return matchingChannelEntries[0];
    }
    else
    {
        Video *instance = [[Video alloc] init];
        
        // As we have a new object, we need to set all the attributes (from the dictionary passed in)
        // We have already obtained the uniqueId, so pass it in as an optimisation
        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext];
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;
{
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    self.uniqueId = uniqueId;
    
    self.categoryId = [dictionary objectForKey: @"category_id"
                                   withDefault: @""];
    
    self.source = [dictionary objectForKey: @"source"
                               withDefault: @""];
    
    self.sourceId = [dictionary objectForKey: @"source_id"
                                 withDefault: @""];
    
    self.starCount = [dictionary objectForKey: @"star_count"
                                  withDefault: [NSNumber numberWithInt: 0]];
    
    self.starredByUser = [dictionary objectForKey: @"starred_by_user"
                                      withDefault: [NSNumber numberWithBool: FALSE]];
    
    self.thumbnailURL = [dictionary objectForKey: @"thumbnail_url"
                                     withDefault: @"http://"];
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
