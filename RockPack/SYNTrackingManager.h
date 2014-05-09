//
//  SYNTrackingManager.h
//  dolly
//
//  Created by Sherman Lo on 18/02/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

typedef NS_ENUM(NSInteger, kNotificationObjectType);

@interface SYNTrackingManager : NSObject

+ (instancetype)sharedManager;

- (void)setup;

- (void)trackClickToMoreWithTitle:(NSString *)title URL:(NSString *)URL;
- (void)trackVideoAddFromScreenName:(NSString *)screenName;
- (void)trackVideoLikeFromScreenName:(NSString *)screenName;
- (void)trackVideoCommentFromScreenName:(NSString *)screenName;
- (void)trackFacebookLogin;
- (void)trackUserLoginFromOrigin:(NSString *)origin;
- (void)trackUserRegistrationFromOrigin:(NSString *)origin;
- (void)trackVideoShareWithService:(NSString *)service;
- (void)trackCollectionShareWithService:(NSString *)service;
- (void)trackCollectionFollowFromScreenName:(NSString *)screenName;
- (void)trackUserCollectionsFollowFromScreenName:(NSString *)screenName;

- (void)trackAvatarUploadFromScreen:(NSString *)screenName;
- (void)trackCoverPhotoUpload;

- (void)trackShareEmailEnteredIsNew:(BOOL)isNew;

- (void)trackVideoMaximiseViaRotation;
- (void)trackVideoMaximise;
- (void)trackVideoAirPlayUsed;

- (void)trackCreateChannelScreenView;

- (void)trackCarouselVideoSelected;
- (void)trackSearchVideoPlayerAppearsInSelected;
- (void)trackSearchVideoPlayerLovedBySelected;

- (void)trackCollectionSelectedIsNew:(BOOL)isNew;
- (void)trackCollectionSaved;

- (void)trackCollectionCreatedWithName:(NSString *)name;

- (void)trackSearchInitiated;

- (void)trackMarkAllNotificationAsRead;
- (void)trackSelectedNotificationOfType:(kNotificationObjectType)type;

- (void)trackOnboardingCompletedWithFollowedCount:(NSInteger)followedCount;

- (void)trackCoverPhotoUploadCompleted;
- (void)trackAvatarPhotoUploadCompleted;

- (void)trackCollectionFollowCompleted;
- (void)trackVideoAddedToCollectionCompleted:(BOOL)isFavouritesChannel;

- (void)trackShareFriendSearch;
- (void)trackShareFriendSearchSelect:(NSString *)origin;

- (void)trackCommentPostedWithTaggedUsers:(BOOL)hasTaggedUsers;

- (void)trackCollectionEdited:(NSString *)name;

- (void)trackVideoLoadTime:(NSTimeInterval)loadTime;

- (void)trackVideoView:(NSString *)videoId currentTime:(CGFloat)currentTime duration:(CGFloat)duration;

- (void)trackAccountPropertyChanged:(NSString *)property;

- (void)trackAddressBookPermission:(BOOL)granted;

- (void)trackStartScreenView;
- (void)trackLoginScreenView;
- (void)trackForgotPasswordScreenView;
- (void)trackRegistrationScreenView;
- (void)trackRegistrationStep2ScreenView;

- (void)trackOnboardingScreenView;

- (void)trackDiscoverScreenView;
- (void)trackFeedScreenView;
- (void)trackOwnProfileScreenView;
- (void)trackActivityScreenView;
- (void)trackClickToMoreScreenView;

- (void)trackVideoBrowseScreenView;
- (void)trackUserBrowseScreenView;
- (void)trackVideoSearchScreenView;
- (void)trackUserSearchScreenView;

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

- (void)trackRateScreenView;

- (void)trackCollectionShareCompletedWithService:(NSString *)service;
- (void)trackVideoShareCompletedWithService:(NSString *)service;

- (void)trackNetworkErrorCode:(NSInteger)code forURL:(NSString *)url;

- (void)trackExternalLinkOpened:(NSString *)url;

- (void)setAgeDimensionFromBirthDate:(NSDate *)birthDate;
- (void)setCategoryDimension:(NSString *)name;
- (void)setGenderDimension:(Gender)gender;
- (void)setLocaleDimension:(NSLocale *)locale;
- (void)setChannelRelationDimension:(NSString *)relationship;

- (void)trackScreenViewWithName:(NSString *)name;

@end
