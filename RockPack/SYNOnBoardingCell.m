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
#import "ChannelOwner.h"

@implementation SYNOnBoardingCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.descriptionLabel.font = [UIFont regularCustomFontOfSize:self.descriptionLabel.font.pointSize];
    self.nameLabel.font = [UIFont regularCustomFontOfSize:self.nameLabel.font.pointSize];
    
    // store the values as read from the XIB file
    nameLabelOrigin = self.nameLabel.frame.origin;
}

-(void)prepareForReuse
{
    // labels could have been moved due to description text missing;
    CGRect rect = self.nameLabel.frame;
    rect.origin = nameLabelOrigin;
    self.nameLabel.frame = rect;
    self.descriptionLabel.hidden = NO;
    self.followButton.selected = NO;
    self.followButton.userInteractionEnabled = YES;
    self.bottomBorderView.hidden = NO;

}

- (void) setRecommendation:(Recommendation *)recommendation
{
    
    if(!recommendation)
        return;
    
    _recommendation = recommendation;
	
    self.nameLabel.text = recommendation.displayName;
    
    recommendation.descriptionText = recommendation.descriptionText;
	
    self.descriptionLabel.attributedText = [self attributedDescriptionStringFrom: recommendation.descriptionText];
    
    if ([self.descriptionLabel.text isEqualToString:@""]) {
        self.descriptionLabel.text = @"";
    }
    
    [self.avatarButton setImageWithURL: [NSURL URLWithString: recommendation.avatarUrl]
                              forState: UIControlStateNormal
                      placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarFriends"]
                               options: SDWebImageRetryFailed];
    
    self.channelOwner = recommendation.channelOwner;
}

- (void) setDelegate:(id<SYNSocialActionsDelegate>)delegate
{
    _delegate = delegate;
    

}
- (IBAction)followButtonTapped:(id)sender {
	[self.delegate followControlPressed:self.followButton withChannelOwner:self.channelOwner completion:nil];
}

-(NSMutableAttributedString*) attributedDescriptionStringFrom:(NSString *) string {
	
	if (!string) {
		return [[NSMutableAttributedString alloc] initWithString: @""];
	}
	NSMutableAttributedString *channelDescription = [[NSMutableAttributedString alloc] initWithString: string];
	
    
    UITextAlignment alignment = IS_IPHONE ? NSTextAlignmentLeft : NSTextAlignmentCenter;
	NSInteger strLength = [channelDescription length];
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.lineBreakMode = NSLineBreakByWordWrapping;
	[style setLineSpacing:1];
	[style setAlignment:alignment];
	
	[channelDescription addAttribute:NSParagraphStyleAttributeName
							   value:style
							   range:NSMakeRange(0, strLength)];
	return channelDescription;
}



@end
