//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
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
