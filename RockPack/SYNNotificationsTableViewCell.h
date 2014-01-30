//
//  SYNNotificationsTableViewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@class SYNActivityViewController;
@class SYNNotification;

@interface SYNNotificationsTableViewCell : UITableViewCell

@property (nonatomic, weak) SYNActivityViewController *delegate;

@property (nonatomic, strong) SYNNotification *notification;

@end
