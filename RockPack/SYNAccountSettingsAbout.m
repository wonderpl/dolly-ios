//
//  SYNAccountSettingsAbout.m
//  rockpack
//
//  Created by Michael Michailidis on 22/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "GAI.h"
#import "SYNAccountSettingsAbout.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>


@interface SYNAccountSettingsAbout ()

@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UILabel *rockpackWithVersionLabel;
@property (strong, nonatomic) UILabel *rockpackCopyrightTextLabel;
@property (strong, nonatomic) UITextView *attributionTextView;
@property (strong, nonatomic) UIButton *termsButton;
@property (strong, nonatomic) UIButton *privacyButton;
@property (strong, nonatomic) UIScrollView *scrollView;


@end

@implementation SYNAccountSettingsAbout

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];

    if (self)
    {
        if (IS_IPAD)
        {
            self.contentSizeForViewInPopover = CGSizeMake(380, 476);
        }
        
        else
        {
            self.contentSizeForViewInPopover = CGSizeMake(320, IS_IOS_7_OR_GREATER ? 598 : 578);
        }
       
    }
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"accountPropertyChanged"
                                                            label: @"About"
                                                            value: nil] build]];
	
    self.view.backgroundColor = [UIColor colorWithWhite:247.0/255 alpha:1.0];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* backButtonImage = [UIImage imageNamed: @"ButtonAccountBackDefault.png"];
    UIImage* backButtonHighlightedImage = [UIImage imageNamed: @"ButtonAccountBackHighlighted.png"];
    
    
    [backButton setImage: backButtonImage
                forState: UIControlStateNormal];
    
    [backButton setImage: backButtonHighlightedImage
                forState: UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame: CGRectMake( -(self.contentSizeForViewInPopover.width * 0.5), -15.0, self.contentSizeForViewInPopover.width, 40.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed: (28.0/255.0) green: (31.0/255.0) blue: (33.0/255.0) alpha: (1.0)];
    titleLabel.text = NSLocalizedString (@"settings_popover_about_title", nil);
    titleLabel.font = [UIFont boldRockpackFontOfSize:18.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    
    UIView * labelContentView = [[UIView alloc]init];
    [labelContentView addSubview:titleLabel];
    
    self.navigationItem.titleView = labelContentView;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake( 0, 0, screenWidth, screenHeight - 144.0)];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    [self.scrollView setContentSize: self.contentSizeForViewInPopover];
    
    //Content
    [self rockpackLogoImage];
    
    
    // Version number display ex. ROCKPACK 1.3.0
    [self rockpackVersionLabel];
   

    // Copyright 2013 Rockpack Limited Label
    [self copyrightRockpackLabel];
    
    // Attributions
    [self attributionList];
    
    // Terms Button
    self.termsButton = [[UIButton alloc] initWithFrame:CGRectMake((self.contentSizeForViewInPopover.width * 0.5) - 80.0,
                                                                  
                                                                  IS_IPHONE ?
                                                                  
                                                                    IS_IOS_7_OR_GREATER ?
                                                                  
                                                                        self.attributionTextView.frame.size.height + 10.0f + 180.0f
                                                                        :
                                                                        self.attributionTextView.frame.size.height + 150.0f
                                                                  
                                                                  :
                                                                  
                                                                    self.attributionTextView.frame.size.height + 100.0f
                                                                  ,
                                                                  
                                                                  160.0,
                                                                  
                                                                  51.0)];
  
 
    UIImage* termsButtonImage = [UIImage imageNamed: @"ButtonTerms.png"];
    UIImage* termsButtonHighlightedImage = [UIImage imageNamed: @"ButtonTermsHighlighted.png"];
    
    
    [self.termsButton setImage: termsButtonImage
                forState: UIControlStateNormal];
    
    [self.termsButton setImage: termsButtonHighlightedImage
                forState: UIControlStateHighlighted];
    
    [self.termsButton addTarget:self
                         action:@selector(termsButtonPressed:)
               forControlEvents:UIControlEventTouchDown];
    
    [self.termsButton setTitle:@"" forState:UIControlStateNormal];

    [self.scrollView addSubview: self.termsButton];
    
    
    // privacy button
    self.privacyButton = [[UIButton alloc] initWithFrame:CGRectMake((self.contentSizeForViewInPopover.width * 0.5) - 80.0,
                                                                  
                                                                  self.termsButton.frame.origin.y + self.termsButton.frame.size.height + 10.0f,
                                                                  
                                                                  160.0,
                                                                  
                                                                  51.0)];
    
    UIImage* privacyButtonImage = [UIImage imageNamed: @"ButtonPrivacy.png"];
    UIImage* privacyButtonHighlightedImage = [UIImage imageNamed: @"ButtonPrivacyHighlighted.png"];
    
    [self.privacyButton setImage: privacyButtonImage
                      forState: UIControlStateNormal];
    
    [self.privacyButton setImage: privacyButtonHighlightedImage
                      forState: UIControlStateHighlighted];
    
    [self.privacyButton addTarget:self
                         action:@selector(privacyButtonPressed:)
               forControlEvents:UIControlEventTouchDown];
    
    [self.privacyButton setTitle:@"" forState:UIControlStateNormal];
    
    [self.scrollView addSubview: self.privacyButton];
    
    [self.view addSubview:self.scrollView];

}


- (void) rockpackLogoImage
{
    self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconRockpackAbout"]];
    self.logoImageView.frame = CGRectMake((self.contentSizeForViewInPopover.width * 0.5) - 38.0, (IS_IPAD ? 40.0 : 30.0), 76.0, 77.0);
    self.logoImageView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview: self.logoImageView];
    
}


- (void) rockpackVersionLabel
{
    //NSString * appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * buildTarget = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kSYNBundleBuildTarget];
    
    NSString * appBuild;
    if ([buildTarget isEqualToString:@"Develop"])
        appBuild = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kSYNBundleFullVersion];
    else
        appBuild = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    
    
    // ROCKPACK 1.0.0 label
    self.rockpackWithVersionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                              
                                                                              self.logoImageView.frame.origin.y
                                                                              + self.logoImageView.frame.size.height,
                                                                              
                                                                              self.contentSizeForViewInPopover.width,
                                                                              
                                                                              60.0)];
    
    self.rockpackWithVersionLabel.text = [NSString stringWithFormat:@"ROCKPACK %@", appBuild];
    self.rockpackWithVersionLabel.textAlignment = NSTextAlignmentCenter;
    self.rockpackWithVersionLabel.font = [UIFont boldRockpackFontOfSize:18.0f];
    self.rockpackWithVersionLabel.textColor = [UIColor colorWithRed:40.0/255.0 green:45.0/255.0 blue:51.0/255 alpha:1.0];
    self.rockpackWithVersionLabel.backgroundColor = [UIColor clearColor];
    
    self.rockpackWithVersionLabel.shadowColor = [UIColor whiteColor];
    self.rockpackWithVersionLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [self.scrollView addSubview: self.rockpackWithVersionLabel];

}


- (void) copyrightRockpackLabel
{
    self.rockpackCopyrightTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                                
                                                                                self.logoImageView.frame.origin.y
                                                                                + self.logoImageView.frame.size.height
                                                                                + self.rockpackWithVersionLabel.frame.size.height
                                                                                - 27.0,
                                                                                
                                                                                self.contentSizeForViewInPopover.width,
                                                                                
                                                                                30.0)];
    
    self.rockpackCopyrightTextLabel.text = NSLocalizedString(@"© 2013 Rockpack Limited.", nil);
    self.rockpackCopyrightTextLabel.textAlignment = NSTextAlignmentCenter;
    self.rockpackCopyrightTextLabel.font = [UIFont rockpackFontOfSize:12.0f];
    self.rockpackCopyrightTextLabel.textColor = [UIColor colorWithWhite:153.0/255.0 alpha:1.0];
    self.rockpackCopyrightTextLabel.backgroundColor = [UIColor clearColor];
    
    self.rockpackCopyrightTextLabel.shadowColor = [UIColor whiteColor];
    self.rockpackCopyrightTextLabel.shadowOffset = CGSizeMake(0.0, 1.0);

    [self.scrollView addSubview: self.rockpackCopyrightTextLabel];

}

- (void) attributionList
{
    self.attributionTextView = [[UITextView alloc] init];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = (IS_IPAD ? 10.0f : 15.0f);
    paragraphStyle.maximumLineHeight = (IS_IPAD ? 10.0f : 15.0f);
    
    NSDictionary *attributes = @{
                                  NSParagraphStyleAttributeName : paragraphStyle,
                                  };
    
    self.attributionTextView.attributedText = [[NSAttributedString alloc] initWithString: NSLocalizedString(@"attribution_list", nil) attributes:attributes];
    self.attributionTextView.textAlignment = NSTextAlignmentCenter;
    self.attributionTextView.font = [UIFont rockpackFontOfSize:12.0f];
    self.attributionTextView.textColor = [UIColor colorWithWhite:153.0/255.0 alpha:1.0];
    self.attributionTextView.backgroundColor = [UIColor clearColor];
    
    self.attributionTextView.layer.shadowColor = [[UIColor whiteColor]CGColor];
    self.attributionTextView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [self.scrollView addSubview: self.attributionTextView];
    
    
    self.attributionTextView.frame = CGRectMake(0.0,
                                                
                                                self.logoImageView.frame.origin.y
                                                + self.logoImageView.frame.size.height
                                                + self.rockpackWithVersionLabel.frame.size.height
                                                + self.rockpackCopyrightTextLabel.frame.size.height
                                                - 20.0,
                                                
                                                self.contentSizeForViewInPopover.width,
                                                
                                                300.0f);

}


- (void) termsButtonPressed: (UIButton*) button
{
    NSURL *url = [NSURL URLWithString:@"http://rockpack.com/tos"];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
        DebugLog(@"%@%@",@"Failed to open TOS url:",[url description]);
}

- (void) privacyButtonPressed: (UIButton*) button
{
    
    NSURL *url = [NSURL URLWithString:@"http://rockpack.com/privacy"];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
        DebugLog(@"%@%@",@"Failed to open Privacy statement url:",[url description]);
}


- (void) didTapBackButton: (id) sender
{
    if(self.navigationController.viewControllers.count > 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
