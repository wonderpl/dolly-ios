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


#define OFFSET_DESCRIPTION_EDIT 130.0f

@interface SYNProfileEditViewController () <SYNImagePickerControllerDelegate, UITextViewDelegate>
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) SYNImagePickerController* imagePickerControllerAvatar;
@property (nonatomic, strong) SYNImagePickerController* imagePickerControllerCoverphoto;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barBtnCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barBtnSave;
@property (nonatomic, strong) UITapGestureRecognizer *tapToHideKeyoboard;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation SYNProfileEditViewController


- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goBack)];
    [self.view addGestureRecognizer:self.tapGesture];
    
    [self.descriptionTextView setText: self.descriptionString];

    [[self.descriptionTextView layer] setBorderColor:[[UIColor colorWithRed:172.0/255.0f green:172.0/255.0f blue:172.0/255.0f alpha:1.0f] CGColor]];
    if (IS_RETINA) {
        [[self.descriptionTextView layer] setBorderWidth:0.5];
    } else {
        [[self.descriptionTextView layer] setBorderWidth:1.0];
    }
    
    //wierd :   textview attributes reset when text is set.
    
    [[self.descriptionTextView layer] setCornerRadius:0];
	self.descriptionTextView.textAlignment = NSTextAlignmentCenter;
	self.descriptionTextView.textColor = [UIColor colorWithWhite:120/255.0 alpha:1.0];
    self.descriptionTextView.textContainer.maximumNumberOfLines = 2;
    [[self.descriptionTextView layer] setBorderColor:[[UIColor colorWithRed:172.0/255.0f green:172.0/255.0f blue:172.0/255.0f alpha:1.0f] CGColor]];
    self.descriptionTextView.font = [UIFont lightCustomFontOfSize:11.0];

    [self.navigationBar setBackgroundTransparent:YES];
    self.descriptionTextView.delegate = self;

    // == Tap gesture do dismiss the keyboard
    self.tapToHideKeyoboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //we move the view up in 1phone 4
    if (!IS_IPHONE_5 && IS_IPHONE) {
        [self.topConstraint setConstant:-50];
    }
    
    [self.navigationBar setTranslucent:YES];
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
        [self.delegate updateUserDescription:self.descriptionTextView.text];
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
        
        int offset = OFFSET_DESCRIPTION_EDIT;
        
        if (!IS_IPHONE_5 && IS_IPHONE) {
            offset += 70;
        } else if (IS_IPAD) {
            offset += 20;
        }
        
        [self moveViewToOffSet: CGPointMake(0, offset)];
    }];
}


- (void) moveViewToOffSet : (CGPoint) offset {
    
    [UIView animateWithDuration:1.5 animations:^{
        if (IS_IPHONE ) {
            if (IS_IPHONE_5) {
                [self.topConstraint setConstant:-70];
            } else {
                [self.topConstraint setConstant:-140];
            }
        } else {
            [self.topConstraint setConstant:offset.y];

        }
        [self.view layoutIfNeeded];
    }];
    
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




@end
