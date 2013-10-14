//
//  SYNInboxOverlayViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 21/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "GAI.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNFriendsViewController.h"
#import "SYNImagePickerController.h"
#import "SYNMasterViewController.h"
#import "SYNNotificationsTableViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNRockpackNotification.h"
#import "SYNSearchBoxViewController.h"
#import "SYNSideNavigationIphoneCell.h"
#import "SYNSideNavigatorViewController.h"
#import "SYNSoundPlayer.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

#define kSideNavTitle @"kSideNavTitle"
#define kSideNavType @"kSideNavType"
#define kSideNavAction @"kSideNavAction"



typedef void (^SideNavigationMotionBlock)(void);

typedef enum : NSInteger {
    kSideNavigationTypeLoad = 0,
    kSideNavigationTypePage

} kSideNavigationType;

@interface SYNSideNavigatorViewController () <SYNImagePickerControllerDelegate>

@property (nonatomic) NSInteger unreadNotifications;
@property (nonatomic, strong) IBOutlet UIButton* settingsButton;
@property (nonatomic, strong) IBOutlet UIImageView* profilePictureImageView;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) NSArray* navigationData;
@property (nonatomic, strong) NSIndexPath* currentlySelectedIndexPath;
@property (nonatomic, strong) NSMutableArray* notifications;
@property (nonatomic, strong) NSMutableDictionary* cellByPageName;
@property (nonatomic, strong) UIColor* navItemColor;
@property (nonatomic, strong) UIView* bottomExtraView;
@property (nonatomic, strong) UIViewController* currentlyLoadedViewController;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (strong, nonatomic) SYNImagePickerController* imagePickerController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

//iPhone specific
@property (weak, nonatomic) IBOutlet UIImageView *navigationContainerBackgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *navigationContainerTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *navigationContainerView;


@end


@implementation SYNSideNavigatorViewController

// Only need synthesize for custom setters, use latest ObjC naming convention
@synthesize currentlyLoadedViewController = _currentlyLoadedViewController;
@synthesize state = _state;


#pragma mark - Object lifecycle

- (id) init
{
    if ((self = [super initWithNibName: @"SYNSideNavigatorViewController"
                                bundle: nil]))
    {
        self.navigationData = @[
                @{kSideNavTitle: NSLocalizedString(@"core_nav_section_feed", nil),
                   kSideNavType: @(kSideNavigationTypePage),
                 kSideNavAction: kFeedViewId},
                @{kSideNavTitle: NSLocalizedString(@"core_nav_section_channels", nil),
                   kSideNavType: @(kSideNavigationTypePage),
                 kSideNavAction: kChannelsViewId},
                @{kSideNavTitle: NSLocalizedString(@"core_nav_section_profile", nil),
                   kSideNavType: @(kSideNavigationTypePage),
                 kSideNavAction: kProfileViewId},
                @{kSideNavTitle: NSLocalizedString(@"core_nav_section_friends", nil),
                  kSideNavType: @(kSideNavigationTypeLoad),
                  kSideNavAction: @"SYNFriendsViewController"},
                @{kSideNavTitle: NSLocalizedString(@"core_nav_section_notifications", nil),
                   kSideNavType: @(kSideNavigationTypeLoad),
                 kSideNavAction: @"SYNNotificationsTableViewController"}];
        
        _state = SideNavigationStateHidden;
        
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.unreadNotifications = 0;
    }
        
    return self;
}


- (void) dealloc
{
    // Defensive programming
    self.searchViewController.searchBoxView.searchTextField.delegate = nil;
    self.imagePickerController.delegate = nil;
    
    // Stop observing everything (less error-prone than trying to remove observers individually
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - View lifecycle
        
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.userNameLabel.font = [UIFont rockpackFontOfSize: self.userNameLabel.font.pointSize];
    self.nicknameLabel.font = [UIFont rockpackFontOfSize: self.nicknameLabel.font.pointSize];
    
    self.navItemColor = [UIColor colorWithRed: (40.0/255.0)
                                        green: (45.0/255.0)
                                         blue: (51.0/255.0)
                                        alpha: (1.0)];
    
    // Need to init this higher up
    
    if (IS_IPHONE)
    {
        self.searchViewController = [[SYNSearchBoxViewController alloc] init];
    }
    
    if(IS_IOS_7_OR_GREATER)
    {
        CGRect frameToMove;
        frameToMove = self.backgroundImageView.frame;
        frameToMove.size.height += 10.0f;
        self.backgroundImageView.frame = frameToMove;
        
        // move elements down so that the title does not hit the new transparent status bar
        
        NSMutableArray * viewArray = [[NSMutableArray alloc] initWithArray: @[self.tableView, self.containerView,
                                                                              self.avatarButton, self.userNameLabel,
                                                                              self.activityIndicator, self.profilePictureImageView]];
        
        if (IS_IPHONE)
        {
            [viewArray addObjectsFromArray: @[self.settingsButton, self.searchViewController.searchBoxView]];
            
            CGRect nFrame = self.nicknameLabel.frame;
            nFrame.origin.y = 468.0f;
            self.nicknameLabel.frame = nFrame;
        }
        
        for (UIView* viewToMove in viewArray)
        {
            frameToMove = viewToMove.frame;
            frameToMove.origin.y += 10.0f;
            viewToMove.frame = frameToMove;
        }
    }
    
    self.cellByPageName = [NSMutableDictionary dictionaryWithCapacity:3];
    
    CGRect newFrame = self.view.frame;
    
    if (IS_IPHONE)
    {
        newFrame.size.height = [SYNDeviceManager.sharedInstance currentScreenHeight] - 78.0f;
        self.view.frame = newFrame;
        
        CGRect screenBounds = self.view.bounds;
        screenBounds.origin.y += IS_IOS_7_OR_GREATER ? 10.0f : 0.0f;
        
        self.mainContentView.frame = screenBounds;
        self.backgroundImageView.image = [[UIImage imageNamed:@"PanelMenu"] resizableImageWithCapInsets:UIEdgeInsetsMake( 68.0f, 0.0f, 65.0f ,0.0f)];
        
        [self addChildViewController:self.searchViewController];
        [self.view insertSubview:self.searchViewController.view belowSubview:self.navigationContainerView];
        self.searchViewController.searchBoxView.searchTextField.delegate = self;
        [self.searchViewController.searchBoxView.integratedCloseButton addTarget:self action:@selector(closeSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationContainerTitleLabel.font = [UIFont rockpackFontOfSize:self.navigationContainerTitleLabel.font.pointSize];
        
        //Correct Notif / friends screen layouts
        CGRect screenBoundsNavCont = self.view.bounds;
        screenBoundsNavCont.origin.y += IS_IOS_7_OR_GREATER ? 10.0f : 0.0f;
        screenBoundsNavCont.size.height += IS_IOS_7_OR_GREATER ? 10.0f : 0.0f;
        
        self.navigationContainerView.frame = screenBounds;
        
        self.navigationContainerBackgroundImage.image = [[UIImage imageNamed:@"PanelMenuSecondLevel"] resizableImageWithCapInsets:UIEdgeInsetsMake(65, 0, 1, 0)];
    }
    
    else // isIPad == TRUE
    {
        CGFloat bgHeight = (self.backgroundImageView.frame.origin.y + self.backgroundImageView.frame.size.height);
        self.bottomExtraView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                        bgHeight,
                                                                        self.backgroundImageView.frame.size.width,
                                                                        [SYNDeviceManager.sharedInstance currentScreenHeight] - bgHeight)];
        
        self.bottomExtraView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PanelMenuBottom"]];
        
        [self.view insertSubview:self.bottomExtraView belowSubview:self.backgroundImageView];
        
        newFrame.size.height = [SYNDeviceManager.sharedInstance currentScreenHeight];
        self.view.frame = newFrame;
        
        
        

        // == Settings Button == //
        
        CGRect settingsButtonFrame = self.settingsButton.frame;
        settingsButtonFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight] - 26.0 - settingsButtonFrame.size.height;
        self.settingsButton.frame = settingsButtonFrame;
        self.settingsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

        // == User Name Label == //
        
        self.userNameLabel.alpha = 0.0;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notificationMarkedRead:)
                                                 name: kNotificationMarkedRead
                                               object: nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userDataChanged:)
                                                 name: kUserDataChanged
                                               object: nil];
    
    self.tableView.scrollsToTop = NO;
    self.tableView.accessibilityLabel = @"Navigation Table";
    [self getNotifications];
}



#pragma mark - Notifications

- (void) getNotifications
{
    [self.appDelegate.oAuthNetworkEngine notificationsFromUserId: self.appDelegate.currentUser.uniqueId completionHandler: ^(id response) {
                                                   
            if (![response isKindOfClass:[NSDictionary class]])
                return;
                                                   
            NSDictionary* responseDictionary = (NSDictionary*)response;
                                                   
            NSDictionary* notificationsDictionary = responseDictionary[@"notifications"];
            if (!notificationsDictionary)
                return;
                                                   
            NSNumber* totalNumber = notificationsDictionary[@"total"];
            if (!totalNumber)
                return;
        
            NSArray* itemsArray = (NSArray*)notificationsDictionary[@"items"];
            if (!itemsArray)
                return;
        
            NSInteger total = [totalNumber integerValue];
                                                   
            if (total == 0) // good responce but no notifications
            {
                [self.tableView reloadData];
                
                [self.notifications removeAllObjects];
                self.notifications = nil;
                return;
            }
                                                   
            self.notifications = [NSMutableArray arrayWithCapacity: total];
            self.unreadNotifications = 0;
        
            for (NSDictionary* itemData in itemsArray)
            {
                if (![itemData isKindOfClass:[NSDictionary class]]) continue;
                                                       
                SYNRockpackNotification* notification = [SYNRockpackNotification notificationWithDictionary:itemData];
                
                if (!notification || notification.objectType == kNotificationObjectTypeUnknown)
                {
                    continue;
                }
                                                       
                if (!notification.read)
                    self.unreadNotifications++;
                                                       
                [self.notifications addObject:notification];
                                                       
            }
                                                   
            [self.tableView reloadData];
        
        if (self.currentlyLoadedViewController && [self.currentlyLoadedViewController isKindOfClass:[SYNNotificationsTableViewController class]])
        {
            ((SYNNotificationsTableViewController*)self.currentlyLoadedViewController).notifications = self.notifications;
        }
        
    } errorHandler:^(id error) {
        DebugLog(@"Could not load notifications");
    }];
}


- (void) notificationMarkedRead: (NSNotification*) notification
{
    self.unreadNotifications--;
    [self.tableView reloadData];
}


#pragma mark - Button Actions

- (IBAction) settingsButtonPressed: (id) sender
{
        [[NSNotificationCenter defaultCenter] postNotificationName:kAccountSettingsPressed
                                                            object:self];
}
- (IBAction)changeAvatarTapped:(id)sender {
    self.imagePickerController = [[SYNImagePickerController alloc] initWithHostViewController:self];
    self.imagePickerController.delegate = self;
    [self.imagePickerController presentImagePickerAsPopupFromView:sender arrowDirection:UIPopoverArrowDirectionRight];
}


#pragma mark - UITableView Deleagate

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return self.navigationData.count;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"NavigationCell";
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    { 
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            SYNSideNavigationIphoneCell* iPhoneCell = [[SYNSideNavigationIphoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            iPhoneCell.accessoryNumberLabel.hidden = YES;
            iPhoneCell.accessoryNumberBackground.hidden = YES;
            cell = iPhoneCell; 
   
        }
        
        NSDictionary* navigationElement = (NSDictionary*)(self.navigationData)[indexPath.row];
        
        
        kSideNavigationType navigationType = [((NSNumber*)navigationElement[kSideNavType]) integerValue];
        
        // == Type == //
        
        NSString* cellTitle = navigationElement[kSideNavTitle];
        
        if (navigationType == kSideNavigationTypePage)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSString* pageName = navigationElement[kSideNavAction];
            
            (self.cellByPageName)[pageName] = cell;
        }
        else
        {
            if (indexPath.row == kNotificationsRowIndex)
            {

                SYNSideNavigationIphoneCell* iPhoneCell = (SYNSideNavigationIphoneCell*)cell;
                
                if (self.unreadNotifications > 0)
                {
                    [iPhoneCell setAccessoryNumber:[NSString stringWithFormat: @"%i",self.unreadNotifications]];
                    iPhoneCell.accessoryNumberLabel.hidden = NO;
                    iPhoneCell.accessoryNumberBackground.hidden = NO;
                }
                else
                {
                    iPhoneCell.accessoryNumberLabel.hidden = YES;
                    iPhoneCell.accessoryNumberBackground.hidden = YES;
                }

                iPhoneCell.accessoryView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"NavArrow"]];
                    
            }
            else
            {
                SYNSideNavigationIphoneCell* iPhoneCell = (SYNSideNavigationIphoneCell*)cell;
                iPhoneCell.accessoryView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"NavArrow"]];
            }
        }
        
        // == Title == //

        cell.textLabel.text = cellTitle;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
    }
    
    return cell;
}

-(void)openToIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* previousSelectedCell = [self.tableView cellForRowAtIndexPath: self.currentlySelectedIndexPath];
    [previousSelectedCell setSelected: NO];
    
    self.currentlySelectedIndexPath = indexPath;
    
    NSDictionary* navigationElement = (NSDictionary*)(self.navigationData)[indexPath.row];
    kSideNavigationType navigationType = [((NSNumber*)navigationElement[kSideNavType]) integerValue];
    NSString* navigationAction = (NSString*)navigationElement[kSideNavAction];
    
    if (navigationType == kSideNavigationTypeLoad)
    {
        Class theClass = NSClassFromString(navigationAction);
        self.currentlyLoadedViewController = (UIViewController*)[[theClass alloc] init];
        
        // == NOTIFICATIONS == //
        if (indexPath.row == kNotificationsRowIndex)
        {
            ((SYNNotificationsTableViewController*)self.currentlyLoadedViewController).notifications = self.notifications;
            self.navigationContainerTitleLabel.text = NSLocalizedString(@"core_nav_section_notifications",nil);
        }
        else if (indexPath.row == kFriendsRowIndex)
        {
            self.navigationContainerTitleLabel.text = NSLocalizedString(@"core_nav_section_friends",nil);
            if(IS_IPHONE)
            {
                SYNFriendsViewController* friendsController = (SYNFriendsViewController*) self.currentlyLoadedViewController;
                [friendsController addSearchBarToView:self.navigationContainerView];
            }
            
        }
        
        
        if (IS_IPAD)
        {
            CGRect frameThatFits = self.currentlyLoadedViewController.view.frame;
            frameThatFits.size.width = self.containerView.frame.size.width;
            frameThatFits.size.height = self.containerView.frame.size.height - 10.0;
            self.currentlyLoadedViewController.view.frame = frameThatFits;
        }
        else if (IS_IPHONE)
        {
            CGRect frameThatFits = self.currentlyLoadedViewController.view.frame;
            frameThatFits.size.width = self.containerView.frame.size.width;
            if(IS_IOS_7_OR_GREATER)
            {
                frameThatFits.origin.y = -10.0f;
                frameThatFits.size.height += 10;
            }
            else
            {
                
                frameThatFits.size.height = self.containerView.frame.size.height - 6.0;
            }
            
            self.currentlyLoadedViewController.view.frame = frameThatFits;
        }
        self.state = SideNavigationStateFull;
        
    }
    else // the selection is a notification for the container to change pages
    {
        
        NSNotification* navigationNotification = [NSNotification notificationWithName: kNavigateToPage
                                                                               object: self
                                                                             userInfo: @{@"pageName":navigationAction}];
        
        [[NSNotificationCenter defaultCenter] postNotification: navigationNotification];
        
        
    }
}


- (void) tableView: (UITableView *) tableView
        didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    [self openToIndexPath:indexPath];
}


- (void) tableView: (UITableView *) tableView
   willDisplayCell: (UITableViewCell *) cell
 forRowAtIndexPath: (NSIndexPath *) indexPath
{
    if ([indexPath isEqual: self.currentlySelectedIndexPath])
    {
        [cell setSelected: YES];
    }
}


#pragma mark - Accessor Methods

- (void) setUser: (User *) user
{
    _user = user;
    NSString* fullname = user.fullName;
    
    if ([fullname length]>1)
    {
        self.userNameLabel.text = self.user.fullName;
        self.nicknameLabel.text = self.user.username;
    }
    else
    {
        self.userNameLabel.text = self.user.username;
        self.nicknameLabel.text = @"";
    }
    
    if (!self.profilePictureImageView.image)
    {
        self.profilePictureImageView.image = [UIImage imageNamed:@"PlaceholderSidebarAvatar"];
    }
    
    // We can't use our standard asynchronous loader due to cacheing    
  
    dispatch_queue_t downloadQueue = dispatch_queue_create("com.rockpack.avatarloadingqueue", NULL);
    dispatch_async(downloadQueue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString: self.user.thumbnailURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imageData)
            {
                self.profilePictureImageView.image = [UIImage imageWithData: imageData];
            }
        });
    });
}


- (void) setSelectedCellByPageName: (NSString*) pageName
{
    self.keyForSelectedPage = pageName;
    UITableViewCell* cellSelected = (UITableViewCell*)(self.cellByPageName)[pageName];
    
    if (!cellSelected)
        return;
    
    NSInteger row = 0;
    for (UITableViewCell* cell in [self.cellByPageName allValues])
    {
        if (cellSelected == cell) {
            [cell setSelected:YES];
            self.currentlySelectedIndexPath = [NSIndexPath indexPathForRow: row inSection: 0];
        }
        else {
            [cell setSelected:NO];
        }
        
        row++;
            
    }
    
    
}


- (void) deselectAllCells
{
    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        for (int row = 0; row < [self.tableView numberOfRowsInSection: section]; row++)
        {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow: row
                                                       inSection: section];
            
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath: cellPath];
            [cell setSelected: NO];
        }
    }
    self.currentlySelectedIndexPath = nil;
}

- (void) setCurrentlyLoadedViewController: (UIViewController *) currentlyLoadedVC
{
    if (self.currentlyLoadedViewController)
    {
        [self.currentlyLoadedViewController removeFromParentViewController];
        [self.currentlyLoadedViewController.view removeFromSuperview];
    }
    
    _currentlyLoadedViewController = currentlyLoadedVC;
    
    // Bail out if setting to nil
    if (!self.currentlyLoadedViewController)
        return;
    
    if (IS_IPHONE)
    {
        // iPhone specific
        CGSize containerSize = self.containerView.frame.size;
        CGRect vcRect = self.currentlyLoadedViewController.view.frame;
        vcRect.origin.x = 0.0;
        vcRect.origin.y = 2.0;
        vcRect.size = containerSize;
        self.currentlyLoadedViewController.view.frame = vcRect;

    }
    else
    {
        // iPad
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        
        CGSize containerSize = CGSizeMake(self.containerView.frame.size.width, screenHeight - 82.0);
        CGRect vcRect = self.currentlyLoadedViewController.view.frame;
        vcRect.origin.x = 0.0;
        vcRect.origin.y = 2.0;
        vcRect.size = containerSize;
        self.currentlyLoadedViewController.view.frame = vcRect;
    }

    
    [self.containerView addSubview: self.currentlyLoadedViewController.view];
    [self addChildViewController:self.currentlyLoadedViewController];
}


- (void) reset
{
    self.currentlySelectedIndexPath = nil;
    
    if (IS_IPHONE)
    {
        CGRect startFrame = self.navigationContainerView.frame;
        startFrame.origin.x = self.view.frame.size.width;
        self.navigationContainerView.frame = startFrame;
        self.currentlyLoadedViewController = nil;
    }
    
}


#pragma mark - Orientation Change

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    CGFloat correctHeight = [SYNDeviceManager.sharedInstance currentScreenHeight];
    
    CGRect newFrame = self.view.frame;
    newFrame.size.height = correctHeight;
    self.view.frame = newFrame;
    
    
    CGRect bottomExtraFrame = self.bottomExtraView.frame;
    bottomExtraFrame.size.height = correctHeight - bottomExtraFrame.origin.y;
    
    self.bottomExtraView.frame = bottomExtraFrame;
    
    CGRect settingsButtonFrame = self.settingsButton.frame;
    settingsButtonFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight] - 30.0 - settingsButtonFrame.size.height;
    self.settingsButton.frame = settingsButtonFrame;
    
    // FIXME: ???
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        
        
    }
    else
    {
        
        
    } 
}


#pragma mark - UITextFieldDelegate - iphone specific

- (BOOL) textFieldShouldBeginEditing: (UITextField *) textField
{
    
    [self.appDelegate.viewStackManager presentSearchBar];
    
    return YES;
}



#pragma mark - close search callback iPhone specific

- (void) closeSearch: (id) sender
{
    
    [self.appDelegate.viewStackManager dismissSearchBar];
}


#pragma mark - Accessor & Animation

-(void) setState:(SideNavigationState)state animated:(BOOL)animated
{
    
    
    if (state == _state) return;
    
    _state = state;
    
    switch (_state)
    {
        case SideNavigationStateHidden:
            [self showHiddenNavigationAnimated:animated];
            break;
            
        case SideNavigationStateHalf:
            [self showHalfNavigationAnimated:animated];
            [self getNotifications];
            break;
            
        case SideNavigationStateFull:
            [self showFullNavigation];
            break;
    }
    
}

- (void) setState: (SideNavigationState) state
{
    [self setState:state animated:YES];
}


- (void) showHalfNavigationAnimated:(BOOL)animated
{
    // Light up navigation button
    self.captiveButton.selected = TRUE;
    
    [[SYNSoundPlayer sharedInstance] playSoundByName: kSoundNewSlideIn];
    self.mainContentView.alpha = 1.0f;
    if(IS_IPHONE)
    {
        [self.view insertSubview:self.searchViewController.searchBoxView belowSubview:self.navigationContainerView];
        self.searchViewController.searchBoxView.searchTextField.text = @"";
        self.searchViewController.searchBoxView.searchTextField.delegate = self;
        [self.searchViewController.searchBoxView resignFirstResponder];
        [self.searchViewController.searchBoxView hideCloseButton];
    }
    
    SideNavigationMotionBlock motionBlock = ^{
        CGRect sideNavigationFrame = self.view.frame;
        if (IS_IPAD)
        {
            sideNavigationFrame.origin.x = 1024.0 - 192.0;
            self.userNameLabel.alpha = 0.0;
        }
        else
        {
            sideNavigationFrame.origin.x = 704.0f;
        }
        self.view.frame = sideNavigationFrame;
    };
    
    if(animated)
    {
        [UIView animateWithDuration: kRockieTalkieAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations: motionBlock
                         completion:^(BOOL finished) {
                             // check for on boarding
                             [self checkAndDisplayOnBoarding];
                         }];
    }
    else
    {
        motionBlock();
    }
    
}

- (void) checkAndDisplayOnBoarding
{
    
    
}

- (void) showFullNavigation
{
    // Light up navigation button
    self.captiveButton.selected = TRUE;
    
    if (IS_IPAD)
    {
        [UIView animateWithDuration: 0.4f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations: ^{
                             CGRect sideNavigationFrame = self.view.frame;
                             
                             sideNavigationFrame.origin.x = 1024.0 - self.view.frame.size.width;
                             self.view.frame =  sideNavigationFrame;
                             
                             self.userNameLabel.alpha = 1.0;
                         }
                         completion: nil];
    }
    else
    {
        CGRect startFrame = self.navigationContainerView.frame;
        startFrame.origin.x = self.view.frame.size.width;
        self.navigationContainerView.frame = startFrame;
        self.navigationContainerView.hidden = NO;
        self.navigationContainerView.alpha = 1.0f;
        [self.view insertSubview:self.navigationContainerView aboveSubview: self.searchViewController.view];
        
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             CGRect selfBounds = self.view.bounds;
                             selfBounds.origin.y = self.navigationContainerView.frame.origin.y;
                             self.navigationContainerView.frame = selfBounds;
                         }
                         completion: nil];
    }
}


- (void) showHiddenNavigationAnimated:(BOOL)animated
{
    // Turn off button highlighting
    self.captiveButton.selected = FALSE;
    
    self.darkOverlay.alpha = 1.0;
    
    SideNavigationMotionBlock motionBlock = ^{
        
        self.darkOverlay.alpha = 0.0;
        
        CGRect sideNavigationFrame = self.view.frame;
        sideNavigationFrame.origin.x = 1024;
        self.view.frame =  sideNavigationFrame;
        
    };
    
    void(^completionBlock)(BOOL) = ^(BOOL finished) {
      
        self.darkOverlay.hidden = YES;
        [self reset];
        [self deselectAllCells];
        
    };
    
    
    if(animated)
    {
        [[SYNSoundPlayer sharedInstance] playSoundByName: kSoundNewSlideOut];
        
        [UIView animateWithDuration: 0.2f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations: motionBlock
                         completion:completionBlock];
    }
    else
    {
        motionBlock();
        completionBlock(YES);
    }
    

}

#pragma mark - Notification Handlers



- (void) userDataChanged: (NSNotification*) notification
{
    [self setUser: self.appDelegate.currentUser];
}


#pragma mark - iPhone navigate back from notifications
- (IBAction) navigateBackTapped: (id) sender
{
    [self deselectAllCells];
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         self.state = SideNavigationStateHalf;
                         CGRect startFrame = self.navigationContainerView.frame;
                         startFrame.origin.x = self.view.frame.size.width;
                         self.navigationContainerView.frame = startFrame;
                         
                     }
                     completion: ^(BOOL finished) {
                         self.currentlyLoadedViewController = nil;
                     }];
}

#pragma mark - image picker delegate

- (void) picker: (SYNImagePickerController *) picker
         finishedWithImage: (UIImage *) image
{
//    DebugLog(@"Orign image width: %f, height%f", image.size.width, image.size.height);
    self.avatarButton.enabled = NO;
    self.profilePictureImageView.image = image;
    [self.activityIndicator startAnimating];
    [self.appDelegate.oAuthNetworkEngine updateAvatarForUserId: self.appDelegate.currentOAuth2Credentials.userId
                                                         image: image
                                             completionHandler: ^(NSDictionary* result)
     {
//         self.profilePictureImageView.image = image;
         [self.activityIndicator stopAnimating];
         self.avatarButton.enabled = YES;
     }
                                                  errorHandler: ^(id error)
     {
         [self.profilePictureImageView setImageWithURL: [NSURL URLWithString: self.user.thumbnailURL]
                                      placeholderImage: [UIImage imageNamed: @"PlaceholderSidebarAvatar"]
                                               options: SDWebImageRetryFailed];
         
         [self.activityIndicator stopAnimating];
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


#pragma mark - Push notification support

- (void) displayFromPushNotification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: kNotificationsRowIndex
                                                inSection: 0];
    
    [self.tableView selectRowAtIndexPath: indexPath
                                animated: YES
                          scrollPosition: UITableViewScrollPositionNone];
    
    [self tableView: self.tableView didSelectRowAtIndexPath: indexPath];
}

@end
