//
//  SYNNotificationsTableViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNNotificationsTableViewCell.h"
#import "SYNActivityViewController.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNNotificationsTableViewCell ()

@property (nonatomic, assign) CGRect imageViewRect;
@property (nonatomic, assign) CGSize mainTextSize;
@property (nonatomic, assign) UIButton *secondaryImageButton;
@property (nonatomic, strong) UIButton *mainImageButton;
@property (nonatomic, strong) UIView *dividerImageView;
@property (nonatomic, strong) CALayer *dividerLayerMask;

@end


@implementation SYNNotificationsTableViewCell

- (id) initWithStyle: (UITableViewCellStyle) style reuseIdentifier: (NSString *) reuseIdentifier
{
    self = [super initWithStyle: UITableViewCellStyleSubtitle
                reuseIdentifier: reuseIdentifier];
    
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // == frames == //
        CGFloat imageViewWidth = 48.0f;
        self.imageViewRect = CGRectMake((IS_IPAD ? 76.0 : 14.0f), (IS_IPAD ? 22.0f : 14.0f), imageViewWidth, imageViewWidth);
        
        
        self.imageView.layer.cornerRadius = imageViewWidth / 2.0f;
        self.imageView.clipsToBounds = YES;
    
        
        // == Profile Image View == //
        self.imageView.frame = self.imageViewRect;
        
        // == Main Text == //
        
        self.textLabel.font = [UIFont lightCustomFontOfSize: IS_IPAD ? 14.0f : 12.0f];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.numberOfLines = 3;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.textLabel.textColor = [UIColor colorWithRed: (40.0 / 255.0)
                                                   green: (45.0 / 255.0)
                                                    blue: (51.0 / 255.0)
                                                   alpha: (1.0)];
        
        // == Subtitle == //
        self.detailTextLabel.font = [UIFont lightCustomFontOfSize: IS_IPAD ? 12.0f : 11.0f];
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        
        self.detailTextLabel.textColor = [UIColor colorWithRed: (187.0 / 255.0)
                                                         green: (187.0 / 255.0)
                                                          blue: (187.0 / 255.0)
                                                         alpha: (1.0)];
        
        // == Channel image view == //
       
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame: CGRectMake(self.frame.size.width, // x will be set in layoutSubviews
                                                                                 20.0,
                                                                                 IS_IPAD ? 92.0f : 60.0f,
                                                                                 IS_IPAD ? 52.0f : 34.0f)];
        self.thumbnailImageView.backgroundColor = [UIColor greenColor];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnailImageView.clipsToBounds = YES;
        [self addSubview: self.thumbnailImageView];
        
        
        
        // == Divider Image View == //
        self.dividerImageView = [[UIView alloc] initWithFrame: CGRectMake(30, 0.0, 256, IS_RETINA ? 0.5 : 1.0f)];
        self.dividerImageView.backgroundColor = [UIColor colorWithRed:(172.0f/255.0f)
                                                                green:(172.0f/255.0f)
                                                                 blue:(172.0f/255.0f)
                                                                alpha:1.0f];
        
        self.dividerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.dividerImageView.layer.mask = self.dividerLayerMask;

        [self addSubview: self.dividerImageView];
        
        // == Buttons == //
        self.mainImageButton = [UIButton buttonWithType: UIButtonTypeCustom];
        
        [self addSubview: self.mainImageButton];
        
        self.secondaryImageButton = [UIButton buttonWithType: UIButtonTypeCustom];
        
        [self addSubview: self.secondaryImageButton];
        
        
    }
    
    return self;
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    // Avatar Image View (Left) //
    
    self.imageView.frame = self.mainImageButton.frame = self.imageViewRect;
    
    
    self.textLabel.frame = CGRectMake((IS_IPAD ? 154.0f : 90.0f),
                                      (IS_IPAD ? 22.0f : 14.0f),
                                      self.mainTextSize.width,
                                      self.mainTextSize.height);
    
    
    // Thumbnail Image View (Right)
    
    CGRect thumbFrame = self.thumbnailImageView.frame;
    thumbFrame.origin.x = self.frame.size.width - thumbFrame.size.width - (IS_IPAD ? 68.0f : 14.0f);
    self.thumbnailImageView.frame = thumbFrame;
    
    
    // Details
    
    CGRect detailsFrame = CGRectMake((IS_IPAD ? 154.0f : 90.0f), 12.0, self.mainTextSize.width, 20.0f);
    detailsFrame.origin.y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height - (self.mainTextSize.height > 40.0 ? 4.0 : 0.0);
    self.detailTextLabel.frame = detailsFrame;
    
    
    if (self.read)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.backgroundColor = [UIColor colorWithRed: (226.0 / 255.0)
                                               green: (231.0 / 255.0)
                                                blue: (231.0 / 255.0)
                                               alpha: (1.0)];
    }
    
    // buttons
    
    self.mainImageButton.frame = self.imageViewRect;
    self.secondaryImageButton.frame = self.thumbnailImageView.frame;
    
}


#pragma mark - Accesssors

- (void) setDelegate: (SYNActivityViewController *) delegate
{
    if (_delegate)
    {
        // we can pass nil to remove observers
        [self.mainImageButton removeTarget: _delegate
                                    action: @selector(mainImageTableCellPressed:)
                          forControlEvents: UIControlEventTouchUpInside];
        
        [self.secondaryImageButton removeTarget: _delegate
                                         action: @selector(itemImageTableCellPressed:)
                               forControlEvents: UIControlEventTouchUpInside];
    }
    
    
    _delegate = delegate;
    
    if (!_delegate)
        return;
    
    [self.mainImageButton addTarget: _delegate
                             action: @selector(mainImageTableCellPressed:)
                   forControlEvents: UIControlEventTouchUpInside];
    
    [self.secondaryImageButton addTarget: _delegate
                                  action: @selector(itemImageTableCellPressed:)
                        forControlEvents: UIControlEventTouchUpInside];
}


- (void) setMessageTitle: (NSString *) messageTitle
{
    
    // == main text label == //
    
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragrahStyle setLineSpacing: 2];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: messageTitle];
    
    [attributedString addAttribute: NSParagraphStyleAttributeName
                             value: paragrahStyle
                             range: NSMakeRange(0, [messageTitle length])];
    
    
    CGRect textLabelFrame = self.textLabel.frame;
    CGFloat maxWidth = IS_IPAD ? 220.0 : 140.0;
    
    NSAttributedString *attributedText =  [[NSAttributedString alloc] initWithString: messageTitle
                                                                          attributes: @{NSFontAttributeName: self.textLabel.font}];
    
    CGRect rect = [attributedText boundingRectWithSize: (CGSize){maxWidth, CGFLOAT_MAX}
                                               options: NSStringDrawingUsesLineFragmentOrigin
                                               context: nil];
    
    
    CGSize mainTSize = CGRectIntegral(rect).size;
    
    mainTSize.height += 6.0f;
    self.mainTextSize = mainTSize;
    
    
    textLabelFrame.size = self.mainTextSize;
    
    self.textLabel.attributedText = attributedString;
    self.textLabel.frame = textLabelFrame;
    
}


- (NSString *) messageTitle
{
    return self.textLabel.text;
}

- (CALayer *)dividerLayerMask {
    
    
	if (!_dividerLayerMask) {
		CAGradientLayer *mask = [CAGradientLayer layer];
		mask.colors = @[ (id) [[UIColor clearColor] CGColor],
						 (id) [[UIColor whiteColor] CGColor],
						 (id) [[UIColor clearColor] CGColor] ];
		mask.locations = @[ @0.0, @0.5, @1.0 ];
		mask.startPoint = CGPointMake(0.0, 0.5);
		mask.endPoint = CGPointMake(1.0, 0.5);
		
		self.dividerLayerMask = mask;
	}
	return _dividerLayerMask;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	[super layoutSublayersOfLayer:layer];
	
	self.dividerLayerMask.frame = self.dividerImageView.bounds;
}


@end
