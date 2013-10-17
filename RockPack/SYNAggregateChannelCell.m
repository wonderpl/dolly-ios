//
//  SYNAggregateChannelCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAggregateChannelCell.h"
#import "SYNTouchGestureRecognizer.h"
#import "UIImage+Tint.h"

@interface SYNAggregateChannelCell () <UIGestureRecognizerDelegate>

@property (nonatomic) CGRect originalImageContainerRect;
@property (nonatomic, strong) IBOutlet UIImageView *lowlightImageView;
@property (nonatomic, strong) SYNTouchGestureRecognizer *touch;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIView *buttonContainerView;
@property (nonatomic, strong) UIView *labelsContainerView;

@end


@implementation SYNAggregateChannelCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    // Tap for showing video
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showChannel:)];
    self.tap.delegate = self;
    [self.lowlightImageView addGestureRecognizer: self.tap];
    
    // Touch for highlighting cells when the user touches them (like UIButton)
    self.touch = [[SYNTouchGestureRecognizer alloc] initWithTarget: self
                                                            action: @selector(showGlossLowlight:)];
    
    self.touch.delegate = self;
    [self.lowlightImageView addGestureRecognizer: self.touch];
}


- (void) prepareForReuse
{
    [super prepareForReuse];
    
    if (self.buttonContainerView)
    {
        [self.buttonContainerView removeFromSuperview];
        self.buttonContainerView = nil;
    }
    
    if (self.labelsContainerView)
    {
        [self.labelsContainerView removeFromSuperview];
        self.labelsContainerView = nil;
    }
    
    self.imageContainer.frame = self.originalImageContainerRect;
    self.lowlightImageView.hidden = NO;
    self.mainTitleLabel.hidden = NO;
}


- (void) setCoverImagesAndTitlesWithArray: (NSArray *) array
{
    if (!array)
    {
        return;
    }
    
    self.originalImageContainerRect = self.imageContainer.frame;
    
    // Remove all out images
    for (UIImageView *imageView in self.imageContainer.subviews) // there should only be UIImageView instances
    {
        [imageView removeFromSuperview];
    }
    
    // Remove all our image buttons
    for (UIImageView *imageView in self.buttonContainerView.subviews) // there should only be UIImageView instances
    {
        [imageView removeFromSuperview];
    }
    
    CGRect containerRect = CGRectZero;
    
    NSInteger count = array.count;
    UIImageView *imageView;
    
    UIImageView *simultatedButton;
    UILabel *label;
    NSString *channelTitle;
    CGSize expectedLabelSize;
    
    if (count == 1)
    {
        containerRect.size = self.imageContainer.frame.size;
        
        self.lowlightImageView.hidden = NO;
        self.mainTitleLabel.hidden = NO;
        
        imageView = [[UIImageView alloc] initWithFrame: containerRect];
        
        [imageView setImageWithURL: [NSURL URLWithString: ((NSString *) array[0][@"image"])]
                  placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                           options: SDWebImageRetryFailed];
        
        [self.imageContainer addSubview: imageView];
        
        self.mainTitleLabel.text = (NSString *) array[0][@"title"];
        
        return;
    }
    
    if (count == 2 || count == 3)
    {
        CGRect shrinkingSelfFrame = self.frame;
        shrinkingSelfFrame.size.height = IS_IPAD ? 149.0f : 182.0f;
        
        self.frame = shrinkingSelfFrame;
        
        CGRect smallerCellFrame = self.imageContainer.frame; // the 2 - 3 options have a smaller total frame
        smallerCellFrame.size.height = IS_IPAD ? shrinkingSelfFrame.size.height : 155.0f;
        
        if (IS_IPHONE)
        {
            smallerCellFrame.origin.y = 54.0f;
        }
        
        self.imageContainer.frame = smallerCellFrame;
        
        containerRect.size = self.imageContainer.frame.size;
        // container.origin = CGPointZero from above -> {{0, 0}, {310, 310}}
        
        self.buttonContainerView = [[UIView alloc] initWithFrame: self.imageContainer.frame];
        
        [self insertSubview: self.buttonContainerView
               belowSubview: self.lowlightImageView];
        
        self.labelsContainerView = [[UIView alloc] initWithFrame: self.imageContainer.frame];
        self.labelsContainerView.userInteractionEnabled = NO;
        self.labelsContainerView.backgroundColor = [UIColor clearColor];
        
        [self insertSubview: self.labelsContainerView
               aboveSubview: self.buttonContainerView];
        
        containerRect.size.width = containerRect.size.width / 2.0;
        
        self.lowlightImageView.hidden = YES;
        self.mainTitleLabel.hidden = YES;
        
        for (int i = 0; i < 2; i++)
        {
            NSDictionary *coverInfo = (NSDictionary *) array[i];
            imageView = [[UIImageView alloc] initWithFrame: containerRect];
            
            if (coverInfo[@"image"])
            {
                [imageView setImageWithURL: [NSURL URLWithString: coverInfo[@"image"]]
                          placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                   options: SDWebImageRetryFailed];
            }
            else
            {
                imageView.image = [UIImage imageNamed: @"PlaceholderChannelSmall.png"];
            }
            
            [self.imageContainer addSubview: imageView];
            
            simultatedButton = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"channelFeedCoverFourth"]];
            simultatedButton.backgroundColor = [UIColor clearColor];
            simultatedButton.frame = CGRectMake(containerRect.origin.x, 0.0f, containerRect.size.width, containerRect.size.height);
            simultatedButton.userInteractionEnabled = TRUE;
            
            [self.buttonContainerView addSubview: simultatedButton];
            
            label = [[UILabel alloc] initWithFrame: CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldRockpackFontOfSize: 14.0f];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.textColor = [UIColor whiteColor];
            channelTitle = coverInfo[@"title"];
            
            NSAttributedString *attributedText =  [[NSAttributedString alloc] initWithString: channelTitle
                                                                                  attributes: @{NSFontAttributeName: label.font}];
            
            CGRect rect = [attributedText boundingRectWithSize: (CGSize){containerRect.size.width, CGFLOAT_MAX}
                                                       options: NSStringDrawingUsesLineFragmentOrigin
                                                       context: nil];
            
            CGFloat height = ceilf(rect.size.height);
            CGFloat width  = ceilf(rect.size.width);
            
            expectedLabelSize = (CGSize){width, height};
            
            label.frame = CGRectMake(containerRect.origin.x + 6.0,
                                     (containerRect.size.height) - (expectedLabelSize.height) - (IS_IPHONE ? 28.0f : 0.0f),
                                     expectedLabelSize.width,
                                     expectedLabelSize.height);
            
            label.text = channelTitle;
            
            [self.labelsContainerView addSubview: label];
            
            containerRect.origin.x += containerRect.size.width;
        }
        
        return;
    }
    
    if (count == 4)
    {
        self.lowlightImageView.hidden = YES;
        self.mainTitleLabel.hidden = YES;
        
        containerRect.size = self.imageContainer.frame.size; // {{0, 0}, {298, 298}} (IPAD),
                                                             // container.origin = CGPointZero from above -> {{0, 0}, {310, 310}}
        
        self.buttonContainerView = [[UIView alloc] initWithFrame: self.imageContainer.frame];
        
        [self insertSubview: self.buttonContainerView
               belowSubview: self.lowlightImageView];
        
        self.labelsContainerView = [[UIView alloc] initWithFrame: self.imageContainer.frame];
        self.labelsContainerView.userInteractionEnabled = NO;
        self.labelsContainerView.backgroundColor = [UIColor clearColor];
        
        [self insertSubview: self.labelsContainerView
               aboveSubview: self.buttonContainerView];
        
        containerRect.size.width = containerRect.size.width / 2.0;
        containerRect.size.height = containerRect.size.height / 2.0;
        
        NSInteger idx = 0;
        
        for (NSDictionary *coverInfo in array)
        {
            imageView = [[UIImageView alloc] initWithFrame: containerRect];
            
            if (coverInfo[@"image"])
            {
                [imageView setImageWithURL: [NSURL URLWithString: coverInfo[@"image"]]
                          placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                   options: SDWebImageRetryFailed];
            }
            else
            {
                imageView.image = [UIImage imageNamed: @"PlaceholderChannelSmall.png"];
            }
            
            [self.imageContainer addSubview: imageView];
            
            simultatedButton = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"channelFeedCoverFourth"]];
            simultatedButton.backgroundColor = [UIColor clearColor];
            simultatedButton.frame = containerRect;
            simultatedButton.userInteractionEnabled = TRUE;
            
            [self.buttonContainerView addSubview: simultatedButton];
            
            label = [[UILabel alloc] initWithFrame: CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldRockpackFontOfSize: 14.0f];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.textColor = [UIColor whiteColor];
            channelTitle = coverInfo[@"title"];
            
            NSAttributedString *attributedText =  [[NSAttributedString alloc] initWithString: channelTitle
                                                                                  attributes: @{NSFontAttributeName: label.font}];
            
            CGRect rect = [attributedText boundingRectWithSize: (CGSize){containerRect.size.width, CGFLOAT_MAX}
                                                       options: NSStringDrawingUsesLineFragmentOrigin
                                                       context: nil];
            
            CGFloat height = ceilf(rect.size.height);
            CGFloat width  = ceilf(rect.size.width);
            
            CGSize expectedLabelSize = (CGSize){width, height};
            
            label.frame = CGRectMake(containerRect.origin.x + 6.0, (containerRect.origin.y + containerRect.size.height) - (expectedLabelSize.height), expectedLabelSize.width, expectedLabelSize.height);
            label.text = channelTitle;
            
            [self.labelsContainerView addSubview: label];
            // set rect
            
            containerRect.origin.x += containerRect.size.width;
            
            if (++idx == 2)
            {
                containerRect.origin.x = 0.0f;
                containerRect.origin.y += containerRect.size.height;
            }
        }
        
        return;
    }
}


- (void) setViewControllerDelegate: (id<SYNAggregateCellDelegate>) viewControllerDelegate
{
    [super setViewControllerDelegate: viewControllerDelegate];
    
    if (self.buttonContainerView)
    {
        for (UIImageView *simulatedButtonView in self.buttonContainerView.subviews)
        {
            // Tap for showing video
            UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                        action: @selector(showChannel:)];
            buttonTap.delegate = self;
            [simulatedButtonView addGestureRecognizer: buttonTap];
            
            // Touch for highlighting cells when the user touches them (like UIButton)
            SYNTouchGestureRecognizer *buttonTouch = [[SYNTouchGestureRecognizer alloc] initWithTarget: self
                                                                                                action: @selector(showGlossLowlight:)];
            
            buttonTouch.delegate = self;
            [simulatedButtonView addGestureRecognizer: buttonTouch];
        }
    }
    
    [self.userThumbnailButton addTarget: self.viewControllerDelegate
                                 action: @selector(profileButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
}


- (void) setTitleMessageWithDictionary: (NSDictionary *) messageDictionary
{
    NSString *channelOwnerName = messageDictionary[@"display_name"] ? messageDictionary[@"display_name"] : @"User";
    
    NSNumber *itemCountNumber = messageDictionary[@"item_count"] ? messageDictionary[@"item_count"] : @1;
    NSString *actionString = [NSString stringWithFormat: @"%i pack%@", itemCountNumber.integerValue, itemCountNumber.integerValue > 1 ? @"s": @""];
    
    // craete the attributed string //
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: channelOwnerName
                                                                                      attributes: self.boldTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @" created "
                                                                                      attributes: self.lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: actionString
                                                                                      attributes: self.lightTextAttributes]];
    
    self.messageLabel.attributedText = attributedCompleteString;
}


#pragma mark - Gesture recognizers for arc menu and show video

// This is used to lowlight the gloss image on touch
- (void) showGlossLowlight: (SYNTouchGestureRecognizer *) recognizer
{
    UIImageView *simulatedButton = self.lowlightImageView;
    UIImage *glossImage = [UIImage imageNamed: @"channelFeedCover"];
    
    // Special-case container views
    if (self.buttonContainerView)
    {
        simulatedButton = (UIImageView *) recognizer.view;
        glossImage = [UIImage imageNamed: @"channelFeedCoverFourth"];
    }
    
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan :
        {
            // Set lowlight tint
            UIImage *lowlightImage = [glossImage tintedImageUsingColor: [UIColor colorWithWhite: 0.0
                                                                                          alpha: 0.3]];
            
            simulatedButton.image = lowlightImage;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            simulatedButton.image = glossImage;
        }
            
        default:
            break;
    }
}


- (void) showChannel: (UITapGestureRecognizer *) recognizer
{
    [self.viewControllerDelegate touchedAggregateCell];
}


@end
