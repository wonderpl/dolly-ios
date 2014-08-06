//
//  SYNVideoButtonBar.m
//  dolly
//
//  Created by Sherman Lo on 16/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoActionsBar.h"
#import "UIFont+SYNFont.h"
#import "SYNAvatarButton.h"
#import "ChannelOwner.h"
#import <UIButton+WebCache.h>

@interface SYNVideoActionsBar ()

@property (nonatomic, weak) IBOutlet UIButton *shopButton;
@property (nonatomic, weak) IBOutlet UIButton *favouriteButton;

@property (nonatomic, weak) IBOutlet UIView *favouritedByContainer;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic, copy) NSArray *favouritedByButtons;

@end

@implementation SYNVideoActionsBar

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.shopButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.shopButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.shopButton.titleLabel.font.pointSize];
    [self.shopButton setBackgroundImage:[UIImage imageNamed:@"ShopMotion0"] forState:UIControlStateNormal];
    [self.shopButton setBackgroundImage: [UIImage imageNamed:@"ShopMotionButtonActive"] forState:UIControlStateSelected];
	[self setDarkAssets];
}

+ (instancetype)bar {
	UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
	return [[nib instantiateWithOwner:self options:nil] firstObject];
}

- (void)setFavouritedBy:(NSArray *)favouritedBy {
	_favouritedBy = [favouritedBy copy];
	
	for (UIButton *button in self.favouritedByButtons) {
		[button removeFromSuperview];
	}
	
	CGFloat buttonSize = CGRectGetHeight(self.favouritedByContainer.bounds);
	
	NSMutableArray *buttons = [NSMutableArray array];
	[favouritedBy enumerateObjectsUsingBlock:^(ChannelOwner *channelOwner, NSUInteger idx, BOOL *stop) {
		CGRect frame = CGRectMake(idx * (buttonSize + 6.0), 0.0, buttonSize, buttonSize);
		NSURL *thumbnailURL = [NSURL URLWithString:channelOwner.thumbnailURL];
		
		SYNAvatarButton *button = [[SYNAvatarButton alloc] initWithFrame:frame];
		[button setImageWithURL:thumbnailURL
					   forState:UIControlStateNormal
			   placeholderImage:[UIImage imageNamed:@"PlaceholderAvatarProfile"]
						options:SDWebImageRetryFailed];
		button.userInteractionEnabled = NO;
		
		[buttons addObject:button];
		[self.favouritedByContainer addSubview:button];
	}];
	
	self.favouritedByButtons = buttons;
}

- (IBAction)favouriteButtonPressed:(UIButton *)button {
	[self.delegate videoActionsBar:self favouritesButtonPressed:button];
}

- (IBAction)annotationButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(videoActionsBar:annotationButtonPressed:)]) {
        [self.delegate videoActionsBar:self annotationButtonPressed:button];
    }
}

- (IBAction)addToChannelButtonPressed:(UIButton *)button {
	[self.delegate videoActionsBar:self addToChannelButtonPressed:button];
}

- (IBAction)shareButtonPressed:(UIButton *)button {
	[self.delegate videoActionsBar:self shareButtonPressed:button];
}


- (void) setLightAssets {
	[self.addButton setImage:[UIImage imageNamed:@"AddButtonLight.png"] forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage imageNamed:@"ShareButtonLight.png"] forState:UIControlStateNormal];
}

- (void) setDarkAssets {
	[self.addButton setImage:[UIImage imageNamed:@"AddButton.png"] forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage imageNamed:@"ShareButton.png"] forState:UIControlStateNormal];
}


@end
