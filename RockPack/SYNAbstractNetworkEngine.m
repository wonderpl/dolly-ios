//
//  SYNAbstractNetworkEngine.m
//  rockpack
//
//  Created by Nick Banks on 18/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "SYNAbstractNetworkEngine.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkOperationJsonObjectParse.h"
#import "SYNAppDelegate.h"
#import "User.h"

@interface SYNAbstractNetworkEngine ()<UIAlertViewDelegate>
{
    BOOL isShowingNetworkError;
}

@end

@implementation SYNAbstractNetworkEngine

@synthesize hostName;

- (id) initWithDefaultSettings
{
    SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    
    if ((self = [super initWithHostName: self.hostName
                     customHeaderFields: @{@"User-Agent" : appDelegate.userAgentString,
                                           @"Accept-Encoding" : @"gzip"}]))
    {

        
        // Cache registries
        self.registry = appDelegate.mainRegistry;
        self.searchRegistry = appDelegate.searchRegistry;
        
        self.locationString = @"";
        
        // This engine is about requesting JSON objects and uses the appropriate operation type
        [self registerOperationSubclass: [SYNNetworkOperationJsonObject class]];
        
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker set: [GAIFields customDimensionForIndex: kGADimensionLocale]
               value: self.localeString];
    }
    
    return self;
}



- (NSString*) localeString
{
    SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    
    if (appDelegate.currentUser)
    {
        return appDelegate.currentUser.locale;
    }
    else
    {
        return [(NSString*)CFBridgingRelease(CFLocaleCreateCanonicalLanguageIdentifierFromString(NULL, (CFStringRef)[NSLocale.autoupdatingCurrentLocale objectForKey: NSLocaleIdentifier])) lowercaseString];
    }
    
    
}


- (NSString *) hostName
{
    AssertOrLog(@"Should not be calling abstract host name method");
    return nil;
}

#pragma mark - Common functionality

// This code block is common to all of the signup/signin methods
- (void) addCommonHandlerToNetworkOperation:  (SYNNetworkOperationJsonObject *) networkOperation
                          completionHandler: (MKNKUserSuccessBlock) completionBlock
                               errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self addCommonHandlerToNetworkOperation:networkOperation completionHandler:completionBlock errorHandler:errorBlock retryInputStream:nil];
}

// This code block is common to all of the signup/signin methods
- (void) addCommonHandlerToNetworkOperation:  (SYNNetworkOperationJsonObject *) networkOperation
                          completionHandler: (MKNKUserSuccessBlock) completionBlock
                               errorHandler: (MKNKUserErrorBlock) errorBlock
                                retryInputStream: (NSInputStream*) retryInputStream
{    
    // First, copy the network operation so that if authentication fails we can try again
    SYNNetworkOperationJsonObject *retryNetworkOperation = [networkOperation copyForRetry];
    if(retryInputStream)
    {
        [retryNetworkOperation setUploadStream:retryInputStream];
    }
    
    __weak MKNetworkOperation *weakNetworkOperation = networkOperation;
    
    // Set the callback logic for our standard network operation 
    [networkOperation addJSONCompletionHandler: ^(id response)
     {
         // == Check to see if our response is a NSDictionary and if it has an error hash == // 
         if ([response isKindOfClass: [NSDictionary class]] && ((NSDictionary *)response[@"error"] != nil))
         {
             DebugLog(@"API Call failed: %@", response);
             
             // == Now check to see if we need to refresh the token == //
             NSDictionary *responseDictionary = (NSDictionary *) response;
             NSString *reason = responseDictionary[@"error"];
             if([reason isEqualToString:@"invalid_token"])
             {
                //  log the user out
                [[NSNotificationCenter defaultCenter] postNotificationName: kAccountSettingsLogout
                                                                        object: nil];
                errorBlock(response);
                return;
             }
             if ([reason isEqualToString: @"expired_token"] == FALSE)
             {
                 // Normal (?) error, we don't need to try refreshing the token
                 errorBlock(response);
             }
             else
             {
                 // OK, out OAuth2 token has expired, so refresh and try again
                 DebugLog (@"Token expired");
                 
                 [self refreshOAuthTokenWithCompletionHandler: ^(id response)
                  {
                      DebugLog (@"Token refreshed");
                      // Now we have a new authentication token, we need to try the network operation again
                      // Set the callback logic for the network operation re-issued if the authentication token has expired and been renewed
                      [retryNetworkOperation
                       addJSONCompletionHandler: ^(id response) {
                           // Check to see if our response is a NSDictionary and if it has an error hash
                           if ([response isKindOfClass: [NSDictionary class]] && ((NSDictionary *)response[@"error"] != nil))
                           {
                               DebugLog(@"API Call failed: %@", response);
                               
                               // Now check to see if we need to refresh the token
                               NSDictionary *responseDictionary = (NSDictionary *) response;
                               NSString *reason = responseDictionary[@"error"];
                               if ([reason isEqualToString: @"expired_token"]
                                   || [reason isEqualToString: @"invalid_request"]
                                   || [reason isEqualToString: @"invalid_grant"]
                                   || [reason isEqualToString: @"unsupported_grant_type"]
                                   || [reason isEqualToString:@"invalid_token"])
                               {
                                   // Just log the user out
                                   [[NSNotificationCenter defaultCenter] postNotificationName: kAccountSettingsLogout
                                                                                       object: nil];
                               }
                               else
                               {
                                   // Not sure what is wrong, so don't log the user out
                                   DebugLog (@"Failure during network operation retry: %@", reason);
                                   errorBlock(response);
                               }
                               
                           }
                           else
                           {
                               // OK, all seems to have gone well, return the object
                               completionBlock(response);
                           }
                       }
                       errorHandler: ^(id response) {
                           if ([response isKindOfClass: [NSError class]])
                           {
                               NSError *responseError = (NSError *) response;
                               NSDictionary* customErrorDictionary = @{@"network_error" : [NSString stringWithFormat: @"%@, Server responded with %i", responseError.domain, responseError.code ] ,@"nserror" : responseError};
                               DebugLog(@"API Call failed: %@", customErrorDictionary);
                               if (responseError.code >=500 && responseError.code < 600)
                               {
                                   [self showErrorPopUpForError:responseError];
                               }
                               errorBlock(customErrorDictionary);
                           }
                           else if ([response isKindOfClass: [NSDictionary class]] && ((NSDictionary *)response[@"error"] != nil))
                           {
                               DebugLog(@"API Call failed: %@", response);
                               errorBlock(response);
                           }
                           else
                           {
                               // No idea what has been passed back, so try to do the least worst thing...
                               errorBlock(nil);
                           }
                       }];
                      
                      // We now try sending our network operation again
                      [self enqueueSignedOperation: retryNetworkOperation];
                  }
                                                 errorHandler:  ^(id response) {
                                                     DebugLog (@"Failed to refresh token");
                                                     
                                                     if ([response isKindOfClass: [NSDictionary class]])
                                                     {
                                                         NSDictionary *responseDictionary = (NSDictionary *) response;
                                                         
                                                         NSString *errorString =  responseDictionary[@"error"];
                                                         
                                                         if ([errorString isEqualToString: @"invalid_grant"] || [errorString isEqualToString: kUserIdInconsistencyError] )
                                                         {
                                                             [[NSNotificationCenter defaultCenter] postNotificationName: kAccountSettingsLogout
                                                                                                                 object: nil];
                                                         }
                                                         else
                                                         {
                                                             errorBlock(response);
                                                         }
                                                     }
                                                     else
                                                     {
                                                         errorBlock(response);
                                                     }
                                                 }];
             }
         }
         else
         {
             completionBlock(response);
         }
     }
                                  errorHandler: ^(id response)
     {
         if ([response isKindOfClass: [NSError class]])
         {
             NSError *responseError = (NSError *) response;
             NSDictionary* customErrorDictionary = @{@"network_error" : [NSString stringWithFormat: @"%@, Server responded with %i", responseError.domain, responseError.code], @"nserror" : responseError};
             DebugLog(@"API Call failed: %@", customErrorDictionary);
             
             id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
             
             NSString *errorCodeString = [NSString stringWithFormat: @"Error %d", responseError.code];
             
             [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"network"
                                                                    action: errorCodeString
                                                                     label: weakNetworkOperation.url
                                                                     value: nil] build]];
             
             if (responseError.code >=500 && responseError.code < 600)
             {
                 [self showErrorPopUpForError:responseError];
             }
             errorBlock(customErrorDictionary);
         }
         else if ([response isKindOfClass: [NSDictionary class]] && ((NSDictionary *)response[@"error"] != nil))
         {
             DebugLog(@"API Call failed: %@", response);
             errorBlock(response);
         }
         else
         {
             // No idea what has been passed back, so try to do the least worst thing...
             errorBlock(nil);
         }
     }];
}

- (void) enqueueSignedOperation: (MKNetworkOperation *) request
{
    DebugLog (@"Called abstract function - unexpected");
}

- (void) refreshOAuthTokenWithCompletionHandler: (MKNKUserErrorBlock) completionBlock
                                       errorHandler: (MKNKUserSuccessBlock) errorBlock
{
    DebugLog (@"Called abstract function - unexpected");
}


- (NSDictionary *) paramsAndLocaleForStart: (int) start
                                      size: (int) size
{
    NSDictionary *params = nil;
    
    if (size == 0)
    {
        params = [self getLocaleParam];
    }
    else
    {
        
        params = [self getLocaleParamWithParams:@{@"start" : @(start), @"size" : @(size)}];
    }

    return params;
}

- (NSDictionary *) paramsForStart: (int) start
                             size: (int) size
{
    NSDictionary *params = nil;
    
    if (size > 0)
    {
        params = @{@"start" : @(start), @"size" : @(size)};
    }
    
    return params;
}



#pragma mark - Utility Methods

- (NSDictionary*) getLocaleParam
{
    return @{@"locale" : self.localeString, @"location" : self.locationString };
}



-(NSDictionary*)getLocaleParamWithParams: (NSDictionary*) parameters
{

    NSMutableDictionary* completeParams = parameters.mutableCopy;
    [completeParams addEntriesFromDictionary:[self getLocaleParam]];
    return completeParams;
    
}

#pragma mark - HTTP status 5xx errors

-(void)showErrorPopUpForError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!isShowingNetworkError)
        {
            isShowingNetworkError = YES;
            NSString* errorMessage = nil;
            NSString* errorTitle = nil;
            switch (error.code) {
                case 500:
                    errorMessage = NSLocalizedString(@"500_error_message", nil);
                    errorTitle = NSLocalizedString(@"500_error_title", nil);
                    break;
                case 503:
                    errorMessage = NSLocalizedString(@"503_error_message", nil);
                    errorTitle = NSLocalizedString(@"503_error_title", nil);
                    break;
                case 504:
                    errorMessage = NSLocalizedString(@"504_error_message", nil);
                    errorTitle = NSLocalizedString(@"504_error_title", nil);
                    break;
                default:
                    errorMessage = NSLocalizedString(@"unknown_error_message", nil);
                    errorTitle = NSLocalizedString(@"unknown_error_title", nil);
                    break;
            }
            [[[UIAlertView alloc] initWithTitle: errorTitle
                                    message: errorMessage
                                   delegate: self
                          cancelButtonTitle: NSLocalizedString(@"OK", nil)
                          otherButtonTitles: nil] show];
        }
    });
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    isShowingNetworkError = NO;
}


#pragma mark - Abstract Methods

- (MKNetworkOperation *) updateChannel: (NSString *) resourceURL
                       forVideosLength: (NSInteger) length
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock
{
    return [[MKNetworkOperation alloc] init]; // to be implemented in subclass
}
-(void)trackSessionWithMessage:(NSString*)message
{
    // to be implemented in subclass
}


@end
