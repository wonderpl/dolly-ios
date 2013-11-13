//
//  SYNVideoQueue.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNVideoQueue.h"
#import "Video.h"
#import "SYNMasterViewController.h"
#import "VideoInstance.h"

@interface SYNVideoQueue ()

@property (nonatomic, assign) BOOL isEmpty;
@property (nonatomic, strong) NSTimer *videoQueueAnimationTimer;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end

@implementation SYNVideoQueue;

#pragma mark - Object lifecycle

+ (id) queue
{
    return [[self alloc] init];
}

- (id) init
{
    if (self = [super init])
    {
        self.appDelegate = (SYNAppDelegate*)UIApplication.sharedApplication.delegate;
    
        [self setup];
    }
    
    return self;
}

- (void) dealloc
{
    // Stop observing everything (less error-prone than trying to remove observers individually
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


- (BOOL) videoInstanceIsAddedToChannel: (VideoInstance*) videoInstance
{
    
    for (VideoInstance* channelInstance in self.currentlyCreatingChannel.videoInstances)
    {
        if ([channelInstance.uniqueId isEqualToString: videoInstance.uniqueId])
        {
            return YES;
        }   
    }
 
    return NO;
}


- (void) setup
{
    // Removed in dealloc
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleVideoQueueAddRequest:)
                                                 name: kVideoQueueAdd
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleVideoQueueRemoveRequest:)
                                                 name: kVideoQueueRemove
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleVideoQueueClearRequest:)
                                                 name: kVideoQueueClear
                                               object: nil];
}


#pragma mark - Notification Handlers

- (void) handleVideoQueueAddRequest:(NSNotification*)notification
{
    
    VideoInstance* videoInstanceToAdd = (VideoInstance*) notification.userInfo[kVideoInstance];
    [self addVideoToQueue: videoInstanceToAdd];
    videoInstanceToAdd.selectedForVideoQueue = YES;
}


- (void) handleVideoQueueRemoveRequest: (NSNotification*) notification
{
    VideoInstance* videoInstanceToAdd = (VideoInstance*) notification.userInfo[kVideoInstance];
    [self removeFromVideoQueue: videoInstanceToAdd];
    videoInstanceToAdd.selectedForVideoQueue = NO;
}


- (void) handleVideoQueueClearRequest: (NSNotification*) notification
{
    
    for (VideoInstance* currentVideoInstance in self.currentlyCreatingChannel.videoInstances)
    {
        [self.appDelegate.channelsManagedObjectContext deleteObject:currentVideoInstance];
    }
    
    [self.appDelegate.channelsManagedObjectContext deleteObject:self.currentlyCreatingChannel];
    
    [self.appDelegate saveChannelsContext];
    
    self.currentlyCreatingChannel = nil;
    
}

#pragma mark - 

- (void) addVideoToQueue: (VideoInstance *) videoInstance
{
    if (!videoInstance)
    {
        AssertOrLog(@"Trying to add a nil video instance into the queue through: 'addVideoToQueue:'");
        return;
    }
    
    if(self.isEmpty)
    {
        AssertOrLog(@"The Video Q is not empty and you cannot currently add more than one videos");
        return;
    }

    
    VideoInstance* copyOfVideoInstance = [VideoInstance instanceFromVideoInstance: videoInstance
                                                        usingManagedObjectContext: self.appDelegate.channelsManagedObjectContext
                                                              ignoringObjectTypes: kIgnoreChannelObjects];
    
    
    
    [self.currentlyCreatingChannel addVideoInstancesObject:copyOfVideoInstance];
    
    
    [self.appDelegate.masterViewController addExistingCollectionsOverlayController];
    
}

- (void) removeFromVideoQueue: (VideoInstance*) videoInstance
{
    // clear objects from core data
    for (VideoInstance* currentVideoInstance in self.currentlyCreatingChannel.videoInstances)
    {
        if ([currentVideoInstance.uniqueId isEqualToString: videoInstance.uniqueId])
        { 
            [self.appDelegate.channelsManagedObjectContext deleteObject: currentVideoInstance];
            
            [self.appDelegate saveChannelsContext];
            
            break;
        }
    }
}


- (Channel*) currentlyCreatingChannel // lazy loading
{
    if (!_currentlyCreatingChannel) // create channel if there is none
    {
        _currentlyCreatingChannel = [Channel insertInManagedObjectContext: self.appDelegate.channelsManagedObjectContext];
        
        User* meOnAnotherContext = [User instanceFromUser: self.appDelegate.currentUser
                                usingManagedObjectContext: self.currentlyCreatingChannel.managedObjectContext];
        
        _currentlyCreatingChannel.channelOwner = (ChannelOwner*)meOnAnotherContext;
        _currentlyCreatingChannel.title = @"";
        _currentlyCreatingChannel.categoryId = @"";
        
        // Set the channel's unique Id to something temporary so that we can perform queries for the videoinstances it contains
        _currentlyCreatingChannel.uniqueId = kNewChannelPlaceholderId;

        NSError *error = nil; // if we cannot save, bail
        
        if (![self.appDelegate.channelsManagedObjectContext save: &error])
        {
            DebugLog(@"Cannot save channel to context!: %@", error);
        }
    }
    
    return _currentlyCreatingChannel;
}


- (BOOL) isEmpty
{
    // we either do not have a channel or we have one and it is empty
    if (!_currentlyCreatingChannel)
    {
        return YES;
    }
    
    return (_currentlyCreatingChannel.videoInstances.count == 0);
}

@end
