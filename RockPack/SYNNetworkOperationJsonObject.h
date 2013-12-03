//
//  SYNNetworkOperationJsonObjectFetch.h
//  rockpack
//
//  Created by Michael Michailidis on 15/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "MKNetworkOperation.h"

@class SYNOAuth2Credential, User;

typedef void (^JSONResponseBlock)(id jsonObject);

typedef void (^MKNKAutocompleteProcessBlock) (NSArray *);
typedef void (^MKNKLoginCompleteBlock) (SYNOAuth2Credential *);
typedef void (^MKNKUserCompleteBlock) (User *);

typedef void (^MKNKJSONCompleteBlock) (NSDictionary *);
typedef void (^MKNKJSONErrorBlock) (NSDictionary *);

typedef void (^MKNKUserErrorBlock) (id);
typedef void (^MKNKUserSuccessBlock) (id);
typedef void (^MKNKBasicSuccessBlock)(void);
typedef void (^MKNKBasicFailureBlock)(void);

typedef void (^MKNKResourceSuccessBlock) (NSString *);
typedef void (^MKNKResourceErrorBlock) (NSError *);

typedef void (^MKNKSearchSuccessBlock) (int);
typedef void (^MKNKSearchFailureBlock) (int);

#import "AppConstants.h"

@interface SYNNetworkOperationJsonObject : MKNetworkOperation

- (void) addJSONCompletionHandler: (JSONResponseBlock) responseBlock errorHandler: (MKNKErrorBlock) errorBlock;

@property (nonatomic) BOOL ignoreCachedResponse;
@property (nonatomic) BOOL parseLocation;

@end
