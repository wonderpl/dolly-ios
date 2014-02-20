//
//  SYNTrackingManager.h
//  dolly
//
//  Created by Sherman Lo on 18/02/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface SYNTrackingManager : NSObject

+ (instancetype)sharedManager;

- (void)setup;

- (void)trackVideoAddFromScreenName:(NSString *)screenName;
- (void)trackVideoLikeFromScreenName:(NSString *)screenName;
- (void)trackVideoCommentFromScreenName:(NSString *)screenName;
- (void)trackFacebookLogin;
- (void)trackUserLoginFromOrigin:(NSString *)origin;
- (void)trackVideoShareWithService:(NSString *)service;
- (void)trackCollectionShareWithService:(NSString *)service;
- (void)trackCollectionFollowFromScreenName:(NSString *)screenName;
- (void)trackUserCollectionsFollowFromScreenName:(NSString *)screenName;

- (void)trackAvatarUploadFromScreen:(NSString *)screenName;
- (void)trackCoverPhotoUpload;

- (void)trackShareEmailEnteredIsNew:(BOOL)isNew;

- (void)trackVideoMaximiseViaRotation;
- (void)trackVideoMaximise;

- (void)trackCarouselVideoSelected;
- (void)trackSearchVideoPlayerAppearsInSelected;
- (void)trackSearchVideoPlayerLovedBySelected;

- (void)trackCollectionSelectedIsNew:(BOOL)isNew;
- (void)trackCollectionSelectionSaved;

- (void)trackSearchInitiated;

- (void)trackMarkAllNotificationAsRead;
- (void)trackSelectedNotificationOfType:(NSString *)type;

- (void)trackOnboardingCompletedWithFollowedCount:(NSInteger)followedCount;

//- (void)trackMoodSelected:(NSString *)name;
//- (void)trackMoodChooseAnotherSelected:(NSString *)moodName;

- (void)trackVideoView:(NSString *)videoId currentTime:(CGFloat)currentTime duration:(CGFloat)duration;

- (void)trackAccountPropertyChanged:(NSString *)property;

- (void)trackAddressBookPermission:(BOOL)granted;

- (void)trackStartScreenView;
- (void)trackLoginScreenView;
- (void)trackForgotPasswordScreenView;
- (void)trackRegistrationScreenView;
- (void)trackRegistrationStep2ScreenView;

- (void)trackMoodMinderScreenView;
- (void)trackDiscoverScreenView;
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

- (void)trackVideoSwipeToVideo:(BOOL)isPrevious;

- (void)trackCarouselVideoPlayerScreenView;
- (void)trackSearchVideoPlayerScreenView;

- (void)trackShareScreenView;

- (void)setAgeDimensionFromBirthDate:(NSDate *)birthDate;

- (void)setGenderDimension:(Gender)gender;
- (void)setLocaleDimension:(NSLocale *)locale;

@end
