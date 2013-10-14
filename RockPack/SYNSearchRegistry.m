//
//  SYNSearchRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "AppConstants.h"
#import "Channel.h"
#import "Friend.h"
#import "SYNAppDelegate.h"
#import "SYNSearchRegistry.h"
#import "Video.h"
#import "VideoInstance.h"
#import <AddressBook/AddressBook.h>

@implementation SYNSearchRegistry


- (BOOL) clearImportContextFromEntityName: (NSString *) entityName
{
    if ([super clearImportContextFromEntityName: entityName])
    {
        [appDelegate saveSearchContext];
        return YES;
    }
    
    return NO;
}


// returns a cached image dictionary
- (NSCache *) registerFriendsFromAddressBookArray: (NSArray *) abArray
{
    NSInteger total = [abArray count];
    
    // placeholders
    NSString *firstName, *lastName, *email;
    NSData *imageData;
    Friend *contactAsFriend;
    
    
    NSCache *imageCache = [[NSCache alloc] init];
    
    // fetch existing friends from DB
    
    NSError *error;
    NSArray *existingFriendsArray;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    // friends from address book only
    fetchRequest.predicate = [NSPredicate predicateWithFormat: @"externalSystem == %@ AND localOrigin == YES", kEmail];
    
    existingFriendsArray = [appDelegate.searchManagedObjectContext
                            executeFetchRequest: fetchRequest
                            error: &error];
    
    
    
    NSMutableDictionary *existingFriendsByEmail = [NSMutableDictionary dictionaryWithCapacity: existingFriendsArray.count];
    
    for (Friend *existingFriend in existingFriendsArray)
    {
        if (!existingFriend.email)
        {
            continue;
        }
        
        existingFriendsByEmail[existingFriend.email] = existingFriend;
        
        existingFriend.markedForDeletionValue = YES;
    }
    
    // parse friends from address book array
    
    for (NSUInteger peopleCounter = 0; peopleCounter < total; peopleCounter++)
    {
        ABRecordRef currentPerson = (__bridge ABRecordRef) abArray[peopleCounter];
        ABRecordID cid;
        
        if (!currentPerson || ((cid = ABRecordGetRecordID(currentPerson)) == kABRecordInvalidID))
        {
            continue;
        }
        
        ABMultiValueRef emailAddressMultValue = ABRecordCopyValue(currentPerson, kABPersonEmailProperty);
        NSArray *emailAddresses = (__bridge NSArray *) ABMultiValueCopyArrayOfAllValues(emailAddressMultValue);
        CFRelease(emailAddressMultValue);
        
        if (emailAddresses.count == 0) // only keep contacts with email addresses
        {
            continue;
        }
        
        email = (NSString *) emailAddresses[0];
        
        if (!(contactAsFriend = existingFriendsByEmail[email])) // will have email due to previous condition
        {
            if (!(contactAsFriend = [Friend insertInManagedObjectContext: appDelegate.searchManagedObjectContext]))
            {
                continue; // if cache AND instatiation fails, bail
            }
        }
        
        contactAsFriend.uniqueId = email; // email serves as a uniqueId for address book friends
        contactAsFriend.markedForDeletionValue = NO;
        contactAsFriend.localOriginValue = YES;
        
        firstName = (__bridge_transfer NSString *) ABRecordCopyValue(currentPerson, kABPersonFirstNameProperty);
        lastName = (__bridge_transfer NSString *) ABRecordCopyValue(currentPerson, kABPersonLastNameProperty);
        contactAsFriend.displayName = [NSString stringWithFormat: @"%@ %@", firstName, lastName];
        
        imageData = (__bridge_transfer NSData *) ABPersonCopyImageData(currentPerson);
        
        
        contactAsFriend.email = email;
        contactAsFriend.externalSystem = kEmail;
        contactAsFriend.externalUID = [NSString stringWithFormat: @"%i", cid];
        
        if (imageData)
        {
            NSString *key = [NSString stringWithFormat: @"cached://%@", contactAsFriend.uniqueId];
            
            contactAsFriend.thumbnailURL = key;
            
            [imageCache setObject: imageData
                           forKey: key];
        }
    }
    
    // delete old friends cached
    Friend *deleteCandidate;
    
    for (id key in existingFriendsByEmail)
    {
        deleteCandidate = (Friend *) existingFriendsByEmail[key];
        
        if (deleteCandidate && deleteCandidate.markedForDeletionValue)
        {
            [deleteCandidate.managedObjectContext
             deleteObject: deleteCandidate];
        }
    }
    
    if (![appDelegate.searchManagedObjectContext
          save: &error])
    {
        return nil; //
    }
    
    return imageCache;
}


- (BOOL) registerFriendsFromDictionary: (NSDictionary *) dictionary
{
    NSDictionary *usersDictionary = dictionary[@"users"];
    
    if (!usersDictionary || ![usersDictionary[@"items"]
                              isKindOfClass: [NSArray class]])
    {
        return NO;
    }
    
    // fetch existing friends
    
    NSError *error;
    NSArray *existingFriendsArray;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    // friends from address book are not found in the web service responce and should be protected from deletion
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"externalSystem != %@", kEmail];
    
    existingFriendsArray = [appDelegate.searchManagedObjectContext
                            executeFetchRequest: fetchRequest
                            error: &error];
    
    
    
    NSMutableDictionary *existingFriendsByUID = [NSMutableDictionary dictionaryWithCapacity: existingFriendsArray.count];
    //    NSMutableDictionary* existingFriendsByEmail = [NSMutableDictionary dictionaryWithCapacity:existingFriendsArray.count];
    
    for (Friend *existingFriend in existingFriendsArray)
    {
        if (!existingFriend.uniqueId)
        {
            existingFriend.markedForDeletionValue = YES;
            continue;
        }
        
        existingFriendsByUID[existingFriend.uniqueId] = existingFriend;
        
        if (!existingFriend.localOriginValue) // protect the address book friends...
        {
            existingFriend.markedForDeletionValue = YES;
        }
        
        //        else if (existingFriend.email && ![existingFriend.email isEqualToString:@""]) // ... and save them in the dictionary
        //            existingFriendsByEmail[existingFriend.email] = existingFriend;
    }
    
    // parse new data
    
    
    NSArray *itemsDictionary = usersDictionary[@"items"];
    
    Friend *friend;
    
    for (NSDictionary *itemDictionary in itemsDictionary)
    {
        if (!(friend = existingFriendsByUID[itemDictionary[@"id"]]))
        {
            if (!(friend = [Friend instanceFromDictionary: itemDictionary
                                usingManagedObjectContext: appDelegate.searchManagedObjectContext]))
            {
                continue;
            }
        }
        
        // if an address book friend has been transfered to
        
        friend.markedForDeletionValue = NO;
    }
    
    // delete old friends
    
    for (id key in existingFriendsByUID)
    {
        Friend *deleteCandidate = (Friend *) existingFriendsByUID[key];
        
        if (deleteCandidate && deleteCandidate.markedForDeletionValue)
        {
            [deleteCandidate.managedObjectContext
             deleteObject: deleteCandidate];
        }
    }
    
    [appDelegate saveSearchContext];
    
    return YES;
}


- (BOOL) registerVideosFromDictionary: (NSDictionary *) dictionary
{
    // == Check for Validity == //
    
    //[self clearImportContextFromEntityName:@"VideoInstance"];
    
    NSDictionary *videosDictionary = dictionary[@"videos"];
    
    if (!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
    {
        return NO;
    }
    
    NSArray *itemArray = videosDictionary[@"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]])
    {
        return NO;
    }
    
    NSFetchRequest *videoFetchRequest = [[NSFetchRequest alloc] init];
    [videoFetchRequest setEntity: [NSEntityDescription entityForName: @"Video"
                                              inManagedObjectContext: importManagedObjectContext]];
    
    NSMutableArray *videoIds = [NSMutableArray array];
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        id uniqueId = (itemDictionary[@"video"])[@"id"];
        
        if (uniqueId)
        {
            [videoIds addObject: uniqueId];
        }
    }
    
    NSPredicate *videoPredicate = [NSPredicate predicateWithFormat: @"uniqueId IN %@", videoIds];
    
    videoFetchRequest.predicate = videoPredicate;
    
    NSArray *existingVideos = [importManagedObjectContext executeFetchRequest: videoFetchRequest
                                                                        error: nil];
    
    // === Main Processing === //
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        if ([itemDictionary isKindOfClass: [NSDictionary class]])
        {
            NSMutableDictionary *fullItemDictionary = [NSMutableDictionary dictionaryWithDictionary: itemDictionary];
            
            // video instances on search do not have channels attached to them
            VideoInstance *videoInstance = [VideoInstance instanceFromDictionary: fullItemDictionary
                                                       usingManagedObjectContext: importManagedObjectContext
                                                             ignoringObjectTypes: kIgnoreChannelObjects
                                                                  existingVideos: existingVideos];
            
            videoInstance.viewId = kSearchViewId;
        }
    }
    
    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
    {
        return NO;
    }
    
    [appDelegate saveSearchContext];
    
    return YES;
}


- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary
{
    NSDictionary *channelsDictionary = dictionary[@"channels"];
    
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
    {
        return NO;
    }
    
    NSArray *itemArray = channelsDictionary[@"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]])
    {
        return NO;
    }
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        Channel *channel = [Channel instanceFromDictionary: itemDictionary
                                 usingManagedObjectContext: importManagedObjectContext];
        
        if (!channel)
        {
            DebugLog(@"Could not instantiate channel with data:\n%@", itemDictionary);
            continue;
        }
        
        channel.viewId = kSearchViewId;
    }
    
    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
    {
        return NO;
    }
    
    [appDelegate saveSearchContext];
    
    return YES;
}


- (BOOL) registerSubscribersFromDictionary: (NSDictionary *) dictionary
                               byAppending: (BOOL) append;
{
    return [self registerChannelOwnersFromDictionary: dictionary
                                           forViewId: kSubscribersListViewId
                                         byAppending: append];
}


- (BOOL) registerUsersFromDictionary: (NSDictionary *) dictionary
                         byAppending: (BOOL) append;
{
    return [self registerChannelOwnersFromDictionary: dictionary
                                           forViewId: kSearchViewId
                                         byAppending: append];
}


- (BOOL) registerChannelOwnersFromDictionary: (NSDictionary *) dictionary
                                   forViewId: (NSString *) viewId
                                 byAppending: (BOOL) append;
{
    NSError *error;
    NSArray *itemsToDelete;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"ChannelOwner"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", viewId]];
    
    
    itemsToDelete = [appDelegate.searchManagedObjectContext
                     executeFetchRequest: fetchRequest
                     error: &error];
    
    if (append == NO)
    {
        for (NSManagedObject *objectToDelete in itemsToDelete)
        {
            [appDelegate.searchManagedObjectContext
             deleteObject: objectToDelete];
        }
    }
    
    NSDictionary *channelsDictionary = dictionary[@"users"];
    
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
    {
        return NO;
    }
    
    NSArray *itemArray = channelsDictionary[@"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]])
    {
        return NO;
    }
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        ChannelOwner *user = [ChannelOwner instanceFromDictionary: itemDictionary
                                        usingManagedObjectContext: appDelegate.searchManagedObjectContext
                                              ignoringObjectTypes: kIgnoreChannelObjects];
        
        if (!user)
        {
            DebugLog(@"Could not instantiate channel with data:\n%@", itemDictionary);
            continue;
        }
        
        user.viewId = viewId;
    }
    
    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
    {
        return NO;
    }
    
    [appDelegate saveSearchContext];
    
    return YES;
}

@end
