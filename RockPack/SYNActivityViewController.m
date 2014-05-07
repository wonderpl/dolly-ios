//
//  SYNActivityViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAppDelegate.h"
#import "SYNMasterViewController.h"
#import "SYNNotificationsTableViewCell.h"
#import "SYNActivityViewController.h"
#import "SYNNotification.h"
#import "Video.h"
#import "SYNTrackingManager.h"
#import "SYNNotificationsMarkAllAsReadCell.h"

#define kNotificationsCellIdent @"kNotificationsCellIdent"
#define kNotificationsSpecialCellIdent @"SYNNotificationsMarkAllAsReadCell"

@interface SYNActivityViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL hasUnreadNotifications;

@property (nonatomic, strong) NSArray *notifications;

@end


@implementation SYNActivityViewController


#pragma mark - View Life Cycle

- (id) initWithViewId:(NSString *)vid
{
    if (self = [super initWithViewId:vid])
    {
        appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
        self.hasUnreadNotifications = NO;
        self.notifications = @[];
		[self loadNotifications];
		
	}
    return self;
}


- (void) viewDidLoad {
    [super viewDidLoad];

	self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:kNotificationsSpecialCellIdent bundle:nil] forCellReuseIdentifier:kNotificationsSpecialCellIdent];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SYNNotificationsTableViewCell" bundle:nil]
           forCellReuseIdentifier:kNotificationsCellIdent];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self loadNotifications];
	[self markAllAsRead];
	
	[[SYNTrackingManager sharedManager] trackActivityScreenView];
}

#pragma mark - Get Data

- (void) loadNotifications
{
    [appDelegate.oAuthNetworkEngine notificationsFromUserId: appDelegate.currentUser.uniqueId
                                          completionHandler: ^(id response) {
                                              
                                              
                                              [self parseNotificationsFromDictionary:response];
                                              
											  
											  if (self.notifications.count == 0) {
												  // Hack to stop the tab bar from being by scrolling via bouncing with no notifications
												  self.tableView.alwaysBounceVertical = NO;
												  
												  [self displayPopupMessage:NSLocalizedString (@"notification_empty", nil) withLoader:NO];
											  } else {
												  self.tableView.alwaysBounceVertical = YES;
												  
												  [self removePopupMessage];
											  }
											  
											  [self.tableView reloadData];
                                              
                                          } errorHandler:^(id error) {
                                              DebugLog(@"Could not load notifications");
                                          }];
}

-(void)parseNotificationsFromDictionary:(NSDictionary*)response
{
    if (![response isKindOfClass:[NSDictionary class]])
        return;
    
    // == Sanity Check == //
    
    NSDictionary* responseDictionary = (NSDictionary*)response;
    
    NSDictionary* notificationsDictionary = responseDictionary[@"notifications"];
    if (!notificationsDictionary)
        return;
    
    NSNumber* totalNumber = notificationsDictionary[@"total"];
    if (!totalNumber)
        return;
    
    NSArray* itemsArray = (NSArray*)notificationsDictionary[@"items"];
    if (!itemsArray)
        return;
    
    // == Get Total == //
    
    NSInteger total = [totalNumber integerValue];
    
    if (total == 0) // good responce but no notifications
    {
        
        self.notifications = @[];
        self.hasUnreadNotifications = NO;
        
        return;
    }
    
    
    NSMutableArray* inNotificationsutArray = @[].mutableCopy;
    
    
    self.hasUnreadNotifications = NO;
    for (NSDictionary* itemData in itemsArray)
    {
        
        
        SYNNotification* notification = [SYNNotification notificationWithDictionary:itemData];
        
        if (!notification || notification.objectType == kNotificationObjectTypeUnknown)
            continue;
        
        if(!notification.read) // one is enought to display the read all button
            self.hasUnreadNotifications = YES;
        
        
        [inNotificationsutArray addObject:notification];
        
    }
    
    self.notifications = [NSArray arrayWithArray:inNotificationsutArray];
    
}

#pragma mark - TableView Delegate/Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger)tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    
    return  _notifications.count;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    // else, it is a normal cell
    SYNNotificationsTableViewCell *notificationCell = [tableView dequeueReusableCellWithIdentifier: kNotificationsCellIdent
                                                                                      forIndexPath: indexPath];
    
    SYNNotification *notification = (SYNNotification *) _notifications[indexPath.row];
	
    notificationCell.notification = notification;
    notificationCell.delegate = self;
    
    return notificationCell;
}


- (CGFloat) tableView: (UITableView *) tableView
            heightForRowAtIndexPath: (NSIndexPath *) indexPath;
{
    return IS_IPAD ? 92.0f : 76.0f;
}




#pragma mark - Button Delegates

// this is the user who initialed the action, goes to is profile
- (void) mainImageTableCellPressed: (UIButton *) button
{
    
    SYNNotificationsTableViewCell *cellPressed = [self getCellFromButton:button];
    
    NSIndexPath *indexPathForCellPressed = [self.tableView indexPathForCell: cellPressed];
    
    if (indexPathForCellPressed.row > self.notifications.count)
        return;
    
    SYNNotification *notification = self.notifications[indexPathForCellPressed.row];
    
    
    [self viewProfileDetails: notification.channelOwner];
    
    [self markAsReadForNotification: notification];
}

// this is the secondary button to the right
- (void) itemImageTableCellPressed: (UIButton *) button
{
    
    SYNNotificationsTableViewCell *cellPressed = [self getCellFromButton:button];
    
    NSIndexPath *indexPathForCellPressed = [self.tableView indexPathForCell: cellPressed];
    
    SYNNotification *notification = self.notifications[indexPathForCellPressed.row  - (NSInteger)(self.hasUnreadNotifications)];
	
	[[SYNTrackingManager sharedManager] trackSelectedNotificationOfType:notification.objectType];
    
    if (!notification)
        return;
    
    switch (notification.objectType)
    {
            
        
        case kNotificationObjectTypeUserAddedYourVideo:
        case kNotificationObjectTypeUserLikedYourVideo:
        {
            
            Channel* channel = [Channel instanceFromDictionary: @{@"id" : notification.channelId, @"resource_url" : notification.channelResourceUrl}
                                     usingManagedObjectContext: [appDelegate mainManagedObjectContext]];
            
            [self viewVideoInstanceInChannel:channel withVideoId:notification.videoId];
            
            break;
        }
            
        case kNotificationObjectTypeUserSubscibedToYourChannel:
        {
            Channel* channel = [Channel instanceFromDictionary: @{@"id" : notification.channelId, @"resource_url" : notification.channelResourceUrl}
                                     usingManagedObjectContext: [appDelegate mainManagedObjectContext]];
            
            if (!channel)
            {
                return;
            }
            
			[self viewChannelDetails:channel withAnimation:YES];
            break;
        }
            
        case kNotificationObjectTypeFacebookFriendJoined:
        {
            ChannelOwner *channelOwner = notification.channelOwner;
            
            if (!channelOwner)
            {
                return;
            }
            
            [self viewProfileDetails: channelOwner];
            break;
        }
            
            
        case kNotificationObjectTypeCommentMention:
        {
            Channel* channel = [Channel instanceFromDictionary: @{@"id" : notification.channelId, @"resource_url" : notification.channelResourceUrl}
                                     usingManagedObjectContext: [appDelegate mainManagedObjectContext]];
            
            [self viewVideoInstanceInChannel:channel withVideoId:notification.videoId];
            break;
        }

         
        default:
            AssertOrLog(@"Unexpected notification type");
            break;
    }
    
    [self markAsReadForNotification: notification];
}

- (void) markAllAsRead {
	[[SYNTrackingManager sharedManager] trackMarkAllNotificationAsRead];
    
    SYNNotification* notification;

    if (self.hasUnreadNotifications)
        notification = nil;
    
    [self markAsReadForNotification: notification];

}

- (void) markAsReadForNotification: (SYNNotification *) notification
{
    
    NSArray *array;
    if (notification) {
        array = @[@(notification.identifier)];
	} else {
        array = @[];
	}
    
    [appDelegate.oAuthNetworkEngine markAsReadForNotificationIndexes:array
                                                          fromUserId:appDelegate.currentUser.uniqueId
                                                   completionHandler:^(id responce) {
        
                                                       
                                                       if(notification)
                                                       {
                                                           // Decrement the badge number (min zero)
                                                           UIApplication.sharedApplication.applicationIconBadgeNumber =
                                                           MAX((UIApplication.sharedApplication.applicationIconBadgeNumber - 1) , 0);
                                                        
                                                           notification.read = YES;
                                                           
                                                           self.hasUnreadNotifications = NO;
                                                           for (SYNNotification* n in self.notifications)
                                                               if(!n.read)
                                                                   self.hasUnreadNotifications = YES;
                                                       }
                                                       else
                                                       {
                                                           for (SYNNotification* n in self.notifications)
                                                               n.read = YES;
                                                           
                                                           UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
                                                           
                                                           self.hasUnreadNotifications = NO;
                                                           
                                                       }
                                                       
                                                       [self.tableView reloadData];
        
                                                   } errorHandler:^(id error) {
                                                       
                                                   }];
    
}


#pragma mark - Delegate Handler

-(SYNNotificationsTableViewCell*)getCellFromButton:(UIButton*)button
{
    
    UIView* cell = button;
    while (![cell isKindOfClass:[SYNNotificationsTableViewCell class]])
    {
        cell = cell.superview;
    }
    return (SYNNotificationsTableViewCell*)cell;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
	[self loadNotifications];
}


@end
