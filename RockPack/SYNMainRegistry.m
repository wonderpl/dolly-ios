//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
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
#import "FeedItem.h"
#import "Video.h"


@interface SYNMainRegistry ()

@property (nonatomic, strong) NSEntityDescription *channelEntity;
@property (nonatomic, strong) NSEntityDescription *videoInstanceEntity;

@end

@implementation SYNMainRegistry

#pragma mark - Update Data Methods


- (BOOL) registerIPBasedLocation:(NSString*)locationString
{
    appDelegate.ipBasedLocation = locationString;
    return YES;
}

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
    
    // Pass viewId s.
    
    for (Channel* ch in newUser.channels)
        ch.viewId = kProfileViewId;
    
    newUser.viewId = kProfileViewId;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}



- (BOOL) registerSubscriptionsForCurrentUserFromDictionary: (NSDictionary*) dictionary
{
    
    // sets the view id
    
    [appDelegate.currentUser setSubscriptionsDictionary:dictionary];
    
    [appDelegate saveContext:YES];
    
    return YES;
    
}

-(BOOL)registerExternalAccountWithCurrentUserFromDictionary:(NSDictionary*)dictionary
{
    NSString* systemName = dictionary[@"external_system"];
    if(!systemName)
        return NO;
    
    ExternalAccount* externalAccount;
    
    for (ExternalAccount* candidateExternalAccount in appDelegate.currentUser.externalAccounts)
    {
        if ([externalAccount.system isEqualToString:systemName]) {
            externalAccount = candidateExternalAccount;
            break;
        }
    }
    if(!externalAccount)
    {
        if(!(externalAccount = [ExternalAccount instanceFromDictionary:dictionary
                                             usingManagedObjectContext:appDelegate.currentUser.managedObjectContext]))
        {
            return NO;
        }
        else
        {
            [appDelegate.currentUser.externalAccountsSet addObject:externalAccount];
        }
    }
    else
    {
        [externalAccount setAttributesFromDictionary:dictionary];
    }
    
    
    [appDelegate saveContext:YES];
    
    return YES;
    
}


- (BOOL) registerCategoriesFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    NSDictionary *categoriesDictionary = dictionary[@"categories"];
    if (!categoriesDictionary || ![categoriesDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = categoriesDictionary[@"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    if (itemArray.count == 0)
        return YES;
    
    
    // Query for existing objects
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity: [NSEntityDescription entityForName: @"Genre"
                                                   inManagedObjectContext: appDelegate.mainManagedObjectContext]];
    
    
    // must not fetch SubGenres
    categoriesFetchRequest.includesSubentities = NO;
    
    
    NSError* error;
    NSArray *existingCategories = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                          error: &error];
    
    NSMutableDictionary* existingCategoriesByIndex = [NSMutableDictionary dictionaryWithCapacity:existingCategories.count];
    
    for (Genre* existingCategory in existingCategories)
    {
        
        existingCategoriesByIndex[existingCategory.uniqueId] = existingCategory;
        
        existingCategory.markedForDeletionValue = YES; // if a real genre is passed - delete the old objects
    }
    

    for (NSDictionary *categoryDictionary in itemArray)
    {
        
        
        NSString *uniqueId = categoryDictionary[@"id"];
        if (!uniqueId)
            continue;
        
        Genre* genre;
        
        genre = existingCategoriesByIndex[uniqueId];
        
        if(!genre)
        {
            genre = [Genre instanceFromDictionary: categoryDictionary
                        usingManagedObjectContext: appDelegate.mainManagedObjectContext];
        }
        else
        {
            [genre setAttributesFromDictionary:categoryDictionary withId:uniqueId usingManagedObjectContext:appDelegate.mainManagedObjectContext];
        }
        
        genre.markedForDeletionValue = NO;
        
        genre.priority = [categoryDictionary objectForKey: @"priority"
                                              withDefault: @0];
        
        
        
    }
        
    
   
    
    for (Genre* category in existingCategories)
    {
        if(category.markedForDeletionValue)
            [category.managedObjectContext delete:category];
    }
    
    
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerCoverArtFromDictionary: (NSDictionary*) dictionary
                          forUserUpload: (BOOL) userUpload
{
    // == Check for Validity == //
    NSDictionary *channelCoverDictionary = dictionary[@"cover_art"];
    if (!channelCoverDictionary || ![channelCoverDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = channelCoverDictionary[@"items"];
    
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

//    BOOL saveResult = [self saveImportContext];
//    
//    if (!saveResult)
//        return NO;
    
    [appDelegate saveContext:NO];
    
    return YES;
}

#pragma mark - Retrieve Functions

-(NSDictionary*)getDataObjectsByEntityName:(NSString*)entityName
{
    return [self getDataObjectsByEntityName:entityName forViewId:kFeedViewId];
}

-(NSDictionary*)getDataObjectsByEntityName:(NSString*)entityName forViewId:(NSString*)viewId
{
    return [self getDataObjectsByEntityName:entityName forViewId:viewId markedForDeletion:YES];
}

-(NSDictionary*)getDataObjectsByEntityName:(NSString*)entityName forViewId:(NSString*)viewId markedForDeletion:(BOOL)marked
{
    
    
    if(!entityName)
        return @{}; // return empty dictionary
    
    
    NSError* error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: entityName
                                         inManagedObjectContext: importManagedObjectContext]];
        
    if(viewId)
    {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"viewId == %@", viewId];
    }
        
    NSArray *existingFeedVideoInstances = [importManagedObjectContext executeFetchRequest: fetchRequest
                                                                                    error: &error];
        
    NSMutableDictionary* managedObjectsByUniqueId = [NSMutableDictionary dictionaryWithCapacity:existingFeedVideoInstances.count];
        
    for (AbstractCommon* existingVideoInstance in existingFeedVideoInstances)
    {
        managedObjectsByUniqueId[existingVideoInstance.uniqueId] = existingVideoInstance;
        
        
        existingVideoInstance.markedForDeletionValue = marked; 
        
    }
    
    
    return managedObjectsByUniqueId;
    
}



#pragma mark - Feed Parsing

- (BOOL) registerDataForSocialFeedFromItemsDictionary: (NSDictionary *) dictionary
                                          byAppending: (BOOL) append
{
    
    
    // == Check for Validity == //
    
//    NSLog(@"\n========= Feed Data: ===========\n%@\n\n", dictionary);
    
    NSArray *itemsArray = dictionary[@"items"];
    if (![itemsArray isKindOfClass: [NSArray class]])
        return NO;
    
    NSDictionary *aggregationsDictionary = dictionary[@"aggregations"];
    if (![aggregationsDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    
    NSDictionary *videoInstancesByUniqueId, *channelInstacesByUniqueId, *feedItemInstacesByUniqueId;
    if(!append)
    {
        // objects returned as markedForDeletion == YES
        videoInstancesByUniqueId = [self getDataObjectsByEntityName:kVideoInstance];
        channelInstacesByUniqueId = [self getDataObjectsByEntityName:kChannel];
        feedItemInstacesByUniqueId = [self getDataObjectsByEntityName:kFeedItem];
    }
    
    // == Initialise Vars == //
    
    FeedItem *aggregationFeedItem;
    
    NSMutableDictionary *aggregationItems = [NSMutableDictionary dictionaryWithCapacity:aggregationsDictionary.allKeys.count];
    
    FeedItem* leafFeedItem;
    AbstractCommon* object;
    
    ChannelOwner* co;
    
    // == Parse Items == //
    
    
    for (NSDictionary* itemDictionary in itemsArray)
    {
        // define type
        
        if(itemDictionary[@"video"]) // videoInstance object
        {
            
            if(!(object = videoInstancesByUniqueId[itemDictionary[@"id"]]))
                if(!(object = [VideoInstance instanceFromDictionary:itemDictionary
                                          usingManagedObjectContext:importManagedObjectContext]))
                       continue;
                   
            co = ((VideoInstance*)object).channel.channelOwner;
            
            
        }
        else if (itemDictionary[@"cover"]) // channel object
        {
            
            if(!(object = channelInstacesByUniqueId[itemDictionary[@"id"]]))
                if(!(object = [Channel instanceFromDictionary:itemDictionary
                                    usingManagedObjectContext:importManagedObjectContext]))
                    continue;
            
            
            co = ((Channel*)object).channelOwner;
        }
        
        
        
        object.viewId = kFeedViewId;
        
        object.markedForDeletionValue = NO;
        
        leafFeedItem = [FeedItem instanceFromResource:object];
        
        if(!leafFeedItem)
            continue;
        
        
        
        // object has been created, see if it belongs to an aggregation
        
        NSString* aggregationIndex = itemDictionary[@"aggregation"] ? itemDictionary[@"aggregation"] : nil;
        if(!aggregationIndex || ![aggregationIndex isKindOfClass:[NSString class]]) // the item IS part of an aggregation
            continue;
        
        
        // if we have already created the FeedItem, use it
        aggregationFeedItem = aggregationItems[aggregationIndex];
        
        // else, create a new one
        if(!aggregationFeedItem)
        {
            NSDictionary* aggregationItemDictionary = aggregationsDictionary[aggregationIndex];
            if(!(aggregationFeedItem = feedItemInstacesByUniqueId[aggregationIndex]))
               if(!(aggregationFeedItem = [FeedItem instanceFromDictionary:aggregationItemDictionary
                                                                    withId:aggregationIndex
                                                 usingManagedObjectContext:importManagedObjectContext]))
               {
                   continue;
               }
                  
            
            aggregationFeedItem.viewId = kFeedViewId;
            aggregationFeedItem.markedForDeletionValue = NO;
            
            aggregationItems[aggregationFeedItem.uniqueId] = aggregationFeedItem;
            
            
            // == Parse Covers == //
            
            NSArray* coversArray = (NSArray*)(aggregationItemDictionary[@"covers"]);
   
            aggregationFeedItem.coverIndexes = [coversArray isKindOfClass:[NSArray class]] ? [coversArray componentsJoinedByString:@":"] : @"Mike";
            
            
        }
        
        
        
        [aggregationFeedItem addFeedItemsObject:leafFeedItem]; // overriden in class
        
    }
    
    if(!append)
    {
        // delete objects
        NSInteger totalObjectCount = (videoInstancesByUniqueId.count + channelInstacesByUniqueId.count + feedItemInstacesByUniqueId.count);
        NSMutableArray* objectsToDelete = [NSMutableArray arrayWithCapacity:totalObjectCount];
        [objectsToDelete addObjectsFromArray:[videoInstancesByUniqueId allValues]];
        [objectsToDelete addObjectsFromArray:[channelInstacesByUniqueId allValues]];
        [objectsToDelete addObjectsFromArray:[feedItemInstacesByUniqueId allValues]];
        
        for (AbstractCommon* objectToDelete in objectsToDelete)
        {
            
            if(!objectToDelete.markedForDeletionValue)
                continue;
            
            [objectToDelete.managedObjectContext deleteObject:objectToDelete];
            
        }
    }
    
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext:NO];
    
    return YES;
}



#pragma mark - Channels

// Called by Main Channel page

- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary
                               forGenre: (Genre*) genre
                            byAppending: (BOOL) append
{
    // == Check for Validity == //
    NSDictionary *channelsDictionary = dictionary[@"channels"];
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog(@"registerChannelsFromDictionary: unexpected JSON format");
        return NO;
    }
    
    NSArray *itemArray = channelsDictionary[@"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
    {
        AssertOrLog(@"registerChannelsFromDictionary: unexpected JSON format");
        return NO;
    }

    // Query for existing objects
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                inManagedObjectContext: importManagedObjectContext]];
    
    NSMutableArray* predicates = [[NSMutableArray alloc] initWithCapacity:2];
    
    
    [predicates addObject: [NSPredicate predicateWithFormat: @"viewId == %@", kChannelsViewId]];
    
    // get all channels that are in the DB, any of them can belong to the new "popular" list
    
    if (genre)
    {
        if ([genre isMemberOfClass: [Genre class]])
        {
            [predicates addObject: [NSPredicate predicateWithFormat: @"categoryId IN %@", [genre getSubGenreIdArray]]];
        }
        else
        {
            [predicates addObject: [NSPredicate predicateWithFormat: @"categoryId == %@", genre.uniqueId]];
        }
        
        [channelFetchRequest setPredicate: [NSCompoundPredicate andPredicateWithSubpredicates: predicates]];
    }
    else // if nil was passed (@"all") then only the first predicate is valid
    {
        [channelFetchRequest setPredicate: (NSPredicate*)predicates[0]];
    }
    

    
    // Get a list of existing channels in in a dictionary
    
    NSError* error;
    NSArray *existingChannels = [importManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                          error: &error];
    
    NSMutableDictionary* existingChannelsByIndex = [NSMutableDictionary dictionaryWithCapacity: existingChannels.count];
    
    for (Channel* existingChannel in existingChannels)
    {
        
        existingChannelsByIndex[existingChannel.uniqueId] = existingChannel;
        
        if(!append)
            existingChannel.popularValue = NO; // set all to NO
        
        // if we do not append and the channel is not owned by the user then delete //
        
        if(!append)
            existingChannel.markedForDeletionValue = YES;
        
        
           
    }


    // Loop through the fresh data from the server
    
    NSInteger items = 0;
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        items++;
        
        
        Channel* channel;
        
        if(!(channel = existingChannelsByIndex[itemDictionary[@"id"] ? itemDictionary[@"id"] : @""]))
            if (!(channel = [Channel instanceFromDictionary: itemDictionary
                                  usingManagedObjectContext: importManagedObjectContext
                                        ignoringObjectTypes: kIgnoreVideoInstanceObjects]))
        {
            continue;
        }
        

        channel.markedForDeletionValue = NO;
        
        
        NSNumber* remotePosition = [itemDictionary objectForKey: @"position" withDefault: @0];
        if([remotePosition intValue] != channel.positionValue)
        {
            channel.position = remotePosition;
        }
        
        
        // nil is passed in case of the @"all" category which is popular
        
        if (!genre) 
            channel.popularValue = YES;
        
        channel.viewId = kChannelsViewId;
    }
    
    // delete old objects //
    
    for (id key in existingChannelsByIndex)
    {
        Channel* deleteCandidate = (Channel*)existingChannelsByIndex[key];
        
        if(deleteCandidate && deleteCandidate.markedForDeletionValue)
            [deleteCandidate.managedObjectContext deleteObject:deleteCandidate];
    }

    
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext:NO];
    
    
    
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


@end
