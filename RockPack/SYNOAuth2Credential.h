//
//  SYNOAuth2Credential.h
//  oauth2demo-iOS
//
//  Created by Nick Banks on 22/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Holds the details returned by a successful OAuth2 authentication call
//
//  which returns the following JSON...
//
//  {"access_token": "948dc75279", "token_type": "bearer", "expires_in": 3600, "refresh_token": "7b4eb06f49"}
//

@import Foundation;

// Number of seconds before the actual expiry of the token to consider it expired
// this is effectively anticipating latency in the network
#define kOAuthTokenExpiryMargin 30.0f

@interface SYNOAuth2Credential : NSObject <NSCoding, NSCopying>

@property (nonatomic, readonly, copy) NSString *accessToken;
@property (nonatomic, readonly, copy) NSDate *expirationDate;
@property (nonatomic, readonly, copy) NSString *refreshToken;
@property (nonatomic, readonly, copy) NSString *resourceURL;
@property (nonatomic, readonly, copy) NSString *tokenType;
@property (nonatomic, readonly, copy) NSString *userId;



// Class methods

+ (id) credentialWithAccessToken: (NSString *) accessToken
                       expiresIn: (NSString *) expiresIn
                    refreshToken: (NSString *) refreshToken
                     resourceURL: (NSString *) resourceURL
                       tokenType: (NSString *) tokenType
                          userId: (NSString *) userId;

// Keychain

+ (id) credentialFromKeychainForService: (NSString *) service
                                account: (NSString *) account;

- (void) saveToKeychainForService: (NSString *) service
                          account: (NSString *) account;

- (void) removeFromKeychainForService: (NSString *) service
                              account: (NSString *) account;

- (BOOL) hasExpired;

-(void)removeFromKeychain;

// Debugging

- (NSString *) description;

@end
