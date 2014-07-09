//
//  SYNTwitterManager.m
//  dolly
//
//  Created by Cong on 07/07/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNTwitterManager.h"
#import "SYNAppDelegate.h"
#import "TWSignedRequest.h"
#import "SYNOAuthNetworkEngine.h"

@import Accounts;
@import Social;
@import Twitter;

#define TW_API_ROOT @"https://api.twitter.com"

static NSString * const kOAuthUrlRequestToken = TW_API_ROOT "/oauth/request_token";
static NSString * const kOAuthUrlToken = TW_API_ROOT @"/oauth/access_token";

static NSString * const kXReverseAuthParameters = @"x_reverse_auth_parameters";
static NSString * const kXReverseAuthTarget = @"x_reverse_auth_target";
static NSString * const kXAuthMode = @"x_auth_mode";
static NSString * const kReverseAuth = @"reverse_auth";
static NSString * const kOAuthTokenIdentifier = @"oauth_token";
static NSString * const kOAuthTokenSecretIdentifier = @"oauth_token_secret";

@interface SYNTwitterManager ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, assign) NSInteger accountIndex;

@end


@implementation SYNTwitterManager

+ (instancetype) sharedTwitterManager
{
    static dispatch_once_t onceQueue;
    static SYNTwitterManager *twitterManager = nil;
    
    dispatch_once(&onceQueue, ^{
        twitterManager = [[self alloc] init];
    });
    
    return twitterManager;
}
-(id)init {
	if (self = [super init]) {
        _accountStore = [[ACAccountStore alloc] init];
        self.accountIndex = 0;
    }
    return self;
}

- (void) loginWithAccount:(ACAccount *)account
                OnSuccess:(TwitterLoginSuccessBlock)successBlock
                onFailure:(TwitterLoginFailureBlock)failureBlock {
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	[self performReverseAuthForAccount:account withHandler:^(NSData *responseData, NSError *error) {
        if (responseData) {
            
            NSString *token = [self createExternalTokenFromDict:responseData];
            
            [appDelegate.oAuthNetworkEngine doTwitterLoginWithAccessToken:token completionHandler:^(SYNOAuth2Credential * credentials) {
                
                successBlock(credentials);
                
            } errorHandler:^(id error) {
                failureBlock(error);
            }];
        }
        else {
            DebugLog(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
        }
    }];
}

- (NSString*) createExternalTokenFromDict:(NSData*) responseData {
    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (NSString *str in parts) {
        NSArray *keyValue = [str componentsSeparatedByString:@"="];
        [dict addEntriesFromDictionary:@{[keyValue firstObject]: [keyValue lastObject]}];
    }

    return [NSString stringWithFormat:@"%@:%@",dict[kOAuthTokenIdentifier], dict[kOAuthTokenSecretIdentifier]];
}

- (void)performReverseAuthForAccount:(ACAccount *)account
                         withHandler:(TWAPIHandler)handler {
    NSParameterAssert(account);

    [self _step1WithCompletion:^(NSData *data, NSError *error) {
        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil, error);
            });
        }
        else {
            NSString *signedReverseAuthSignature = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self _step2WithAccount:account signature:signedReverseAuthSignature andHandler:^(NSData *responseData, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(responseData, error);
                });
            }];
        }
    }];
}

- (void)_step2WithAccount:(ACAccount *)account
                signature:(NSString *)signedReverseAuthSignature
               andHandler:(TWAPIHandler)completion {
    
    NSParameterAssert(account);
    NSParameterAssert(signedReverseAuthSignature);
    
    NSDictionary *step2Params = @{kXReverseAuthTarget: [TWSignedRequest consumerKey], kXReverseAuthParameters: signedReverseAuthSignature};
    
    NSURL *authTokenURL = [NSURL URLWithString:kOAuthUrlToken];
    
    SLRequest *step2Request = [self requestWithUrl:authTokenURL parameters:step2Params requestMethod:SLRequestMethodPOST];
    
    [step2Request setAccount:account];
    [step2Request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(responseData, error);
        });
    }];
}

- (SLRequest *)requestWithUrl:(NSURL *)url
                   parameters:(NSDictionary *)dict
                requestMethod:(SLRequestMethod )requestMethod {

    NSParameterAssert(url);
    NSParameterAssert(dict);
    
    return [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:requestMethod URL:url parameters:dict];
}

- (void)_step1WithCompletion:(TWAPIHandler)completion {
    
    NSURL *url = [NSURL URLWithString:kOAuthUrlRequestToken];
    TWSignedRequest *step1Request = [[TWSignedRequest alloc] initWithURL:url parameters:@{kXAuthMode: kReverseAuth} requestMethod:TWSignedRequestMethodPOST];
    
    [step1Request performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(data, error);
        });
    }];
}


- (void)refreshTwitterAccounts:(void (^)(BOOL))completion {
    if (![self hasAppKeys]) {
    	DebugLog(@"No keys");
    } else if (![self isLocalTwitterAccountAvailable]) {

        [[[UIAlertView alloc]initWithTitle:@"You don't have any Twitter accounts" message:@"Go to settings and add a twitter account" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
    } else {
        [self _obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (granted) {
                    completion(YES);
                } else {
					completion(NO);
                    
                    [[[UIAlertView alloc]initWithTitle:@"Twitter access" message:@"You havn't given us access to your twitter. Go to settings and allow us to use your account" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

                    DebugLog(@"No access to the Twitter accounts.");
                }
            });
        }];
    }
}

- (void)_obtainAccessToAccountsWithBlock:(void (^)(BOOL))block {
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }
        block(granted);
    };
    [_accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:handler];
}

- (BOOL)hasAppKeys {
    return ([[TWSignedRequest consumerKey] length] && [[TWSignedRequest consumerSecret] length]);
}

- (BOOL)isLocalTwitterAccountAvailable {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

@end
