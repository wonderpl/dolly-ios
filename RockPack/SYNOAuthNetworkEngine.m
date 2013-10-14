//
//  SYNOAuthNetworkEngine.m
//  oauth2demo-iOS
//
//  Created by Nick Banks on 21/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "NSString+Utils.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkOperationJsonObject.h"
#import "SYNOAuth2Credential.h"
#import "SYNOAuthNetworkEngine.h"
#import "NSDictionary+RequestEncoding.h"
#import "SYNFacebookManager.h"
#import "Video.h"
#import "GAI.h"
#import "VideoInstance.h"
#import "UIImage+Resize.h"

@interface SYNOAuthNetworkEngine ()

@property (nonatomic, copy) SYNOAuth2CompletionBlock oAuthCompletionBlock;
@property (nonatomic, copy) SYNOAuth2RefreshCompletionBlock oAuthRefreshCompletionBlock;
@property (nonatomic, strong) SYNOAuth2Credential *oAuth2Credential;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end

@implementation SYNOAuthNetworkEngine

#pragma mark - OAuth2 Housekeeping functions

- (id) initWithDefaultSettings
{
    
    hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"SecureAPIHostName"];

    if ((self = [super initWithDefaultSettings]))
    {
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    // read host from plist
    
    
    return self;
}


- (NSString *) hostName
{
    return hostName;
}


-(SYNOAuth2Credential*)oAuth2Credential
{
    return self.appDelegate.currentOAuth2Credentials;
}


// Enqueues the operation if already authenticated, and if not, tries to authentican and then re-queue if successful
- (void) enqueueSignedOperation: (MKNetworkOperation *) request
{
	// If we're not authenticated, and this is not part of the OAuth process,
	if (!self.oAuth2Credential)
    {
		AssertOrLog(@"enqueueSignedOperation - Not authenticated");
	}
	else
    {   
        [request setAuthorizationHeaderValue: self.oAuth2Credential.accessToken
                                 forAuthType: @"Bearer"];
        
        request.shouldCacheResponseEvenIfProtocolIsHTTPS = TRUE;
        
		[self enqueueOperation: request];
	}
}


#pragma mark - Loggin-In and Signing-Up

// This code block is common to all of the signup/signin methods
- (void) addCommonOAuthPropertiesToUnsignedNetworkOperation: (SYNNetworkOperationJsonObject *) networkOperation
                                                  forOrigin: (NSString*)origin // @"Facebook" | @"Rockpack"
                                          completionHandler: (MKNKLoginCompleteBlock) completionBlock
                                               errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // Add locale to every request
    NSDictionary* localeParam = @{@"locale" : self.localeString};
    [networkOperation addParams: localeParam];
    
    [networkOperation setUsername: kOAuth2ClientId
                         password: @""
                        basicAuth: YES];

    [networkOperation addJSONCompletionHandler: ^(id response)
     {
         if ([response isKindOfClass: [NSDictionary class]])
         {
             NSDictionary *responseDictionary = (NSDictionary *) response;
             
             NSString* possibleError = responseDictionary[@"error"];
             
             if(possibleError)
             {
                 errorBlock(responseDictionary);
                 return;
             }
             
             // if the user loggin in with an external account is not yet registered, a record is created on the fly and 'registered' is sent back
             
             BOOL hasJustBeenRegistered = responseDictionary[@"registered"] ? YES : NO;
             if(hasJustBeenRegistered)
             {
                 id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
                 
                 [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                        action: @"userRegistration"
                                                                         label: origin
                                                                         value: nil] build]];
             }
             
             SYNOAuth2Credential* newOAuth2Credentials = [SYNOAuth2Credential credentialWithAccessToken: responseDictionary[@"access_token"]
                                                                                              expiresIn: responseDictionary[@"expires_in"]
                                                                                           refreshToken: responseDictionary[@"refresh_token"]
                                                                                            resourceURL: responseDictionary[@"resource_url"]
                                                                                              tokenType: responseDictionary[@"token_type"]
                                                                                                 userId: responseDictionary[@"user_id"]];
             if (newOAuth2Credentials == nil)
             {
                 DebugLog(@"Invalid credential returned");
                 errorBlock(@{@"parsing_error": @"credentialWithAccessToken: did not complete correctly"});
                 return;
             }
             
             completionBlock(newOAuth2Credentials);
         }
         else
         {
             // We were expecing a dictionary back, so call error block
             errorBlock(response);
         }
     }
      errorHandler: ^(NSError* error)
     {
         DebugLog(@"Server Failed");
         
         if (error.code >=500 && error.code < 600)
         {
             [self showErrorPopUpForError:error];
         }
         
         NSDictionary* customErrorDictionary = @{@"network_error": [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code], @"nserror" : error };
         errorBlock(customErrorDictionary);
     }];

}


// Send the token data back to the server
- (void) doFacebookLoginWithAccessToken: (NSString*) facebookAccessToken
                                expires: (NSDate *) expirationDate
                            permissions: (NSArray *) permissions
                      completionHandler: (MKNKLoginCompleteBlock) completionBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    NSString *apiString = [NSString stringWithFormat: @"%@?locale=%@", kAPISecureExternalLogin, self.localeString];
    
    NSMutableDictionary* postLoginParams = @{@"external_system" : @"facebook",
                                             @"external_token" : facebookAccessToken}.mutableCopy;
    
    // Add optional information
    if (expirationDate)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName: @"UTC"]];
        [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss"];
        
        postLoginParams[@"token_expires"] = [dateFormatter stringFromDate: expirationDate];
    }
    
    if (permissions)
    {
        postLoginParams[@"token_permissions"] = [permissions componentsJoinedByString: @","];
    }
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*) [self operationWithPath: apiString
                                                                                                        params: postLoginParams
                                                                                                    httpMethod: @"POST"
                                                                                                           ssl: TRUE];
    
    [self addCommonOAuthPropertiesToUnsignedNetworkOperation: networkOperation
                                                   forOrigin: kOriginFacebook
                                           completionHandler: completionBlock
                                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
}


// Get authentication token by using exisiting username and password
- (void) doSimpleLoginForUsername: (NSString*) username
                      forPassword: (NSString*) password
                completionHandler: (MKNKLoginCompleteBlock) completionBlock
                     errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    NSString *apiString = [NSString stringWithFormat: @"%@?locale=%@", kAPISecureLogin, self.localeString];
    
    NSDictionary* postLoginParams = @{@"grant_type" : @"password",
                                      @"username" : username,
                                      @"password" : password};
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*) [self operationWithPath: apiString
                                                                                                        params: postLoginParams
                                                                                                    httpMethod: @"POST"
                                                                                                           ssl: TRUE];
    [self addCommonOAuthPropertiesToUnsignedNetworkOperation: networkOperation
                                                   forOrigin: kOriginRockpack
                                           completionHandler: completionBlock
                                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
}


- (IBAction) refreshOAuthTokenWithCompletionHandler: (MKNKUserErrorBlock) completionBlock
                                       errorHandler: (MKNKUserSuccessBlock) errorBlock
{
    // Check to see that our stored refresh token is not actually nil
    if (self.oAuth2Credential.refreshToken == nil)
    {
        AssertOrLog(@"Stored refresh token is nil");
        errorBlock(@{@"error": kStoredRefreshTokenNilError});
        return;
    }
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    NSString *apiString = [NSString stringWithFormat: @"%@?locale=%@", kAPIRefreshToken, self.localeString];
    
    NSDictionary *refreshParams = @{@"grant_type" : @"refresh_token",
                                    @"refresh_token" : self.oAuth2Credential.refreshToken};

    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*) [self operationWithPath: apiString
                                                                                                        params: refreshParams
                                                                                                    httpMethod: @"POST"
                                                                                                           ssl: TRUE];  
    // Set Basic Authentication username and password
    [networkOperation setUsername: kOAuth2ClientId
                         password: @""
                        basicAuth: YES];
    
    [networkOperation addHeaders: @{@"Content-Type" : @"application/x-www-form-urlencoded"}];
    
    
    [networkOperation addCompletionHandler: ^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *responseDictionary = [completedOperation responseJSON];
         if([self.appDelegate.currentUser.uniqueId isEqualToString:responseDictionary[@"user_id"]])
         {
             // Parse the new OAuth details, creating a new credential object
             SYNOAuth2Credential* newOAuth2Credentials = [SYNOAuth2Credential credentialWithAccessToken: responseDictionary[@"access_token"]
                                                                                          expiresIn: responseDictionary[@"expires_in"]
                                                                                       refreshToken: responseDictionary[@"refresh_token"]
                                                                                        resourceURL: responseDictionary[@"resource_url"]
                                                                                          tokenType: responseDictionary[@"token_type"]
                                                                                             userId: responseDictionary[@"user_id"]];
         
             // Save the new credential object in the keychain
             // The user passed back is assumed to be the current user
             [newOAuth2Credentials saveToKeychainForService: [[NSBundle mainBundle] bundleIdentifier]
                                                    account: responseDictionary[@"user_id"]];
             completionBlock(responseDictionary);
        }
        else
        {
            AssertOrLog(@"Refreshed OAuth2 credentials do not match the current user!!");
            errorBlock(@{@"error": kUserIdInconsistencyError});
        }
     }
     errorHandler: ^(MKNetworkOperation* completedOperation, NSError* error)
     {
         
         if (error.code >=500 && error.code < 600)
         {
             [self showErrorPopUpForError:error];
         }
         
         NSDictionary *responseDictionary = [completedOperation responseJSON];
         errorBlock(responseDictionary);
         DebugLog (@"failed");
     }];
    
    [self enqueueOperation: networkOperation];
}


// Get authentication token by registering details with server
- (void) registerUserWithData: (NSDictionary*) userData
            completionHandler: (MKNKLoginCompleteBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    NSString *apiString = [NSString stringWithFormat: @"%@?locale=%@", kAPISecureRegister, self.localeString];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: userData
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonOAuthPropertiesToUnsignedNetworkOperation: networkOperation
                                                   forOrigin: kOriginRockpack
                                           completionHandler: completionBlock
                                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
}


- (void) doRequestPasswordResetForUsername: (NSString*) username
                        completionHandler: (MKNKJSONCompleteBlock) completionBlock
                             errorHandler: (MKNKErrorBlock) errorBlock
{
    NSDictionary* requestData = @{@"username" : username};

    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    NSString *apiString = [NSString stringWithFormat: @"%@?locale=%@", kAPIPasswordReset, self.localeString];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: requestData
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/x-www-form-urlencoded"}];
    
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeURL;
    
    [networkOperation setUsername: kOAuth2ClientId
                         password: @""
                        basicAuth: YES];
    
    [networkOperation addJSONCompletionHandler: completionBlock
                                  errorHandler:^(NSError *error) {
                                      if (error.code >=500 && error.code < 600)
                                      {
                                          [self showErrorPopUpForError:error];
                                      }
                                      errorBlock(error);
                                  }];
    
    [self enqueueOperation: networkOperation];

}

- (void) doRequestUsernameAvailabilityForUsername: (NSString*) username
                         completionHandler: (MKNKJSONCompleteBlock) completionBlock
                              errorHandler: (MKNKErrorBlock) errorBlock
{
    NSDictionary* requestData = @{@"username" : username};
    
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    NSString *apiString = [NSString stringWithFormat: @"%@?locale=%@", kAPIUsernameAvailability, self.localeString];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: requestData
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/x-www-form-urlencoded"}];
    
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeURL;
    
    [networkOperation setUsername: kOAuth2ClientId
                         password: @""
                        basicAuth: YES];
    
    [networkOperation addJSONCompletionHandler: completionBlock
                                  errorHandler:^(NSError *error) {
                                      if (error.code >=500 && error.code < 600)
                                      {
                                          [self showErrorPopUpForError:error];
                                      }
                                      errorBlock(error);
                                  }];
    
    [self enqueueOperation: networkOperation];
    
}



#pragma mark - User Data

- (void) notificationsFromUserId: (NSString *) userId
               completionHandler: (MKNKUserErrorBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIGetUserNotifications stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: @{@"locale" : self.localeString}
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

- (void) markAsReadForNotificationIndexes: (NSArray*) indexes
                               fromUserId: (NSString*)userId
                        completionHandler: (MKNKUserErrorBlock) completionBlock
                             errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIGetUserNotifications stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    apiString = [NSString stringWithFormat: @"%@?locale=%@", apiString, self.localeString];
    
    NSDictionary *params = @{@"mark_read" : indexes};
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

-(void)userDataForUser:(User*)user
          onCompletion:(MKNKUserSuccessBlock) completionBlock
               onError: (MKNKUserErrorBlock) errorBlock
{
    if(!user || !user.uniqueId || ![user.uniqueId isKindOfClass:[NSString class]]) {
        errorBlock(@{@"parameter_error":@"the user passed has no unique id or is null"});
        return;
    }
        
    
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : user.uniqueId};
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"start"] = @(0);
    
    parameters[@"size"] = @(1000);
    
    parameters[@"locale"] = self.localeString;
    
    NSString *apiString = [kAPIGetUserDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: parameters
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: YES];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    
    
    [self enqueueSignedOperation: networkOperation];
    
    
}

-(void)userSubscriptionsForUser:(User*)user
                   onCompletion:(MKNKUserSuccessBlock) completionBlock
                        onError: (MKNKUserErrorBlock) errorBlock
{
    
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : user.uniqueId};
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"start"] = @(0);
    
    parameters[@"size"] = @(1000);
    
    
   
    NSString *apiString = [kAPIGetUserSubscriptions stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: [self getLocaleParamWithParams:parameters]
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: YES];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    
    
    [self enqueueSignedOperation: networkOperation];
    
}


- (void) retrieveAndRegisterUserFromCredentials: (SYNOAuth2Credential *) credentials
                              completionHandler: (MKNKUserSuccessBlock) completionBlock
                                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : credentials.userId};
    
    NSString *apiString = [kAPIGetUserDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    NSMutableString* apiMutString = [NSMutableString stringWithString:apiString];
    [apiMutString appendFormat:@"?locale=%@&data=channels&data=external_accounts&data=flags", self.localeString];
    
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: [NSString stringWithString:apiMutString]
                                                                                                       params: nil
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: YES];
    
    
    
    
    
    networkOperation.ignoreCachedResponse = YES; // hack to get the operation read the headers
        
    [networkOperation addJSONCompletionHandler:^(NSDictionary *responseDictionary)
    {
        
        NSString* possibleError = responseDictionary[@"error"];
         
        if (possibleError)
        {
            errorBlock(responseDictionary);
            return;
        }
        
        
        // Register User
        
        BOOL userRegistered = [self.registry registerUserFromDictionary:responseDictionary];
        if(!userRegistered) {
            errorBlock(@{@"saving_error" : @"Main Registry Could Not Save the User"});
            return;
        }

        // Get subscriptions
        
        NSString* userId = responseDictionary[@"id"];

        [self channelSubscriptionsForUserId:userId
                                 credential:credentials
                                      start:0
                                       size:50
                          completionHandler:^(id subscriptionsDictionary) {
                              NSString* possibleError = subscriptionsDictionary[@"error"];
                              
                              if (possibleError)
                              {
                                  errorBlock(responseDictionary);
                                  return;
                              }
                              
                              BOOL userRegistered = [self.registry registerSubscriptionsForCurrentUserFromDictionary:subscriptionsDictionary];
                              if(!userRegistered)
                                  return;
                              
                              completionBlock(responseDictionary);
                          }
                               errorHandler:^(id errorObject) {
                                   if([errorObject isKindOfClass:[NSDictionary class]])
                                   {
                                       errorBlock(errorObject);
                                   }
                                   else if([errorObject isKindOfClass:[NSError class]])
                                   {
                                       NSError* error = (NSError*) errorObject;
                                       
                                       if (error.code >=500 && error.code < 600)
                                       {
                                           [self showErrorPopUpForError:error];
                                       }
                                       
                                       DebugLog(@"API Call failed");
                                       NSDictionary* customErrorDictionary = @{@"network_error" : [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code] , @"nserror" : error };
                                       errorBlock(customErrorDictionary);
                                   }
                                   else
                                   {
                                       errorBlock(nil);
                                   }
                                   
                               }];
    }
                                  errorHandler: ^(NSError* error)
     {
         DebugLog(@"API Call failed");
         
         if (error.code >=500 && error.code < 600)
         {
             [self showErrorPopUpForError:error];
         }
         
         NSDictionary* customErrorDictionary = @{@"network_error" : [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code] , @"nserror" : error };
         errorBlock(customErrorDictionary);
     }];
    
    [networkOperation setAuthorizationHeaderValue: credentials.accessToken
                                      forAuthType: @"Bearer"];
    
    [self enqueueOperation: networkOperation];
    
    
}



- (void) changeUserField: (NSString*) userField
                 forUser: (User *) user
            withNewValue: (id)newValue
       completionHandler: (MKNKUserSuccessBlock) completionBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : user.uniqueId, @"ATTRIBUTE" : userField};
    
    NSString *apiString = [kAPIChangeUserFields stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: YES];

    if ([newValue isKindOfClass: [NSString class]])
    {
        [networkOperation setCustomPostDataEncodingHandler: ^ NSString * (NSDictionary *postDataDict) {
            // Wrap it in quotes to make it valid JSON
            NSString *JSONFormattedFieldValue = [NSString stringWithFormat: @"\"%@\"", (NSString*)newValue];
            return JSONFormattedFieldValue;
            
        } forType: @"application/json"];
    }
    else if ([newValue isKindOfClass:[NSNumber class]])
    {
        // in reality the only case of passing a number is for a BOOL
        [networkOperation setCustomPostDataEncodingHandler: ^ NSString * (NSDictionary *postDataDict) {
            
            // Wrap it in quotes to make it valid JSON
            NSString *JSONFormattedBoolValue = ((NSNumber*)newValue).boolValue ? @"true" : @"false";
            return JSONFormattedBoolValue;
            
        } forType: @"application/json"];
    }
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) changeUserPasswordWithOldValue: (NSString*) oldPassword
                            andNewValue: (NSString*) newValue
                              forUserId: (NSString *) userId
                      completionHandler: (MKNKUserSuccessBlock) completionBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock;
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIChangeuserPassword stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    NSDictionary *params = @{@"old" : oldPassword,
                             @"new" : newValue};
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

#pragma mark - Avatars

- (void) updateAvatarForUserId: (NSString *) userId
                         image: (UIImage *) image
             completionHandler: (MKNKUserSuccessBlock) completionBlock
                  errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIUpdateAvatar stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: TRUE];

    UIImage *newImage = [UIImage scaleAndRotateImage: image
                                         withMaxSize: 600];
    
    
//        DebugLog(@"New image width: %f, height%f", newImage.size.width, newImage.size.height);
    // We have to perform the image upload with an input stream

    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.70);
    
    // Other attempts at performing scaling
    //    NSData *imageData = UIImagePNGRepresentation(newImage);
    //    NSData *imageData = UIImageJPEGRepresentation(image, 0.70);
    //    NSData *imageData = [image jpegDataForResizedImageWithMaxDimension: 600];
    
    NSString *lengthString = [NSString stringWithFormat: @"%@", @(imageData.length)];
    NSInputStream *inputStream = [NSInputStream inputStreamWithData: imageData];
    networkOperation.uploadStream = inputStream;
    
    [networkOperation addHeaders: @{@"Content-Type" : @"image/jpeg", @"Content-Length" : lengthString}];
    SYNAppDelegate* blockAppDelegate = self.appDelegate;
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: ^(NSDictionary* result) {
                               NSDictionary* headerDictionary = [networkOperation.readonlyResponse allHeaderFields];
                               User* currentUser = blockAppDelegate.currentUser;
                               
                               if (currentUser)
                               {
                                   NSString *newThumbnailURL = headerDictionary[@"Location"];
                                   currentUser.thumbnailURL = newThumbnailURL;
                                   [blockAppDelegate saveContext: YES];
                                   [[NSNotificationCenter defaultCenter] postNotificationName: kUserDataChanged
                                                                                       object: nil
                                                                                     userInfo: @{@"user":currentUser}];
                               }
                               if(completionBlock) //Important to nil check blocks - otherwise crash may ensue!
                               {
                                   completionBlock(headerDictionary);
                               }
                           }
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


#pragma mark - Channel management

- (void) channelCreatedForUserId: (NSString *) userId
                       channelId: (NSString *) channelId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock {
    
    [self channelDataForUserId:userId
                     channelId:channelId
                       inRange: NSMakeRange(0, 1000)
             completionHandler:completionBlock
                  errorHandler:errorBlock];

}


- (void) channelDataForUserId: (NSString *) userId
                    channelId: (NSString *) channelId
                      inRange: (NSRange) range
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"start"] = @(range.location);
    
    parameters[@"size"] = @(range.length);
    
    NSString *apiString = [kAPIGetChannelDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: [self getLocaleParamWithParams: parameters]
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) manageChannelForUserId: (NSString *) userId
                          title: (NSString *) title
                    description: (NSString *) description
                       category: (NSString *) category
                          cover: (NSString *) cover
                       isPublic: (BOOL) isPublic
                      apiString: apiString
                       httpVerb: (NSString *) httpVerb
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *params = nil;
    
    if (title && description && category && cover)
    {
        params = @{@"title" : title,
                   @"description" : description,
                   @"category" : category,
                   @"cover" : cover,
                   @"public" : @(isPublic)};
    }
    else
    {
        AssertOrLog(@"One or more of the required parameters is nil");
    }


    apiString = [NSString stringWithFormat: @"%@?locale=%@", apiString, self.localeString];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: httpVerb
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


// Wrapper function for channel creation
- (void) createChannelForUserId: (NSString *) userId
                          title: (NSString *) title
                    description: (NSString *) description
                       category: (NSString *) category
                          cover: (NSString *) cover
                       isPublic: (BOOL) isPublic
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    NSString *apiString = [kAPICreateNewChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    [self manageChannelForUserId: userId
                           title: title
                     description: description
                        category: category
                           cover: cover
                        isPublic: isPublic
                       apiString: apiString
                        httpVerb: @"POST"
               completionHandler: completionBlock
                    errorHandler: errorBlock];
}


// Wrapper function for channel update
- (void) updateChannelForUserId: (NSString *) userId
                      channelId: (NSString *) channelId
                          title: (NSString *) title
                    description: (NSString *) description
                       category: (NSString *) category
                          cover: (NSString *) cover
                       isPublic: (BOOL) isPublic
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIUpdateExistingChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    [self manageChannelForUserId: userId
                           title: title
                     description: description
                        category: category
                           cover: cover
                        isPublic: isPublic
                        apiString: apiString
                        httpVerb: @"PUT"
               completionHandler: completionBlock
                    errorHandler: errorBlock];
}


- (void) updatePrivacyForChannelForUserId: (NSString *) userId
                                channelId: (NSString *) channelId
                                isPublic: (BOOL) isPublic
                        completionHandler: (MKNKUserSuccessBlock) completionBlock
                             errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIUpdateChannelPrivacy stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: TRUE];
    [networkOperation setCustomPostDataEncodingHandler: ^NSString * (NSDictionary *postDataDict)
     {
         // Wrap it in quotes to make it valid JSON
         NSString *privacyValueString = [NSString stringWithFormat: @"%@", isPublic ? @"true" : @"false"];
         return privacyValueString;
     }
     forType: @"application/json"];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) deleteChannelForUserId: (NSString *) userId
                      channelId: (NSString *) channelId
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIDeleteChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"DELETE"
                                                                                                          ssl: TRUE];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) videosForChannelForUserId: (NSString *) userId
                         channelId: (NSString *) channelId
                           inRange: (NSRange) range
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIGetVideosForChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"start"] = @(range.location);
    parameters[@"size"] = @(range.length);
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: [self getLocaleParamWithParams:parameters]
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) updateVideosForChannelForUserId: (NSString *) userId
                               channelId: (NSString *) channelId
                        videoInstanceSet: (NSOrderedSet *) videoInstanceSet
                           clearPrevious: (BOOL) clearPrevious
                       completionHandler: (MKNKUserSuccessBlock) completionBlock
                            errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIUpdateVideosForChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];

    apiString = [NSString stringWithFormat: @"%@?locale=%@", apiString, self.localeString];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: (clearPrevious ? @"PUT" : @"POST")
                                                                                                          ssl: TRUE];
    
    
    
    
    NSArray* videoIdArray = [[videoInstanceSet array] valueForKey:@"uniqueId"];
    
    
    [networkOperation setCustomPostDataEncodingHandler: ^ NSString * (NSDictionary *postDataDict)
    {
         
         NSError *error;
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject: videoIdArray
                                                            options: 0
                                                              error: &error];
         
         NSString *jsonString = [[NSString alloc] initWithData: jsonData
                                                      encoding: NSUTF8StringEncoding];
        
//        DebugLog(@"%@", jsonString);
        
         return jsonString;
     }
     forType: @"application/json"];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (MKNetworkOperation *) updateRecommendedChannelsScreenForUserId: (NSString *) userId
                                                          forRange: (NSRange) range
                                                    ignoringCache: (BOOL) ignore
                                                     onCompletion: (MKNKJSONCompleteBlock) completeBlock
                                                          onError: (MKNKJSONErrorBlock) errorBlock
{
    NSMutableDictionary *tempParameters = [NSMutableDictionary dictionary];
    
    tempParameters[@"start"] = [NSString stringWithFormat: @"%i", range.location];
    tempParameters[@"size"] = [NSString stringWithFormat: @"%i", range.length];
    
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    NSString *apiString = [kAPIRecommendedChannels stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *) [self operationWithPath: apiString
                                                                                                         params: [self getLocaleParamWithParams: tempParameters]
                                                                                                     httpMethod: @"GET"
                                                                                                            ssl: TRUE];
    
//    networkOperation.ignoreCachedResponse = ignore;
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        completeBlock(dictionary);
    } errorHandler: ^(NSError *error) {
        errorBlock(@{@"network_error": @"Engine Failed to Load Channels"});
        
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
    }];
    
    [self enqueueSignedOperation: networkOperation];
    
    return networkOperation;
}



- (MKNetworkOperation*) updateChannel: (NSString *) resourceURL
                      forVideosLength: (NSInteger) length
                    completionHandler: (MKNKUserSuccessBlock) completionBlock
                         errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // get the path stripping the "http://" because we might want to force a refresh by using "https://"
    
    NSRange rangeOfWS = [resourceURL rangeOfString:@"/ws"];
    NSString* onlyThePathPart = [resourceURL substringFromIndex:rangeOfWS.location];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"start"] = @(0);
    
    parameters[@"size"] = @(length);
    
    parameters[@"locale"] = self.localeString;
    
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath:onlyThePathPart
                                                                                                       params:parameters
                                                                                                   httpMethod:@"GET"
                                                                                                          ssl:YES];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
    
    return networkOperation;
    
}




// User activity

- (void) recordActivityForUserId: (NSString *) userId
                          action: (NSString *) action
                 videoInstanceId: (NSString *) videoInstanceId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIRecordUserActivity stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    apiString = [NSString stringWithFormat: @"%@?locale=%@", apiString, self.localeString];
    
    NSDictionary *params = nil;
    
    if (action && videoInstanceId)
    {
    params = @{@"action" : action,
                             @"video_instance" : videoInstanceId};
    }
    else
    {
        AssertOrLog(@"One or more of the required parameters is nil");
    }

    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) activityForUserId: (NSString *) userId
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIGetUserActivity stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


// Cover art

- (void) updateCoverArtForUserId: (NSString *) userId
                    onCompletion: (MKNKVoidBlock) completionBlock
                            onError: (MKNKErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIGetUserCoverArt stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: [self getLocaleParam]
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    __weak SYNOAuthNetworkEngine* wself = self;
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: ^(NSDictionary *dictionary) {
                               BOOL registryResultOk = [wself.registry registerCoverArtFromDictionary: dictionary
                                                                                           forUserUpload: YES];
                               if (!registryResultOk)
                                   return;
                               
                               completionBlock();
                           }
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) coverArtForUserId: (NSString *) userId
                     start: (unsigned int) start
                      size: (unsigned int) size
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSDictionary *params = [self paramsForStart: start
                                           size: size];
    
    NSString *apiString = [kAPIGetUserCoverArt stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) uploadCoverArtForUserId: (NSString *) userId
                           image: (UIImage *) image
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIUploadUserCoverArt stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    apiString = [NSString stringWithFormat: @"%@?locale=%@", apiString, self.localeString];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    // We have to perform the image upload with an input stream
    UIImage *newImage = [UIImage scaleAndRotateImage: image
                                         withMaxSize: 2028];
    
    
//    DebugLog(@"New image width: %f, height%f", newImage.size.width, newImage.size.height);
    // We have to perform the image upload with an input stream
    
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.70);

    NSString *lengthString = [NSString stringWithFormat: @"%@", @(imageData.length)];
    NSInputStream *inputStream = [NSInputStream inputStreamWithData: imageData];
    networkOperation.uploadStream = inputStream;
    
    [networkOperation addHeaders: @{@"Content-Type" : @"image/jpeg", @"Content-Length" : lengthString}];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock retryInputStream:[NSInputStream inputStreamWithData: imageData]];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) deleteCoverArtForUserId: (NSString *) userId
                         coverId: (NSString *) coverId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"COVERID" : coverId};
    
    NSString *apiString = [kAPIDeleteUserCoverArt stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"DELETE"
                                                                                                          ssl: TRUE];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


#pragma mark - Subscriptions

- (void) channelSubscriptionsForUserId: (NSString *) userId
                            credential: (SYNOAuth2Credential*)credential
                                 start: (unsigned int) start
                                  size: (unsigned int) size
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSDictionary *params = [self paramsAndLocaleForStart:start size:size];
    
    // we are not using the subscriptions_url returned from user info data but using a std one.
    NSString *apiString = [kAPIGetUserSubscriptions stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: YES];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [networkOperation setAuthorizationHeaderValue: credential.accessToken
                                      forAuthType: @"Bearer"];
    
    [self enqueueOperation: networkOperation];
}

- (void) channelSubscribeForUserId: (NSString *) userId
                        channelURL: (NSString *) channelURL
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPICreateUserSubscription stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];

    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    apiString = [NSString stringWithFormat: @"%@?locale=%@", apiString, self.localeString];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: YES];
    
    
    [networkOperation setCustomPostDataEncodingHandler: ^NSString * (NSDictionary *postDataDict)
     {
         // Wrap it in quotes to make it valid JSON
         NSString *channelURLJSONString = [NSString stringWithFormat: @"\"%@\"", channelURL];
         return channelURLJSONString;
     }
     forType: @"application/json"];
    
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
    
//    DebugLog(@"%@", networkOperation);
}

- (void) channelUnsubscribeForUserId: (NSString *) userId
                           channelId: (NSString *) channelId
                   completionHandler: (MKNKUserSuccessBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"SUBSCRIPTION" : channelId};
    
    NSString *apiString = [kAPIDeleteUserSubscription stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"DELETE"
                                                                                                          ssl: YES];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}



// This is NOT the method called when User logs in for their subscriptions, its called by the FeedViewController

- (void) subscriptionsUpdatesForUserId: (NSString *) userId
                                 start: (unsigned int) start
                                  size: (unsigned int) size
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIUserSubscriptionUpdates stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    NSDictionary *params = [self paramsAndLocaleForStart: start
                                                    size: size];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: YES];
    
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];

    [self enqueueSignedOperation: networkOperation];  
}

- (void) feedUpdatesForUserId: (NSString *) userId
                        start: (unsigned int) start
                         size: (unsigned int) size
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIContentFeedUpdates stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    NSDictionary *params = [self paramsAndLocaleForStart: start
                                                    size: size];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: YES];
    
    
    
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

-(void)getFlagsforUseId:(NSString*)userId
      completionHandler: (MKNKUserSuccessBlock) completionBlock
           errorHandler: (MKNKUserSuccessBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kFlagsGetAll stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: YES];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
    
}


-(void)setFlag:(NSString*)flag withValue:(BOOL)value forUseId:(NSString*)userId
    completionHandler: (MKNKUserSuccessBlock) completionBlock
    errorHandler: (MKNKUserSuccessBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId, @"FLAG": flag};
    
    NSString *apiString = [kFlagsSet stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: (value ? @"PUT" : @"DELETE")
                                                                                                          ssl: YES];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
    
}


- (void) shareLinkWithObjectType: (NSString *) objectType
                        objectId: (NSString *) objectId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    NSString *apiString = [NSString stringWithFormat: @"%@?locale=%@", kAPIShareLink, self.localeString];
    
    NSDictionary *params = nil;
    
    if (objectType && objectId)
    {
        params = @{@"object_type" : objectType,
                   @"object_id" : objectId};
    }
    else
    {
        AssertOrLog(@"One or more of the required parameters is nil");
    }

    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

- (void) emailShareWithObjectType: (NSString *) shareType
                         objectId: (NSString *) objectId
                       withFriend: (Friend *) friendToShare
                completionHandler: (MKNKUserSuccessBlock) completionBlock
                     errorHandler: (MKNKUserErrorBlock) errorBlock
{
    if (!objectId || !friendToShare)
    {
        errorBlock (@{@"params_error": [NSString stringWithFormat: @"params sent: %@ %@", objectId, friendToShare]});
        return;
    }
    
    NSString *apiString = [NSString stringWithFormat: @"%@?locale=%@", kAPIShareEmail, self.localeString];
    
    NSMutableDictionary *params = @{@"object_type": shareType,
                                   @"object_id": objectId,
                                   @"email": friendToShare.email}.mutableCopy;
    
    if(friendToShare.displayName)
        [params addEntriesFromDictionary:@{@"name":friendToShare.displayName}];
    
    if(friendToShare.externalSystem && friendToShare.externalUID)
       [params addEntriesFromDictionary:@{@"external_system":friendToShare.externalSystem,
                                          @"external_uid":friendToShare.externalUID}];
    
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *) [self operationWithPath: apiString
                                                                                                         params: params
                                                                                                     httpMethod: @"POST"
                                                                                                            ssl: YES];
    [networkOperation addHeaders: @{@"Content-Type": @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) reportConcernForUserId: (NSString *) userId
                     objectType: (NSString *) objectType
                       objectId: (NSString *) objectId
                         reason: (NSString *) reason
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIReportConcern stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    apiString = [NSString stringWithFormat: @"%@?locale=%@", apiString, self.localeString];
    
    NSDictionary *params = nil;
    
    if (objectType && objectId && reason)
    {
        params = @{@"object_type" : objectType,
                   @"object_id" : objectId,
                   @"reason" : reason};
    }
    else
    {
        AssertOrLog(@"One or more of the required parameters is nil");
    }
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) reportPlayerErrorForVideoInstanceId: (NSString *) videoInstanceId
                            errorDescription: (NSString *) errorDescription
                           completionHandler: (MKNKUserSuccessBlock) completionBlock
                                errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    NSString *apiString = [NSString stringWithFormat: @"%@?locale=%@", kAPIReportPlayerError, self.localeString];
    
    NSDictionary *params = nil;
    
    if (videoInstanceId && errorDescription)
    {
        params = @{@"video_instance" : videoInstanceId,
                   @"error" : errorDescription};
    }
    else
    {
        AssertOrLog(@"One or more of the required parameters is nil");
    }

    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


#pragma mark - Push notification token update

- (void) updateApplePushNotificationForUserId: (NSString *) userId
                                        token: (NSString *) token
                            completionHandler: (MKNKUserSuccessBlock) completionBlock
                                 errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self connectExternalAccoundForUserId:userId
                              accountData:@{@"external_system": @"apns", @"external_token" : token}
                        completionHandler:completionBlock
                             errorHandler:errorBlock];
}

- (void) connectFacebookAccountForUserId: (NSString*)userId
                      andAccessTokenData: (FBAccessTokenData*)data
                       completionHandler: (MKNKUserSuccessBlock) completionBlock
                            errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    
    NSMutableDictionary* accountData = @{@"external_system": @"facebook",
                                         @"external_token" : data.accessToken,
                                         @"token_permissions" : [data.permissions componentsJoinedByString:@","]}.mutableCopy;
    
    if (data.expirationDate)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName: @"UTC"]];
        [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss"];
        
        accountData[@"token_expires"] = [dateFormatter stringFromDate: data.expirationDate];
    }
    
    // this will also register the external account returned in CoreData with using the same JSON it sends in the request
    
    [self connectExternalAccoundForUserId:userId
                              accountData:accountData
                        completionHandler:completionBlock
                             errorHandler:errorBlock];
}

- (void) getExternalAccountForUserId:(NSString*)userId
                           accountId:(NSString*)accountId
                   completionHandler: (MKNKUserSuccessBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    NSString *apiString = [kGetExternalAccountId stringByReplacingOccurrencesOfStrings: @{@"USERID" : userId, @"ACCOUNTID" : accountId}];
    
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: YES];
    
    NSLog(@"%@", networkOperation.url);
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

-(void)getExternalAccountForUrl: (NSString*)urlString
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithURLString:urlString];
    
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

/*
 {
 "external_system": "facebook",
 "external_token": "xxx",
 "token_expires": "2013-03-28T19:16:13",
 "token_permissions": "read,write",
 "meta": {
    "key": "value"
 }
 }
 */
- (void) connectExternalAccoundForUserId: (NSString*) userId
                             accountData: (NSDictionary*)accountData
                        completionHandler: (MKNKUserSuccessBlock) completionBlock
                            errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // Check if any nil parameters passed in (defensive)
    if (!accountData || !userId)
    {
        AssertOrLog(@"connectToExtrnalAccoundForUserId error with: %@ %@", accountData, userId);
        return;
    }
   
    
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kRegisterExternalAccount stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];

    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: accountData
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: YES];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    __weak SYNOAuthNetworkEngine* wself = self;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler:^(id responce) {
                               
                               // use the same JSON that is sent in the request , some fields might be missing but they can
                               // always be retrieved later
                               
                               BOOL didRegister = [wself.registry registerExternalAccountWithCurrentUserFromDictionary:accountData];
                               if(!didRegister) {
                                   errorBlock(@{@"registry_error" : @"could not register external account"});
                                   return;
                               }
                                   
                               
                               completionBlock(responce);
                               
                               
                           } errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

- (SYNNetworkOperationJsonObject*) friendsForUser: (User*)user
                                       onlyRecent: (BOOL)recent
                                completionHandler: (MKNKUserSuccessBlock) completionBlock
                                     errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    if(!user)
        return nil;
    
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : user.uniqueId};
    
    NSString *apiString = [kAPIFriends stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    if(recent)
        params[@YES] = @"share_filter";
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: YES];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
    
    return networkOperation;
}

-(void)getClientIPBasedLocation
{
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: kLocationService
                                                                                                       params: nil
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: YES];
    __weak SYNOAuthNetworkEngine* wself = self;
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler:^(id responce) {
                               
                               if(![responce isKindOfClass:[NSString class]])
                                   return;
                               
                               [wself.registry registerIPBasedLocation:responce];
                               
                           } errorHandler:^(id error) {
                               
                           }];
    
    [self enqueueOperation: networkOperation];
}

-(void)trackSessionWithMessage:(NSString*)message
{
    
    
    NSString* did = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSMutableDictionary *params = @{@"device":did}.mutableCopy;
    
    if(message)
        [params addEntriesFromDictionary:@{@"trigger":message}];
       
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithPath: kAPIReportSession
                                                       params: params
                                                   httpMethod: @"POST" ssl:YES];
    
    [networkOperation setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool: YES forKey: kUserDefaultsNotFirstInstall];
        
        
        
    } errorHandler: ^(NSError *error) {
        DebugLog(@"API request failed");
    }];
    
    [self enqueueOperation: networkOperation];
}

@end
