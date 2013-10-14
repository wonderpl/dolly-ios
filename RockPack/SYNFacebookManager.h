//
//  SYNFacebookManager.h
//  rockpack
//
//  Created by Nick Banks on 12/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _PermissionType : NSInteger
{
    kFacebookPermissionTypeEmail = 0,
    kFacebookPermissionTypeRead = 1,
    kFacebookPermissionTypePublish = 2
} PermissionType;

static NSString* const FacebookEmailPermission = @"email";
static NSString* const FacebookReadPermission = @"read_stream";
static NSString* const FacebookPublishPermission = @"publish_actions";

@protocol FBGraphUser;
@class Friend;

// Localizable error messages

#define kFacebookLoginCancelled	  NSLocalizedString(@"Log in cancelled, or permission denied.  Check Facebook settings", nil)
#define kFacebookPermissionDenied NSLocalizedString(@"Permission denied", nil)
#define kFacebookUnknownError	  NSLocalizedString(@"Unknown error, nil", nil)

// Block typedefs

typedef void (^FacebookOpenSessionSuccessBlock)(void);
typedef void (^FacebookOpenSessionFailureBlock)(NSString *errorMessage);

typedef void (^FacebookLoginSuccessBlock)(NSDictionary<FBGraphUser> *userInfo);
typedef void (^FacebookLoginFailureBlock)(NSString *errorMessage);

typedef void (^FacebookLogoutSuccessBlock)(void);
typedef void (^FacebookLogoutFailureBlock)(NSString *errorMessage);

typedef void (^FacebookPostSuccessBlock)(void);
typedef void (^FacebookPostFailureBlock)(NSError *error);



@interface SYNFacebookManager : NSObject

+ (instancetype) sharedFBManager;

- (void) loginOnSuccess: (FacebookLoginSuccessBlock) successBlock
              onFailure: (FacebookLoginFailureBlock) failureBlock;

- (void) logoutOnSuccess: (FacebookLogoutSuccessBlock) successBlock
               onFailure: (FacebookLogoutFailureBlock) failureBlock;

- (void) openSessionFromExistingToken: (NSString *) token
                            onSuccess: (FacebookOpenSessionSuccessBlock) successBlock
                            onFailure: (FacebookOpenSessionFailureBlock) failureBlock;

- (void) postMessageToWall: (NSString *) message
                 onSuccess: (FacebookPostSuccessBlock) successBlock
                 onFailure: (FacebookPostFailureBlock) failureBlock;

- (void) openSessionWithPermissionType: (PermissionType) permissionType
                             onSuccess: (FacebookOpenSessionSuccessBlock) successBlock
                             onFailure: (FacebookOpenSessionFailureBlock) failureBlock;


- (BOOL) hasActiveSession;
- (BOOL) hasActiveSessionWithPermissionType:(NSString*)permissionString;

- (void) sendAppRequestToFriend: (Friend *) toFriend
                      onSuccess: (FacebookPostSuccessBlock) successBlock
                      onFailure: (FacebookPostFailureBlock) failureBlock;

@end
