//
//  SYNFacebookManager.m
//  rockpack
//
//  Created by Nick Banks on 12/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "Friend.h"
#import "SYNFacebookManager.h"
#import "SYNSessionTokenCachingStrategy.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"

@interface SYNFacebookManager ()

@property (atomic, assign) int outstandingLoginRequests;
@property (nonatomic, strong) SYNSessionTokenCachingStrategy *tokenCachingStrategy;

@end



@implementation SYNFacebookManager

// Singleton
+ (instancetype) sharedFBManager
{
    static dispatch_once_t onceQueue;
    static SYNFacebookManager *fBManager = nil;
    
    dispatch_once(&onceQueue, ^{fBManager = [[self alloc] init]; });
    return fBManager;
}


// Log into Facebook (with read permissions)
// This is done is a couple of stages...
//
// 1. Check to see if we have an open session, and if not open one
// 2. Check to see if we have extended read permissions to allow us to get the user's email address
// 3. Once we have an email address, then call the suceess block, otherwise if anything else goes wrong
//    call the failure block
- (void) loginOnSuccess: (FacebookLoginSuccessBlock) successBlock
              onFailure: (FacebookLoginFailureBlock) failureBlock
{
    self.outstandingLoginRequests++;
    
    [self openSessionWithPermissionType: kFacebookPermissionTypeEmail
                              onSuccess: ^{
                                  // request me information
                                  [FBRequestConnection startForMeWithCompletionHandler: ^(FBRequestConnection *connection,
                                                                                          NSDictionary<FBGraphUser> *userInfo,
                                                                                          NSError *error) {
                                      if (error)
                                      {
                                          // Graph query failed, so parse NSError userInfo to get description
                                          NSString *errorMessage = [self parsedErrorMessage: error];
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              self.outstandingLoginRequests--;
                                              
                                              if (self.outstandingLoginRequests <= 0)
                                              {
                                                  //Only report error if the very last login attempt failed.
                                                  failureBlock(errorMessage);
                                              }
                                          });
                                      }
                                      else
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              self.outstandingLoginRequests--;
                                              successBlock(userInfo);
                                          });
                                      }
                                  }];
                              }
                              onFailure: ^(NSString *errorMessage) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      self.outstandingLoginRequests--;
                                      
                                      if (self.outstandingLoginRequests <= 0)
                                      {
                                          //Only report error if the very last login attempt failed.
                                          failureBlock(errorMessage);
                                      }
                                  });
                              }];
}


// Logout


- (void) logoutOnSuccess: (FacebookLogoutSuccessBlock) successBlock
               onFailure: (FacebookLogoutFailureBlock) failureBlock
{
    if (FBSession.activeSession.isOpen)
    {
        [FBSession.activeSession closeAndClearTokenInformation];
        if(successBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock();
            });
        }
        
    }
    else
    {
        // If we get here, then some sort of error has occurred
        if(failureBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(@"Session already open");
            });
        }
        
    }
}

- (BOOL) hasActiveSession
{
    return [[FBSession activeSession] isOpen];
}

- (BOOL) hasActiveSessionWithPermissionType:(NSString*)permissionString
{
    return [[FBSession activeSession] isOpen] && !([FBSession.activeSession.permissions indexOfObject:permissionString] == NSNotFound);
}

- (void) openSessionFromExistingToken: (NSString *) token
                            onSuccess: (FacebookOpenSessionSuccessBlock) successBlock
                            onFailure: (FacebookOpenSessionFailureBlock) failureBlock
{
    if (nil == self.tokenCachingStrategy)
    {
        self.tokenCachingStrategy = [[SYNSessionTokenCachingStrategy alloc] initWithToken: token
                                                                           andPermissions: @[FacebookReadPermission]];
        //        // Hard-code for demo purposes, should be set to
        //        // a unique value that identifies the user of the app.
        //        [self.tokenCaching setThirdPartySessionId: @"213465780"];
    }
    
    FBSession *session = [[FBSession alloc] initWithAppID: nil
                                              permissions: @[FacebookReadPermission]
                                          urlSchemeSuffix: nil
                                       tokenCacheStrategy: self.tokenCachingStrategy];
    
    if (session.state == FBSessionStateCreatedTokenLoaded)
    {
        // Set the active session
        [FBSession setActiveSession: session];
        
        // Open the session, but do not use iOS6 system acount login
        // if the caching strategy does not store info locally on the
        // device, otherwise you could use:
        // FBSessionLoginBehaviorUseSystemAccountIfPresent
        [session openWithBehavior: FBSessionLoginBehaviorWithFallbackToWebView
                completionHandler: ^(FBSession *session,
                                     FBSessionState state,
                                     NSError *error) {
                    if (!error)
                    {
                        if (session.isOpen)
                        {
                            successBlock();
                        }
                    }
                    else
                    {
                        failureBlock([error description]);
                    }
                }];
    }
}



// Helper method to open a session if required
- (void) openSessionWithPermissionType: (PermissionType) permissionType
                             onSuccess: (FacebookOpenSessionSuccessBlock) successBlock
                             onFailure: (FacebookOpenSessionFailureBlock) failureBlock
{
    
    NSString* permissionString;
    switch (permissionType) {
            
        case kFacebookPermissionTypeEmail:
            permissionString = FacebookEmailPermission;
            break;
            
        case kFacebookPermissionTypeRead:
            permissionString = FacebookReadPermission;
            break;
            
        case kFacebookPermissionTypePublish:
            permissionString = FacebookPublishPermission;
            break;
            
        default:
            failureBlock([NSString stringWithFormat:@"permissionType '%d' was not recognised", permissionType]);
            return;
    }
    
    // Is the Facebook session already open ?
    if ([FBSession.activeSession isOpen])
    {
        // Check to see that the permissions asked are not already granted...
        if ([FBSession.activeSession.permissions indexOfObject:permissionString] == NSNotFound)
        {
            
            [FBSession.activeSession requestNewPublishPermissions: @[permissionString]
                                                  defaultAudience: FBSessionDefaultAudienceEveryone
                                                completionHandler: ^(FBSession *session, NSError *error) {
                                                    // Permissission denied
                                                    if (error)
                                                    {
                                                        NSString *errorMessage = kFacebookPermissionDenied;
                                                        
                                                        DebugLog(@"** Reauthorize Result: Permission '%@' denied", permissionString);
                                                        // Something went wrong or the user refused permission to access email address
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            failureBlock(errorMessage);
                                                        });
                                                    }
                                                    else
                                                    {
                                                        DebugLog(@"** Reauthorization Result: Suceeded '%@' granted", permissionString);
                                                        
                                                        // OK, the user has now granted required extended permissions...
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            successBlock();
                                                        });
                                                        
                                                        
                                                    }
                                                }];
        }
        else
        {
            
            // We have already been granted the required extended permissions
            DebugLog(@"** Reauthorization Result: Permission '%@' is already granted", permissionString);
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock();
            });
        }
        
        
    }
    else
    {
        // Session not yet open, so open it with 'email' permissions
    
        __block BOOL hasExecuted = NO; // Keep track of whether the completion handler has been called.
        
        
        [FBSession openActiveSessionWithReadPermissions: @[FacebookEmailPermission] // start with 'email' permissions
                                           allowLoginUI: YES
                                      completionHandler: ^(FBSession *session,
                                                           FBSessionState status,
                                                           NSError *error) {
                                          NSString *errorMessage = nil;
                                          
                                          NSLog(@"%@", [session.accessTokenData dictionary]);
                                          
                                          //We only expect this completion handler to be called once. The FBSession seems to store it
                                          //and it gets called again on logout. the hasExecuted boolean flag prevents the block from being called unless it has been
                                          //recreated again during another login attempt.
                                          if (hasExecuted)
                                          {
                                              return;
                                          }
                                          else
                                          {
                                              hasExecuted = YES;
                                          }
                                          
                                          // Check to see if the user cancelled the log in
                                          if (status == FBSessionStateClosedLoginFailed)
                                          {
                                              DebugLog(@"++ openSession: Login cancelled");
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  failureBlock(kFacebookLoginCancelled);
                                              });
                                          }
                                          else
                                          {
                                              if (error)
                                              {
                                                  // Something went wrong, so parse NSError userInfo to get description
                                                  errorMessage = [self parsedErrorMessage: error];
                                                  DebugLog(@"++ openSession: Error:%@", errorMessage);
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      failureBlock(errorMessage);
                                                  });
                                              }
                                              else
                                              {
                                                  if (session.isOpen)
                                                  {
                                                      if (status == FBSessionStateOpen)
                                                      {
                                                          DebugLog(@"++ openSession: Calling recursive");
                                                          // Now here's the clever bit,
                                                          // Now we have an open session, call ourselves recursively so as to possibly extend the permissions
                                                          [self openSessionWithPermissionType: permissionType
                                                                                    onSuccess: successBlock // pass original to avoid double wrapping
                                                                                    onFailure: failureBlock];
                                                      }
                                                      else
                                                      {
                                                          DebugLog(@"++ openSession: Other session state, not calling recursive");
                                                      }
                                                  }
                                                  else
                                                  {
                                                      DebugLog(@"++ openSession: Unknown error");
                                                      // For some reason, the session is not open
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          failureBlock(kFacebookUnknownError);
                                                      });
                                                  }
                                              }
                                          }
                                      }];
    }
}


#pragma mark - Posting to Wall


- (void) postMessageToWall: (NSString *) message
                 onSuccess: (FacebookPostSuccessBlock) successBlock
                 onFailure: (FacebookPostFailureBlock) failureBlock
{
    if (![FBSession.activeSession isOpen] || [[[FBSession activeSession] permissions] indexOfObject: @"publish_actions"] == NSNotFound)
    {
        // reopen session
        
        [self openSessionWithPermissionType: kFacebookPermissionTypeRead | kFacebookPermissionTypePublish
                                  onSuccess: ^{
                                      [self	 postMessageToWall: message
                                                     onSuccess: successBlock
                                                     onFailure: failureBlock];
                                  }
                                  onFailure: ^(NSString *errorMessage) {
                                  }];
        
        return;
    }
    
    NSDictionary *postParams = @{
                                 @"caption": @"First Post",
                                 @"message": message,
                                 @"description": message
                                 };
    
    [FBRequestConnection startWithGraphPath: @"me/feed"
                                 parameters: postParams
                                 HTTPMethod: @"POST"
                          completionHandler: ^(FBRequestConnection *connection, id result, NSError *error) {
                              DebugLog(@"result = %@", result);
                              
                              if (error)
                              {
                                  DebugLog(@"%@", error);
                                  
                                  if (failureBlock)
                                  {
                                      failureBlock(error);
                                  }
                                  
                                  return;
                              }
                              
                              if (successBlock)
                              {
                                  successBlock();
                              }
                          }];
}


// Helper method to extract a user readable string from an NSError returned by a Facebook API call
- (NSString *) parsedErrorMessage: (NSError *) facebookError
{
    NSDictionary *outerDict = (NSMutableDictionary *) [facebookError userInfo];
    NSDictionary *parsedJSONResponseKey = [outerDict isKindOfClass: [NSDictionary class]] ? outerDict[@"com.facebook.sdk:ParsedJSONResponseKey"] : nil;
    NSDictionary *body = [parsedJSONResponseKey isKindOfClass: [NSDictionary class]] ? parsedJSONResponseKey[@"body"] : nil;
    NSDictionary *error = [body isKindOfClass: [NSDictionary class]] ? body[@"error"] : nil;
    NSString *message = error[@"message"];
    
    NSString *errorMessage = @"Unknown error";
    
    if (message)
    {
        // Remove the pesky error code from the front (if it's there)
        NSRange range = [message rangeOfString: message];
        
        // RegEx to detect '(nnn) '
        message = [message stringByReplacingOccurrencesOfString: @"\\(#[0-9]+\\)\\s"
                                                     withString: @""
                                                        options: NSRegularExpressionSearch
                                                          range: range];
        errorMessage = message;
    }
    
    return [NSString stringWithFormat: NSLocalizedString(@"Facebook\n\n%@", nil), errorMessage];
}


- (void) sendAppRequestToFriend: (Friend *) toFriend
                      onSuccess: (FacebookPostSuccessBlock) successBlock
                      onFailure: (FacebookPostFailureBlock) failureBlock
{
    
    
    if (!toFriend || ![[FBSession activeSession] isOpen])
        return;
    
    // Reads the value of the custom key I added to the Info.plist
    NSString *facebookAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"FacebookAppID"];
    
    //
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary: @{@"app_id": facebookAppId}];
    
    // if the Friend's Id was passed correctly we can set it
    if (toFriend.externalUID && ![toFriend.externalUID isEqualToString: @""])
    {
        [params addEntriesFromDictionary: @{@"to": toFriend.externalUID}];
    }
    
    [FBWebDialogs presentRequestsDialogModallyWithSession: [FBSession activeSession]
                                                  message: @"Join me on Rockpack so we can share videos"
                                                    title: @"Invite Friend"
                                               parameters: params
                                                  handler: ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      DebugLog(@"FBWebDialogResult: %@\n%@", result == 0 ? @"Completed" : @"NOT Completed", resultURL);
                                                      
                                                      if (error)
                                                      {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request: %@", error);
                                                          failureBlock(error);
                                                      }
                                                      else
                                                      {
                                                          if (result == FBWebDialogResultDialogNotCompleted)
                                                          {
                                                              NSLog(@"User canceled request by clicking 'X'.");
                                                          }
                                                          else
                                                          {
                                                              NSLog(@"Request Sent of Ok Button Pressed");
                                                              successBlock();
                                                          }
                                                      }
                                                  }];
}





@end
