//
//  SYNUserProfileViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 12/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAppDelegate.h"
#import "SYNImagePickerController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNUserProfileViewController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "User.h"

@interface SYNUserProfileViewController () <SYNImagePickerControllerDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) IBOutlet UIButton* avatarButton;
@property (nonatomic, strong) SYNImagePickerController* imagePickerController;

@end


@implementation SYNUserProfileViewController

#pragma mark - Object lifecycle

- (void) dealloc
{
    // Defensive programming
    self.imagePickerController.delegate = nil;
    
    // Stop observing everything (less error-prone than trying to remove observers individually
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.fullNameLabel.font = [UIFont boldRockpackFontOfSize:30];
    self.userNameLabel.font = [UIFont rockpackFontOfSize:12.0];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userDataChanged:)
                                                 name: kUserDataChanged
                                               object: nil];
    
    [self pack];
}


- (void) userDataChanged: (NSNotification*) notification
{
    User* currentUser = (User*)[notification userInfo][@"user"];
    if(!currentUser)
        return;
    
    if ([self.channelOwner.uniqueId isEqualToString: currentUser.uniqueId])
    {
        [self setChannelOwner: currentUser];
    }
}


- (void) pack
{
    if (IS_IPHONE)
    {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineHeightMultiple: 1.0f];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString: self.fullNameLabel.text];
        
        [attString addAttribute: NSParagraphStyleAttributeName
                          value: style
                          range: NSMakeRange(0, self.fullNameLabel.text.length)];
        
        self.fullNameLabel.font = [UIFont rockpackFontOfSize:17.0f];
        [self.fullNameLabel removeFromSuperview];
        self.fullNameLabel.frame = CGRectMake(42.0f, 0.0f, 150, 34);
        self.fullNameLabel.attributedText = attString;
        [self.fullNameLabel sizeToFit];
        
        
        CGRect newFrame = self.view.frame;
        newFrame.size.width = 44.0f + self.fullNameLabel.frame.size.width;
        
        self.view.frame = newFrame;
        
        [self.view addSubview:self.fullNameLabel];
        
        self.fullNameLabel.center = CGPointMake(44.0f + self.fullNameLabel.frame.size.width/2.0f, 19.0f);
        
    }
    else
    {
        CGSize maxSize = [self.fullNameLabel.text sizeWithFont:self.fullNameLabel.font];
        CGRect selfFrame = self.view.frame;
        if (maxSize.width + self.fullNameLabel.frame.origin.x > selfFrame.size.width)
        {
            selfFrame.size.width = maxSize.width + self.fullNameLabel.frame.origin.x + 30.0;
            self.view.frame = selfFrame;
        }
        
        CGRect textRect = CGRectZero;
        textRect.size = [self.fullNameLabel.text sizeWithFont: self.fullNameLabel.font];
        CGRect referenceRect = self.profileImageView.frame;
        textRect.origin = CGPointMake(referenceRect.origin.x + referenceRect.size.width + 10.0,
                                      referenceRect.origin.y + 10.0);
        self.fullNameLabel.frame = textRect;
        
        textRect.origin = CGPointMake(textRect.origin.x,
                                      textRect.origin.y + textRect.size.height + 5.0f);
        textRect.size = [self.userNameLabel.text sizeWithFont: self.userNameLabel.font];
        
        self.userNameLabel.frame = textRect;
    }
}


- (void) setChannelOwner: (ChannelOwner*) channelOwner
{
    _channelOwner = channelOwner;
    
    NSString* userName;
    if ([channelOwner isKindOfClass:[User class]])
    {
        User* ownerAsUser = (User*)channelOwner;
        if (ownerAsUser.fullNameIsPublicValue)
        {
            userName = ownerAsUser.fullName;
        }
        
        if (userName.length < 1)
        {
            userName = ownerAsUser.username;
        }

        // Enable change avatar button
        self.avatarButton.enabled = TRUE;
    }
    else
    {
        userName = channelOwner.displayName;
        
        // Disable change avatar button
        self.avatarButton.enabled = FALSE;
    }
    
    self.userNameLabel.text = channelOwner.username;
    self.fullNameLabel.text = userName;
    
    UIImage* placeholderImage = [UIImage imageNamed: @"PlaceholderAvatarProfile"];
    
    if (![channelOwner.thumbnailURL isEqualToString:@""]) // there is a url string
    {
        NSArray *thumbnailURLItems = [channelOwner.thumbnailURL componentsSeparatedByString:@"/"];
        
        // whatever is set to be the default size by the server (ex. 'thumbnail_small') //
        if (thumbnailURLItems.count >= 5)
        {
            NSString* thumbnailSizeString = thumbnailURLItems[5];
            
            
            NSString* thumbnailUrlString = [channelOwner.thumbnailURL stringByReplacingOccurrencesOfString:thumbnailSizeString withString:@"thumbnail_medium"];

            // We can't use our standard asynchronous loader due to cacheing
            dispatch_queue_t downloadQueue = dispatch_queue_create("com.rockpack.avatarloadingqueue", NULL);
            dispatch_async(downloadQueue, ^{
                
                NSData * imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString: thumbnailUrlString]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.self.profileImageView.image = [UIImage imageWithData: imageData];
                });
            });
        }
        else
        {
            self.profileImageView.image = placeholderImage;
        }
    }
    else
    {
        self.profileImageView.image = placeholderImage;
    }

    [self pack];
}


- (IBAction) userTouchedAvatarButton: (UIButton *) avatarButton
{
    self.imagePickerController = [[SYNImagePickerController alloc] initWithHostViewController: self];
    self.imagePickerController.delegate = self;
    
    [self.imagePickerController presentImagePickerAsPopupFromView: avatarButton
                                                   arrowDirection: UIPopoverArrowDirectionRight];
}


#pragma mark - image picker delegate

- (void) picker: (SYNImagePickerController *) picker
         finishedWithImage: (UIImage *) image
{
    SYNAppDelegate *appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.avatarButton.enabled = NO;
    self.profileImageView.image = image;
    [self.activityIndicatorView startAnimating];
    [appDelegate.oAuthNetworkEngine updateAvatarForUserId: appDelegate.currentOAuth2Credentials.userId
                                                    image: image
                                        completionHandler: ^(NSDictionary* result)
     {
         //         self.profilePictureImageView.image = image;
         [self.activityIndicatorView stopAnimating];
         self.avatarButton.enabled = YES;
     }
                                             errorHandler: ^(id error)
     {
         [self.profileImageView setImageWithURL: [NSURL URLWithString: self.channelOwner.thumbnailURL]
                               placeholderImage: [UIImage imageNamed: @"PlaceholderNotificationAvatar"]
                                        options: SDWebImageRetryFailed];
         
         [self.activityIndicatorView stopAnimating];
         self.avatarButton.enabled = YES;
         
         UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"register_screen_form_avatar_upload_title",nil)
                                                         message: NSLocalizedString(@"register_screen_form_avatar_upload_description",nil)
                                                        delegate: nil
                                               cancelButtonTitle: nil
                                               otherButtonTitles: NSLocalizedString(@"OK",nil), nil];
         [alert show];
     }];
    
    self.imagePickerController = nil;
}

@end
