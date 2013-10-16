//
//  SYNAggregateVideoCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNAggregateVideoCell.h"
#import "SYNAppDelegate.h"
#import "SYNTouchGestureRecognizer.h"
#import "UIColor+SYNColor.h"
#import "UIImage+Tint.h"

@interface SYNAggregateVideoCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *lowlightImageView;
@property (nonatomic, strong) IBOutlet UILabel *likeLabel;
@property (nonatomic, strong) SYNTouchGestureRecognizer *touch;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end


@implementation SYNAggregateVideoCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.mainTitleLabel.font = [UIFont boldRockpackFontOfSize: self.mainTitleLabel.font.pointSize];
    self.likeLabel.font = [UIFont rockpackFontOfSize: self.likeLabel.font.pointSize];
    
    if (!IS_IPAD)
    {
        self.likesNumberLabel.hidden = YES;
    }
    else
    {
        self.likesNumberLabel.font = [UIFont boldRockpackFontOfSize: self.likesNumberLabel.font.pointSize];
    }
    
    // Tap for showing video
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showVideo:)];
    self.tap.delegate = self;
    [self.lowlightImageView addGestureRecognizer: self.tap];
    
    // Touch for highlighting cells when the user touches them (like UIButton)
    self.touch = [[SYNTouchGestureRecognizer alloc] initWithTarget: self
                                                            action: @selector(showGlossLowlight:)];
    
    self.touch.delegate = self;
    [self.lowlightImageView addGestureRecognizer: self.touch];
}


- (void) setCoverImagesAndTitlesWithArray: (NSArray *) array
{
    if (!self.videoImageView)
    {
        CGRect videoImageFrame = CGRectZero;
        videoImageFrame.size = self.imageContainer.frame.size;
        self.videoImageView = [[UIImageView alloc] initWithFrame: videoImageFrame];
        [self.imageContainer addSubview: self.videoImageView];
    }
    
    NSDictionary *coverInfo = (NSDictionary *) array[0];
    
    [self.videoImageView setImageWithURL: [NSURL URLWithString: coverInfo[@"image"]]
                        placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                 options: SDWebImageRetryFailed];
}


- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    [super setViewControllerDelegate: (id < SYNAggregateCellDelegate >)viewControllerDelegate];

    [self.heartButton addTarget: self.viewControllerDelegate
                         action: @selector(likeButtonPressed:)
               forControlEvents: UIControlEventTouchUpInside];
}


- (void) setTitleMessageWithDictionary: (NSDictionary *) messageDictionary
{
    NSString *channelOwnerName = messageDictionary[@"display_name"] ? messageDictionary[@"display_name"] : @"User";
    
    NSNumber *itemCountNumber = messageDictionary[@"item_count"] ? messageDictionary[@"item_count"] : @1;
    NSString *actionString = [NSString stringWithFormat: @"%i video%@", itemCountNumber.integerValue, itemCountNumber.integerValue > 1 ? @"s": @""];
    
    NSString *channelNameString = messageDictionary[@"channel_name"] ? messageDictionary[@"channel_name"] : @"his channel";
    
    // create the attributed string //
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: channelOwnerName
                                                                                      attributes: self.boldTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @" added "
                                                                                      attributes: self.lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: actionString
                                                                                      attributes: self.lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @" to "
                                                                                      attributes: self.lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: channelNameString
                                                                                      attributes: self.boldTextAttributes]];
    
    self.messageLabel.attributedText = attributedCompleteString;
    self.messageLabel.center = CGPointMake(self.messageLabel.center.x, self.userThumbnailImageView.center.y + 2.0f);
    self.messageLabel.frame = CGRectIntegral(self.messageLabel.frame);
}


- (void) setSupplementaryMessageWithDictionary: (NSDictionary *) messageDictionary
{
    NSNumber *likesNumber = messageDictionary[@"star_count"] ? messageDictionary[@"star_count"] : @(0);
    NSString *likesString = [NSString stringWithFormat: @"%i likes", likesNumber.integerValue];
    
    NSAttributedString *likesAttributedString = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"%@ ", likesString]
                                                                                attributes: self.boldTextAttributes];
    
    if (likesNumber.integerValue == 0)
    {
        if (IS_IPAD)
        {
            self.likesNumberLabel.text = @"0";
            self.likeLabel.hidden = YES;
        }
        else
        {
            self.likeLabel.attributedText = likesAttributedString;
        }
        
        return;
    }
    
    SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    NSArray *users = messageDictionary[@"starrers"] ? messageDictionary[@"starrers"] : @[];
    
    // initial setup
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    if (!IS_IPAD && users.count > 3)
    {
        [attributedCompleteString appendAttributedString: likesAttributedString];
    }
    else
    {
        self.likesNumberLabel.text = [NSString stringWithFormat: @"%i", likesNumber.integerValue];
    }
    
    if (users.count > 1 && users.count < 4 && IS_IPAD)
    {
        [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @"including "
                                                                                          attributes: self.lightTextAttributes]];
    }
    
    self.heartButton.selected = NO;
    
    if (users.count > 0)
    {
        ChannelOwner *co;
        NSString *name;
        
        for (int i = 0; i < users.count; i++)
        {
            co = (ChannelOwner *) users[i];
            
            if (!co)
            {
                continue;
            }
            
            if ([co.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
            {
                name = @"You";
                self.heartButton.selected = YES;
            }
            else
            {
                name = co.displayName;
            }
            
            [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: name
                                                                                              attributes: self.boldTextAttributes]];
            
            if ((users.count - i) == 2) // the one before last
            {
                [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @" & "
                                                                                                  attributes: self.boldTextAttributes]];
            }
            else if ((users.count - i) > 2)
            {
                [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @", "
                                                                                                  attributes: self.boldTextAttributes]];
            }
        }
    }
    
    self.likeLabel.attributedText = attributedCompleteString;
}


- (void) prepareForReuse
{
    [super prepareForReuse];
    
    self.likeLabel.hidden = NO;
    self.heartButton.selected = NO;
}


#pragma mark - Gesture recognizers for arc menu and show video

// This is used to lowlight the gloss image on touch
- (void) showGlossLowlight: (SYNTouchGestureRecognizer *) recognizer
{
    UIImage *glossImage = [UIImage imageNamed: @"GlossFeedVideo"];
    
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan :
        {
            // Set lowlight tint
            UIImage *lowlightImage = [glossImage tintedImageUsingColor: [UIColor colorWithWhite: 0.0
                                                                                          alpha: 0.3]];
            self.lowlightImageView.image = lowlightImage;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.lowlightImageView.image = glossImage;
        }
            
        default:
            break;
    }
}


- (void) showVideo: (UITapGestureRecognizer *) recognizer
{
    [self.viewControllerDelegate touchedAggregateCell];
}


@end
