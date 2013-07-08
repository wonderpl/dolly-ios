//
//  SYNLoginOnBoardingController.m
//  rockpack
//
//  Created by Michael Michailidis on 21/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLoginOnBoardingController.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+SYNColor.h"
#import "SYNDeviceManager.h"

#import "AppConstants.h"

@interface SYNLoginOnBoardingController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, weak) id <UIScrollViewDelegate> delegate;

@end

@implementation SYNLoginOnBoardingController

@synthesize scrollView = scrollView;

#pragma mark - Object lifecycle

- (id) initWithDelegate: (id <UIScrollViewDelegate>) delegate
{
    if ((self = [super init]))
    {
        self.delegate = delegate;
    }
    
    return self;
}

- (void) dealloc
{
    self.scrollView.delegate = nil;
}


#pragma mark - View lifecycle

- (void) loadView
{
    CGFloat totalWidth = 1024.0;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, totalWidth, 300.0)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    scrollView.pagingEnabled = YES;
    scrollView.scrollEnabled = YES;
    scrollView.bounces = YES;
    scrollView.userInteractionEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    scrollView.delegate = self.delegate;

    self.view = [[UIView alloc] initWithFrame:self.scrollView.frame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:scrollView];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	
    UIView* messageView;
    NSString* messageText;
    NSString* titleText;
    
    CGRect messageViewFrame;
    
    NSString* localisedKey;
    NSString* localisedDefault;
    
    CGSize totalScrollSize;
    

    totalScrollSize.height = self.scrollView.frame.size.height;
    for (int i = 0; i < kLoginOnBoardingMessagesNum; i++)
    {
        localisedKey = [NSString stringWithFormat:@"startscreen_onboard_%i", i + 1];
        localisedDefault = [NSString stringWithFormat:@"Text for onboard screen %i", i + 1];
        
        messageText = NSLocalizedString(localisedKey, localisedDefault);
        
        localisedKey = [NSString stringWithFormat:@"startscreen_onboard_%i_title", i + 1];
        localisedDefault = [NSString stringWithFormat:@"Text for onboard title %i", i + 1];
        
        titleText = NSLocalizedString(localisedKey, localisedDefault);
        
        messageView = [self createNewMessageViewWithMessage:messageText andTitle:titleText];
        
        messageViewFrame = messageView.frame;
        messageViewFrame.origin.x = i * messageViewFrame.size.width;
        
        messageView.frame = CGRectIntegral(messageViewFrame);
        
        
        
        [self.scrollView addSubview:messageView];
        
        totalScrollSize.width += messageView.frame.size.width;
    }
    
    [self.scrollView setContentSize:totalScrollSize];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
    self.pageControl.numberOfPages = kLoginOnBoardingMessagesNum;
    self.pageControl.center = CGPointMake(self.view.frame.size.width * 0.5, 270.0);
    self.pageControl.frame = CGRectIntegral(self.pageControl.frame);
    self.pageControl.userInteractionEnabled = NO; // dont block the screen
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:self.pageControl];
}


- (UIView*) createNewMessageViewWithMessage: (NSString*) message
                                   andTitle: (NSString*)title
{
    // Set up onboard text
    CGRect viewFrame = CGRectZero;
    viewFrame.size.width = [[SYNDeviceManager sharedInstance] currentScreenWidth];
    viewFrame.size.height = self.scrollView.frame.size.height;
    UIView* messageView = [[UIView alloc] initWithFrame:viewFrame];
    
    UIFont* fontToUse;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fontToUse = [UIFont rockpackFontOfSize: 22.0];
    }
    else
    {
        fontToUse = [UIFont rockpackFontOfSize: 16.0];
    }
    
    
    UILabel* onboardMessageLabel = [[UILabel alloc] init];
    onboardMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    onboardMessageLabel.textAlignment = NSTextAlignmentCenter;
    
    CGRect onboardMessageLabelFrame;
    onboardMessageLabelFrame.size = CGSizeMake(self.scrollView.frame.size.width, 150.0);
    
    onboardMessageLabelFrame.origin.x = viewFrame.size.width * 0.5 - onboardMessageLabelFrame.size.width * 0.5;
    onboardMessageLabelFrame.origin.y = 130.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        onboardMessageLabelFrame.origin.y = 150.0;
    
    onboardMessageLabel.frame = CGRectIntegral(onboardMessageLabelFrame);
    
    
    onboardMessageLabel.numberOfLines = 2;
    onboardMessageLabel.text = message;
    
    // Set font
    
    
    // Colour of onboard text
    onboardMessageLabel.textColor = [UIColor whiteColor];
    
    // Colour of small DropShadow on text
    onboardMessageLabel.shadowColor = [UIColor colorWithRed: 0.0f
                                                      green: 0.0f
                                                       blue: 0.0f
                                                      alpha:0.5f];
    onboardMessageLabel.font = fontToUse;
    // Offset of small DropShadow's
    
    onboardMessageLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    
    // Colour of onboard text shadow (R, G, B)
    onboardMessageLabel.layer.shadowColor = [UIColor colorWithRed: 0.0f
                                                            green: 0.0f
                                                             blue: 0.0f
                                                            alpha: 1.0f].CGColor;
    
    
    
    messageView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    messageView.layer.shadowRadius = 10.0f;
    messageView.layer.shadowOpacity = 0.3f;
    
    onboardMessageLabel.backgroundColor = [UIColor clearColor];
    
    [messageView addSubview:onboardMessageLabel];
    
    // TITLES
    
    if(![title isEqualToString:@""])
    {
        
      
        UIFont* fontTitleToUse;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            fontTitleToUse = [UIFont boldRockpackFontOfSize: 28.0];
        }
        else
        {
            fontTitleToUse = [UIFont boldRockpackFontOfSize: 22.0];
        }
        
        // Setup Frame for Title Message Label
        CGRect onboardTitleLabelFrame;
        onboardTitleLabelFrame.size = [title sizeWithFont:fontTitleToUse];
        onboardTitleLabelFrame.origin.x = viewFrame.size.width * 0.5 - onboardTitleLabelFrame.size.width * 0.5;
        onboardTitleLabelFrame.origin.y = 140.0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            onboardTitleLabelFrame.origin.y = 180.0;
        
        UILabel* onboardTitleLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(onboardTitleLabelFrame)];
     
        onboardTitleLabel.text = title;
        onboardTitleLabel.backgroundColor = [UIColor clearColor];
        
        onboardTitleLabel.font = fontTitleToUse;
        
        // Colour of onboard text
        onboardTitleLabel.textColor = [UIColor whiteColor];
        
        // Colour of small DropShadow on text
        onboardTitleLabel.shadowColor = [UIColor colorWithRed: 0.0f
                                                        green: 0.0f
                                                         blue: 0.0f
                                                        alpha: 0.5f];
        
        onboardTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        [messageView addSubview:onboardTitleLabel];
    }
    
    
    return messageView;
}



-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    
    
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    CGRect currenChildFrame;
    CGFloat newX = 0.0;
    
    CGSize totalScrollSize;
    totalScrollSize.height = self.scrollView.frame.size.height;
    for (UIView* childView in self.scrollView.subviews)
    {
        currenChildFrame = childView.frame;
        
        currenChildFrame.size.width = [[SYNDeviceManager sharedInstance] currentScreenWidth];
        
        currenChildFrame.origin.x = newX;
        
        newX += currenChildFrame.size.width;
        
        childView.frame = CGRectIntegral(currenChildFrame);
        
        totalScrollSize.width += currenChildFrame.size.width;
        
        for (UIView* subChildView in childView.subviews)
        {
            subChildView.center = CGPointMake(childView.frame.size.width * 0.5, subChildView.center.y);
            subChildView.frame = CGRectIntegral(subChildView.frame);
        }
    }
    
    [self.scrollView setContentSize:totalScrollSize];
    
    CGPoint newCOffset = CGPointMake(self.pageControl.currentPage * currenChildFrame.size.width, self.scrollView.contentOffset.y);
    
    [self.scrollView setContentOffset:newCOffset];
}

@end
