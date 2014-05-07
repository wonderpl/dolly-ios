//
//  SYNOnBoardingCell.m
//  dolly
//
//  Created by Michael Michailidis on 25/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingCell.h"
#import "UIButton+WebCache.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNGenreManager.h"
#import "Recommendation.h"

@implementation SYNOnBoardingCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    
    self.descriptionLabel.font = [UIFont regularCustomFontOfSize:self.descriptionLabel.font.pointSize];
    self.subGenreLabel.font = [UIFont regularCustomFontOfSize:self.subGenreLabel.font.pointSize];
    self.nameLabel.font = [UIFont regularCustomFontOfSize:self.nameLabel.font.pointSize];
    
    // store the values as read from the XIB file
    nameLabelOrigin = self.nameLabel.frame.origin;
    subGenreLabelOrigin = self.subGenreLabel.frame.origin;
    
    // only iPhone cells have the separator at the bottom
    if(IS_IPHONE)
    {
        CGRect bottomBorderFrame = self.bottomBorderView.frame;
        bottomBorderFrame.size.height = IS_RETINA ? 0.5f : 1.0f;
        self.bottomBorderView.frame = bottomBorderFrame;
    }
    
    
}

-(void)prepareForReuse
{
    // labels could have been moved due to description text missing;
    CGRect rect = self.nameLabel.frame;
    rect.origin = nameLabelOrigin;
    self.nameLabel.frame = rect;
    
    rect = self.subGenreLabel.frame;
    rect.origin = subGenreLabelOrigin;
    self.subGenreLabel.frame = rect;
    [self.subGenreLabel setBackgroundColor:[UIColor clearColor]];
    
    self.descriptionLabel.hidden = NO;
    self.followButton.selected = NO;
    self.followButton.userInteractionEnabled = YES;

}

- (void) setRecommendation:(Recommendation *)recommendation
{
    
    if(!recommendation)
        return;
    
    _recommendation = recommendation;
	
    self.nameLabel.text = recommendation.displayName;
    
    recommendation.descriptionText = recommendation.descriptionText;
	
    if (IS_IPAD) {
		SYNGenreManager *genreManager = [SYNGenreManager sharedManager];
		self.subGenreLabel.backgroundColor = [genreManager colorForGenreWithId:recommendation.categoryId];
    }
    
    self.descriptionLabel.text = recommendation.descriptionText;
    
    if ([self.descriptionLabel.text isEqualToString:@""]) {
        self.descriptionLabel.text = @"";
    }
    
    [self.avatarButton setImageWithURL: [NSURL URLWithString: recommendation.avatarUrl]
                              forState: UIControlStateNormal
                      placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarFriends"]
                               options: SDWebImageRetryFailed];
}

- (void) setDelegate:(id<SYNSocialActionsDelegate>)delegate
{
    _delegate = delegate;
    

}
- (IBAction)followButtonTapped:(id)sender {
	
	[self.delegate followControlPressed:self.followButton withChannelOwner:self.recommendation.channelOwner completion:nil];

}

@end
