//
//  SYNIPhoneSignupUsernameViewController.m
//  dolly
//
//  Created by Sherman Lo on 14/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNIPhoneSignupUsernameViewController.h"
#import "SYNSignupViewController+Protected.h"
#import "UIFont+SYNFont.h"
#import "SYNTextFieldLogin.h"
#import "SYNLoginManager.h"
#import "NSString+Validation.h"
#import "SYNImagePickerController.h"
#import "SYNIPhoneSignupDetailsViewController.h"
#import "SYNTrackingManager.h"
#import "UIImageView+RoundImage.h"

static const NSInteger NameMaxLength = 32;
static const NSInteger UsernameMaxLength = 20;

@interface SYNIPhoneSignupUsernameViewController () <UIBarPositioningDelegate, UITextFieldDelegate, SYNImagePickerControllerDelegate>

@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *firstNameTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *lastNameTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *usernameTextField;

@property (nonatomic, strong) NSMutableSet *validatedUsernames;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *nextBarButton;

@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

@property (nonatomic, strong) SYNImagePickerController *imagePicker;

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;

@end

@implementation SYNIPhoneSignupUsernameViewController

#pragma mark - Init / Dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.validatedUsernames = [NSMutableSet set];
	}
	return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.usernameTextField.font = [UIFont lightCustomFontOfSize:self.usernameTextField.font.pointSize];
	self.errorLabel.font = [UIFont lightCustomFontOfSize:self.errorLabel.font.pointSize];
    
    [self.avatarImageView roundImage];
    [self.avatarImageView setContentMode:UIViewContentModeScaleAspectFill];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackRegistrationScreenView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"SignupDetails"]) {
		SYNIPhoneSignupDetailsViewController *detailsViewController = segue.destinationViewController;
		detailsViewController.firstName = self.firstNameTextField.text;
		detailsViewController.lastName = self.lastNameTextField.text;
		detailsViewController.username = self.usernameTextField.text;
		detailsViewController.avatarImage = self.avatarImageView.image;
	}
}

#pragma mark - IBActions

- (IBAction)backButtonPressed:(UIBarButtonItem *)barButton {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonPressed:(UIBarButtonItem *)barButton {
	[self submitUsername];
}

- (IBAction)photoButtonTapped: (id) sender {
	[[SYNTrackingManager sharedManager] trackAvatarUploadFromScreen:@"Registration"];
	
    self.imagePicker = [[SYNImagePickerController alloc] initWithHostViewController: self];
    self.imagePicker.delegate = self;
    
    [self.imagePicker presentImagePickerAsPopupFromView: nil
                                         arrowDirection: UIPopoverArrowDirectionLeft];
}

#pragma mark - SYNImagePickerControllerDelegate

- (void)picker:(SYNImagePickerController *)picker finishedWithImage:(UIImage *)image {
    self.imagePicker = nil;
	
    self.avatarImageView.image = image;
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
	return UIBarPositionTopAttached;
}

#pragma mark - Private

- (void)submitUsername {
	if (![self validateFirstNameField:self.firstNameTextField errorLabel:self.errorLabel]) {
		return;
	}
	if (![self validateLastNameField:self.lastNameTextField errorLabel:self.errorLabel]) {
		return;
	}
	if (![self validateUsernameField:self.usernameTextField errorLabel:self.errorLabel]) {
		return;
	}

	if ([self.validatedUsernames containsObject:self.usernameTextField.text]) {
		[self performSegueWithIdentifier:@"SignupDetails" sender:self];
		
		return;
	}
	
	UINavigationItem *navigationItem = self.navigationBar.topItem;
	[navigationItem setLeftBarButtonItem:nil animated:YES];
	[navigationItem setRightBarButtonItem:nil animated:YES];
	
	[[SYNLoginManager sharedManager] doRequestUsernameAvailabilityForUsername:self.usernameTextField.text
															completionHandler:^(NSDictionary *result) {
																[navigationItem setLeftBarButtonItem:self.backBarButton animated:YES];
																[navigationItem setRightBarButtonItem:self.nextBarButton animated:YES];
																
																NSNumber *availabilitynumber = result[@"available"];
																
																if (availabilitynumber) {
																	BOOL usernameAvailable = [availabilitynumber boolValue];
																	
																	if (usernameAvailable) {
																		[self.validatedUsernames addObject:self.usernameTextField.text];
																		[self performSegueWithIdentifier:@"SignupDetails" sender:self];

																	} else {
																		self.usernameTextField.errorMode = YES;
																		self.errorLabel.text = NSLocalizedString(@"register_screen_form_field_username_already_taken", nil);
																	}
																} else {
																	NSArray *formErrors = result[@"message"];
																	NSString *errorString = NSLocalizedString(@"unknown_error_message", nil);
																	
																	if (formErrors && [formErrors count] > 0) {
																		errorString = [NSString stringWithFormat: NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Username", nil), formErrors[0]];
																	}
																	
																	self.errorLabel.text = errorString;
																	
																	[navigationItem setRightBarButtonItem:self.nextBarButton animated:YES];
																}
															} errorHandler: ^(NSError *error) {
																[navigationItem setLeftBarButtonItem:self.backBarButton animated:YES];
																[navigationItem setRightBarButtonItem:self.nextBarButton animated:YES];
																
																self.errorLabel.text = NSLocalizedString(@"unknown_error_message", nil);
															}];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(SYNTextFieldLogin *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	textField.errorMode = NO;
	self.errorLabel.text = nil;
	
	NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	if (textField == self.usernameTextField && [newString length] > UsernameMaxLength) {
		return NO;
	}
	
	if ((textField == self.firstNameTextField || textField == self.lastNameTextField)
		&& [newString length] > NameMaxLength) {
		return NO;
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self submitUsername];
	
	return YES;
}

@end
