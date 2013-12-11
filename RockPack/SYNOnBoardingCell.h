//
//  SYNOnBoardingCell.h
//  dolly
//
//  Created by Michael Michailidis on 25/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNSocialActionsDelegate.h"
#import "SYNAvatarButton.h"
#import "SYNSocialButton.h"
#import "Recomendation.h"

@interface SYNOnBoardingCell : UICollectionViewCell
{
    CGPoint nameLabelOrigin;
    CGPoint subGenreLabelOrigin;
}

// avatar button is currently used as an image only but can change to accomodate press events
@property (nonatomic, strong) IBOutlet SYNAvatarButton* avatarButton;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UILabel* descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel* subGenreLabel;

@property (nonatomic, strong) IBOutlet UIView* bottomBorderView;

@property (nonatomic, strong) IBOutlet SYNSocialButton* followButton;


@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;
@property (nonatomic, weak) Recomendation* recomendation;

@end
