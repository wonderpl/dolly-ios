//
//  SYNProfileEditViewController.m
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileEditViewController.h"
#import "SYNImagePickerController.h"
#import "SYNTrackingManager.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
#import "UINavigationBar+Appearance.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"


static const CGFloat OFFSET_DESCRIPTION_EDIT = 130.0f;

@interface SYNProfileEditViewController () <SYNImagePickerControllerDelegate, UITextViewDelegate>
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) SYNImagePickerController* imagePickerControllerAvatar;
@property (nonatomic, strong) SYNImagePickerController* imagePickerControllerCoverphoto;
@property (nonatomic, strong) UITapGestureRecognizer *tapToHideKeyoboard;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centreDescriptionConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topProfileUploadButton;

@end

@implementation SYNProfileEditViewController


- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goBack)];
    [self.view addGestureRecognizer:self.tapGesture];
    
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.lineSpacing = 6;
	style.alignment = NSTextAlignmentCenter;
	
	NSDictionary *descriptionAttributes = @{NSParagraphStyleAttributeName : style,
											NSFontAttributeName : [UIFont regularCustomFontOfSize : 16],
											NSForegroundColorAttributeName : [UIColor dollyTextMediumGray],
											};
	
	
	self.descriptionTextView.attributedText = [[NSAttributedString alloc]
											   initWithString:self.descriptionString
											   attributes:descriptionAttributes];
		
    [[self.descriptionTextView layer] setCornerRadius:0];
    
    
    //TODO: dont use UIPlaceHolderTextView, find something better.
    
    if (IS_IPHONE) {
        self.descriptionTextView.placeholder = @"                  Edit Description";
    } else {
        self.descriptionTextView.placeholder = @"                          Edit Description";
    }
    
    [self.descriptionTextView setPlaceHolderLabelFont:[UIFont regularCustomFontOfSize : self.descriptionTextView.font.pointSize]];
    
    self.descriptionTextView.delegate = self;

    // == Tap gesture do dismiss the keyboard
    self.tapToHideKeyoboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	self.cancelButton.tintColor = [[UINavigationBar appearance] tintColor];
	self.cancelButton.titleLabel.font = [UIFont regularCustomFontOfSize : IS_IPHONE ? 15 : 17];
	[self.cancelButton setTitle:NSLocalizedString(@"cancel", @"cancel in edit mode") forState:UIControlStateNormal];
	
	self.saveButton.tintColor = [[UINavigationBar appearance] tintColor];
	self.saveButton.titleLabel.font = [UIFont regularCustomFontOfSize : IS_IPHONE ? 15 : 17];
	[self.saveButton setTitle:NSLocalizedString(@"save", @"save in edit mode") forState:UIControlStateNormal];
	
	[self.navigationBar setBackgroundTransparent:YES];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationBar setTranslucent:YES];
	
	if (IS_IPAD) {
		[self updateLayoutForOrientation: [[SYNDeviceManager sharedInstance] orientation]];
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[SYNTrackingManager sharedManager] trackEditProfileScreenView];
}

- (void) goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)coverImageButtonTapped:(id)sender {
	[[SYNTrackingManager sharedManager] trackCoverPhotoUpload];
    
    //302,167 is the values for the cropping, the cover photo dimensions is 907 x 502
    self.imagePickerControllerCoverphoto = [[SYNImagePickerController alloc] initWithHostViewController:self withCropSize:CGSizeMake(302,167)];
    self.imagePickerControllerCoverphoto.delegate = self;
    
    if (UIDeviceOrientationIsLandscape([[SYNDeviceManager sharedInstance] isLandscape])) {
        [self.imagePickerControllerCoverphoto presentImagePickerAsPopupFromView:sender arrowDirection:UIPopoverArrowDirectionAny];
    }
    else {
        [self.imagePickerControllerCoverphoto presentImagePickerAsPopupFromView:sender arrowDirection:UIPopoverArrowDirectionRight];
    }
    
}


- (IBAction)avatarButtonTapped:(id)sender {
	[[SYNTrackingManager sharedManager] trackAvatarUploadFromScreen:[self trackingScreenName]];
	
    self.imagePickerControllerAvatar = [[SYNImagePickerController alloc] initWithHostViewController:self withCropSize:CGSizeMake(280, 280)];
    
    self.imagePickerControllerAvatar.delegate = self;
    [self.imagePickerControllerAvatar presentImagePickerAsPopupFromView:sender arrowDirection:UIPopoverArrowDirectionRight];
    
}

- (void) picker: (SYNImagePickerController *) picker finishedWithImage: (UIImage *) image {
    
    if (picker == self.imagePickerControllerAvatar) {
        [appDelegate.oAuthNetworkEngine updateAvatarForUserId: appDelegate.currentOAuth2Credentials.userId
                                                        image: image
                                            completionHandler: ^(NSDictionary* result) {
                                                [[SYNTrackingManager sharedManager] trackAvatarPhotoUploadCompleted];
                                                
                                                
                                                [self.delegate updateAvatarImage:result[@"thumbnail_url"]];
                                                [self goBack];
                                                
                                            } errorHandler: ^(id error) {
                                                NSLog(@"updateProfileForUserId error: %@", error);
                                            }];
        self.imagePickerControllerAvatar = nil;
    } else {
        [appDelegate.oAuthNetworkEngine updateProfileCoverForUserId: appDelegate.currentOAuth2Credentials.userId
                                                              image: image
                                                  completionHandler: ^(NSDictionary* result)
         {
			 [[SYNTrackingManager sharedManager] trackCoverPhotoUploadCompleted];
             [self.delegate updateCoverImage:result[@"Location"] ];

             [self goBack];
         } errorHandler: ^(id error) {
             NSLog(@"updateProfileForUserId error: %@", error);
         }];
        
        self.imagePickerControllerCoverphoto = nil;
    }
}


#pragma mark - barbutton items

- (IBAction)cancelTapped:(id)sender {
    [self goBack];
}

- (IBAction)saveDescription:(id)sender {

    [self updateField:@"description" forValue:self.descriptionTextView.text withCompletionHandler:^{
        appDelegate.currentUser.channelOwnerDescription = self.descriptionTextView.text;
        [appDelegate saveContext: YES];
        [self goBack];
    }];
    
}

- (void) updateField: (NSString *) field
            forValue: (id) newValue
withCompletionHandler: (MKNKBasicSuccessBlock) successBlock {
    __weak SYNProfileEditViewController *wself = self;
    
    [appDelegate.oAuthNetworkEngine changeUserField: field
                                            forUser: appDelegate.currentUser
                                       withNewValue: newValue
                                  completionHandler: ^(NSDictionary * dictionary){
                                      
                                      successBlock();
                                      
                                      [wself.delegate updateUserDescription:self.descriptionTextView.text];
                                      
                                      
                                  } errorHandler: ^(id errorInfo) {
                                      
                                      if (!errorInfo || ![errorInfo isKindOfClass: [NSDictionary class]])
                                      {
                                          return;
                                      }
                                      
                                      NSString *message = errorInfo[@"message"];
                                      
                                      if (message)
                                      {
                                          if ([message isKindOfClass: [NSArray class]])
                                          {
                                              NSLog(@"Error %@", message);
                                          }
                                          else if ([message isKindOfClass: [NSString class]])
                                          {
                                              NSLog(@"Error %@", message);
                                          }
                                      }
                                  }];
}




#pragma mark - Textview delegate
-(void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

-(void) textViewDidBeginEditing:(UITextView *)textView {
    [self.view addGestureRecognizer:self.tapToHideKeyoboard];
	[UIView animateWithDuration:0.3f animations:^{

		[self calculateAndMoveViews];
    }];

}

-(void) calculateAndMoveViews {

	int offset = OFFSET_DESCRIPTION_EDIT;
	
	if (IS_IPHONE ) {
		if (!IS_IPHONE_5) {
			offset += 92;
		}
	} else if (IS_IPAD) {
		if (UIDeviceOrientationIsLandscape([[SYNDeviceManager sharedInstance] orientation])) {
			offset += 60;
		}
	}
	
	[self moveViewToOffSet: CGPointMake(0, offset)];

}

- (void) moveViewToOffSet : (CGPoint) offset {
    
    [UIView animateWithDuration:1.5 animations:^{
        if (IS_IPHONE ) {
			//TODO: make these values not hard coded
            if (IS_IPHONE_5) {
                [self.topConstraint setConstant:-50];
            } else {
                [self.topConstraint setConstant:-140];
            }
        } else {
			if (UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation])) {
				[self.topConstraint setConstant:offset.y - 25];
			} else {
				[self.topConstraint setConstant:offset.y - 262];
			}
        }
    }];

	[self.view layoutIfNeeded];

    [self.delegate setCollectionViewContentOffset: offset animated:NO];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 100) ? NO : YES;
}


#pragma mark - gesture reconiser methods

-(void)dismissKeyboard {
    [self.descriptionTextView resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
    [self.view removeGestureRecognizer:self.tapToHideKeyoboard];
}


- (NSString *)trackingScreenName {
	return @"Profile";
}


- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
										 duration: (NSTimeInterval) duration {
	if (IS_IPHONE) {
        return;
    }
	
    [self updateLayoutForOrientation: toInterfaceOrientation];
}

- (void)updateLayoutForOrientation: (UIDeviceOrientation) orientation {
    
	if (self.isEditingDescription) {
		[self calculateAndMoveViews];
		return;
	}
    if (UIDeviceOrientationIsPortrait(orientation)) {
		self.topConstraint.constant = 233;
        self.centreDescriptionConstraint.constant = 0;
        self.topProfileUploadButton.constant = 211;
    } else {
		self.topConstraint.constant = 120;
        self.centreDescriptionConstraint.constant = 1;
        self.topProfileUploadButton.constant = 208;
        
    }
    
}


- (BOOL) isEditingDescription {
	return [self.descriptionTextView isFirstResponder];
}



@end
