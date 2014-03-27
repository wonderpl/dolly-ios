//
//  SYNProfileHeader.m
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileHeader.h"
#import "UIFont+SYNFont.h"
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"
#import "SYNSocialFollowButton.h"
@interface SYNProfileHeader ()

@property (nonatomic, strong) IBOutlet UIButton *avatarButton;

@property (nonatomic, strong) IBOutlet UIImageView *coverImage;
@property (nonatomic, strong) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UITextView *aboutMeTextView;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlsView;
@property (nonatomic, strong) IBOutlet UIButton *moreButton;
@property (nonatomic, strong) IBOutlet SYNSocialFollowButton *followAllButton;
@property (nonatomic, strong) IBOutlet UILabel *followersCountLabel;

@end


@implementation SYNProfileHeader

-(void) awakeFromNib {
    [super awakeFromNib];
    [self setUpViews];
}


- (void) setChannelOwner:(ChannelOwner *)channelOwner {
    _channelOwner = channelOwner;
    [self setLabelsFromChannelOwner:channelOwner];
    [self setProfileImage:channelOwner.thumbnailURL];
    [self setCoverphotoImage:channelOwner.coverPhotoURL];
}

- (void) setLabelsFromChannelOwner:(ChannelOwner*) channelOwner {
    self.userNameLabel.text = [NSString stringWithFormat:@"@%@", channelOwner.username];
    self.fullNameLabel.text = channelOwner.displayName;
    
    [self.segmentedController setTitle:[NSString stringWithFormat:@"%@ (%lld)", NSLocalizedString(@"Collections", nil), channelOwner.totalVideosValueChannelValue] forSegmentAtIndex:0];

    
    [self.segmentedController setTitle:[NSString stringWithFormat:@"%@ (%lld)", NSLocalizedString(@"Following", nil), channelOwner.subscriptionCountValue] forSegmentAtIndex:1];

    [self.segmentedController layoutIfNeeded];

    self.aboutMeTextView.text = channelOwner.channelOwnerDescription;
    [self.followAllButton setSelected:self.channelOwner.subscribedByUserValue];
    [self setUpViews];
    [self setFollowersCountLabel];
}


-(void) setProfileImage : (NSString*) thumbnailURL
{
    [self.avatarButton setImageWithURL: [NSURL URLWithString: self.channelOwner.thumbnailLargeUrl]
                              forState: UIControlStateNormal
                      placeholderImage: [UIImage imageNamed:@"PlaceholderAvatarProfile"]
                               options: SDWebImageRetryFailed];
    
    self.avatarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.avatarButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    
}

-(void) setCoverphotoImage: (NSString*) thumbnailURL
{
    
    NSString *thumbnailUrlString;
    if (IS_IPAD)
    {
        thumbnailUrlString = [thumbnailURL stringByReplacingOccurrencesOfString: @"thumbnail_medium"                                                                                               withString: @"ipad"];
    }
    else
    {
        thumbnailUrlString = [thumbnailURL stringByReplacingOccurrencesOfString: @"thumbnail_medium"                                                                                               withString: @"thumbnail_medium"];
    }
    
    __weak SYNProfileHeader *weakSelf = self;
    
    [self.coverImage setImageWithURL:[NSURL URLWithString: thumbnailUrlString]
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               if (image && cacheType == SDImageCacheTypeNone)
                               {
                                   weakSelf.coverImage.alpha = 0.0;
                                   [UIView animateWithDuration:1.0 animations:^{
                                       weakSelf.coverImage.alpha = 1.0;
                                   }];
                               }
                           }];
}

-(void) setDescriptionText : (NSString*) text {
    self.aboutMeTextView.text = text;
    [self setUpDescriptionTextView];

}

- (void) setUpDescriptionTextView {
    self.aboutMeTextView.font = [UIFont lightCustomFontOfSize:11];
	self.aboutMeTextView.textAlignment = NSTextAlignmentCenter;
	self.aboutMeTextView.textColor = [UIColor colorWithWhite:120/255.0 alpha:1.0];
    [[self.aboutMeTextView layer] setBorderColor:[[UIColor colorWithRed:172.0/255.0f green:172.0/255.0f blue:172.0/255.0f alpha:1.0f] CGColor]];

}


- (void) setUpViews {
    
    [self.userNameLabel setFont:[UIFont regularCustomFontOfSize:self.userNameLabel.font.pointSize]];
    self.userNameLabel.textColor = [UIColor colorWithWhite:120/255.0 alpha:1.0];
    self.fullNameLabel.font = [UIFont regularCustomFontOfSize:self.fullNameLabel.font.pointSize];

    [self setUpDescriptionTextView];
    
    if (!self.isUserProfile) {
        if (IS_IPAD) {
            [self.descriptionTopConstraint setConstant:202];
        }
    } else if (self.isUserProfile && IS_IPHONE) {
        [self.coverImageBottom setConstant:158];
    }
    
    if (IS_IPAD && self.isUserProfile) {
        [self.descriptionTopConstraint setConstant:189];
    }

    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont regularCustomFontOfSize:15], NSFontAttributeName,
                                [UIColor dollyTextMediumGray], NSForegroundColorAttributeName, nil];
    [self.segmentedController setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    self.segmentedController.layer.borderColor = [[UIColor grayColor] CGColor];
    
}

-(void) setFollowersCountLabel {
    NSString *tmpString;
    if (self.channelOwner.subscribersCountValue == 1) {
        tmpString = [[NSString alloc] initWithFormat:@"%lld %@", self.channelOwner.subscribersCountValue, NSLocalizedString(@"follower", "follower count in profile")];
    }
    else {
        tmpString = [[NSString alloc] initWithFormat:@"%lld %@", self.channelOwner.subscribersCountValue, NSLocalizedString(@"followers", "followers count in profile")];
    }
    
    [self.followersCountLabel setText:tmpString];
    [self.followersCountLabel setFont:[UIFont  regularCustomFontOfSize:self.followersCountLabel.font.pointSize]];
}

-(void) setIsUserProfile:(BOOL)isUserProfile {
    
    if (isUserProfile) {
        self.followAllButton.hidden = YES;
        self.avatarButton.userInteractionEnabled = YES;
        self.moreButton.hidden = NO;
        self.userNameLabel.hidden = YES;
    } else {
        self.followAllButton.hidden = NO;
        self.moreButton.hidden = YES;
        self.avatarButton.userInteractionEnabled = NO;
    }
    
    _isUserProfile = isUserProfile;
}


- (void) setDelegate: (id<SYNProfileDelegate>)  delegate
{
    _delegate = delegate;
}

- (IBAction)segmentedControllerTapped:(id)sender {
    
    if (self.segmentedController.selectedSegmentIndex == 0) {
        [self.delegate collectionsTabTapped];
    } else if (self.segmentedController.selectedSegmentIndex == 1) {
        [self.delegate followingsTabTapped];
    }
}

- (IBAction) avatarButtonTapped:(id)sender {
    [self.delegate editButtonTapped];
}

- (IBAction) moreButtonTapped:(id)sender {
    [self.delegate moreButtonTapped];
}

- (IBAction)followUserButtonTapped:(id)sender {
    [self.delegate followUserButtonTapped:sender];
}


@end
