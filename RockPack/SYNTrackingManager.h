//
//  SYNTrackingManager.h
//  dolly
//
//  Created by Sherman Lo on 18/02/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNTrackingManager : NSObject

+ (instancetype)sharedManager;

- (void)trackVideoAddFromScreenName:(NSString *)screenName;
- (void)trackVideoLikeFromScreenName:(NSString *)screenName;
- (void)trackFacebookLogin;
- (void)trackUserLoginFromOrigin:(NSString *)origin;
- (void)trackVideoShareWithService:(NSString *)service;
- (void)trackCollectionShareWithService:(NSString *)service;
- (void)trackCollectionFollowFromScreenName:(NSString *)screenName;
- (void)trackUserCollectionsFollowFromScreenName:(NSString *)screenName;

- (void)trackVideoMaximiseViaRotation;
- (void)trackVideoMaximise;

- (void)trackAccountPropertyChanged:(NSString *)property;

- (void)trackStartScreenView;
- (void)trackLoginScreenView;
- (void)trackForgotPasswordScreenView;
- (void)trackRegistrationScreenView;
- (void)trackRegistrationStep2ScreenView;

- (void)trackMoodMinderScreenView;
- (void)trackFeedScreenView;
- (void)trackOwnProfileScreenView;
- (void)trackActivityScreenView;

- (void)trackProfileOverlayScreenView;
- (void)trackAccountSettingsScreenView;
- (void)trackAboutScreenView;
- (void)trackFeedbackScreenView;
- (void)trackHintsScreenView;
- (void)trackFriendsScreenView;
- (void)trackFriendsFBConnectScreenView;
- (void)trackBlogScreenView;
- (void)trackHelpScreenView;

- (void)trackEditProfileScreenView;
- (void)trackOwnProfileFollowingScreenView;
- (void)trackOwnCollectionScreenView;
- (void)trackEditCollectionScreenView;

- (void)trackCollectionFollowersScreenView;

- (void)trackOtherUserProfileScreenView;
- (void)trackOtherUserCollectionFollowingScreenView;
- (void)trackOtherUserCollectionScreenView;

- (void)trackCommentingScreenView;

- (void)trackCarouselVideoPlayerScreenView;
- (void)trackSearchVideoPlayerScreenView;

- (void)trackShareScreenView;

- (void)setAgeDimensionFromBirthDate:(NSDate *)birthDate;

@end
