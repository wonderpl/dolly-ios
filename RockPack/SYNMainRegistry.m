//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "CoverArt.h"
#import "FeedItem.h"
#import "Genre.h"
#import "NSDictionary+Validation.h"
#import "SYNAppDelegate.h"
#import "SYNMainRegistry.h"
#import "Video.h"
#import "Comment.h"
#import "Mood.h"
#import "VideoInstance.h"
@import CoreData;


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
    
    [categoriesFetchRequest setEntity: [NSEntityDescription entityForName: kGenre
                                                   inManagedObjectContext: importManagedObjectContext]];
    
    categoriesFetchRequest.predicate = [NSPredicate predicateWithFormat:@"name != %@", kPopularGenreName];
    
    // must not fetch SubGenres
    categoriesFetchRequest.includesSubentities = NO;
    
    
    NSError* error;
    NSArray *existingCategories = [importManagedObjectContext executeFetchRequest: categoriesFetchRequest
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
                        usingManagedObjectContext: importManagedObjectContext];
        }
        else
        {
            [genre setAttributesFromDictionary:categoryDictionary withId:uniqueId usingManagedObjectContext:importManagedObjectContext];
        }
        
        genre.markedForDeletionValue = NO;
        
        genre.priority = [categoryDictionary objectForKey: @"priority"
                                              withDefault: @0];
        
    }
        
    
    for (Genre* category in existingCategories)
    {
        if(category.markedForDeletionValue)
            [category.managedObjectContext deleteObject:category];
    }
    
    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}

- (BOOL) registerCommentsFromDictionary: (NSDictionary*) dictionary
                           withExisting: (NSArray*)existingComments
                     forVideoInstanceId: (NSString*)vid
{
    // == Check for Validity == //
    NSDictionary *channelCoverDictionary = dictionary[@"comments"];
    if (![channelCoverDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = channelCoverDictionary[@"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    Comment* comment;
    
    NSMutableDictionary* commentsById = [NSMutableDictionary dictionary];
    for (comment in existingComments)
    {
        if(!comment.uniqueId)
            continue;
        
        commentsById[comment.uniqueId] = comment;
        
        if(comment.localDataValue == NO) // only mark for deletion comments that are present in the server and not on the fly comments
            comment.markedForDeletionValue = YES;
        
    }
    
    for (NSDictionary *commentItemDictionary in itemArray)
    {
        if (![commentItemDictionary isKindOfClass: [NSDictionary class]])
            continue;
        
        NSString* commentId = [commentItemDictionary objectForKey:@"id"];
        
        if(![commentId isKindOfClass:[NSNumber class]])
            continue;
        
        if(!(comment = commentsById[commentId]))
        {
            if(!(comment = [Comment instanceFromDictionary:commentItemDictionary
                                 usingManagedObjectContext:importManagedObjectContext]))
            {
                continue;
            }
        }
        
        comment.markedForDeletionValue = NO;
        
        comment.localDataValue = NO;
        
        comment.videoInstanceId = [NSString stringWithString:vid];
        
    }
    
    // delete old comments
    
    for (NSString* key in commentsById)
    {
        comment = commentsById[key];
        if(comment.markedForDeletionValue)
        {
            [comment.managedObjectContext deleteObject:comment];
        }
        
    }
    
    
    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
        return NO;
    
    [appDelegate saveContext:NO];
    
    return YES;
}

-(BOOL)registerMoodsFromDictionary:(NSDictionary*)dictionary
                 withExistingMoods:(NSArray*)moods
{
    // == Check for Validity == //
    NSDictionary *channelCoverDictionary = dictionary[@"moods"];
    if (![channelCoverDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = channelCoverDictionary[@"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    // create lookup
    
    Mood* mood;
    
    NSMutableDictionary* moodsById = [NSMutableDictionary dictionary];
    for (mood in moods)
    {
        if(!mood.uniqueId)
            continue;
        
        moodsById[mood.uniqueId] = mood;
        mood.markedForDeletionValue = YES;
        
    }
    
    
    for (NSDictionary *moodItemDictionary in itemArray)
    {
        if (![moodItemDictionary isKindOfClass: [NSDictionary class]])
            continue;
        
        NSString* moodId = [moodItemDictionary objectForKey:@"id"];
        
        if(![moodId isKindOfClass:[NSString class]])
            continue;
        
        if(!(mood = moodsById[moodId]))
        {
            if(!(mood = [Mood instanceFromDictionary:moodItemDictionary
               usingManagedObjectContext:importManagedObjectContext]))
            {
                continue;
            }
        }
        
        mood.markedForDeletionValue = NO;
        
    }
    
    for (NSString* key in moodsById)
    {
        mood = moodsById[key];
        if(mood.markedForDeletionValue)
           [mood.managedObjectContext deleteObject:mood];
    }
    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
        return NO;
    
    [appDelegate saveContext:NO];
    
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

    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
        return NO;
    
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
        }
        else if (itemDictionary[@"cover"]) // channel object
        {
            
            if(!(object = channelInstacesByUniqueId[itemDictionary[@"id"]]))
                if(!(object = [Channel instanceFromDictionary:itemDictionary
                                    usingManagedObjectContext:importManagedObjectContext]))
                    continue;
        }
        
        
        
        object.viewId = kFeedViewId;
        
        object.markedForDeletionValue = NO;
        
        leafFeedItem = [FeedItem instanceFromResource:object];
        
        if(!leafFeedItem)
            continue;
        
        
        
        // object has been created, see if it belongs to an aggregation
        
        NSString* aggregationIndex = itemDictionary[@"aggregation"];
        if(!aggregationIndex || ![aggregationIndex isKindOfClass:[NSString class]]) // the item IS part of an aggregation
            continue;
        
        
        // if we have already created the FeedItem, use it
        aggregationFeedItem = aggregationItems[aggregationIndex];
		
        // else, create a new one
        if(!aggregationFeedItem)
        {
            NSDictionary* aggregationItemDictionary = aggregationsDictionary[aggregationIndex];
			
			aggregationFeedItem = feedItemInstacesByUniqueId[aggregationIndex];
			
			if (aggregationFeedItem) {
				[aggregationFeedItem setAttributesFromDictionary:aggregationItemDictionary];
			} else {
				aggregationFeedItem = [FeedItem instanceFromDictionary:aggregationItemDictionary
																withId:aggregationIndex
											 usingManagedObjectContext:importManagedObjectContext];
				
				if (!aggregationFeedItem) {
					continue;
				}
			}
            
            aggregationFeedItem.viewId = kFeedViewId;
            aggregationFeedItem.markedForDeletionValue = NO;
            
            aggregationItems[aggregationFeedItem.uniqueId] = aggregationFeedItem;
            
            
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
