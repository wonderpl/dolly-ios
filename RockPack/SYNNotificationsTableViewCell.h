//
//  SYNNotificationsTableViewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNActivityViewController;

@interface SYNNotificationsTableViewCell : UITableViewCell

@property (nonatomic) BOOL read;
@property (nonatomic, strong) UIImageView *playSymbolImageView;
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, weak) NSString *messageTitle;
@property (nonatomic, weak) SYNActivityViewController *delegate;

@end
