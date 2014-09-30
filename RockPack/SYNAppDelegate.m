//
//  SYNAppDelegate.m
//  RockPack
//
//  Created by Nick Banks on 12/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Appirater.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "ExternalAccount.h"
#import "NSObject+Blocks.h"
#import "SYNActivityManager.h"
#import "SYNAppDelegate.h"
#import "SYNContainerViewController.h"
#import "SYNDeviceManager.h"
#import "SYNFacebookManager.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "SYNLoginManager.h"
#import "SYNOnBoardingViewController.h"
#import "UIViewController+PresentNotification.h"
#import "SYNOnBoardingOverlayViewController.h"
#import "SYNTrackingManager.h"
#import "SYNYouTubeWebView.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ACTReporter.h>
#import <TestFlight.h>
#import <sqlite3.h>
#import "SYNGenreManager.h"
#import "SYNLocationManager.h"
#import "SYNAppearanceManager.h"
#import "SYNFeedModel.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNRemoteLogger.h"
#import "SYNAddEmailAlertView.h"
#import "SYNFeedRootViewController.h"


@import AVFoundation;

@interface SYNAppDelegate () {
    BOOL enteredAppThroughNotification;
    BOOL refetchUserData;
}

@property (nonatomic, strong) NSManagedObjectContext *channelsManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *privateManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *searchManagedObjectContext;
@property (nonatomic, strong) NSString *apnsToken;
@property (nonatomic, strong) NSString *rockpackURL;
@property (nonatomic, strong) NSString *userAgentString;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) SYNChannelManager *channelManager;
@property (nonatomic, strong) UIViewController *loginViewController;
@property (nonatomic, strong) SYNMasterViewController *masterViewController;
@property (nonatomic, strong) SYNNetworkEngine *networkEngine;
@property (nonatomic, strong) SYNOAuthNetworkEngine *oAuthNetworkEngine;
@property (nonatomic, strong) SYNVideoQueue *videoQueue;
@property (nonatomic, strong) SYNNavigationManager* navigationManager;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSURL *pendingOpenURL;

@end


@implementation SYNAppDelegate

// Required, as we are providing both getter and setter
@synthesize  currentOAuth2Credentials = _currentOAuth2Credentials;

- (BOOL) application: (UIApplication *) application
         didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
#ifdef ENABLE_USER_RATINGS
    [Appirater setAppId:APP_ID];
    [Appirater setDaysUntilPrompt: 1];
    [Appirater setUsesUntilPrompt: 2];
    [Appirater setTimeBeforeReminding: 10];
    //[Appirater setDebug: YES];
#endif
    
    // Google Adwords conversion tracking.
	[ACTConversionReporter reportWithConversionID:@"983664386"
											label:@"Km3nCP6G-wQQgo6G1QM"
											value:@"0"
									 isRepeatable:NO];
    
    // We need to set the audio session so that that app will continue to play audio even if the mute switch is on
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
	
    if (![audioSession setCategory: AVAudioSessionCategoryPlayback
                             error: &setCategoryError])
    {
        DebugLog(@"Error setting AVAudioSessionCategoryPlayback: %@", setCategoryError);
    }
	
	[SYNAppearanceManager setupGlobalAppAppearance];
    
    // Se up CoreData //
    [self initializeCoreDataStack];
    
    // Video Queue View Controller //
    self.videoQueue = [SYNVideoQueue queue];
    
    // Subscriptions Manager //
    self.channelManager = [SYNChannelManager manager];
    
    [SYNYouTubeWebView setup];
	
	[[SYNLocationManager sharedManager] updateLocationWithCompletion:^(NSString *location) {
		if (self.currentUser) {
			[[SYNGenreManager sharedManager] fetchGenresWithCompletion:nil];
		}
	}];
	
    // Video Queue View Controller //
    self.navigationManager = [SYNNavigationManager manager];
    
    // Network Engine //
    [self initializeNetworkEngines];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loginCompleted:)
                                                 name: kLoginCompleted
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onBoardingCompleted:)
                                                 name: kOnboardingCompleted
                                               object: nil];

    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
    [TestFlight addCustomEnvironmentInformation:[NSString stringWithFormat:@"Current User: %@", self.currentUser.username] forKey:@"User Name"];
    [TestFlight takeOff: kTestFlightAppToken];
	
	[[SYNTrackingManager sharedManager] setup];
	[[SYNTrackingManager sharedManager] setLocaleDimension:[NSLocale currentLocale]];
    
    SYNOAuth2Credential *credential = [SYNOAuth2Credential credentialFromKeychainForService: [[NSBundle mainBundle] bundleIdentifier]
                                                                                    account: self.currentUser.uniqueId];
	
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"didFinishLaunchingWithOptions: Starting app in state: %d",
                                         application.applicationState]];
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"didFinishLaunchingWithOptions: Protected data available: %d",
                                         application.protectedDataAvailable]];
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"didFinishLaunchingWithOptions: Current username: (%@) %@",
                                         self.currentUser.uniqueId, self.currentUser.username]];
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"didFinishLaunchingWithOptions: Credentials from keychain: %@",
                                         credential]];
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"didFinishLaunchingWithOptions: Current credentials: %@",
                                         self.currentOAuth2Credentials]];
	
    if (self.currentUser && self.currentOAuth2Credentials)
    {
		[[SYNTrackingManager sharedManager] setAgeDimensionFromBirthDate:self.currentUser.dateOfBirth];
		[[SYNTrackingManager sharedManager] setGenderDimension:self.currentUser.genderValue];
		
        // If we have a user and a refresh token... //
        if ([self.currentOAuth2Credentials hasExpired])
        {
			[[SYNRemoteLogger sharedLogger] log:@"didFinishLaunchingWithOptions: Token refresh"];
            [self refreshExpiredTokenOnStartup];
        }
        else // we have an access token //
        {
            // set timer for auto refresh //
            
            [self setTokenExpiryTimer];
            
            [self refreshUserData];
            
            self.window.rootViewController = [self createAndReturnRootViewController];
            
            
            if ([self.window.rootViewController isKindOfClass:[SYNMasterViewController class]]) {
                [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"didFinishLaunchingWithOptions: Controller with credentials: %@",
                                                     self.masterViewController.showingViewController]];
            } else {
                [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"didFinishLaunchingWithOptions: Controller with credentials: %@",
                                                     NSStringFromClass([self.window.rootViewController class])]];
            }

        }
    }
    else
    {
        if ((self.currentUser || self.currentOAuth2Credentials) && application.protectedDataAvailable)
        {
			[[SYNRemoteLogger sharedLogger] log:@"didFinishLaunchingWithOptions: Logging the user out"];
			
            [self logout];
        }
        
        if (application.applicationState != UIApplicationStateBackground) {
            self.window.rootViewController = [self createAndReturnLoginViewController];
        }
        
        if ([self.window.rootViewController isKindOfClass:[SYNMasterViewController class]]) {
            [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"didFinishLaunchingWithOptions: Controller without credentials: %@",
                                                 self.masterViewController.showingViewController]];
        } else {
            [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"didFinishLaunchingWithOptions: Controller without credentials: %@",
                                                 NSStringFromClass([self.window.rootViewController class])]];
        }
    }
    
#ifdef ENABLE_USER_RATINGS
    [Appirater appLaunched: YES];
#endif
    
    if (launchOptions != nil)
    {
        NSDictionary* userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
		
        if (userInfo != nil)
        {
            DebugLog(@"Launched from push notification: %@", userInfo);
			[self handleRemoteNotification: userInfo];
        }
    }
    
    return YES;
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application
{
    // Save any credentials that could have been refreshed while the device was locked.
    if (_currentOAuth2Credentials) {
        [_currentOAuth2Credentials saveToKeychainForService: [[NSBundle mainBundle] bundleIdentifier]
                                                    account: _currentOAuth2Credentials.userId];
    }
}

- (void) refreshUserData
{
    // Re-fetch data for current user
    if (refetchUserData) {
        [self.oAuthNetworkEngine retrieveAndRegisterUserFromCredentials: self.currentOAuth2Credentials
         completionHandler: ^(NSDictionary* dictionary) {
             refetchUserData = NO;
             if ([self.currentUser.uniqueId isEqualToString: dictionary[@"id"]]) {
                 // reset cached property but don't remove the old coredata record
                 _currentUser.currentValue = NO;
                 [self saveContext:YES];
                 _currentUser = nil;
             }
             [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"Refetched user data: %@", self.currentUser]];
         }
         errorHandler: ^(NSError *error) {
             [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"Failed to refetch user data: %@", error]];
         }];
    }

    [self refreshFacebookSession];
}

- (void) refreshFacebookSession
{
    // link to facebook

    if (self.currentUser.facebookAccount)
    {
        if (!FBSession.activeSession.isOpen && FBSession.activeSession.accessTokenData)
        {
            [FBSession.activeSession
             openWithCompletionHandler: ^(FBSession *session, FBSessionState status, NSError *error) {
                 DebugLog(@"*** Complete! %@", session);
             }];
        }
        else
        {
            
            [self.oAuthNetworkEngine getExternalAccountForUrl: self.currentUser.facebookAccount.url
                                            completionHandler: ^(id response)
             {
                 NSDictionary *external_accounts = response[@"external_accounts"];
                 if(![external_accounts isKindOfClass:[NSDictionary class]])
                     return;
                 
                 [self.currentUser setExternalAccountsFromDictionary:external_accounts];
                 
                 if (self.currentUser.facebookAccount)
                 {
                     [[SYNFacebookManager sharedFBManager] openSessionFromExistingToken: self.currentUser.facebookAccount.token
                                                                              onSuccess: ^{
                                                                              }
                                                                              onFailure: ^(NSString *errorMessage) {
                                                                              }];
                 }
             } errorHandler: ^(id error) {
             }];
        }
    }
}


- (void) setTokenExpiryTimer
{
    if (self.tokenExpiryTimer)
    {
        [self.tokenExpiryTimer invalidate];
    }
    
    NSTimeInterval intervalToExpiry = [self.currentOAuth2Credentials.expirationDate timeIntervalSinceNow];
    
    self.tokenExpiryTimer = [NSTimer scheduledTimerWithTimeInterval: intervalToExpiry
                                                             target: self
                                                           selector: @selector(refreshExpiredToken)
                                                           userInfo: nil
                                                            repeats: NO];
}


- (void) refreshExpiredTokenOnStartup
{
    //Add imageview to the window as placeholder while we wait for the token refresh call.
    [self.tokenExpiryTimer invalidate];
    
    UIImageView *startImageView = nil;
    CGPoint startImageCenter = self.window.center;
    
    if (IS_IPAD)
    {
        if (UIDeviceOrientationIsLandscape([[SYNDeviceManager sharedInstance] currentOrientation]))
        {
            startImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Default-Landscape"]];
            
            if ([[SYNDeviceManager sharedInstance] currentOrientation] == UIDeviceOrientationLandscapeLeft)
            {
                startImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
                startImageCenter.x -= 10;
            }
            else
            {
                startImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                startImageCenter.x += 10;
            }
        }
        else
        {
            startImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Default-Portrait"]];
            startImageCenter.y += 10;
        }
    }
    else
    {
        if ([SYNDeviceManager.sharedInstance currentScreenHeight] > 480.0f)
        {
            startImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Default-568h"]];
        }
        else
        {
            startImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Default"]];
        }
    }
    
    [self.window addSubview: startImageView];
    
    startImageView.center = startImageCenter;

    
    //refresh token
    [self.oAuthNetworkEngine refreshOAuthTokenWithCompletionHandler: ^(id response) {
        
        if (!self.window.rootViewController)
        {
            self.window.rootViewController = [self createAndReturnRootViewController];
        }
        
        self.tokenExpiryTimer = nil;
        
        [self refreshUserData];
        [startImageView removeFromSuperview];
    } errorHandler: ^(id response) {
        DebugLog(@"Failed to refresh token");
        if (!self.window.rootViewController)
        {
            self.window.rootViewController = [self createAndReturnRootViewController];
        }
        [startImageView removeFromSuperview];
    }];
}


- (void) refreshExpiredToken
{
    [self.tokenExpiryTimer invalidate];
    
    self.tokenExpiryTimer = nil;
    
    [self.oAuthNetworkEngine
     refreshOAuthTokenWithCompletionHandler: ^(id response) {
     }
     errorHandler: ^(id response) {
        DebugLog(@"Failed to refresh token");
     }];
}


- (UIViewController *) createAndReturnRootViewController
{
    SYNContainerViewController *containerViewController = [[SYNContainerViewController alloc] init];
    
    self.masterViewController = [[SYNMasterViewController alloc] initWithContainerViewController: containerViewController];
    
    // whenever you pass the login screen you must reregister
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)];
    
    return self.masterViewController;
}


- (UIViewController *) createAndReturnLoginViewController
{
    if (IS_IPAD)
    {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login_ipad" bundle:nil];
		self.loginViewController = [storyboard instantiateInitialViewController];
    }
    else
    {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login_iphone" bundle:nil];
		self.loginViewController = [storyboard instantiateInitialViewController];
    }
    
    return self.loginViewController;
}


- (void) logout
{
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"Logging out, call stack: %@", [NSThread callStackSymbols]]];
	
    // As we are logging out, we need to unregister the current user (the new user will be re-registered on login below)
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
	
	[[SYNFeedModel sharedModel] reset];
    
    self.masterViewController = nil;
    
    [self.currentOAuth2Credentials removeFromKeychain];
    
    [self.tokenExpiryTimer invalidate];
    self.tokenExpiryTimer = nil;
    
    [[SYNFacebookManager sharedFBManager] logoutOnSuccess: ^{
    }
                                                onFailure: ^(NSString *errorMessage) {
                                                }];
    
    self.currentOAuth2Credentials = nil;
    
    _currentUser = nil;
    
    [self nukeCoreData];
	
    self.window.rootViewController = [self createAndReturnLoginViewController];
}


- (void)loginCompleted:(NSNotification *)notification {
	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
	[[SYNTrackingManager sharedManager] setAgeDimensionFromBirthDate:self.currentUser.dateOfBirth];
	[[SYNTrackingManager sharedManager] setGenderDimension:self.currentUser.genderValue];
	[SYNActivityManager.sharedInstance updateActivityForCurrentUserWithReset:YES];
	
	[[SYNGenreManager sharedManager] fetchGenresWithCompletion:nil];
	
	if ([SYNLoginManager sharedManager].registrationCheck) {
		self.window.rootViewController = [[SYNOnBoardingViewController alloc] init];
	} else {
		self.window.rootViewController = [self createAndReturnRootViewController];
	}
	
	self.loginViewController = nil;
}


- (void)onBoardingCompleted: (NSNotification *)notification {
    
    UIViewController* mvc = [self createAndReturnRootViewController];
    
    self.window.rootViewController = mvc;
    
    [mvc presentNotificationWithMessage: NSLocalizedString(@"We are building your feed", nil)
                                andType:NotificationMessageTypeSuccess];
}

#pragma mark - App Delegate Methods

// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
- (void) applicationWillResignActive: (UIApplication *) application
{
    // We need to save out database here (not in background)
    [self saveContext: kSaveSynchronously];
}


// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
- (void) applicationDidEnterBackground: (UIApplication *) application
{
    // We need to save out database here (not in background)
    [self saveContext: kSaveSynchronously];
    [self.tokenExpiryTimer invalidate];
    self.tokenExpiryTimer = nil;
}


- (void) applicationWillEnterForeground: (UIApplication *) application
{
    [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"applicationWillEnterForeground: %@, %@",
                                         self.loginViewController, self.currentOAuth2Credentials]];

    if (self.currentOAuth2Credentials)
    {
        NSTimeInterval refreshTimeout = [self.currentOAuth2Credentials.expirationDate timeIntervalSinceNow];
    
        if (refreshTimeout < kOAuthTokenExpiryMargin)
        {
            [[SYNRemoteLogger sharedLogger] log:@"applicationWillEnterForeground: refresh"];
            [self refreshExpiredToken];
        }
        else
        {
            [self setTokenExpiryTimer];
        }
    }

}


- (void) applicationDidBecomeActive: (UIApplication *) application
{
    [FBAppEvents activateApp];
    
    [SYNActivityManager.sharedInstance updateActivityForCurrentUserWithReset:NO];
    
    [self checkForUpdatedPlayerCode];
    
    // send tracking code
    
    NSString *message;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kUserDefaultsNotFirstInstall]) // IS first install
    {
        message = @"install";
        [[NSUserDefaults standardUserDefaults] setBool: YES
                                                forKey: kUserDefaultsNotFirstInstall];
    }
    else if (enteredAppThroughNotification)
    {
        message = @"URL";
        enteredAppThroughNotification = NO;
    }
    else
    {
        message = nil;
    }
    
    [self.oAuthNetworkEngine
     trackSessionWithMessage: message];

    if (!self.window.rootViewController)
    {
        self.window.rootViewController = [self createAndReturnRootViewController];
    }

    SYNOAuth2Credential *credential = [SYNOAuth2Credential credentialFromKeychainForService: [[NSBundle mainBundle] bundleIdentifier]
                                                                                    account: self.currentUser.uniqueId];
    
    [[SYNAddEmailAlertView sharedInstance] appBecameActive];
	
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"applicationDidBecomeActive: Starting app in state: %d",
                                         application.applicationState]];
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"applicationDidBecomeActive: Protected data available: %d",
                                         application.protectedDataAvailable]];
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"applicationDidBecomeActive: Current username: (%@) %@",
                                         self.currentUser.uniqueId, self.currentUser.username]];
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"applicationDidBecomeActive: Credentials from keychain: %@",
                                         credential]];
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"applicationDidBecomeActive: Current credentials: %@",
                                         self.currentOAuth2Credentials]];
    
    if ([self.window.rootViewController isKindOfClass:[SYNMasterViewController class]]) {
	    [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"applicationDidBecomeActive: Current view controller: %@",
                                             self.masterViewController.showingViewController]];
    } else {
        [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"applicationDidBecomeActive: Current view controller: %@",
                                             NSStringFromClass([self.window.rootViewController class])]];
    }

}


- (void) applicationWillTerminate: (UIApplication *) application
{
    // Saves changes in the application's managed object context before the application terminates.
    
    // We need to save out database here (not in background)
    [self saveContext: kSaveSynchronously];
}

#pragma mark - Core Data stack

- (void) initializeCoreDataStack
{
    NSError *error;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource: @"Rockpack"
                                              withExtension: @"momd"];
    
    if (!modelURL)
    {
        AssertOrLog(@"Failed to find model URL");
    }
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    
    if (!managedObjectModel)
    {
        AssertOrLog(@"Failed to initialize model");
    }
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
    
    if (!persistentStoreCoordinator)
    {
        AssertOrLog(@"Failed to initialize persistent store coordinator");
    }
    
    
    // == 3 Contexts == //
    
    
    // == Private Context == //
    self.privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    self.privateManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    // == Main Context == //
    self.mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    self.mainManagedObjectContext.parentContext = self.privateManagedObjectContext;
    
    // == Search Context == //
    self.searchManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    NSPersistentStoreCoordinator *searchPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
    NSPersistentStore *searchStore = [searchPersistentStoreCoordinator addPersistentStoreWithType: NSInMemoryStoreType
                                                                                    configuration: nil
                                                                                              URL: nil
                                                                                          options: nil
                                                                                            error: &error];
    
    if (!searchStore)
    {
        AssertOrLog(@"Failed to initialize search managed context in app delegate");
    }
    
    self.searchManagedObjectContext.persistentStoreCoordinator = searchPersistentStoreCoordinator;

    // == Channel Context == //
    self.channelsManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    NSPersistentStoreCoordinator *channelsPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
    NSPersistentStore *channelsStore = [channelsPersistentStoreCoordinator addPersistentStoreWithType: NSInMemoryStoreType
                                                                                        configuration: nil
                                                                                                  URL: nil
                                                                                              options: nil
                                                                                                error: &error];
    
    if (!channelsStore)
    {
        AssertOrLog(@"Failed to initialize channels managed context in app delegate");
    }
    
    self.channelsManagedObjectContext.persistentStoreCoordinator = channelsPersistentStoreCoordinator;
    
    
    // same as: "file://" + "((NSArray*)NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES))[0]";
    NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                              inDomains: NSUserDomainMask] lastObject];
    
    storeURL = [storeURL URLByAppendingPathComponent: @"Rockpack.sqlite"];
    
    // check for integrity
    if([self isDatabaseCorruptedAtFilePath:storeURL.path])
    {
        // if corrupt delete the file
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    }
    
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType: NSSQLiteStoreType
                                                                                              URL: storeURL
                                                                                            error: &error];
    BOOL isCompatible;
    if (sourceMetadata) {
        NSManagedObjectModel *destinationModel = [persistentStoreCoordinator managedObjectModel];
        isCompatible = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
    } else {
        // assume empty db is compatible
        isCompatible = YES;
    }

    NSPersistentStore *store;

    if (isCompatible) {
        // Open existing db
        store = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                         configuration: nil
                                                                   URL: storeURL
                                                               options: @{NSMigratePersistentStoresAutomaticallyOption: @(YES)}
                                                                 error: &error];
    } else {
        // Nuke the db to ensure we have clean schema and data, but first try to extract the current user
        NSPersistentStore *tmpStore = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                                               configuration: nil
                                                                                         URL: storeURL
                                                                                     options: @{NSInferMappingModelAutomaticallyOption: @(YES), NSMigratePersistentStoresAutomaticallyOption: @(YES)}
                                                                                       error: &error];
        // currentUser getter will try and fetch user record from coredata
        NSDictionary *currentUserDict;
        if (self.currentUser) {
            currentUserDict = @{@"id": self.currentUser.uniqueId,
                                @"username": self.currentUser.username};
        }
        
        // delete old db
        [persistentStoreCoordinator removePersistentStore:tmpStore error:&error];
        [[NSFileManager defaultManager] removeItemAtURL: storeURL error: &error];

        // and create a new one
        store = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                         configuration: nil
                                                                   URL: storeURL
                                                               options: @{NSMigratePersistentStoresAutomaticallyOption: @(YES)}
                                                                 error: &error];

        // create currentUser if we have the data
        if (currentUserDict) {
            _currentUser = [User instanceFromDictionary: currentUserDict
                              usingManagedObjectContext: self.mainManagedObjectContext
                                    ignoringObjectTypes: kIgnoreNothing];
            _currentUser.currentValue = YES;
            refetchUserData = YES;
            [self saveContext:YES];
        }

    }
    
    if (store == nil)
    {
        DebugLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    _mainRegistry = [SYNMainRegistry registryWithParentContext:self.mainManagedObjectContext];
    _searchRegistry = [SYNSearchRegistry registryWithParentContext:self.searchManagedObjectContext];
}


- (void) nukeCoreData
{
    _mainRegistry = nil;
    _searchRegistry = nil;
    self.mainManagedObjectContext = nil;
    self.privateManagedObjectContext = nil;
    self.searchManagedObjectContext = nil;
    self.channelsManagedObjectContext = nil;
    self.oAuthNetworkEngine = nil;
    self.networkEngine = nil;

    NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                              inDomains: NSUserDomainMask] lastObject];
    
    storeURL = [storeURL URLByAppendingPathComponent: @"Rockpack.sqlite"];
    
    NSError* error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL: storeURL
                                                  error: &error])
    {
        [self initializeCoreDataStack];
        [self initializeNetworkEngines];
        // Video Queue //
        self.videoQueue = [SYNVideoQueue queue];
        
        // Subscriptions Manager //
        self.channelManager = [SYNChannelManager manager];
    }
    else
    {
        AssertOrLog(@"*** Could not delete persistent store, %@", error);
    }
}

- (BOOL) isDatabaseCorruptedAtFilePath:(NSString*)filePath {
    
    
    BOOL bResult;
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        @try {
            NSString *sqlRaw = @"PRAGMA integrity_check;";
            
            const char *sql = [sqlRaw cStringUsingEncoding:NSUTF8StringEncoding];
            
            sqlite3_stmt *check_statement;
            
            if (sqlite3_prepare_v2(database, sql, -1, &check_statement, NULL) == SQLITE_OK) {
                
                int success = sqlite3_step(check_statement);
                
                DebugLog(@"SQL integrity_check result is %d", success);
                NSString *response = nil;
                switch (success) {
                    case SQLITE_ERROR:
                        bResult = YES;
                        break;
                    case SQLITE_DONE:
                        DebugLog(@"Result is simple DONE of the sqllite3 on isDatabaseCorrupted");
                        break;
                    case SQLITE_BUSY:
                        DebugLog(@"Result is simple BUSY of the sqllite3 on isDatabaseCorrupted");
                        break;
                    case SQLITE_MISUSE:
                        DebugLog(@"Bad utilization of the sqllite3 on isDatabaseCorrupted");
                        break;
                    case SQLITE_ROW:
                        response = [NSString stringWithUTF8String:(char *)sqlite3_column_text(check_statement, 0)];
                        if ([[[response lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet
                                                                                          whitespaceAndNewlineCharacterSet]] isEqualToString:@"ok"]){
                            bResult = NO;
                        } else {
                            DebugLog(@"ATTENTION: integrity_check response %@", response);
                            bResult = NO;
                        }
                        break;
                        
                    default:
                        break;
                }
                
                sqlite3_finalize(check_statement);
            }
            
        }
        @catch (NSException *exception) {
            DebugLog(@"Exception %@", [exception description]);
            return YES;
        }
    }
    
    sqlite3_close(database);
    return bResult;
}


// Save the main context first (propagating the changes to the private) and then the private
- (void) saveContext: (BOOL) wait
{
    if ([self.mainManagedObjectContext hasChanges])
    {
        [self.mainManagedObjectContext performBlock: ^{
            
            NSError *error = nil;
            
            if (![self.mainManagedObjectContext save: &error])
            {
                AssertOrLog(@"Error saving Main moc: %@\n%@", [error localizedDescription], [error userInfo]);
            }
            
            void (^ savePrivate) (void) = ^{
                
                NSError *error = nil;
                
                if (![self.privateManagedObjectContext save: &error])
                {
                    AssertOrLog(@"Error saving Private moc: %@\n%@", [error localizedDescription], [error userInfo]);
                }
            };
            
            if ([self.privateManagedObjectContext hasChanges])
            {
                if (wait)
                {
                    [self.privateManagedObjectContext performBlockAndWait: savePrivate];
                }
                else
                {
                    [self.privateManagedObjectContext performBlock: savePrivate];
                }
            }
        }];
    }
}


- (void) saveSearchContext
{
    if ([self.searchManagedObjectContext hasChanges])
    {
        NSError *error = nil;
        
        if (![self.searchManagedObjectContext save:&error])
        {
            AssertOrLog(@"Error saving Search moc: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
}


- (void) saveChannelsContext
{
    if (!self.channelsManagedObjectContext)
    {
        return;
    }
    
    if ([self.channelsManagedObjectContext hasChanges])
    {
        NSError *error = nil;
        
        if (![self.channelsManagedObjectContext save:&error])
        {
            AssertOrLog(@"Error saving Channels moc: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
}


#pragma mark - Network engine suport

- (void) initializeNetworkEngines
{
    self.networkEngine = [[SYNNetworkEngine alloc] initWithDefaultSettings];
    [self.networkEngine useCache];
    
    self.oAuthNetworkEngine = [[SYNOAuthNetworkEngine alloc] initWithDefaultSettings];
    
    [self.oAuthNetworkEngine useCache];
    
    // Use this engine as the default for the asynchronous image loading category on UIImageView
    UIImageView.defaultEngine = self.networkEngine;
    
    // track first install
    
    
    
}

-(void)setIpBasedLocation:(NSString *)ipBasedLocation
{
    self.networkEngine.locationString = ipBasedLocation;
    self.oAuthNetworkEngine.locationString = ipBasedLocation;
}
#pragma mark - Clearing Data

- (void) clearCoreDataMainEntities: (BOOL) userBound
{
    
    // this is called when user logs out AND when change of locale, in the latter case the userBound flag is NO so as not to delete one's own videos and subscriptions
    
    NSError *error;
    NSArray *itemsToDelete;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // == Clear VideoInstances == //
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"FeedItem"
                                         inManagedObjectContext: self.mainManagedObjectContext]];
    
    
    itemsToDelete = [self.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                 error: &error];
    
    for (NSManagedObject *objectToDelete in itemsToDelete)
    {
        [self.mainManagedObjectContext deleteObject: objectToDelete];
    }
    
    
    // == Clear VideoInstances == //
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"VideoInstance"
                                         inManagedObjectContext: self.mainManagedObjectContext]];
    
    
    itemsToDelete = [self.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                 error: &error];
    
    for (NSManagedObject *objectToDelete in itemsToDelete)
    {
        [self.mainManagedObjectContext deleteObject: objectToDelete];
    }
	
    // === Clear Channels === //
    
    if (!userBound)
    {
        // do not delete data relating to the user such as subscriptions and channels (usually when calling the function due to a change in locale)
        NSPredicate *notUserChannels = [NSPredicate predicateWithFormat: @"channelOwner.uniqueId != %@ AND subscribedByUser != YES", self.currentUser.uniqueId];
        [fetchRequest setPredicate: notUserChannels];
    }
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                         inManagedObjectContext: self.mainManagedObjectContext]];
    
    itemsToDelete = [self.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                 error: &error];
    
    for (NSManagedObject *objectToDelete in itemsToDelete)
    {
        [self.mainManagedObjectContext deleteObject: objectToDelete];
    }
    
    fetchRequest.predicate = nil;

    
    
    // === Clear Categories (Genres) === //
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Genre"
                                         inManagedObjectContext: self.mainManagedObjectContext]];
    
    fetchRequest.includesSubentities = YES; // to include SubGenre objecst
    
    itemsToDelete = [self.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                 error: &error];
    
    for (NSManagedObject *objectToDelete in itemsToDelete)
    {
        [self.mainManagedObjectContext deleteObject: objectToDelete];
    }
    
    // == Clear ChannelOwner == //
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"ChannelOwner"
                                         inManagedObjectContext: self.mainManagedObjectContext]];
    
    fetchRequest.includesSubentities = NO; // do not include User objects as these are handled elsewhere
    
    if (!userBound)
    {
        // do not delete data relating to the user such as subscriptions and channels
        NSPredicate *ownsUseSubscribedChannels = [NSPredicate predicateWithFormat: @"ANY channels.subscribedByUser == NO"];
        [fetchRequest setPredicate: ownsUseSubscribedChannels];
    }
    
    itemsToDelete = [self.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                 error: &error];
    
    for (NSManagedObject *objectToDelete in itemsToDelete)
    {
        [self.mainManagedObjectContext deleteObject: objectToDelete];
    }
    
    fetchRequest.predicate = nil;
    
    
    // == Clear Friends (if not just changing locale) == //
    
    if(!userBound)
    {
        [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                             inManagedObjectContext: self.mainManagedObjectContext]];
        
        
        itemsToDelete = [self.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                     error: &error];
        
        for (NSManagedObject *objectToDelete in itemsToDelete)
        {
            [self.mainManagedObjectContext deleteObject: objectToDelete];
        }
    }
    
    
    // == Save == //
    
    [self saveContext: YES];
    
    if (!userBound)
    {
        // notify that the cleaning of the data due to a change in locale has been performed
        [[NSNotificationCenter defaultCenter] postNotificationName: kClearedLocationBoundData
                                                            object: self];
    }
}

- (void)handlePendingOpenURL {
	if (self.pendingOpenURL) {
		[self parseAndActionRockpackURL:self.pendingOpenURL];
	}
	self.pendingOpenURL = nil;
}


- (void) deleteDataObject: (NSManagedObject *) managedObject
{
    [self.mainManagedObjectContext
     deleteObject: managedObject];
}


#pragma mark - User and Credentials

- (User *) currentUser
{
    if (!_currentUser)
    {
        NSError *error = nil;
        NSEntityDescription *userEntity = [NSEntityDescription entityForName: @"User"
                                                      inManagedObjectContext: self.mainManagedObjectContext];
        
        
        NSFetchRequest *userFetchRequest = [[NSFetchRequest alloc] init];
        [userFetchRequest setEntity: userEntity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"current == %@", @(YES)];
        [userFetchRequest setPredicate: predicate];
        
        
        NSArray *userEntries = [self.mainManagedObjectContext
                                executeFetchRequest: userFetchRequest
                                error: &error];
        
        if (userEntries.count > 0)
        {
            _currentUser = (User *) userEntries[0];
            
            if (userEntries.count > 1) // housekeeping, clear duplicate user entries
            {
                for (int u = 1; u < userEntries.count; u++)
                {
                    [self.mainManagedObjectContext
                     deleteObject: ((User *) userEntries[u])];
                }
            }
        }
        else
        {
            DebugLog(@"No Current User Found in AppDelegate...");
            _currentUser = nil;
        }
    }
    
    return _currentUser;
}


- (void) setCurrentOAuth2Credentials: (SYNOAuth2Credential *) nCurrentOAuth2Credentials
{
    if (!self.currentUser)
    {
        _currentOAuth2Credentials = nil;
        DebugLog(@"Tried to save credentials without an active user");
        return;
    }
    
    _currentOAuth2Credentials = nCurrentOAuth2Credentials;

    // Could be running in the background on a locked device, so don't try to save
    // the credentials unless the keychain is available.
    if ([UIApplication sharedApplication].protectedDataAvailable)
    {
        if (_currentOAuth2Credentials) {
            [_currentOAuth2Credentials saveToKeychainForService: [[NSBundle mainBundle] bundleIdentifier]
                                                        account: _currentOAuth2Credentials.userId];
        } else {
            [_currentOAuth2Credentials removeFromKeychain];
        }
    }
}


- (SYNOAuth2Credential *) currentOAuth2Credentials
{
    if (!self.currentUser)
    {
        return nil;
    }
    
    if (!_currentOAuth2Credentials)
    {
        _currentOAuth2Credentials = [SYNOAuth2Credential credentialFromKeychainForService: [[NSBundle mainBundle] bundleIdentifier]
                                                                                  account: self.currentUser.uniqueId];
        if (!_currentOAuth2Credentials)
        {
            DebugLog(@"Detected currentUser data, but no matching OAuth2 credentials");
        }
    }
    
    return _currentOAuth2Credentials;
}


// Used to force a refresh of the credentials
- (void) resetCurrentOAuth2Credentials
{
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"resetCurrentOAuth2Credentials: %@", [NSThread callStackSymbols]]];
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"resetCurrentOAuth2Credentials: App state: %d",
                                         [UIApplication sharedApplication].applicationState]];
	[[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"resetCurrentOAuth2Credentials: Protected data available: %d",
                                         [UIApplication sharedApplication].protectedDataAvailable]];
    _currentOAuth2Credentials = nil;
}


#pragma mark - UIWebView-based video player HTML updater

- (void) checkForUpdatedPlayerCode
{
    [self.networkEngine updatePlayerSourceWithCompletionHandler: ^(NSDictionary *dictionary) {
        
         if (dictionary && [dictionary isKindOfClass: [NSDictionary class]])
         {
             // Handle YouTube player updates
             NSString *youTubePlayerURLString = dictionary[@"youtube"];
             
             // Only update if we have valid HTML
             if ([youTubePlayerURLString length])
             {
                 [self saveAsFileToDocumentsDirectory: @"YouTubeIFramePlayer"
                                               asType: @"html"
                                          usingSource: youTubePlayerURLString];
             }
         }
         else
         {
             DebugLog(@"Unexpected response from player source update");
         }
     }
     errorHandler: ^(NSError *error) {
         DebugLog(@"Player source update failed");
         // Don't worry, we'll try again next time the app comes to the foreground
     }];
}

- (void) saveAsFileToDocumentsDirectory: (NSString *) fileName
                                 asType: (NSString *) type
                            usingSource: (NSString *) source
{
    NSString *destinationPath = [self destinationPathInDocumentsDirectoryUsingFilename:fileName andType:type];
    
	[source writeToFile:destinationPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


- (NSString *) destinationPathInDocumentsDirectoryUsingFilename: (NSString *) fileName
                                                        andType: (NSString *) type
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *pathComponent = [NSString stringWithFormat: @"%@.%@", fileName, type];
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent: pathComponent];
    
    return destinationPath;
}


#pragma mark - Notification support

- (void) application: (UIApplication *) application
         didRegisterForRemoteNotificationsWithDeviceToken: (NSData *) deviceToken
{
    // Strip all the formatting from the token
    NSString *formattedToken = [deviceToken description];
    
    formattedToken = [formattedToken stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"<>"]];
    formattedToken = [formattedToken stringByReplacingOccurrencesOfString: @" "
                                                               withString: @""];
    
    self.apnsToken = formattedToken;
    
    // If the user has already logged in then send the latest token to the server, but wait a while until any token refreshes have occurred
    if (self.currentUser)
    {
        [self performBlock: ^{
            
            [self.oAuthNetworkEngine updateApplePushNotificationForUserId: self.currentUser.uniqueId
                                                                    token: formattedToken
                                                        completionHandler: ^(NSDictionary *dictionary) {
                                                            
                                                            
                                                            DebugLog(@"Apple push notification token update successful");
                                                            
                                                        } errorHandler: ^(NSError *error) {
                                                            
                                                            DebugLog(@"Apple push notification token update failed");
                                                            
                                                        }];
        } afterDelay: 2.0f];       
    }
}


- (void) application: (UIApplication *) application
         didFailToRegisterForRemoteNotificationsWithError: (NSError *) error
{
    DebugLog(@"Failed to get token, error: %@", error);
    self.apnsToken = nil;
}

/*
// Standard notification (opens notification center)
// where "%@ has subscribed to your channel" is in the list of localised strings
{
    "aps" : {
        "alert" : {
            "loc-key" : "%@ has subscribed to your channel",
            "loc-args" : [ "Synchromation"]
        },
        "badge" : 5,
    }
}


// Enhanced notification
// corresponding to rockpack://vACcGSVlSIKbkR9tNoi-Ag/channel/chjXG7BaAcR5qKFdeHkGgOEQ/video/viqUJNamm6j8puq1g2svvHGw/
// that will open the asset directly
{
    "aps" : {
        "alert" : {
            "loc-key" : "%@ has liked your video",
            "loc-args" : [ "Synchromation"]
        },
    "badge" : 5,
    },
    "rck" : {
        "url" : "vACcGSVlSIKbkR9tNoi-Ag/channel/chjXG7BaAcR5qKFdeHkGgOEQ/video/viqUJNamm6j8puq1g2svvHGw/"
        "id" : "xyz123"
    }
}


// Unknown notification
// where "%%@ and %@ have invited you to play Monopoly" is NOT in the list of localised strings
{
    "aps" : {
        "alert" : {
            "loc-key" : "%%@ and %@ have invited you to play Monopoly",
            "loc-args" : [ "Nick", "Michael"]
        },
        "badge" : 5,
    }
}
 */

- (void) application: (UIApplication*) application
         didReceiveRemoteNotification: (NSDictionary*) userInfo
{
	DebugLog(@"Received notification: %@", userInfo);
    
    UIApplicationState state = [application applicationState];
    
    if (state != UIApplicationStateActive)
    {
        // The app is in the background, and the user has tapped on a notification
        // so we do need to handle this case
        [self handleRemoteNotification: userInfo];
    }
}


- (void) handleRemoteNotification: (NSDictionary*) userInfo
{
    NSNumber *notificationId = userInfo[@"id"];
    NSString *urlString = userInfo[@"url"];
    
	if (self.currentUser && urlString) {
		if (notificationId) {
			NSArray *array = @[notificationId];
			
			// First, mark the notification as read (on the server)
			[self.oAuthNetworkEngine markAsReadForNotificationIndexes: array
														   fromUserId: self.currentUser.uniqueId
													completionHandler: ^(id response) {
														DebugLog(@"Mark as read succeeded");
														
														// TODO: Check that the bedge count is being handled correctly
														// Decrement the badge number (min zero)
														UIApplication.sharedApplication.applicationIconBadgeNumber = MAX((UIApplication.sharedApplication.applicationIconBadgeNumber - 1) , 0);
													}
														 errorHandler: ^(id error) {
														DebugLog(@"Mark as read failed");
													}];
		}
        
        // Now actually handle the rockpack:// url
		NSString *appURLScheme = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppURLScheme"];
		
		NSString *dollyURLString = [NSString stringWithFormat:@"%@://%@", appURLScheme, urlString];
        NSURL *dollyURL = [NSURL URLWithString:dollyURLString];
		      
        if (userInfo[@"tracking_code"]) {
            NSArray *pathComponents = dollyURL.pathComponents;
            NSString *videoId = pathComponents[4];
            NSString *channelId = pathComponents[2];
            
            NSDictionary* trackingDict = @{@"tracking_code" : userInfo[@"tracking_code"],
                                           @"id" : channelId
                                           };
            
            [[SYNActivityManager sharedInstance] addObjectFromDict:trackingDict];

            trackingDict = @{@"tracking_code" : userInfo[@"tracking_code"],
                                           @"id" : videoId
                                           };
            
            [[SYNActivityManager sharedInstance] addObjectFromDict:trackingDict];

        }
        
        [self parseAndActionRockpackURL:dollyURL];
    }
}


#pragma mark - Social deep linking

- (NSDictionary *) parseURLParams: (NSString *) query
{
    NSArray *pairs = [query componentsSeparatedByString: @"&"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (NSString *pair in pairs)
    {
        NSRange range = [pair rangeOfString: @"="];
        
        NSString *key = [pair substringToIndex: range.location];
        NSString *value = [pair substringFromIndex: range.location + 1];
        
        params[key] = value;
    }
    
    return params;
}

- (BOOL) parseAndActionRockpackURL: (NSURL *) url
{
	if (!self.masterViewController.showingViewController) {
		// FIXME: This is a really dodgy hack to sort out an issue with how the view hierarchy is set up.
		// There isn't any showingViewController until the call to get the categories returns in
		// viewDidLoad in MasterViewController. Since we expect it to exist in order to show the notification
		// this causes problems. So I'm currently storing it here and going to handle it when we finish
		// getting the categories
		self.pendingOpenURL = url;
	}
	
    BOOL success = FALSE;
    
    if (self.currentUser)
    {
        NSString *userId = url.host;
        NSArray *pathComponents = url.pathComponents;
        
        // Default to other user's deep link
        NSString *httpScheme = @"http:";
        
        // Vary schema dependent on whether the deep link is from current user or a different user
        if ([userId isEqualToString: self.currentUser.uniqueId])
        {
            httpScheme = @"https:";
        }
        
        NSString *hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey: ([userId isEqualToString: self.currentUser.uniqueId])? @"SecureAPIHostName" : @"APIHostName"];
		
		SYNAbstractViewController *currentViewController = self.masterViewController.showingViewController;
        
        UIViewController *topController = self.masterViewController.presentedViewController;
        
        if ([topController isKindOfClass:[SYNVideoPlayerViewController class]]) {
            [self.masterViewController dismissViewControllerAnimated:NO completion:nil];
        }

        switch (pathComponents.count)
        {
                // User profile
            case 1:
            {
                if (userId)
                {
                    ChannelOwner *channelOwner = [ChannelOwner instanceFromDictionary: @{@"id" : userId}
                                                            usingManagedObjectContext: self.mainManagedObjectContext
                                                                  ignoringObjectTypes: kIgnoreChannelObjects];
                    
                    [currentViewController viewProfileDetails:channelOwner];
                    success = TRUE;
                }
                break;
            }
               
            case 2:
            {
                NSString *channelOwnerId = pathComponents[1];

                    ChannelOwner *channelOwner = [ChannelOwner instanceFromDictionary: @{@"id" : channelOwnerId}
                                                            usingManagedObjectContext: self.mainManagedObjectContext
                                                                  ignoringObjectTypes: kIgnoreChannelObjects];
                    
                    [currentViewController viewProfileDetails:channelOwner];
                    success = TRUE;
                break;
            }

                // Channel
            case 3:
            {
                // Extract the channelId from the path
                NSString *channelId = pathComponents[2];
                NSString *resourceURL = [NSString stringWithFormat: @"%@//%@/ws/%@/channels/%@/", httpScheme, hostName, userId, channelId];
                Channel* channel = [Channel instanceFromDictionary: @{@"id" : channelId, @"resource_url" : resourceURL}
                                         usingManagedObjectContext: self.mainManagedObjectContext];
                
                if (channel)
                {
                    [currentViewController viewChannelDetails:channel withAnimation:YES];
                    success = TRUE;
                }
                break;
            }
                
                // Video Instance
            case 5:
            {
                NSString *channelId = pathComponents[2];
                NSString *videoId = pathComponents[4];
                NSString *resourceURL = [NSString stringWithFormat: @"%@//%@/ws/%@/channels/%@/", httpScheme, hostName, userId, channelId];
                Channel* channel = [Channel instanceFromDictionary: @{@"id" : channelId, @"resource_url" : resourceURL}
                                         usingManagedObjectContext: self.mainManagedObjectContext];
                
                if (channel)
                {
                    [currentViewController viewVideoInstanceInChannel:channel withVideoId:videoId];
                    success = TRUE;
                }
                break;
            }
                
            case 6:
            {
                
                NSString *channelId = pathComponents[2];
                NSString *videoId = pathComponents[4];
                NSString *resourceURL = [NSString stringWithFormat: @"%@//%@/ws/%@/channels/%@/", httpScheme, hostName, userId, channelId];
                Channel* channel = [Channel instanceFromDictionary: @{@"id" : channelId, @"resource_url" : resourceURL}
                                         usingManagedObjectContext: self.mainManagedObjectContext];
                
                if (channel)
                {
                    [currentViewController viewVideoInstanceInChannel:channel withVideoId:videoId withClickToMore:YES];
                    success = TRUE;
                }
                
                break;
            }
            default:
                // Not sure what this is so indicate failure
                break;
        }
        
        [[SYNTrackingManager sharedManager] trackExternalLinkOpened:[url absoluteString]];
		
        enteredAppThroughNotification = YES;
    }
    else
    {
        DebugLog(@"No active user, ignored");
    }
    
    return success;
}

- (void) updateFeedWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[SYNFeedModel sharedModel] reloadInitialPageWithCompletionHandler:^(BOOL success, BOOL hasChanged) {
        UIBackgroundFetchResult result;
        if (success) {
            if (hasChanged) {
                [self.navigationManager switchToFeed];
				//Update widget in background fetch. 
                SYNFeedRootViewController *viewController = (SYNFeedRootViewController *)self.masterViewController.showingViewController;
                [viewController updateWidgetFeedItem];
                result = UIBackgroundFetchResultNewData;
            } else {
                result = UIBackgroundFetchResultNoData;
            }
        } else {
            result = UIBackgroundFetchResultFailed;
        }

        [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"updateFeedWithCompletionHandler: end: %d %d",
                                             success, hasChanged]];

        // Wait a second to give the images a chance to download
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"updateFeedWithCompletionHandler: callback: %u",
                                                 result]];
            completionHandler(result);
        });
    }];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{

    [[SYNRemoteLogger sharedLogger] log:[NSString stringWithFormat:@"performFetchWithCompletionHandler: start: %@",
                                         self.currentOAuth2Credentials]];

    if (self.currentOAuth2Credentials) {
        NSTimeInterval refreshTimeout = [self.currentOAuth2Credentials.expirationDate timeIntervalSinceNow];
        if (refreshTimeout >= kOAuthTokenExpiryMargin)
        {
            [[SYNRemoteLogger sharedLogger] log:@"performFetchWithCompletionHandler: valid token"];
            [self updateFeedWithCompletionHandler:completionHandler];
        }
        else
        {
            // refresh expired token
            [self.oAuthNetworkEngine
             refreshOAuthTokenWithCompletionHandler: ^(id response) {
                [[SYNRemoteLogger sharedLogger] log:@"performFetchWithCompletionHandler: refresh success"];
                [self updateFeedWithCompletionHandler:completionHandler];
             }
             errorHandler: ^(id response) {
                 [[SYNRemoteLogger sharedLogger] log:@"performFetchWithCompletionHandler: refresh error"];
                 completionHandler(UIBackgroundFetchResultFailed);
             }];
        }
    }
    else
    {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}


// rockpack://USERID/
// (test) http://dev.rockpack.com/paulegan/deeplinktest/user.html
// rockpack://USERID/channels/CHANNELID/
// (test) http://dev.rockpack.com/paulegan/deeplinktest/channel.html
// rockpack://USERID/channels/CHANNELID/videos/VIDEOID/
// (test) http://dev.rockpack.com/paulegan/deeplinktest/video.html
// http://share.demo.rockpack.com/s/SXL1kOk

- (BOOL)  application: (UIApplication *) application
              openURL: (NSURL *) url
    sourceApplication: (NSString *) sourceApplication
           annotation: (id) annotation
{
	NSString *appURLScheme = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppURLScheme"];
	
    // Is it one of our own custom 'rockpack' URL schemes
    if ([url.scheme isEqualToString:appURLScheme])
    {
        return [self parseAndActionRockpackURL: url];
    }
    else if ([url.scheme hasPrefix: @"fb"])
    {
        // Parse the fragment of the URL (separated by &)
        NSDictionary *params = [self parseURLParams: [url fragment]];
        
        // Check if target URL exists
        NSString *targetURLString = [params valueForKey: @"target_url"];
        
        if (targetURLString)
        {
            targetURLString = [targetURLString stringByAppendingString: @"&rockpack_redirect=true"];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: targetURLString]];
            [request setHTTPMethod: @"GET"];
            
            // Make sure we don't reuse old data
            self.rockpackURL = nil;
            
            // Start asynchronous connection
            self.connection = [[NSURLConnection alloc] initWithRequest: request
                                                              delegate: self];
        }
        
        enteredAppThroughNotification = YES;
		
        [[SYNTrackingManager sharedManager] trackExternalLinkOpened:targetURLString];
		
        return [FBSession.activeSession
                handleOpenURL: url];
    }
    else
    {
        // No idea what this scheme does so indicated failure
        return NO;
    }
}


#pragma mark -
#pragma mark NSURLConnection delegates for deep linking

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
    if (self.currentUser.currentValue && self.currentOAuth2Credentials)
    {
        if (self.rockpackURL)
        {
            NSURL *url = [NSURL URLWithString: self.rockpackURL];
            [self parseAndActionRockpackURL: url];
        }
    }
}

- (NSString *)userAgentString {
	if (!_userAgentString) {
		NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
		
		NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
		NSString *bundleVersion = infoDictionary[(NSString *)kCFBundleVersionKey];
		
		NSString *deviceModel = [[UIDevice currentDevice] model];
		NSString *osVersion = [[UIDevice currentDevice] systemVersion];
		
		self.userAgentString = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@)", bundleName, bundleVersion, deviceModel, osVersion];
	}
	return _userAgentString;
}

- (NSURLRequest *) connection: (NSURLConnection *) connection
              willSendRequest: (NSURLRequest *) request
             redirectResponse: (NSURLResponse *) redirectResponse
{
    NSURLRequest *newRequest = request;
    
	NSString *appURLScheme = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppURLScheme"];
    
    if (redirectResponse && !self.rockpackURL)
    {
        NSString *urlString = [(NSHTTPURLResponse *) redirectResponse allHeaderFields][@"Location"];
        
        if ([urlString hasPrefix: appURLScheme])
        {
            self.rockpackURL = urlString;
            newRequest = nil;
        }
    }
    
    return newRequest;
}

@end
