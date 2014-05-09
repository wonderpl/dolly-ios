#import "NSDictionary+Validation.h"
#import "SYNActivityManager.h"
#import "Video.h"
#import "VideoAnnotation.h"
@import Foundation;

NSString *const VideoSourceYouTube = @"youtube";
NSString *const VideoSourceOoyala = @"ooyala";

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
    instance.thumbnailURL = video.thumbnailURL;
	instance.linkTitle = video.linkTitle;
	instance.linkURL = video.linkURL;
    
    return instance;
}


+ (Video *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
               ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
	NSString *videoId = dictionary[@"id"];
	
    Video *instance = [Video insertInManagedObjectContext: managedObjectContext];
	
    instance.uniqueId = videoId;
	
    [instance setAttributesFromDictionary:dictionary];
    
    return instance;
}

+ (NSDictionary *)videosFromDictionaries:(NSArray *)dictionaries
				   inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	
	NSArray *videoIds = [dictionaries valueForKey:@"id"];
	
	NSMutableDictionary *existingVideos = [[self existingVideosWithIds:videoIds
												inManagedObjectContext:managedObjectContext] mutableCopy];
	
	NSMutableDictionary *videos = [NSMutableDictionary dictionary];
	for (NSDictionary *dictionary in dictionaries) {
		NSString *videoId = dictionary[@"id"];
		
		Video *video = existingVideos[videoId];
		if (video) {
			[video setAttributesFromDictionary:dictionary];
		} else {
			video = [Video instanceFromDictionary:dictionary
						usingManagedObjectContext:managedObjectContext
							  ignoringObjectTypes:kIgnoreNothing];
			existingVideos[video.uniqueId] = video;
		}
		
		videos[videoId] = video;
	}
	
	return videos;
}

+ (NSDictionary *)existingVideosWithIds:(NSArray *)videoIds
				 inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uniqueId IN %@", videoIds]];
	
	NSArray *videos = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
	
	return [NSDictionary dictionaryWithObjects:videos forKeys:[videos valueForKey:@"uniqueId"]];
}

- (BOOL)hasLink {
	return ([self.linkTitle length] && [self.linkURL length]);
}

- (void)setAttributesFromDictionary:(NSDictionary *)dictionary {
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog(@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    
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
    
	self.videoDescription = [dictionary objectForKey:@"description" withDefault:@""];
    
    self.thumbnailURL = [dictionary objectForKey: @"thumbnail_url"
                                     withDefault: @""];
	
	self.linkTitle = [dictionary objectForKey:@"link_title" withDefault:@""];
	self.linkURL = [dictionary objectForKey:@"link_url" withDefault:@""];
	
	for (VideoAnnotation *annotation in [self.videoAnnotations copy]) {
		[self.managedObjectContext deleteObject:annotation];
	}
	
	NSArray *annotations = [VideoAnnotation videoAnnotationsFromDictionaries:dictionary[@"annotations"]
													  inManagedObjectContext:self.managedObjectContext];
	self.videoAnnotations = [NSSet setWithArray:annotations];
}

- (NSSet *)annotationsAtTime:(NSTimeInterval)time {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startTimestamp <= %f) AND (endTimestamp >= %f)", time, time];
	return [self.videoAnnotations filteredSetUsingPredicate:predicate];
}

@end
