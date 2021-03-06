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
#import "Recommendation.h"
#import "NSString+Validation.h"
#import "SYNActivityManager.h"

@import AddressBook;

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
- (NSMutableDictionary *) registerFriendsFromAddressBookArray: (NSArray *) abArray
{
    NSInteger total = [abArray count];
    
    // placeholders
    NSData *imageData;
    Friend *contactAsFriend;
    
    
    NSMutableDictionary *imageCache = [[NSMutableDictionary alloc] init];
    
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
        
        NSString *email;
        
        for (int i = 0; i<emailAddresses.count; i++) {
            email = (NSString *) emailAddresses[i];
            
            if (![email isValidEmail]) {
                continue;
            }
            
            if (!(contactAsFriend = existingFriendsByEmail[email])) // will have email due to previous condition
            {
                if (!(contactAsFriend = [Friend insertInManagedObjectContext: appDelegate.searchManagedObjectContext]))
                {
                    continue; // if cache AND instatiation fails, bail
                }
            }
            
            
            
            
            [contactAsFriend setAttributesFromAddressBook:currentPerson email:email];
            
            imageData = (__bridge_transfer NSData *) ABPersonCopyImageData(currentPerson);
            
            if (imageData)
            {
                NSString *key = [NSString stringWithFormat: @"cached://%@", contactAsFriend.uniqueId];
                
                contactAsFriend.thumbnailURL = key;
                
                [imageCache setObject: imageData
                               forKey: key];
            }

            
            if (existingFriendsByEmail[contactAsFriend.email]) {
                contactAsFriend.lastShareDate = ((Friend*)existingFriendsByEmail[contactAsFriend.email]).lastShareDate;
            }
            
            contactAsFriend.externalUID = [NSString stringWithFormat: @"%i", cid];

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
    
    
    // friends from address book are not found in the web service responce and should be protected from deletion
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"externalSystem != %@", kEmail];
    
    NSArray *existingFriendsArray = [self getExistingFriends];
    NSMutableDictionary *existingFriendsByUID = [self getFriendsByIdFromArray:existingFriendsArray];
    NSMutableDictionary *existingFriendsByEmail = [self getFriendsByEmailFromArray:existingFriendsArray];

    // parse new data
    
    NSArray *itemsDictionary = usersDictionary[@"items"];

    Friend *friend;
    
    for (NSDictionary *itemDictionary in itemsDictionary)
    {
    	friend = [Friend instanceFromDictionary: itemDictionary
                      usingManagedObjectContext: appDelegate.searchManagedObjectContext];

        // if an address book friend has been transfered to
        
        if ([existingFriendsByUID objectForKey:itemDictionary[@"external_uid"]]) {
            
            ((Friend*)[existingFriendsByUID objectForKey:itemDictionary[@"external_uid"]]).markedForDeletionValue = YES;
        }
        
        if (existingFriendsByEmail[itemDictionary[@"email"]]) {
            friend.thumbnailURL = ((Friend*)existingFriendsByEmail[itemDictionary[@"email"]]).thumbnailURL;
        }
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
    
    [appDelegate.searchManagedObjectContext processPendingChanges];
    [appDelegate saveSearchContext];
    
    return YES;
}

- (NSArray*)getExistingFriends {
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];

    
    return [appDelegate.searchManagedObjectContext
     executeFetchRequest: fetchRequest
     error: &error];
}

- (NSMutableDictionary*)getFriendsByIdFromArray :(NSArray*) friendsArray {
    
    
    NSMutableDictionary *existingFriendsByUID = [NSMutableDictionary dictionaryWithCapacity: friendsArray.count];

    for (Friend *existingFriend in friendsArray)
    {
        //Defensive, No id so delete
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
    }

    
    return existingFriendsByUID;
}

- (NSMutableDictionary*)getFriendsByEmailFromArray :(NSArray*) friendsArray {
    
    NSMutableDictionary *existingFriendsByEmail = [NSMutableDictionary dictionaryWithCapacity: friendsArray.count];
    
    for (Friend *existingFriend in friendsArray) {
        if (existingFriend.email) {
            existingFriendsByEmail[existingFriend.email] = existingFriend;
        }
	}
    
    return existingFriendsByEmail;
}


- (BOOL)registerVideoInstancesFromDictionary: (NSDictionary *) dictionary {
    return [self registerVideoInstancesFromDictionary:dictionary withViewId:kSearchViewId];
}

- (BOOL) registerVideoInstancesFromDictionary: (NSDictionary *) dictionary withViewId:(NSString*)viewId {
    // == Check for Validity == //
    
    NSDictionary *videosDictionary = dictionary[@"videos"];
    
    if (!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    
    NSArray *itemArray = videosDictionary[@"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    
    NSFetchRequest *videoFetchRequest = [[NSFetchRequest alloc] init];
    [videoFetchRequest setEntity: [NSEntityDescription entityForName: kVideo
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
                                                             ignoringObjectTypes: kIgnoreNothing
                                                                  existingVideos: existingVideos];
            
            videoInstance.viewId = viewId; // kSearchViewId and kMoodViewId usually
        
        	[[SYNActivityManager sharedInstance] addObjectFromDict:fullItemDictionary];
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

- (BOOL) registerSubscribersFromDictionary: (NSDictionary *) dictionary;
{
    return [self registerChannelOwnersFromDictionary: dictionary
                                           forViewId: kSubscribersListViewId];
}


- (BOOL) registerUsersFromDictionary: (NSDictionary *) dictionary;
{
    return [self registerChannelOwnersFromDictionary: dictionary
                                           forViewId: kSearchViewId];
}

// User Recommendations (like that on the on boarding) are registered as Recommendation Obejcts
- (BOOL) registerRecommendationsFromDictionary: (NSDictionary *) dictionary {
	// Delete existing recommendations
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Recommendation entityName]];
	NSArray *recommendations = [importManagedObjectContext executeFetchRequest:fetchRequest error:nil];
	for (Recommendation *recommendation in recommendations) {
		[importManagedObjectContext deleteObject:recommendation];
	}
	
    NSDictionary *usersDictionary = dictionary[@"users"];
    if (![usersDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    //NSNumber* total = usersDictionary[@"total"];
    NSArray* itemsArray = usersDictionary[@"items"];
    for (NSDictionary* itemDictionary in itemsArray)
    {
        Recommendation* recomendation = [Recommendation instanceFromDictionary:itemDictionary
                                                   usingManagedObjectContext:importManagedObjectContext];
        
        if(!recomendation)
            continue;
    }
    
    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
    {
        return NO;
    }
    
    [appDelegate saveSearchContext];
    
    return YES;
}

- (BOOL) registerChannelOwnersFromDictionary: (NSDictionary *) dictionary
                                   forViewId: (NSString *) viewId {
    
    
    NSDictionary *channelOwnersDictionary = dictionary[@"users"];
    
    if (![channelOwnersDictionary isKindOfClass: [NSDictionary class]])
    {
        return NO;
    }
    
    NSArray *itemArray = channelOwnersDictionary[@"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    ChannelOwner *channelOwner;
    for (NSDictionary *itemDictionary in itemArray)
    {
        if(!(channelOwner = [ChannelOwner instanceFromDictionary: itemDictionary
                                       usingManagedObjectContext: importManagedObjectContext
                                             ignoringObjectTypes: kIgnoreChannelObjects]))
        {
            continue;
        }
        
        channelOwner.markedForDeletionValue = NO;
        channelOwner.viewId = viewId;
    }
    
    
    /* NOTE:  search registry never clears its entries upon registry because the data is always considered fresh.
    It is the controllers responsibility to clear it when needed */
    
    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
    {
        return NO;
    }
    
    [appDelegate saveSearchContext];
    
    return YES;
}

@end
