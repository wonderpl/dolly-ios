//
//  SYNImagePickerController.m
//  rockpack
//
//  Created by Mats Trovik on 15/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNImagePickerController.h"
#import "SYNCameraPopoverViewController.h"

@interface SYNImagePickerController () <SYNCameraPopoverViewControllerDelegate, UIPopoverControllerDelegate, GKImagePickerDelegate, UIActionSheetDelegate>

@property (nonatomic, assign) BOOL didShowModally;
@property (nonatomic, assign) CGRect popoverPresentingFrame;
@property (nonatomic, weak) UIView* popoverView;
@property (nonatomic, assign) UIPopoverArrowDirection direction;
@property (nonatomic,strong) UIPopoverController* menuPopoverController;
@property (nonatomic) CGSize cropSize;

@end

@implementation SYNImagePickerController

#pragma mark - Object lifecycle

- (void) dealloc
{
    // Defensive programming
    self.menuPopoverController.delegate = nil;
    self.gkImagePicker.delegate = nil;
    self.cameraPopoverController.delegate = nil;
}

- (id) initWithHostViewController: (UIViewController*) host
{
    self = [super init];
    if (self)
    {
        _hostViewController = host;
        self.cropSize = CGSizeMake(280, 280);

    }
    return self;
}

- (id) initWithHostViewController: (UIViewController*) host withCropSize:(CGSize) cropSize
{
    self = [super init];
    if (self)
    {
        _hostViewController = host;
        
        _cropSize = cropSize;
        
    }
    return self;
}


- (void) presentImagePickerAsPopupFromView: (UIView*) view
                            arrowDirection: (UIPopoverArrowDirection) direction
{
    if (IS_IPHONE)
    {
        [self presentImagePickerModally];
    }
    else
    {
        self.popoverPresentingFrame = [self.hostViewController.view convertRect: view.frame
                                                                       fromView: self.hostViewController.view];
        
        self.direction = direction;
        self.popoverView = view;

        SYNCameraPopoverViewController *actionPopoverController = [[SYNCameraPopoverViewController alloc] init];
        actionPopoverController.delegate = self;
        
        // Need show the popover controller
        self.menuPopoverController = [[UIPopoverController alloc] initWithContentViewController: actionPopoverController];
        //size of the buttons of the popover
        self.menuPopoverController.popoverContentSize = CGSizeMake(206, 88);
        self.menuPopoverController.delegate = self;
        
        [self.menuPopoverController presentPopoverFromRect: self.popoverPresentingFrame
                                                          inView: self.hostViewController.view
                                        permittedArrowDirections: self.direction
                                                        animated: YES];
    }
}


- (void) presentImagePickerModally
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIActionSheet* sourceSelector = [[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"channel_creation_screen_select_upload_photo_label", nil)
                                                                    delegate: self
                                                           cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                                      destructiveButtonTitle: nil
                                                           otherButtonTitles: NSLocalizedString(@"camera_popover_button_takephoto_label", nil),
                                         NSLocalizedString(@"camera_popover_button_choose_label", nil), nil];
        
        [sourceSelector showInView: self.hostViewController.view];
    }
    else
    {
        [self showImagePickerModally: UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
}


- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
    if (popoverController == self.menuPopoverController)
    {
        self.menuPopoverController = nil;
    }
    else if (popoverController == self.cameraPopoverController)
    {
        self.cameraPopoverController = nil;
        self.gkImagePicker = nil;
    }
    else
    {
        AssertOrLog(@"Unknown popup dismissed");
    }
}


- (void) userTouchedTakePhotoButton
{
    [self.menuPopoverController dismissPopoverAnimated: NO];
    [self showImagePicker: UIImagePickerControllerSourceTypeCamera];
}


- (void) userTouchedChooseExistingPhotoButton
{
    [self.menuPopoverController dismissPopoverAnimated: NO];
    [self showImagePicker: UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void) showImagePicker: (UIImagePickerControllerSourceType) sourceType
{
    if (IS_IPHONE)
    {
        [self showImagePickerModally: sourceType];
        return;
    }
    
    self.gkImagePicker = [[GKImagePicker alloc] init];
    self.gkImagePicker.cropSize = self.cropSize;
    self.gkImagePicker.delegate = self;
    self.gkImagePicker.imagePickerController.sourceType = sourceType;

    
    if ((sourceType == UIImagePickerControllerSourceTypeCamera) && [UIImagePickerController respondsToSelector: @selector(isCameraDeviceAvailable:)])
    {
        if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront])
        {
            self.gkImagePicker.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            
            }
    }
    


    //    self.cameraPopoverController = [[UIPopoverController alloc] initWithContentViewController: tmp];
    
//    self.testPicker.extendedLayoutIncludesOpaqueBars = YES;
//    self.testPicker.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    self.cameraPopoverController = [[UIPopoverController alloc] initWithContentViewController: self.gkImagePicker.imagePickerController];
    
    self.cameraPopoverController.delegate = self;
//    [self.cameraPopoverController setPopoverContentSize:CGSizeMake(1024, 1024)];

    if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                
        [self.cameraPopoverController presentPopoverFromRect:self.popoverView.frame inView:self.hostViewController.view permittedArrowDirections:self.direction animated:YES];
        
    }
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self showImagePickerModally:sourceType];
        
    }
    
}

- (void) showImagePickerModally: (UIImagePickerControllerSourceType) sourceType
{
    self.didShowModally = YES;
    self.gkImagePicker = [[GKImagePicker alloc] init];
    self.gkImagePicker.cropSize = self.cropSize;
    self.gkImagePicker.delegate = self;
    
    
    self.gkImagePicker.imagePickerController.sourceType = sourceType;
    
    if ((sourceType == UIImagePickerControllerSourceTypeCamera) && [UIImagePickerController respondsToSelector: @selector(isCameraDeviceAvailable:)])
    {
        if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront])
        {
            self.gkImagePicker.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    
    [self.hostViewController presentViewController: self.gkImagePicker.imagePickerController
                                          animated: YES
                                        completion: nil];
}

# pragma mark - GKImagePicker Delegate Methods

- (void) imagePicker: (GKImagePicker *) imagePicker
         pickedImage: (UIImage *) image
{
    [self hideImagePicker];
    
    if ([self.delegate respondsToSelector: @selector(picker: finishedWithImage:)])
    {
        [self.delegate picker:self finishedWithImage: image];
    }
}


- (void) hideImagePicker
{
    if (self.didShowModally)
    {
        [self.hostViewController dismissViewControllerAnimated: YES
                                                    completion: nil];
        self.gkImagePicker = nil;
    }
    else
    {
        [self.cameraPopoverController dismissPopoverAnimated: YES];
    }
}

#pragma mark - actionsheet delegate
- (void) actionSheet: (UIActionSheet *) actionSheet
didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (buttonIndex == 0)
    {
        //Camera
        [self showImagePicker: UIImagePickerControllerSourceTypeCamera];
    }
    else if (buttonIndex ==1)
    {
        //Choose existing
        [self showImagePicker: UIImagePickerControllerSourceTypePhotoLibrary];
    }
}


- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view
{
    *rect = self.popoverView.frame;
}



@end
