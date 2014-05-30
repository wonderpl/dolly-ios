//
//  SYNOAuth2Credential.m
//  oauth2demo-iOS
//
//  Created by Nick Banks on 22/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNOAuth2Credential.h"
#import "SSKeychain.h"
#import "AppConstants.h"
#import "SYNAppDelegate.h"
#import "SYNRemoteLogger.h"

@interface SYNOAuth2Credential ()

// Now give access to the private vars
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *tokenType;
@property (nonatomic, copy) NSDate *expirationDate;
@property (nonatomic, copy) NSString *resourceURL;
@property (nonatomic, copy) NSString *userId;

@end

@implementation SYNOAuth2Credential

#pragma mark - Class Methods

+ (id) credentialWithAccessToken: (NSString *) accessToken
                       expiresIn: (NSString *) expiresIn
                    refreshToken: (NSString *) refreshToken
                     resourceURL: (NSString *) resourceURL
                       tokenType: (NSString *) tokenType
                          userId: (NSString *) userId
{
    return [[self alloc] initWithAccessToken: accessToken
                                   expiresIn: expiresIn
                                refreshToken: refreshToken
                                 resourceURL: resourceURL
                                   tokenType: tokenType
                                      userId: userId];
}

+ (id) credentialFromKeychainForService: (NSString *) service
                                account: (NSString *) account
{
    NSData *data = [SSKeychain passwordDataForService: service
                                              account: account];
    
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData: data] : nil;
}


#pragma mark - Initialization

- (id) initWithAccessToken: (NSString *) accessToken
                  expiresIn: (NSString *) expiresIn
               refreshToken: (NSString *) refreshToken
                resourceURL: (NSString *) resourceURL
                  tokenType: (NSString *) tokenType
                     userId: (NSString *) userId
{
    if ((self = [super init]))
    {
        self.accessToken = accessToken;
        self.refreshToken = refreshToken;
        self.tokenType = tokenType;
        self.resourceURL = resourceURL;
        self.userId = userId;

        // We need to do a bit of wizzardry on the expiration date, as we don't actually get sent the data
        // so we must calculate it (as we don't want to do this every time the 'hasExpired' method is called
        // as that might be expensive (in terms of CPU)
        
        if (expiresIn != nil)
        {
            NSTimeInterval timeIntervalSeconds = (double) [expiresIn doubleValue];
            
            // Just to be on the safe side, assume that the token expires shortly before it actually does.
            timeIntervalSeconds -= kOAuthTokenExpiryMargin;
            
            self.expirationDate = [NSDate dateWithTimeIntervalSinceNow: timeIntervalSeconds];
        }
    }
    
    return self;
}


- (id) initWithAccessToken: (NSString *) accessToken
            expirationDate: (NSDate *) expirationDate
              refreshToken: (NSString *) refreshToken
               resourceURL: (NSString *) resourceURL
                 tokenType: (NSString *) tokenType
                    userId: (NSString *) userId
{
    if ((self = [super init]))
    {
        self.accessToken = accessToken;
        self.refreshToken = refreshToken;
        self.tokenType = tokenType;
        self.expirationDate = expirationDate;
    }
    
    return self;
}


#pragma mark -
#pragma mark Public Methods

- (BOOL) hasExpired
{
    return [self.expirationDate compare: [NSDate date]] == NSOrderedAscending;
}

- (void) saveToKeychainForService: (NSString *) service
                         account: (NSString *) account
{
    NSData *credentialData = [NSKeyedArchiver archivedDataWithRootObject: self];

    if ([SSKeychain setPasswordData: credentialData
                         forService: service
                            account: account])
    {
        [[SYNRemoteLogger sharedLogger] log:@"saveToKeychainForService: success"];
        // Invalidate any cached credentials we may have
        SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
        [appDelegate resetCurrentOAuth2Credentials];
        [appDelegate setTokenExpiryTimer];
    }
    else
    {
        [[SYNRemoteLogger sharedLogger] log:@"saveToKeychainForService: failed"];
    }
}

- (void) removeFromKeychainForService: (NSString *) service
                              account: (NSString *) account
{
    [SSKeychain deletePasswordForService: service
                                 account: account];
}

-(void)removeFromKeychain
{
    [self removeFromKeychainForService: [[NSBundle mainBundle] bundleIdentifier]
                               account: self.userId];
}

#pragma mark - For debugging only

- (NSString *) description
{
    return [NSString stringWithFormat: @"<%@ accessToken:\"%@\" refreshToken:\"%@\" tokenType:\"%@\" expirationDate:\"%@\" resourceURL:\"%@\" userId:\"%@\">", [self class], self.accessToken, self.refreshToken, self.tokenType, self.expirationDate, self.resourceURL, self.userId];
}


#pragma mark - NSCoding protocol

- (id) initWithCoder: (NSCoder *) decoder
{
    if ((self = [super init]))
    {
        self.accessToken = [decoder decodeObjectForKey: @"accessToken"];
        self.refreshToken = [decoder decodeObjectForKey: @"refreshToken"];
        self.tokenType = [decoder decodeObjectForKey: @"tokenType"];
        self.expirationDate = [decoder decodeObjectForKey: @"expirationDate"];
        self.resourceURL = [decoder decodeObjectForKey: @"resourceURL"];
        self.userId = [decoder decodeObjectForKey: @"userId"];
    }
    
    return self;
}


- (void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject: self.accessToken
                   forKey: @"accessToken"];
    
    [encoder encodeObject: self.refreshToken
                   forKey: @"refreshToken"];
    
    [encoder encodeObject: self.tokenType
                   forKey: @"tokenType"];
    
    [encoder encodeObject: self.expirationDate
                   forKey: @"expirationDate"];
    
    [encoder encodeObject: self.resourceURL
                   forKey: @"resourceURL"];
    
    [encoder encodeObject: self.userId
                   forKey: @"userId"];
}


#pragma mark - NSCopying protocol

- (id) copyWithZone: (NSZone *) zone
{
    SYNOAuth2Credential *credential = [[SYNOAuth2Credential allocWithZone: zone] initWithAccessToken: self.accessToken
                                                                                      expirationDate: self.expirationDate
                                                                                        refreshToken: self.refreshToken
                                                                                         resourceURL: self.resourceURL
                                                                                           tokenType: self.tokenType
                                                                                              userId: self.userId];
    return credential;
}

@end
