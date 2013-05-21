//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "CoverArt.h"
#import "NSDictionary+Validation.h"
#import "SYNAppDelegate.h"
#import "SYNMainRegistry.h"
#import "VideoInstance.h"
#import "Genre.h"
#import "AppConstants.h"
#import <CoreData/CoreData.h>
#import "VideoInstance.h"


@interface SYNMainRegistry ()

@property (nonatomic, strong) NSEntityDescription *channelEntity;
@property (nonatomic, strong) NSEntityDescription *videoInstanceEntity;
@property (nonatomic, strong) NSString *localeString;

@end

@implementation SYNMainRegistry

#pragma mark - Update Data Methods

- (BOOL) registerUserFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    // dictionary also contains the set of user channels
    
    User* newUser = [User instanceFromDictionary: dictionary
                       usingManagedObjectContext: appDelegate.mainManagedObjectContext
                             ignoringObjectTypes: kIgnoreNothing];
    
    if(!newUser)
        return NO;
    
    newUser.currentValue = YES;
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerChannelOwnerFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    // dictionary also contains the set of user channels
    
    ChannelOwner* channelOwner = [ChannelOwner instanceFromDictionary: dictionary
                                            usingManagedObjectContext: importManagedObjectContext
                                                  ignoringObjectTypes: kIgnoreNothing];
    
    if (!channelOwner)
        return NO;
    
    
    BOOL saveResult = [self saveImportContext];
    if (!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    
    return YES;
}


- (BOOL) registerSubscriptionsForCurrentUserFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    User* currentUser = appDelegate.currentUser;
    
    if (!currentUser)
        return NO;
    
    NSDictionary* channeslDictionary = [dictionary objectForKey: @"channels"];
    if (!channeslDictionary)
        return NO;
    
    NSArray* itemsArray = [channeslDictionary objectForKey: @"items"];
    if (!itemsArray)
        return NO;
    
    for (NSDictionary* subscriptionChannel in itemsArray)
    {
        
        // must use the main context so as to be able to link it with the channel owner
        
        Channel* channel = [Channel instanceFromDictionary:subscriptionChannel
                                 usingManagedObjectContext:currentUser.managedObjectContext
                                       ignoringObjectTypes:kIgnoreNothing
                                                 andViewId:kProfileViewId];
        
        if (!channel)
            continue;
        
        
        [currentUser addSubscriptionsObject:channel];
        
    }
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerCategoriesFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    NSDictionary *categoriesDictionary = [dictionary objectForKey: @"categories"];
    if (!categoriesDictionary || ![categoriesDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = [categoriesDictionary objectForKey: @"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]] || [itemArray count] == 0)
        return NO;
    
    // We need to mark all of our existing Category objects corresponding to this viewId, just in case they are no longer required
    // and should be removed in a post-import cleanup
    NSArray *existingObjectsInViewId = [self markManagedObjectForPossibleDeletionWithEntityName: @"Genre"
                                                                                      andViewId: nil
                                                                         inManagedObjectContext: importManagedObjectContext];
    
    // === Main Processing === //
    for (NSDictionary *categoryDictionary in itemArray)
        if ([categoryDictionary isKindOfClass: [NSDictionary class]])
            [Genre instanceFromDictionary: categoryDictionary
                   usingManagedObjectContext: importManagedObjectContext];
    
    // == =============== == //
    
    // Now remove any Category objects that are no longer referenced in the import
    [self removeUnusedManagedObjects: existingObjectsInViewId
              inManagedObjectContext: importManagedObjectContext];
    
    // [[NSNotificationCenter defaultCenter] postNotificationName: kCategoriesUpdated object: nil];
    
    BOOL saveResult = [self saveImportContext];
    if (!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerCoverArtFromDictionary: (NSDictionary*) dictionary
                          forUserUpload: (BOOL) userUpload
{
    // == Check for Validity == //
    NSDictionary *channelCoverDictionary = [dictionary objectForKey: @"cover_art"];
    if (!channelCoverDictionary || ![channelCoverDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = [channelCoverDictionary objectForKey: @"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    for (NSDictionary *individualChannelCoverDictionary in itemArray)
    {
        if (![individualChannelCoverDictionary isKindOfClass: [NSDictionary class]])
            continue;
        
        [CoverArt instanceFromDictionary: individualChannelCoverDictionary
               usingManagedObjectContext: importManagedObjectContext
                           forUserUpload: userUpload]; 
    }

    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerVideoInstancesFromDictionary: (NSDictionary *) dictionary
                                    forViewId: (NSString*) viewId
                                  byAppending: (BOOL) append
{
    // == Check for Validity == //
    NSDictionary *videosDictionary = [dictionary objectForKey: @"videos"];
    if (!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    
    NSArray *itemArray = [videosDictionary objectForKey: @"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    // == =============== == //
    
    //Get all current videos for the viewId
    NSEntityDescription* videoInstanceEntity = [NSEntityDescription entityForName: @"VideoInstance"
                                                           inManagedObjectContext: importManagedObjectContext];
    NSFetchRequest *videoInstanceFetchRequest = [[NSFetchRequest alloc] init];
    [videoInstanceFetchRequest setEntity: videoInstanceEntity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"viewId == %@", viewId];
    [videoInstanceFetchRequest setPredicate: predicate];
    NSError* error = nil;
    NSArray *matchingVideoInstanceEntries = [importManagedObjectContext executeFetchRequest: videoInstanceFetchRequest
                                                                                error: &error];
    NSMutableDictionary* existingVideosByIndex = [NSMutableDictionary dictionaryWithCapacity:matchingVideoInstanceEntries.count];
    
    // Organise videos by Id
    for (VideoInstance* existingVideo in matchingVideoInstanceEntries)
    {
        [existingVideosByIndex setObject:existingVideo forKey:existingVideo.uniqueId];
        
        // We need to mark all of our existing VideoInstance objects corresponding to this viewId, just in case they are no longer required
        // and should be removed in a post-import cleanup
        existingVideo.markedForDeletionValue = YES;
    }
    
        // === Main Processing === //
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        
        NSString *uniqueId = [itemDictionary objectForKey: @"id"];
        if(!uniqueId)
            continue;
        
        VideoInstance* video = [existingVideosByIndex objectForKey:uniqueId];
        
        if (!video)
        {
            // The video is not in the dictionary of existing videos
            // Create a new video object. kIgnoreStoredObjects makes sure no attempt is made to query first
            video = [VideoInstance instanceFromDictionary: itemDictionary
                                usingManagedObjectContext: importManagedObjectContext
                                      ignoringObjectTypes: kIgnoreStoredObjects
                                                andViewId: viewId];
            
        }
        
        video.markedForDeletionValue = NO; // This video is in the dictionary and should not be deleted.
        
        video.position = [itemDictionary objectForKey: @"position"
                                          withDefault: [NSNumber numberWithInt: 0]];
    }    
    
    // == =============== == //
    
    // Now remove any VideoInstance objects that are no longer referenced in the import
    [self removeUnusedManagedObjects: matchingVideoInstanceEntries
              inManagedObjectContext: importManagedObjectContext];
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerChannelFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    // == =============== == //
    
    [Channel instanceFromDictionary: dictionary
          usingManagedObjectContext: importManagedObjectContext
                ignoringObjectTypes: kIgnoreNothing
                          andViewId: kChannelDetailsViewId];
    
    BOOL saveResult = [self saveImportContext];
    if (!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary
                        forChannelOwner: (ChannelOwner*) channelOwner
                            byAppending: (BOOL) append
{
    // == Check for Validity == //
    if(!channelOwner)
        return NO;
    
    NSDictionary *channelsDictionary = [dictionary objectForKey: @"channels"];
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = [channelsDictionary objectForKey: @"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    if (itemArray.count == 0)
        return YES;
    
    // Query for existing objects
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                inManagedObjectContext: channelOwner.managedObjectContext]];
    
    NSPredicate* ownedByUserPredicate = [NSPredicate predicateWithFormat:@"channelOwner.uniqueId == %@", channelOwner.uniqueId];
    
    [channelFetchRequest setPredicate: ownedByUserPredicate];
    
    NSError* error;
    NSArray *matchingChannelEntries = [channelOwner.managedObjectContext executeFetchRequest: channelFetchRequest
                                                                                       error: &error];
    
    NSMutableDictionary* existingChannelsByIndex = [NSMutableDictionary dictionaryWithCapacity:matchingChannelEntries.count];
    
    for (Channel* existingChannel in matchingChannelEntries)
    {
        // NSLog(@" - Channel: %@ (%@)", existingChannel.title, existingChannel.categoryId);
        [existingChannelsByIndex setObject:existingChannel forKey:existingChannel.uniqueId];
        
        if (!append)
            existingChannel.markedForDeletionValue = YES; // if a real genre is passed - delete the old objects
    }
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        
        NSString *uniqueId = [itemDictionary objectForKey: @"id"];
        if (!uniqueId)
            continue;
        
        Channel* channel;
        
        channel = [existingChannelsByIndex objectForKey:uniqueId];
        
        if (!channel)
        {
            channel = [Channel instanceFromDictionary: itemDictionary
                            usingManagedObjectContext: channelOwner.managedObjectContext
                                  ignoringObjectTypes: (kIgnoreStoredObjects | kIgnoreChannelOwnerObject)
                                            andViewId: kChannelsViewId];
        }
        
        
        channel.markedForDeletionValue = NO;
        
        channel.position = [itemDictionary objectForKey: @"position"
                                            withDefault: [NSNumber numberWithInt: 0]];
        
        [channelOwner addChannelsObject:channel];
    }
    
    
    [self removeUnusedManagedObjects: matchingChannelEntries
              inManagedObjectContext: channelOwner.managedObjectContext];
    
    
    BOOL saveResult = [self saveImportContext];
    if (!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}



- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary
                               forGenre: (Genre*) genre
                            byAppending: (BOOL) append
{
    // == Check for Validity == //
    NSDictionary *channelsDictionary = [dictionary objectForKey: @"channels"];
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = [channelsDictionary objectForKey: @"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    // Query for existing objects
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                inManagedObjectContext: appDelegate.mainManagedObjectContext]];
    
    NSPredicate* genrePredicate;
    
    if(genre)
    {
        if ([genre isMemberOfClass: [Genre class]])
        {
            genrePredicate = [NSPredicate predicateWithFormat: @"categoryId IN %@", [genre getSubGenreIdArray]];
        }
        else
        {
            genrePredicate = [NSPredicate predicateWithFormat: @"categoryId == %@", genre.uniqueId];
        }
    }

    [channelFetchRequest setPredicate: genrePredicate];
    
    
    NSError* error;
    NSArray *matchingChannelEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                          error: &error];
    
    
    NSMutableDictionary* existingChannelsByIndex = [NSMutableDictionary dictionaryWithCapacity: matchingChannelEntries.count];
    
    for (Channel* existingChannel in matchingChannelEntries)
    {
        
   
        [existingChannelsByIndex setObject:existingChannel forKey:existingChannel.uniqueId];
        
        if(!append)
            existingChannel.popularValue = NO; // set all to NO
        
        // if we do not append and the channel is not owned by the user then delete
        if(!append && existingChannel.channelOwner != appDelegate.currentUser)
            existingChannel.markedForDeletionValue = YES; 
           
        
    }

    for (NSDictionary *itemDictionary in itemArray)
    {
        NSString *uniqueId = [itemDictionary objectForKey: @"id"];
        if(!uniqueId)
            continue;
        
        Channel* channel;
        
        channel = [existingChannelsByIndex objectForKey: uniqueId];
        
        if (!channel)
        {
            channel = [Channel instanceFromDictionary: itemDictionary
                            usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                  ignoringObjectTypes: kIgnoreStoredObjects
                                            andViewId: kChannelsViewId];
        }

        channel.markedForDeletionValue = NO;
        
        channel.position = [itemDictionary objectForKey: @"position"
                                            withDefault: [NSNumber numberWithInt: 0]];
        
        if (!genre)
            channel.popularValue = YES;
    }
    
    [self removeUnusedManagedObjects: matchingChannelEntries
              inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


#pragma mark - Database garbage collection

// Before we start adding objects to the import context for a particular viewId, mark them all for possible deletion.
// We will unmark them if any of them are re-used by the import. All new objects are created with this marked for deletion flag already false
- (NSArray *) markManagedObjectForPossibleDeletionWithEntityName: (NSString *) entityName
                                                       andViewId: (NSString *) viewId
                                          inManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    // ARC based compiler now inits all local vars to nil by default
    NSError *error;
    
    // Create an entity description based on the name passed in
    NSEntityDescription *entityToMark = [NSEntityDescription entityForName: entityName
                                                    inManagedObjectContext: managedObjectContext];
    
    NSFetchRequest *entityFetchRequest = [[NSFetchRequest alloc] init];
    [entityFetchRequest setEntity: entityToMark];
    
    // Only use the viewId as a predicate if we actually have one (makes no sense for categories)
    if (viewId)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"viewId == \"%@\"", viewId];
        [entityFetchRequest setPredicate: predicate];
    }

    NSArray *matchingCategoryInstanceEntries = [managedObjectContext executeFetchRequest: entityFetchRequest
                                                                                   error: &error];
    
    [matchingCategoryInstanceEntries enumerateObjectsUsingBlock: ^(id managedObject, NSUInteger idx, BOOL *stop)
     {
         ((AbstractCommon *)managedObject).markedForDeletionValue = TRUE;
     }];
    
    // Return the array of pre-existing objects, so that we don't have to perform another fetch for cleanup
    return matchingCategoryInstanceEntries;
}


// Iterate through all previously existing NSManaged objects that corresponded to a viewId and delete them if necessary
- (void) removeUnusedManagedObjects: (NSArray *) managedObjects
             inManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if(!managedObjects)
        return;
    
    [managedObjects enumerateObjectsUsingBlock: ^(AbstractCommon* managedObject, NSUInteger idx, BOOL *stop)
    {
         if (managedObject.markedForDeletionValue)
         {
             [managedObjectContext deleteObject:managedObject];
             // DebugLog (@"Deleted NSManagedObject that is no longer used after import");
         }
     }];
}

@end
