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
#import <UIImageView+WebCache.h>
#import "Video.h"
#import "SYNNotificationsMarkAllAsReadCell.h"
#import <QuartzCore/QuartzCore.h>

#define kNotificationsCellIdent @"kNotificationsCellIdent"
#define kNotificationsSpecialCellIdent @"SYNNotificationsMarkAllAsReadCell"

@interface SYNActivityViewController ()
{
    BOOL hasUnreadNotifications;
}

@property (nonatomic, strong) IBOutlet UITableView* tableView;


@end


@implementation SYNActivityViewController

@synthesize notifications = _notifications;




#pragma mark - View Life Cycle

- (id) initWithViewId:(NSString *)vid
{
    if (self = [super initWithViewId:vid])
    {
        appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
        hasUnreadNotifications = NO;
        self.notifications = @[];
        [self loadNotifications];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
	self.automaticallyAdjustsScrollViewInsets = YES;
    
    [tracker set: kGAIScreenName
           value: @"Notifications"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.layer.borderColor = [[UIColor colorWithRed:(172.0f/255.0f) green:(172.0f/255.0f) blue:(172.0f/255.0f) alpha:1.0f] CGColor];
    self.tableView.layer.borderWidth = IS_RETINA ? 0.5f : 1.0f;
	
    
    [self.tableView registerNib:[UINib nibWithNibName:kNotificationsSpecialCellIdent bundle:nil] forCellReuseIdentifier:kNotificationsSpecialCellIdent];
    
    
    [self.tableView registerClass: [SYNNotificationsTableViewCell class]
           forCellReuseIdentifier: kNotificationsCellIdent];
    
    
    if(self.notifications.count == 0)
    {
        
        // display no notifications message
        
        [self displayPopupMessage:NSLocalizedString (@"notification_empty", nil) withLoader:NO];
    }
    
    [self.tableView reloadData];
    
    if (!IS_IPHONE_5) {
        UIEdgeInsets tmpInsets = self.tableView.contentInset;
        tmpInsets.bottom += 88;
        [self.tableView setContentInset: tmpInsets];
    }

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
        
        self.notifications = @[];
        hasUnreadNotifications = NO;
        
        return;
    }
    
    
    NSMutableArray* inNotificationsutArray = @[].mutableCopy;
    
    
    hasUnreadNotifications = NO;
    for (NSDictionary* itemData in itemsArray)
    {
        
        
        SYNNotification* notification = [SYNNotification notificationWithDictionary:itemData];
        
        if (!notification || notification.objectType == kNotificationObjectTypeUnknown)
            continue;
        
        if(!notification.read) // one is enought to display the read all button
            hasUnreadNotifications = YES;
        
        
        [inNotificationsutArray addObject:notification];
        
    }
    
    self.notifications = [NSArray arrayWithArray:inNotificationsutArray];
    
    [appDelegate.masterViewController displayNotificationsLoaded:self.notifications.count];
    
}

#pragma mark - TableView Delegate/Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger)tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    
    return  _notifications.count + (NSUInteger)(hasUnreadNotifications); // if zero then return zero, else add one
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    
    if(indexPath.row == 0 && hasUnreadNotifications) // it is the special 'read all' cell
    {
        SYNNotificationsMarkAllAsReadCell *notificationMarkAllAsReadCell = [tableView dequeueReusableCellWithIdentifier: kNotificationsSpecialCellIdent
                                                                                          forIndexPath: indexPath];
        
        
        return notificationMarkAllAsReadCell;
        
        
    }
    
    // else, it is a normal cell
    SYNNotificationsTableViewCell *notificationCell = [tableView dequeueReusableCellWithIdentifier: kNotificationsCellIdent
                                                                                      forIndexPath: indexPath];
    
    SYNNotification *notification = (SYNNotification *) _notifications[indexPath.row - (NSInteger)(hasUnreadNotifications)];
    
    NSMutableString *constructedMessage = [[NSMutableString alloc] init];
    
    // "Your friend ..."
    if([notification.messageType isEqualToString: @"joined"])
    {
        [constructedMessage appendString:@"Your friend "];
    }
    
    if(notification.channelOwner.displayName)
    {
        [constructedMessage appendFormat: @"%@ ", [notification.channelOwner.displayName uppercaseString]];
    }
    else
    {
        [constructedMessage appendFormat: @"%@ ", [notification.channelOwner.displayName uppercaseString]];
    }
    
 
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
        NSMutableString *message = [NSMutableString stringWithFormat: NSLocalizedString(@"notification_joined_action", @"Your friend [[displayName]] has joined Wonder PL"), [notification.channelOwner.displayName uppercaseString]];
        
        constructedMessage = message;
    }
    else if ([notification.messageType isEqualToString: @"repack"])
    {
        [constructedMessage appendString: NSLocalizedString(@"notification_repack_action", nil)];
    }
    else if ([notification.messageType isEqualToString: @"unavailable"])
    {
        [constructedMessage appendString: NSLocalizedString(@"notification_unavailable_action", nil)];
    }
    else
    {
        // TODO: Implement Default
        [constructedMessage appendString: NSLocalizedString(notification.messageType, nil)];
        
    }
    
    notificationCell.messageTitle = [NSString stringWithString: constructedMessage];
    
    NSURL *userThumbnailUrl = [NSURL URLWithString: notification.channelOwner.thumbnailLargeUrl];
    
    [notificationCell.imageView setImageWithURL: userThumbnailUrl
                               placeholderImage: [UIImage imageNamed: @"PlaceholderNotificationAvatar.png"]
                                        options: SDWebImageRetryFailed];
    
    NSURL *thumbnaillUrl;
    UIImage *placeholder;
    

    switch (notification.objectType)
    {
        case kNotificationObjectTypeUserLikedYourVideo:
            thumbnaillUrl = [NSURL URLWithString: notification.videoThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationVideo"];

            break;
            
        case kNotificationObjectTypeUserSubscibedToYourChannel:
            thumbnaillUrl = [NSURL URLWithString: notification.channelThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationChannel"];
            break;
            
        case kNotificationObjectTypeFacebookFriendJoined:
            // TODO: Check if Implemented
            break;
            
        case kNotificationObjectTypeUserAddedYourVideo:
            thumbnaillUrl = [NSURL URLWithString: notification.videoThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationVideo"];
            
            break;
            
        case kNotificationObjectTypeYourVideoNotAvailable:
            // TODO: Implement
            break;
            
        default:
            // TODO: Catch all code
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
    return IS_IPAD ? 92.0f : 76.0f;
}



- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    
    SYNNotification* notification;
    
    if(indexPath.row == 0 && hasUnreadNotifications)
        notification = nil;
    else
        notification = _notifications[indexPath.row - (NSInteger)(hasUnreadNotifications)];
    
    
    [self markAsReadForNotification: notification];
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
    
    SYNNotification *notification = self.notifications[indexPathForCellPressed.row];
    
    if (!notification)
        return;
    
    switch (notification.objectType)
    {
            
        
        case kNotificationObjectTypeUserAddedYourVideo:
        case kNotificationObjectTypeUserLikedYourVideo:
        {
            
            Channel *channel = [self channelFromChannelId: notification.channelId];
            
            if (!channel)
            {
                // the channel is no longer in the DB, might have been deleted after the notification has been issued
                
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Channel Unavailable", nil)
                                            message:NSLocalizedString(@"The Channel for which this notification has been issued might have been deleted", nil)
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                return;
            }
            
            channel.autoplayId = notification.videoId;
            
			[self viewChannelDetails: channel];
            
            break;
        }
            
        case kNotificationObjectTypeUserSubscibedToYourChannel:
        {
            Channel *channel = [self channelFromChannelId: notification.channelId];
            
            if (!channel)
            {
                return;
            }
            
			[self viewChannelDetails:channel];
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
            
         
        default:
            AssertOrLog(@"Unexpected notification type");
            break;
    }
    
    [self markAsReadForNotification: notification];
}


- (void) markAsReadForNotification: (SYNNotification *) notification
{
    
    NSArray *array;
    if(notification)
        array = @[@(notification.identifier)];
    else
        array = @[];
    
    [appDelegate.oAuthNetworkEngine markAsReadForNotificationIndexes:array
                                                          fromUserId:appDelegate.currentUser.uniqueId
                                                   completionHandler:^(id responce) {
        
                                                       
                                                       if(notification)
                                                       {
                                                           // Decrement the badge number (min zero)
                                                           UIApplication.sharedApplication.applicationIconBadgeNumber =
                                                           MAX((UIApplication.sharedApplication.applicationIconBadgeNumber - 1) , 0);
                                                        
                                                           notification.read = YES;
                                                           
                                                           hasUnreadNotifications = NO;
                                                           for (SYNNotification* n in self.notifications)
                                                               if(!n.read)
                                                                   hasUnreadNotifications = YES;
                                                       }
                                                       else
                                                       {
                                                           for (SYNNotification* n in self.notifications)
                                                               n.read = YES;
                                                           
                                                           UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
                                                           
                                                           hasUnreadNotifications = NO;
                                                           
                                                       }
                                                       
                                                       
        
                                                       [self.tableView reloadData];
        
        
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
    
    if(!channelId)
        return channel; // returns nil;

    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    
    channelFetchRequest.entity = [NSEntityDescription entityForName: kChannel
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
