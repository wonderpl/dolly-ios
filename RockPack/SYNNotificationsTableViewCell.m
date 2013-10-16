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

@interface SYNNotificationsTableViewCell ()

@property (nonatomic, assign) CGRect imageViewRect;
@property (nonatomic, assign) CGSize mainTextSize;
@property (nonatomic, assign) UIButton *secondaryImageButton;
@property (nonatomic, strong) UIButton *mainImageButton;
@property (nonatomic, strong) UIView *dividerImageView;

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
        self.imageViewRect = CGRectMake(8.0, 8.0, 60.0, 60.0);
        
        // == Profile Image View == //
        self.imageView.frame = self.imageViewRect;
        
        // == Main Text == //
        self.textLabel.frame = CGRectMake(74.0, 10.0, 0.0, 0.0); // width, height will be set below
        self.textLabel.font = [UIFont rockpackFontOfSize: 14.0];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.numberOfLines = 3;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.textLabel.textColor = [UIColor colorWithRed: (40.0 / 255.0)
                                                   green: (45.0 / 255.0)
                                                    blue: (51.0 / 255.0)
                                                   alpha: (1.0)];
        
        // == Subtitle == //
        self.detailTextLabel.font = [UIFont rockpackFontOfSize: 12.0];
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        
        self.detailTextLabel.textColor = [UIColor colorWithRed: (187.0 / 255.0)
                                                         green: (187.0 / 255.0)
                                                          blue: (187.0 / 255.0)
                                                         alpha: (1.0)];
        
        // == Channel image view == //
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, 60, 60.0)]; // x, y will be set below
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.thumbnailImageView.clipsToBounds = TRUE;
        [self addSubview: self.thumbnailImageView];
        
        self.playSymbolImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, 60, 60.0)]; 
        self.playSymbolImageView.contentMode = UIViewContentModeCenter;
        self.playSymbolImageView.clipsToBounds = TRUE;
        self.playSymbolImageView.hidden = TRUE;
        self.playSymbolImageView.image = [UIImage imageNamed: @"OverlayNotificationVideo"];
        
        [self addSubview: self.playSymbolImageView];
        
        // == Divider Image View == //
        self.dividerImageView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 362.0, 2.0)];
        self.dividerImageView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"NavDivider"]];
        
        [self addSubview: self.dividerImageView];
        
        // == Buttons == //
        self.mainImageButton = [UIButton buttonWithType: UIButtonTypeCustom];
        self.mainImageButton.frame = self.imageViewRect;
        [self addSubview: self.mainImageButton];
        
        self.secondaryImageButton = [UIButton buttonWithType: UIButtonTypeCustom];
        self.secondaryImageButton.frame = self.imageViewRect;
        [self addSubview: self.secondaryImageButton];
    }
    
    return self;
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    // Image Vsiew //
    
    self.imageView.frame = self.mainImageButton.frame = self.imageViewRect;
    
    
    self.textLabel.frame = CGRectMake(76.0,
                                      (self.mainTextSize.height > 40.0 ? 6.0 : 12.0),
                                      self.mainTextSize.width,
                                      self.mainTextSize.height);
    
    // Thumbnail - Place at the end
    CGRect thumbnailImageViewFrame = self.imageView.frame;
    thumbnailImageViewFrame.origin.x = self.frame.size.width - 68.0;
    thumbnailImageViewFrame.origin.y = self.imageView.frame.origin.y;
    
    self.thumbnailImageView.frame = self.secondaryImageButton.frame = thumbnailImageViewFrame;
    
    // Make this the same size as the other thumbnail
    self.playSymbolImageView.frame = self.thumbnailImageView.frame;
    
    // Details
    CGRect detailsFrame = CGRectMake(76.0, 12.0, self.mainTextSize.width, 20.0f);
    detailsFrame.origin.y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height - (self.mainTextSize.height > 40.0 ? 4.0 : 0.0);
    self.detailTextLabel.frame = detailsFrame;
    
    self.dividerImageView.center = CGPointMake(self.center.x, self.frame.size.height);
    
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
}


#pragma mark - Accesssors

- (void) setDelegate: (SYNActivityViewController *) delegate
{
    if (_delegate && delegate && _delegate == delegate) // assign once
    {
        return;
    }
    
    // we can pass nil to remove observers
    [self.mainImageButton removeTarget: _delegate
                                action: @selector(mainImageTableCellPressed:)
                      forControlEvents: UIControlEventTouchUpInside];
    
    [self.secondaryImageButton removeTarget: _delegate
                                     action: @selector(itemImageTableCellPressed:)
                           forControlEvents: UIControlEventTouchUpInside];
    
    _delegate = delegate;
    
    if (!_delegate)
    {
        return;
    }
    
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
    CGFloat maxWidth = IS_IPAD ? 200.0 : 170.0;
    
    CGSize mainTSize = [messageTitle sizeWithFont: self.textLabel.font
                                constrainedToSize: CGSizeMake(maxWidth, 500.0)
                                    lineBreakMode: self.textLabel.lineBreakMode];
    
    mainTSize.height += 2.0f;
    self.mainTextSize = mainTSize;
    
    
    
    textLabelFrame.size = self.mainTextSize;
    
    self.textLabel.attributedText = attributedString;
    self.textLabel.frame = textLabelFrame;
    
    //self.textLabel.text = messageTitle;
}


- (NSString *) messageTitle
{
    return self.textLabel.text;
}


@end
