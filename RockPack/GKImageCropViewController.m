//
//  GKImageCropViewController.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImageCropView.h"
#import "GKImageCropViewController.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
@import QuartzCore;

@interface GKImageCropViewController ()

@property (nonatomic, strong) GKImageCropView *imageCropView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *useButton;
@property (nonatomic, strong) UIToolbar *toolbar;

- (void) _actionCancel;
- (void) _actionUse;
- (void) _setupNavigationBar;
- (void) _setupCropView;

@end

@implementation GKImageCropViewController

#pragma mark -
#pragma mark Getter/Setter

@synthesize sourceImage, cropSize, delegate;
@synthesize imageCropView;
@synthesize toolbar;
@synthesize cancelButton, useButton, resizeableCropArea;


- (id) init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Move and Scale", @"");
    
    [self _setupNavigationBar];
    [self _setupCropView];
    [self _setupToolbar];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self.navigationController setNavigationBarHidden: YES];
    }
    else
    {
        [self.navigationController setNavigationBarHidden: NO];
    }
}


#pragma mark -
#pragma Private Methods

- (void) _actionCancel
{
    [[UIApplication sharedApplication] setStatusBarHidden: NO
                                            withAnimation: UIStatusBarAnimationSlide];
    
    [self.navigationController popViewControllerAnimated: YES];
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
}


- (void) _actionUse
{
    [[UIApplication sharedApplication] setStatusBarHidden: NO
                                            withAnimation: UIStatusBarAnimationSlide];
    
    _croppedImage = [self.imageCropView croppedImage];
    
    [self.delegate imageCropController: self
             didFinishWithCroppedImage: _croppedImage];
}


- (void) _setupNavigationBar
{
    // Add title (offset due to custom font)
    UIView *containerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 200, 28)];
    
    containerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 3, 200, 28)];
    label.backgroundColor = [UIColor clearColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = self.navigationItem.title;
    [containerView addSubview: label];
    self.navigationItem.titleView = containerView;
    
    UIBarButtonItem *customCancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(_actionCancel)];
    

    UIBarButtonItem *customUseButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"use" style:UIBarButtonItemStylePlain target:self action:@selector(_actionUse)];

    self.navigationItem.leftBarButtonItem = customCancelButtonItem;
    
    self.navigationItem.rightBarButtonItem = customUseButtonItem;
}


- (void) _setupCropView
{
    self.imageCropView = [[GKImageCropView alloc] initWithFrame: self.view.bounds];
    
    [self.imageCropView setImageToCrop: sourceImage];
    
    [self.imageCropView setResizableCropArea: self.resizeableCropArea];
    
    [self.imageCropView setCropSize: cropSize];
    
    [self.view addSubview: self.imageCropView];
}


- (void) _setupCancelButton
{
    self.cancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [self.cancelButton setBackgroundImage: [UIImage imageNamed: @"ButtonCancel~iphone.png"]
                                 forState: UIControlStateNormal];
    
    [self.cancelButton setBackgroundImage: [UIImage imageNamed: @"ButtonCancelHighlighted~iphone.png"]
                                 forState: UIControlStateHighlighted];
    
    [[self.cancelButton titleLabel] setFont: [UIFont regularCustomFontOfSize: 11.0]];
    [[self.cancelButton titleLabel] setShadowOffset: CGSizeMake(0, 1)];
    [self.cancelButton setFrame: CGRectMake(0, 0, 48, 49)];
    
    [self.cancelButton  setTitle: nil
                        forState: UIControlStateNormal];
    
    [self.cancelButton setTitleShadowColor: [UIColor colorWithRed: 0.827 green: 0.831 blue: 0.839 alpha: 1]
                                  forState: UIControlStateNormal];
    
    [self.cancelButton addTarget: self
                          action: @selector(_actionCancel)
                forControlEvents: UIControlEventTouchUpInside];
}


- (void) _setupUseButton
{
    self.useButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [self.useButton setBackgroundImage: [UIImage imageNamed: @"ButtonConfirmYellow~iphone.png"]
                              forState: UIControlStateNormal];
    
    [self.useButton setBackgroundImage: [UIImage imageNamed: @"ButtonConfirmYellowHighlighted~iphone.png"]
                              forState: UIControlStateHighlighted];
    
    [[self.useButton titleLabel] setFont: [UIFont regularCustomFontOfSize: 11]];
    [[self.useButton titleLabel] setShadowOffset: CGSizeMake(0, -1)];
    [self.useButton setFrame: CGRectMake(0, 0, 48, 49)];
    
    [self.useButton setTitle: nil
                    forState: UIControlStateNormal];
    
    [self.useButton setTitleShadowColor: [UIColor colorWithRed: 0.118 green: 0.247 blue: 0.455 alpha: 1]
                               forState: UIControlStateNormal];
    
    [self.useButton addTarget: self
                       action: @selector(_actionUse)
             forControlEvents: UIControlEventTouchUpInside];
}


- (UIImage *) _toolbarBackgroundImage
{
    const float colorMask[6] = {
        222, 255, 222, 255, 222, 255
    };
    
    UIImage *img = [[UIImage alloc] init];
    CGImageRef imgRef = CGImageCreateWithMaskingColors(img.CGImage, colorMask);
    UIImage *maskedImage = [UIImage imageWithCGImage: imgRef];
    
    CGImageRelease(imgRef);
    
    [self.toolbar setBackgroundImage: [UIImage new]
                  forToolbarPosition: UIToolbarPositionAny
                          barMetrics: UIBarMetricsDefault];
    
    [self.toolbar setBackgroundColor: [UIColor clearColor]];
    return maskedImage;
}


- (void) _setupToolbar
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.toolbar = [[UIToolbar alloc] initWithFrame: CGRectZero];
        self.toolbar.clipsToBounds = YES;
        
        [self.toolbar setBackgroundImage: [UIImage new]
                      forToolbarPosition: UIToolbarPositionAny
                              barMetrics: UIBarMetricsDefault];
        
        [self.toolbar setBackgroundColor: [UIColor clearColor]];
        
        [self.view addSubview: self.toolbar];
        
        [self _setupCancelButton];
        [self _setupUseButton];
        
        UILabel *info = [[UILabel alloc] initWithFrame: CGRectMake((self.view.frame.size.width - 250) / 2, 0, 320, 40)];
        info.text = NSLocalizedString(@"MOVE AND SCALE", nil);
        info.textColor = [UIColor colorWithRed: 255.0 / 255.0
                                         green: 255.0 / 255.0
                                          blue: 255.0 / 255.0
                                         alpha: 1];
        
        info.font = [UIFont lightCustomFontOfSize: 18];
        
        info.layer.shadowColor = [[UIColor colorWithRed: (1.0 / 255.0)
                                                  green: (1.0 / 255.0)
                                                   blue: (1.0 / 255.0)
                                                  alpha: (1.0)] CGColor];
        
        info.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        info.layer.shadowRadius = 1.0;
        info.layer.shadowOpacity = 1.0;
        info.backgroundColor = [UIColor clearColor];
        info.textAlignment = NSTextAlignmentCenter;
        //[info sizeToFit];
        
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView: self.cancelButton];
        
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                                                              target: nil
                                                                              action: nil];
        
        UIBarButtonItem *lbl = [[UIBarButtonItem alloc] initWithCustomView: info];
        UIBarButtonItem *use = [[UIBarButtonItem alloc] initWithCustomView: self.useButton];
        
        
        [self.toolbar setItems: @[cancel, flex, lbl, flex, use]];
    }
}


#pragma mark -
#pragma Super Class Methods

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.imageCropView.frame = CGRectMake(self.view.center.x - (self.view.frame.size.width * 0.5), (self.view.center.y) - (self.view.frame.size.height * 0.5), self.view.frame.size.width, self.view.frame.size.height);
    
    self.toolbar.frame = CGRectMake((self.view.center.x + 6) - (self.view.frame.size.width * 0.5), self.view.center.y - 174, 308, 54);
}


- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
