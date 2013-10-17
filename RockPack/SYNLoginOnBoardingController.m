//
//  SYNLoginOnBoardingController.m
//  rockpack
//
//  Created by Michael Michailidis on 21/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "AppConstants.h"
#import "SYNDeviceManager.h"
#import "SYNLoginOnBoardingController.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>


@interface SYNLoginOnBoardingController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, weak) id <UIScrollViewDelegate> delegate;

@end


@implementation SYNLoginOnBoardingController

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
    [self removeObserver:self forKeyPath:@"view.frame"];
}


#pragma mark - View lifecycle

- (void) loadView
{
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0f, 500.0)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.scrollView.delegate = self.delegate;
    
    self.view = [[UIView alloc] initWithFrame: self.scrollView.frame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview: self.scrollView];
    
    [self addObserver:self forKeyPath:@"view.frame" options:NSKeyValueObservingOptionOld context:NULL];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
	
    UIView* messageView;
    NSString* messageText;
    NSString* titleText;
    
    CGPoint messageViewCenter;
    
    NSString* localisedKey;
    NSString* localisedDefault;
    
    CGSize totalScrollSize;

    totalScrollSize.height = self.scrollView.frame.size.height;
    
    for (int i = 0; i < kLoginOnBoardingMessagesNum; i++)
    {
        // Get the Title
        
        
        
        // Get the Message
        if (IS_IPHONE)
        {
            localisedKey = [NSString stringWithFormat:@"startscreen_onboard_%i_iphone", i + 1];
            localisedDefault = [NSString stringWithFormat:@"Text for onboard screen %i", i + 1];
            messageText = NSLocalizedString(localisedKey, localisedDefault);
            
            localisedKey = [NSString stringWithFormat:@"startscreen_onboard_%i_title_iphone", i + 1];
            localisedDefault = [NSString stringWithFormat:@"Text for onboard title %i", i + 1];
            titleText = NSLocalizedString(localisedKey, localisedDefault);


        }
        else
        {
            localisedKey = [NSString stringWithFormat:@"startscreen_onboard_%i_ipad", i + 1];
            localisedDefault = [NSString stringWithFormat:@"Text for onboard screen %i", i + 1];
            messageText = NSLocalizedString(localisedKey, localisedDefault);
            
            localisedKey = [NSString stringWithFormat:@"startscreen_onboard_%i_title_ipad", i + 1];
            localisedDefault = [NSString stringWithFormat:@"Text for onboard title %i", i + 1];
            titleText = NSLocalizedString(localisedKey, localisedDefault);
        }

        
        messageView = [self createNewMessageViewWithMessage:messageText
                                                   andTitle:titleText
                                              andCardNumber:[NSString stringWithFormat:@"%i",i]];
        
        messageViewCenter = messageView.center;
        messageViewCenter.x = (i + 0.5) * self.scrollView.frame.size.width;
        
        CGRect integralFrame = CGRectIntegral(messageView.frame);
        
        //Text Frame
        CGRect iPadMessageRect = CGRectMake((self.view.frame.size.width * 0.5) - (integralFrame.size.width * 0.5), self.view.frame.size.height - 350, integralFrame.size.width, integralFrame.size.height);
        CGRect iPhoneMessageRect = CGRectMake((self.view.frame.size.width * 0.5) - (integralFrame.size.width * 0.5), self.view.frame.size.height - 300, integralFrame.size.width, integralFrame.size.height);
        
        messageView.frame = IS_IPAD ? iPadMessageRect : iPhoneMessageRect;
                
        // Only add Image to first Card
        if (i == 0)
        {
            //Image Frame
            CGRect iPadImageRect = CGRectMake((messageView.frame.size.width * 0.5) - 140, messageView.frame.origin.y - 210, 280, 200);
            CGRect iPhoneImageRect = CGRectMake((messageView.frame.size.width * 0.5) - 140, messageView.frame.origin.y - 220, 280, 200);
            
            UIImageView * messageImageView = [[UIImageView alloc]initWithFrame: IS_IPAD ? iPadImageRect : iPhoneImageRect];
            
            messageImageView.image = [UIImage imageNamed: [NSString stringWithFormat:@"login_onboard_1.png"]];
            [messageView addSubview:messageImageView];
        }
        

        [self.scrollView addSubview:messageView];
        
        totalScrollSize.width += self.scrollView.frame.size.width;
    }
    
    [self.scrollView setContentSize:totalScrollSize];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.view.frame.size.width * 0.5) - 50, self.view.frame.size.height - 50, 100.0, 40.0)];
    self.pageControl.numberOfPages = kLoginOnBoardingMessagesNum;
    //self.pageControl.center = CGPointMake(self.view.frame.size.width * 0.5, 270.0);
    self.pageControl.frame = CGRectIntegral(self.pageControl.frame);
    self.pageControl.userInteractionEnabled = NO; // dont block the screen
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    //Tappable Dots
    self.pageControl.userInteractionEnabled = YES;
    [self.pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];

    
    [self.view addSubview:self.pageControl];
}


- (UIView*) createNewMessageViewWithMessage: (NSString*) message
                                   andTitle: (NSString*)title
                              andCardNumber: (NSString*)cardNumber
{
    CGRect newFrame = CGRectZero;
    
    
    // Limit label width to fit on portrait iPad, or iPhone screen
    newFrame.size.width = IS_IPHONE ? 260.0f: 578.0f;
    newFrame.size.height = 0.0f;
    
    UIView* container = [[UIView alloc] initWithFrame:newFrame];
    
    // Title label, Offset from the top of the scroll view;
    //newFrame.origin.y = IS_IPHONE ? 205.0f : 170.0f;
    newFrame.origin.y = IS_IPHONE ? 70.0f : 30.0f;

    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:newFrame];
    if(title)
    {
        
        UIFont* fontTitleToUse = [UIFont regularCustomFontOfSize: IS_IPHONE ? 25.0f : 28.0f];
        titleLabel.font = fontTitleToUse;
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor colorWithWhite:0.0f/255.0f alpha:0.2f];
        titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        [titleLabel sizeToFit];
        // add the newly created height to the frame
        newFrame.size.height = titleLabel.frame.size.height;
        
        [container addSubview:titleLabel];
    }
    
    //Text label, laid out under title, if there is one
    newFrame.origin.y += newFrame.size.height;
    
    UILabel* textLabel = [[UILabel alloc] initWithFrame:newFrame];
    if (message)
    {
        UIFont* fontToUse = [UIFont lightCustomFontOfSize:  IS_IPHONE ? 16.0f : 22.0f];
        
        // Move text on first card down a bit - only ipad
        if (IS_IPAD)
        {
            textLabel.frame = CGRectMake(newFrame.origin.x, newFrame.origin.y + 8.0f, newFrame.size.width, newFrame.size.height);
        }
        
        textLabel.font = fontToUse;
        textLabel.numberOfLines =0;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.text = message;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        textLabel.shadowColor = [UIColor colorWithWhite:0.0f/255.0f alpha:0.2f];
        textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [textLabel sizeToFit];
        [container addSubview:textLabel];
    }

    
    UIView * labelSeperatorView;
    
    //Different Setup for text on First Card
    if ([cardNumber isEqual:@"0"]) {
        textLabel.frame = CGRectMake(textLabel.frame.origin.x, IS_IPHONE ? textLabel.frame.origin.y + 0.0f : textLabel.frame.origin.y, textLabel.frame.size.width, textLabel.frame.size.height);

    }
    
    //Don't show seperator on First card
    else if (![cardNumber isEqual:@"0"])
    {
        labelSeperatorView =[[UIView alloc] initWithFrame:IS_IPHONE ? CGRectMake(newFrame.origin.x, newFrame.origin.y + 4.0f, 70.0f, 2.0f) : CGRectMake(newFrame.origin.x, newFrame.origin.y + 13.0f, 70.0f, 2.0f) ];
        labelSeperatorView.backgroundColor = [UIColor whiteColor];
        [container addSubview:labelSeperatorView];
    }
    
    
    // Resize the container to match the label heights
    newFrame = container.frame;
    newFrame.size.height = textLabel.frame.origin.y + textLabel.frame.size.height;
    container.frame = newFrame;

    //Center the labels in the container
    CGPoint center = textLabel.center;
    center.x = container.center.x;
    textLabel.center = center;
    
    center = titleLabel.center;
    center.x = container.center.x;
    titleLabel.center = center;
    
    //Center the Seperator Line
    center = labelSeperatorView.center;
    center.x = container.center.x;
    labelSeperatorView.center = center;
    
    return container;
    
    
}

- (void) pageTurn: (UIPageControl *) aPageControl
{
    int whichPage = aPageControl.currentPage;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         if (IS_IPHONE)
                         {
                             self.scrollView.contentOffset = CGPointMake(320.0f * whichPage, 0.0f);
                         }
                         
                         else
                         {
                             if ([[SYNDeviceManager sharedInstance] isLandscape])
                             {
                                 self.scrollView.contentOffset = CGPointMake(1024.0f * whichPage, 0.0f);
                             }
                             
                             else
                             {
                                 self.scrollView.contentOffset = CGPointMake(768.0f * whichPage, 0.0f);
                             }
                         }
                     }
                     completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"view.frame"]) {
        [self refreshLayout];
    }
}


-(void)refreshLayout
{
    CGPoint messageViewCenter;
    CGSize totalScrollSize = CGSizeZero;
    totalScrollSize.height = self.scrollView.frame.size.height;
    int i=0;
    for (UIView* childView in self.scrollView.subviews)
    {
        messageViewCenter = childView.center;
        messageViewCenter.x = (i + 0.5) * self.scrollView.frame.size.width;
        childView.center = messageViewCenter;
        
        childView.frame = CGRectIntegral(childView.frame);
        
        totalScrollSize.width += self.scrollView.frame.size.width;
        i++;
    }
    
    [self.scrollView setContentSize: totalScrollSize];
    
    CGPoint newCOffset = CGPointMake(self.pageControl.currentPage * self.scrollView.frame.size.width, self.scrollView.contentOffset.y);
    
    [self.scrollView setContentOffset: newCOffset];
    
}



@end
