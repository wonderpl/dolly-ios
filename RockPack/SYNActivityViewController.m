//
//  SYNNotificationsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "SYNAppDelegate.h"
#import "SYNMasterViewController.h"
#import "SYNNotificationsTableViewCell.h"
#import "SYNActivityViewController.h"
#import "SYNNotification.h"
#import "UIImageView+WebCache.h"
#import "Video.h"

#define kNotificationsCellIdent @"kNotificationsCellIdent"

@interface SYNActivityViewController ()

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@end


@implementation SYNActivityViewController

@synthesize notifications = _notifications;




#pragma mark - View Life Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Notifications"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView registerClass: [SYNNotificationsTableViewCell class]
           forCellReuseIdentifier: kNotificationsCellIdent];
    
    [self loadNotifications];
}

#pragma mark - Get Data

- (void) loadNotifications
{
    [appDelegate.oAuthNetworkEngine notificationsFromUserId: appDelegate.currentUser.uniqueId
                                          completionHandler: ^(id response) {
                                              
                                              
                                              [self parseNotificationsFromDictionary:response];
                                              
                                              
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
        [self.tableView reloadData];
        
        self.notifications = @[];
        return;
    }
    
    
    NSMutableArray* inNotificationsutArray = @[].mutableCopy;
    
    
    
    for (NSDictionary* itemData in itemsArray)
    {
        
        
        SYNNotification* notification = [SYNNotification notificationWithDictionary:itemData];
        
        if (!notification || notification.objectType == kNotificationObjectTypeUnknown)
            continue;
        
        
        [inNotificationsutArray addObject:notification];
        
    }
    
    self.notifications = [NSArray arrayWithArray:inNotificationsutArray];
    
    [self.tableView reloadData];
}

#pragma mark - TableView Delegate/Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger)	tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return _notifications ? _notifications.count : 0;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    SYNNotificationsTableViewCell *notificationCell = [tableView dequeueReusableCellWithIdentifier: kNotificationsCellIdent
                                                                                      forIndexPath: indexPath];
    
    SYNNotification *notification = (SYNNotification *) _notifications[indexPath.row];
    
    NSMutableString *constructedMessage = [[NSMutableString alloc] init];
    
    [constructedMessage appendFormat: @"%@ ", [notification.channelOwner.displayName uppercaseString]];
    
    if ([notification.messageType isEqualToString: @"subscribed"])
    {
        [constructedMessage appendString: NSLocalizedString(@"notification_subscribed_action", nil)];
    }
    else if ([notification.messageType isEqualToString: @"starred"])
    {
        [constructedMessage appendString: NSLocalizedString(@"notification_liked_action", nil)];
    }
    else if ([notification.messageType isEqualToString: @"joined"])
    {
        NSMutableString *message = [NSMutableString stringWithFormat: NSLocalizedString(@"notification_joined_action", @"Your Facebook friend (name) has joined Rockpack"), [notification.channelOwner.displayName uppercaseString]];
        
        constructedMessage = message;
    }
    else
    {
        AssertOrLog(@"Notification type unexpected");
    }
    
    notificationCell.messageTitle = [NSString stringWithString: constructedMessage];
    
    NSURL *userThumbnailUrl = [NSURL URLWithString: notification.channelOwner.thumbnailLargeUrl];
    
    [notificationCell.imageView setImageWithURL: userThumbnailUrl
                               placeholderImage: [UIImage imageNamed: @"PlaceholderNotificationAvatar.png"]
                                        options: SDWebImageRetryFailed];
    
    NSURL *thumbnaillUrl;
    UIImage *placeholder;
    
    notificationCell.playSymbolImageView.hidden = TRUE;

    switch (notification.objectType)
    {
        case kNotificationObjectTypeUserLikedYourVideo:
            thumbnaillUrl = [NSURL URLWithString: notification.videoThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationVideo"];
            notificationCell.playSymbolImageView.hidden = FALSE;

            break;
            
        case kNotificationObjectTypeUserSubscibedToYourChannel:
            thumbnaillUrl = [NSURL URLWithString: notification.channelThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationChannel"];
            break;
            
        case kNotificationObjectTypeFacebookFriendJoined:
            break;
            
        default:
            AssertOrLog(@"Unexpected notification type");
            break;
    }
    
    // If we have a righthand image then load it
    if (thumbnaillUrl && placeholder)
    {
        notificationCell.thumbnailImageView.hidden = FALSE;
        
        [notificationCell.thumbnailImageView setImageWithURL: thumbnaillUrl
                                            placeholderImage: placeholder
                                                     options: SDWebImageRetryFailed];
    }
    else
    {
        // Otherwse hide it
        notificationCell.thumbnailImageView.hidden = TRUE;
    }
    
    notificationCell.delegate = self;
    notificationCell.read = notification.read;
    
    notificationCell.detailTextLabel.text = notification.dateDifferenceString;
    
    
    return notificationCell;
}


- (CGFloat) tableView: (UITableView *) tableView
            heightForRowAtIndexPath: (NSIndexPath *) indexPath;
{
    return 77.0f;
}



- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    [self markAsReadForNotification: _notifications[indexPath.row]];
    
    // Decrement the badge number (min zero)
    UIApplication.sharedApplication.applicationIconBadgeNumber = MAX((UIApplication.sharedApplication.applicationIconBadgeNumber - 1) , 0);
}







// this is the user who initialed the action, goes to is profile
- (void) mainImageTableCellPressed: (UIButton *) button
{
    
    SYNNotificationsTableViewCell *cellPressed = [self getCellFromButton:button];
    
    NSIndexPath *indexPathForCellPressed = [self.tableView indexPathForCell: cellPressed];
    
    if (indexPathForCellPressed.row > self.notifications.count)
        return;
    
    SYNNotification *notification = self.notifications[indexPathForCellPressed.row];
    
    
    [appDelegate.viewStackManager viewProfileDetails: notification.channelOwner];
    
    [self markAsReadForNotification: notification];
}


- (void) itemImageTableCellPressed: (UIButton *) button
{
    SYNNotificationsTableViewCell *cellPressed = [self getCellFromButton:button];
    
    NSIndexPath *indexPathForCellPressed = [self.tableView
                                            indexPathForCell: cellPressed];
    
    SYNNotification *notification = self.notifications[indexPathForCellPressed.row];
    
    if (!notification)
    {
        return;
    }
    
    
    switch (notification.objectType)
    {
        case kNotificationObjectTypeUserLikedYourVideo:
        {
            Channel *channel = [self channelFromChannelId: notification.channelId];
            
            if (!channel)
            {
                return;
            }
            
            [appDelegate.viewStackManager viewChannelDetails: channel
                                              withAutoplayId: notification.videoId];
            break;
        }
            
        case kNotificationObjectTypeUserSubscibedToYourChannel:
        {
            Channel *channel = [self channelFromChannelId: notification.channelId];
            
            if (!channel)
            {
                return;
            }
            
            [appDelegate.viewStackManager viewChannelDetails: channel];
            break;
        }
            
        case kNotificationObjectTypeFacebookFriendJoined:
        {
            ChannelOwner *channelOwner = notification.channelOwner;
            
            if (!channelOwner)
            {
                return;
            }
            
            [appDelegate.viewStackManager viewProfileDetails: channelOwner];
            break;
        }
            
        default:
            AssertOrLog(@"Unexpected notification type");
            break;
    }
    
    [self markAsReadForNotification: notification];
}


- (void) markAsReadForNotification: (SYNNotification *) notification
{
    if (notification == nil || notification.read) // if already read or nil, don't bother...
    {
        return;
    }
    
    NSArray *array = @[@(notification.identifier)];
    
    [appDelegate.oAuthNetworkEngine markAsReadForNotificationIndexes:array
                                                          fromUserId:appDelegate.currentUser.uniqueId
                                                   completionHandler:^(id responce) {
        
                                                       notification.read = YES;
        
                                                       [self.tableView reloadData];
        
                                                       [[NSNotificationCenter defaultCenter]  postNotificationName: kNotificationMarkedRead
                                                                                                            object: self];
        
                                                   } errorHandler:^(id error) {
        
                                                   }];
    
}




#pragma mark - Accessors

- (void) setNotifications: (NSArray *) notifications
{
    _notifications = notifications;
    
    [self.tableView reloadData];
}


- (NSArray *) notifications
{
    return _notifications;
}


- (Channel *) channelFromChannelId: (NSString *) channelId
{
    NSError *error;
    Channel *channel;

    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    
    channelFetchRequest.entity = [NSEntityDescription entityForName: @"Channel"
                                             inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    channelFetchRequest.predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", channelId];

    NSArray *matchingChannelEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                               error: &error];
    
    if (matchingChannelEntries.count > 0)
    {
        channel = matchingChannelEntries[0];
    }
    
    return channel;
}

-(NSInteger)unreadNotificationsCount
{
    __block NSInteger unread = 0;
    [self.notifications enumerateObjectsUsingBlock:^(SYNNotification* notification, NSUInteger idx, BOOL *stop) {
        unread += (NSInteger)(notification.read); // convert the YES, NO into a 1, 0 int and add it
    }];
    return unread;
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

@end
