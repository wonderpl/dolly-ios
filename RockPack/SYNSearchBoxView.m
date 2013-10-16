//
//  SYNSearchBoxView.m
//  rockpack
//
//  Created by Michael Michailidis on 30/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNDeviceManager.h"
#import "SYNSearchBoxView.h"
#import "SYNTextField.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNSearchBoxView ()

//iPhone specific
@property (nonatomic, strong) IBOutlet UIImageView* searchFieldFrameImageView;

@end


@implementation SYNSearchBoxView

#define kGrayPanelBorderWidth 2.0

+ (id) searchBoxView
{
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        if (IS_IPAD)
        {
            CGFloat barWidth = [SYNDeviceManager.sharedInstance currentScreenWidth] - 90.0;
            
            backgroundPanel = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, barWidth, 61.0)];
            backgroundPanel.backgroundColor = [UIColor whiteColor];
            
            backgroundPanel.autoresizesSubviews = YES;
            
            initialPanelHeight = backgroundPanel.frame.size.height;
            
            // == Gray Panel == //
            grayPanel = [[UIView alloc] initWithFrame:CGRectMake(kGrayPanelBorderWidth,
                                                                 kGrayPanelBorderWidth,
                                                                 backgroundPanel.frame.size.width - kGrayPanelBorderWidth * 2,
                                                                 backgroundPanel.frame.size.height - kGrayPanelBorderWidth * 2)];
            
            grayPanel.backgroundColor = [UIColor colorWithRed:(249.0/255.0) green:(249.0/255.0) blue:(249.0/255.0) alpha:(1.0)];
            grayPanel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [backgroundPanel addSubview:grayPanel];
            
            
            backgroundPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
            
            // == Loop == //
            UIImage* loopImage = [UIImage imageNamed:@"IconSearch"];
            UIImageView* loopImageView = [[UIImageView alloc] initWithImage:loopImage];
            loopImageView.frame = CGRectMake(15.0, 15.0, loopImage.size.width, loopImage.size.height);
            loopImageView.image = loopImage;
            grayPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
            [grayPanel addSubview:loopImageView];
            
            // == Label == //
            CGRect fieldRect = grayPanel.frame;
            fieldRect.origin.x += 28.0 + loopImage.size.width;
            fieldRect.origin.y += 14.0;
            fieldRect.size.width -= 28.0 * 2;
            fieldRect.size.height -= 14.0 * 2;
            self.searchTextField = [[SYNTextField alloc] initWithFrame:fieldRect];
            self.searchTextField.font = [UIFont rockpackFontOfSize:26.0];
        }
        else
        {
            backgroundPanel = [[UIView alloc] initWithFrame: CGRectMake(0, -10, 320, 75)];
            backgroundPanel.backgroundColor = [UIColor colorWithRed:(248.0/255.0) green:(248.0/255.0) blue:(248.0/255.0) alpha:(1.0)];
            
//            self.backgroundSearchPanel = [[UIImageView alloc] initWithFrame: CGRectMake(0, 10, 320, 65)];
//            self.backgroundSearchPanel.image = [UIImage imageNamed: @"PanelSearch"];
//            [backgroundPanel addSubview: self.backgroundSearchPanel];
            
            self.searchFieldFrameImageView = [[UIImageView alloc] initWithFrame: CGRectMake(10, 20, 300, 45)];
            
            self.searchFieldFrameImageView.image = [[UIImage imageNamed: @"FieldSearch"]
                                                    resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f,20.0f, 0.0f, 20.0f)];
            
            [backgroundPanel addSubview: self.searchFieldFrameImageView];

            initialPanelHeight = backgroundPanel.frame.size.height;
            
            // == Loop == //
            UIImage* loupeImage = [UIImage imageNamed: @"IconSearch"];
            UIImageView* loupeImageView = [[UIImageView alloc] initWithImage: loupeImage];
            loupeImageView.frame = CGRectMake(10.0f, 20.0f, 34.0f, 45.0f);
            loupeImageView.image = loupeImage;
            [backgroundPanel addSubview: loupeImageView];
            
            // == Label == //
            self.searchTextField = [[SYNTextField alloc] initWithFrame: CGRectMake(52, 18, 248, 30)];
            
            self.searchTextField.font = [UIFont rockpackFontOfSize: 16.0];
            self.searchTextField.textColor = [UIColor colorWithRed: 40.0/255.0 green: 45.0/255.0 blue: 51.0/255.0 alpha: 1.0];
            self.searchTextField.layer.shadowOpacity = 1.0;
            self.searchTextField.layer.shadowColor = [UIColor whiteColor].CGColor;
            self.searchTextField.layer.shadowOffset = CGSizeMake(0.0f,1.0f);
            self.searchTextField.layer.shadowRadius = 0.0f;

            // Display Search instead of Return on iPhone Keyboard
            self.searchTextField.returnKeyType = UIReturnKeySearch;
            
            self.integratedCloseButton = [[UIButton alloc] initWithFrame: CGRectMake(266, 20, 44, 44)];
            
            UIImage* closeButtonImage = [UIImage imageNamed: @"ButtonCloseSearch"];
            
            [self.integratedCloseButton setImage: closeButtonImage
                                forState: UIControlStateNormal];
            
            [backgroundPanel addSubview: self.integratedCloseButton];
                                          
        }
    
        self.searchTextField.backgroundColor = [UIColor clearColor];
        self.searchTextField.textAlignment = NSTextAlignmentLeft;
        self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        // Display Search instead of Return on iPad Keyboard
        self.searchTextField.returnKeyType = UIReturnKeySearch;

        self.frame = backgroundPanel.frame;
        
        [self addSubview: backgroundPanel];
        [self addSubview: self.searchTextField];
        
        self.autoresizesSubviews = YES;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return self;
}


-(void)enlargeForiOS7
{
    CGRect endFrame = self.frame;
    CGRect elFrame;
    endFrame.size.height +=  10.0f;
    
    
    for (UIView* element in self.subviews)
    {
        elFrame = element.frame;
        if(element == self.backgroundSearchPanel)
            elFrame.size.height += 10.0f;
        else
            elFrame.origin.y += 10.0f;
        element.frame = elFrame;
        
    }
    self.frame = endFrame;
}

-(void)shrinkForiOS7
{
    CGRect endFrame = self.frame;
    CGRect elFrame;
    endFrame.size.height -=  10.0f;
    for (UIView* element in self.subviews)
    {
        elFrame = element.frame;
        if(element == self.backgroundSearchPanel)
            elFrame.size.height -= 10.0f;
        else
            elFrame.origin.y -= 10.0f;
        element.frame = elFrame;
        
    }
    self.frame = endFrame;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    if (!IS_IOS_7_OR_GREATER)
    {
        self.searchFieldFrameImageView.image = [[UIImage imageNamed: @"FieldSearch"]
                                                resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f,20.0f, 0.0f, 20.0f)];
        
        self.searchTextField.font = [UIFont rockpackFontOfSize: self.searchTextField.font.pointSize];
        self.searchTextField.textColor = [UIColor colorWithRed: 40.0/255.0 green: 45.0/255.0 blue: 51.0/255.0 alpha: 1.0];
        self.searchTextField.layer.shadowOpacity = 1.0;
        self.searchTextField.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.searchTextField.layer.shadowOffset = CGSizeMake(0.0f,1.0f);
        self.searchTextField.layer.shadowRadius = 0.0f;
        self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        // Display Search instead of Return on iPhone Keyboard
        self.searchTextField.returnKeyType = UIReturnKeySearch;
        
        [self hideCloseButton];
    }
}


- (void) resizeForHeight: (CGFloat) height
{
    if (IS_IPAD)
    {
        CGRect panelFrame = backgroundPanel.frame;
        panelFrame.size.height = initialPanelHeight + height + (height > 0.0 ? 10.0 : 0.0);
        backgroundPanel.frame = panelFrame;
        
        panelFrame.origin.x += kGrayPanelBorderWidth;
        panelFrame.origin.y += kGrayPanelBorderWidth;
        panelFrame.size.width -= kGrayPanelBorderWidth * 2;
        panelFrame.size.height -= kGrayPanelBorderWidth * 2;
        grayPanel.frame = panelFrame;
        
        CGRect selfFrame = self.frame;
        selfFrame.size.height = panelFrame.size.height;
        self.frame = selfFrame;
    }
    else
    {
        CGRect selfFrame = self.frame;
        selfFrame.size.height = MIN(65.0 + height, 548.0f);
        self.frame = selfFrame;
    }
}


#pragma mark - reveal closebutton (iPhone)
- (void) revealCloseButton
{
    CGRect newFrame = self.integratedCloseButton.frame;
    newFrame.origin.x = self.frame.size.width - newFrame.size.width - 10.0f;
    self.integratedCloseButton.frame = newFrame;
    
    newFrame = self.searchTextField.frame;
    newFrame.size.width = self.integratedCloseButton.frame.origin.x - 10.0f - newFrame.origin.x;
    self.searchTextField.frame = newFrame;
    
    newFrame = self.searchFieldFrameImageView.frame;
    newFrame.size.width = self.integratedCloseButton.frame.origin.x - 10.0f - newFrame.origin.x;
    self.searchFieldFrameImageView.frame = newFrame;
}


- (void) hideCloseButton
{
    CGRect newFrame = self.integratedCloseButton.frame;
    newFrame.origin.x = self.frame.size.width;
    self.integratedCloseButton.frame = newFrame;
    
    newFrame = self.searchTextField.frame;
    newFrame.size.width = self.frame.size.width -10.0f - newFrame.origin.x;
    self.searchTextField.frame = newFrame;
    
    newFrame = self.searchFieldFrameImageView.frame;
    newFrame.size.width = self.frame.size.width -10.0f - newFrame.origin.x;
    self.searchFieldFrameImageView.frame = newFrame;
}

@end
