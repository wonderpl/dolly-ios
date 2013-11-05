//
//  SYNImagePickerController.h
//  rockpack
//
//  Created by Mats Trovik on 15/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import Foundation;

@class SYNImagePickerController;

@protocol SYNImagePickerControllerDelegate <NSObject>

@optional
/**
	callback method for returning a selected image
	@param picker the image picker returning the image
	@param image the returned image
 */
-(void)picker:(SYNImagePickerController*)picker finishedWithImage:(UIImage*)image;

@end

@interface SYNImagePickerController : NSObject

@property(nonatomic,weak) UIViewController* hostViewController; //< view controller hosting the picker. will receive commands to present the picker
@property(nonatomic,weak) id<SYNImagePickerControllerDelegate> delegate; //< picker delegate

/**
	recommended initialiser. assigns a host view controller which will present the image picker.
 
	@param host the host view controller
	@returns successfully initialised picker, or nil
 */
-(id)initWithHostViewController:(UIViewController*)host;


/**
 Present picker as a popup.
 
 if on iPad the image picker is presented as a popover from the specified view with the specified arrow direction.
 if on iPhone the image picker is presented modally.
 
 @param view view to show the popup from
 @param direction for popover arrow
 */
-(void)presentImagePickerAsPopupFromView:(UIView*)view arrowDirection:(UIPopoverArrowDirection)direction;


/**
	present image picker modally, allows selection of camera/library if camera present on device, otherwise straight to library.
 */
-(void)presentImagePickerModally;


@end
