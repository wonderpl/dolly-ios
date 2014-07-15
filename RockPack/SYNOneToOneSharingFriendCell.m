//
//  SYNOneToOneSharingFriendCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOneToOneSharingFriendCell.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>
#import <UIButton+WebCache.h>


@interface SYNOneToOneSharingFriendCell ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *avatarButton;
@property (strong, nonatomic) Friend *friend;

@end

@implementation SYNOneToOneSharingFriendCell

-(void)awakeFromNib
{
    
    self.nameLabel.font = [UIFont lightCustomFontOfSize:self.nameLabel.font.pointSize];
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width * 0.5;
    
}


- (void)setDisplayName:(NSString*)displayName {
    if (!displayName) {
        self.nameLabel.text = @"";
        return;
    }
    
    CGRect currentNameLabelFrame = self.nameLabel.frame;
    
    self.nameLabel.text = displayName;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:displayName
                                                                         attributes:@{NSFontAttributeName: self.nameLabel.font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.frame.size.width, 26.0f}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    
    currentNameLabelFrame.origin.y = 56.0f;
    currentNameLabelFrame.size.height = rect.size.height;
    
    self.nameLabel.frame = currentNameLabelFrame;

}

- (void)setFriend:(Friend *)friendItem {
    
    _friend = friendItem;

    
    if ([friendItem.thumbnailURL rangeOfString: @"localhost"].location == NSNotFound) // is not a fake URL
    {
        [self.avatarButton setImageWithURL:[NSURL URLWithString: friendItem.thumbnailURL]
                                           forState:UIControlStateNormal
                                   placeholderImage:[UIImage imageNamed:@"PlaceholderAvatarChannel"]
                                            options:SDWebImageRetryFailed];
    
    } else {
        [self setAvatarImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]];
    }
    
    if ([friendItem.displayName length] > 0) {
        [self setDisplayName: friendItem.displayName];
    } else {
        [self setDisplayName: friendItem.email];
    }

}

- (void)setAvatarImage:(UIImage *)avatarImage {
    [self.avatarButton setImage:avatarImage forState:UIControlStateNormal];
}

- (void)setAvatarAlpha:(double)alpha {
	self.avatarButton.alpha = alpha;
}
- (IBAction)avatarButtonTapped:(id)sender {
        [self.delegate cell:self tappedWithFriend:self.friend];
}

@end
