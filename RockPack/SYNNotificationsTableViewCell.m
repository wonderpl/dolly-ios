//
//  SYNNotificationsTableViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNNotificationsTableViewCell.h"
#import "SYNActivityViewController.h"
#import "SYNNotification.h"
#import "UIFont+SYNFont.h"
#import <UIButton+WebCache.h>
#import <UIImageView+WebCache.h>

typedef NS_ENUM(NSInteger, SYNNotificationsTableViewCellThumbnailType) {
	SYNNotificationsTableViewCellThumbnailTypeNone,
	SYNNotificationsTableViewCellThumbnailTypeChannel,
	SYNNotificationsTableViewCellThumbnailTypeVideo
};

@interface SYNNotificationsTableViewCell ()

@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) IBOutlet UIButton *userThumbnailButton;
@property (nonatomic, strong) IBOutlet UIButton *videoThumbnailButton;

@end


@implementation SYNNotificationsTableViewCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	self.messageLabel.font = [UIFont lightCustomFontOfSize:self.messageLabel.font.pointSize];
	self.timeLabel.font = [UIFont lightCustomFontOfSize:self.timeLabel.font.pointSize];
	
	self.userThumbnailButton.contentMode = UIViewContentModeScaleAspectFill;
	self.videoThumbnailButton.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	[self.userThumbnailButton setImage:nil forState:UIControlStateNormal];
	[self.userThumbnailButton cancelCurrentImageLoad];
	
	[self.videoThumbnailButton setImage:nil forState:UIControlStateNormal];
	[self.videoThumbnailButton cancelCurrentImageLoad];
}

- (void)setNotification:(SYNNotification *)notification {
	_notification = notification;
	
	NSURL *userThumbnailURL = [NSURL URLWithString:notification.channelOwner.thumbnailLargeUrl];
	[self.userThumbnailButton setImageWithURL:userThumbnailURL
									 forState:UIControlStateNormal
							 placeholderImage:[UIImage imageNamed:@"PlaceholderNotificationAvatar"]
									  options:SDWebImageRetryFailed];
	
	NSString *messageString = [self messageFromNotification:notification];
	self.messageLabel.attributedText = [self attributedMessageString:messageString];
	
    self.timeLabel.text = notification.dateDifferenceString;
	
	NSURL *videoThumbnailURL = [NSURL URLWithString:notification.videoThumbnailUrl];
	[self.videoThumbnailButton setImageWithURL:videoThumbnailURL
									  forState:UIControlStateNormal
							  placeholderImage:[UIImage imageNamed:@"PlaceholderNotificationVideo"]
									   options:SDWebImageRetryFailed];
	
	UIColor *unreadColor = [UIColor colorWithWhite:249.0/255.0 alpha:1.0];
	UIColor *readColor = [UIColor whiteColor];
	self.backgroundColor = (notification.read ? readColor : unreadColor);
}

#pragma mark - Accesssors

- (void) setDelegate: (SYNActivityViewController *) delegate {
	if (_delegate) {
		// we can pass nil to remove observers
		[self.userThumbnailButton removeTarget: _delegate
									action: @selector(mainImageTableCellPressed:)
						  forControlEvents: UIControlEventTouchUpInside];
		
		[self.videoThumbnailButton removeTarget: _delegate
										 action: @selector(itemImageTableCellPressed:)
							   forControlEvents: UIControlEventTouchUpInside];
	}


	_delegate = delegate;

	if (!_delegate)
		return;

	[self.userThumbnailButton addTarget: _delegate
							 action: @selector(mainImageTableCellPressed:)
				   forControlEvents: UIControlEventTouchUpInside];

	[self.videoThumbnailButton addTarget: _delegate
								  action: @selector(itemImageTableCellPressed:)
						forControlEvents: UIControlEventTouchUpInside];
}

#pragma mark - Private

- (NSAttributedString *)attributedMessageString:(NSString *)messageString {
	
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	paragraphStyle.lineSpacing = 2.0;
	
	NSDictionary *attributes = @{ NSParagraphStyleAttributeName : paragraphStyle,
								  NSFontAttributeName : self.messageLabel.font };
	
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:messageString
																		   attributes:attributes];
	
	return attributedString;
}

- (NSString *)messageFromNotification:(SYNNotification *)notification {
	NSDictionary *stringMapping = @{ @(kNotificationObjectTypeFacebookFriendJoined) : @"notification_joined_action",
									 @(kNotificationObjectTypeUserSubscibedToYourChannel) : @"notification_subscribed_action",
									 @(kNotificationObjectTypeUserLikedYourVideo) : @"notification_liked_action",
									 @(kNotificationObjectTypeUserAddedYourVideo) : @"notification_repack_action",
									 @(kNotificationObjectTypeYourVideoNotAvailable) : @"notification_unavailable_action" };
	
	NSString *mappedKey = stringMapping[@(notification.objectType)];
	if (mappedKey) {
		NSString *displayName = [notification.channelOwner.displayName uppercaseString];
		return [NSString stringWithFormat:NSLocalizedString(mappedKey, nil), displayName];
	} else {
		return NSLocalizedString(notification.messageType, nil);
	}
}

@end
