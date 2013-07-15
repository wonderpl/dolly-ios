//
//  SYNSearchRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNSearchRegistry.h"
#import "Video.h"
#import "VideoInstance.h"
#import "Channel.h"
#import "SYNAppDelegate.h"
#import "AppConstants.h"

@implementation SYNSearchRegistry

-(id)init
{
    if (self = [super init])
    {
        appDelegate = UIApplication.sharedApplication.delegate;
        importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSConfinementConcurrencyType];
        importManagedObjectContext.parentContext = appDelegate.searchManagedObjectContext;
    }
    return self;
}


-(BOOL)registerVideosFromDictionary:(NSDictionary *)dictionary
{
    
    // == Check for Validity == //
    
    //[self clearImportContextFromEntityName:@"VideoInstance"];
    
    NSDictionary *videosDictionary = dictionary[@"videos"];
    if (!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    
    
    NSArray *itemArray = videosDictionary[@"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    
    NSFetchRequest *videoFetchRequest = [[NSFetchRequest alloc] init];
    [videoFetchRequest setEntity: [NSEntityDescription entityForName: @"Video"
                                              inManagedObjectContext: importManagedObjectContext]];
    
    NSMutableArray* videoIds = [NSMutableArray array];
    for (NSDictionary *itemDictionary in itemArray)
    {
        id uniqueId = [itemDictionary[@"video"] objectForKey:@"id"];
        if(uniqueId)
        {
            [videoIds addObject:uniqueId];
        }
    }
    
    NSPredicate* videoPredicate = [NSPredicate predicateWithFormat:@"uniqueId IN %@", videoIds];
    
    videoFetchRequest.predicate = videoPredicate;
    
    NSArray *existingVideos = [importManagedObjectContext executeFetchRequest: videoFetchRequest
                                                                        error: nil];
    
    // === Main Processing === //
    
    for (NSDictionary *itemDictionary in itemArray) {
        
        if ([itemDictionary isKindOfClass: [NSDictionary class]]) {
            
            NSMutableDictionary* fullItemDictionary = [NSMutableDictionary dictionaryWithDictionary:itemDictionary];
            
            // video instances on search do not have channels attached to them
            VideoInstance* videoInstance = [VideoInstance instanceFromDictionary: fullItemDictionary
                                                       usingManagedObjectContext: importManagedObjectContext
                                                             ignoringObjectTypes: kIgnoreChannelObjects existingVideos:existingVideos];
            
            videoInstance.viewId = kSearchViewId;
        }
            
    }
       
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveSearchContext];
    
    return YES;
}

-(BOOL)registerChannelsFromDictionary:(NSDictionary *)dictionary
{
    NSDictionary *channelsDictionary = dictionary[@"channels"];
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = channelsDictionary[@"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    
        
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        
        
        Channel* channel = [Channel instanceFromDictionary:itemDictionary
                                 usingManagedObjectContext:importManagedObjectContext]; 
        
        if(!channel)
        {
            DebugLog(@"Could not instantiate channel with data:\n%@", itemDictionary);
            continue;
        }
        

        channel.viewId = kSearchViewId;
        
    }
    
            
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveSearchContext];
    
    
    return YES;
    
}

-(BOOL)registerSubscribersFromDictionary:(NSDictionary *)dictionary
{
    
    
    
    return [self registerChannelOwnersFromDictionary:dictionary forViewId:kChannelDetailsViewId];
}

-(BOOL)registerUsersFromDictionary:(NSDictionary *)dictionary
{
    return [self registerChannelOwnersFromDictionary:dictionary forViewId:kSearchViewId];
    
}

-(BOOL)registerChannelOwnersFromDictionary:(NSDictionary*)dictionary forViewId:(NSString*)viewId
{
    NSError *error;
    NSArray *itemsToDelete;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // == Clear VideoInstances == //
    
    [fetchRequest setEntity:[NSEntityDescription entityForName: @"ChannelOwner"
                                        inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"viewId == %@", viewId]];
    
    NSLog(@"%@", fetchRequest.predicate);
    
    itemsToDelete = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                          error: &error];
    
    for (NSManagedObject* objectToDelete in itemsToDelete) {
        
        [appDelegate.searchManagedObjectContext deleteObject: objectToDelete];
    }
    
    NSDictionary *channelsDictionary = dictionary[@"users"];
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = channelsDictionary[@"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        
        
        ChannelOwner* user = [ChannelOwner instanceFromDictionary:itemDictionary
                                        usingManagedObjectContext:appDelegate.searchManagedObjectContext
                                              ignoringObjectTypes:kIgnoreChannelObjects];
        
        if(!user)
        {
            DebugLog(@"Could not instantiate channel with data:\n%@", itemDictionary);
            continue;
        }
        
        
        user.viewId = viewId;
        
    }
    
    
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveSearchContext];
    
    
    return YES;
}


@end
