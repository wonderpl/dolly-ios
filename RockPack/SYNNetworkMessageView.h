//
//  SYNNetworkErrorView.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

typedef enum NotificationMessageType : NSInteger {
    NotificationMessageTypeNetworkError = 0,
    NotificationMessageTypeSuccess = 1,
    NotificationMessageTypeError = 2
} NotificationMessageType;

@interface SYNNetworkMessageView : UIView
{
    NotificationMessageType _type;

}


-(void)setText:(NSString*)text;
-(void)setIconImage:(UIImage*)image;
-(void)setCenterVerticalOffset:(CGFloat)centerYOffset;


-(CGFloat)height;

- (id)initWithMessageType:(NotificationMessageType)type;

@end
