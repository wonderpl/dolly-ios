//
//  SYNNetworkEngine.m
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "Channel.h"
#import "Genre.h"
#import "NSString+Utils.h"
#import "SYNAppDelegate.h"
#import "SYNMainRegistry.h"
#import "SYNNetworkEngine.h"
#import "SYNSearchRegistry.h"
#import "VideoInstance.h"

@interface SYNNetworkEngine ()

@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end

@implementation SYNNetworkEngine

@synthesize shouldFirstCheckCache;

- (NSString *) hostName
{
    return hostName;
}


- (id) initWithDefaultSettings
{
    hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"APIHostName"];
    
    if ((self = [super initWithDefaultSettings]))
    {
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}


#pragma mark - Engine API


- (void) updateCategoriesOnCompletion: (MKNKJSONCompleteBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock
{
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithPath: kAPICategories
                                                       params: [self getLocaleParam]
                                                   httpMethod: @"GET"];
    
    //networkOperation.ignoreCachedResponse = YES;
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        completionBlock(dictionary);
    } errorHandler: ^(NSError *error) {
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
        
        DebugLog(@"API request failed");
    }];
    
    [self enqueueOperation: networkOperation];
}


#pragma mark - Cover art

- (void) updateCoverArtWithWithStart: (unsigned int) start
                                size: (unsigned int) size
                   completionHandler: (MKNKJSONCompleteBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // If size is 0, then don't include start and size in the call (i.e. just use default params), otherwise assume both params are valid
    NSDictionary *params = [self paramsAndLocaleForStart: start
                                                    size: size];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *) [self operationWithPath: kAPIGetCoverArt
                                                                                                         params: params
                                                                                                     httpMethod: @"GET"];
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary){
        BOOL registryResultOk = [self.registry
                                 registerCoverArtFromDictionary: dictionary
                                 forUserUpload: NO];
        
        if (!registryResultOk)
        {
            return;
        }
        
        completionBlock(dictionary);
    } errorHandler: ^(NSError *error) {
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
        
        DebugLog(@"API request failed");
    }];
    
    [self enqueueOperation: networkOperation];
}


- (void) updateCoverArtOnCompletion: (MKNKJSONCompleteBlock) completionBlock
                            onError: (MKNKErrorBlock) errorBlock
{
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *) [self operationWithPath: kAPIGetCoverArt
                                                                                                         params: [self getLocaleParam]];
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        BOOL registryResultOk = [self.registry
                                 registerCoverArtFromDictionary: dictionary
                                 forUserUpload: NO];
        
        if (!registryResultOk)
        {
            return;
        }
        
        completionBlock(dictionary);
    } errorHandler: ^(NSError *error) {
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
        
        DebugLog(@"API request failed");
    }];
    
    [self enqueueOperation: networkOperation];
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
                                                                                                          ssl: FALSE];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
}


- (void) videosForChannelForUserId: (NSString *) userId
                         channelId: (NSString *) channelId
                           inRange: (NSRange) range
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID": userId,
                                                @"CHANNELID": channelId};
    
    NSString *apiString = [kAPIGetVideosForChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"start"] = @(range.location);
    parameters[@"size"] = @(range.length);
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *) [self operationWithPath: apiString
                                                                                                         params: [self getLocaleParamWithParams: parameters]
                                                                                                     httpMethod: @"GET"
                                                                                                            ssl: NO];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
}


- (MKNetworkOperation *) updateChannel: (NSString *) resourceURL
                       forVideosLength: (NSInteger) length
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"start"] = @(0);
    parameters[@"size"] = @(length);
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithURLString: resourceURL
                                                            params: [self getLocaleParamWithParams: parameters]];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
    
    return networkOperation;
}


- (MKNetworkOperation *) updateChannelsScreenForCategory: (NSString *) categoryId
                                                forRange: (NSRange) range
                                           ignoringCache: (BOOL) ignore
                                            onCompletion: (MKNKJSONCompleteBlock) completeBlock
                                                 onError: (MKNKJSONErrorBlock) errorBlock
{
    NSMutableDictionary *tempParameters = [NSMutableDictionary dictionary];
    
    tempParameters[@"start"] = [NSString stringWithFormat: @"%i", range.location];
    tempParameters[@"size"] = [NSString stringWithFormat: @"%i", range.length];
    
    if (![categoryId isEqualToString: @"all"])
    {
        tempParameters[@"category"] = categoryId;
    }
    
    
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithPath: kAPIPopularChannels
                                                       params: [self getLocaleParamWithParams: tempParameters]];
    
    networkOperation.ignoreCachedResponse = ignore;
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        completeBlock(dictionary);
    } errorHandler: ^(NSError *error) {
        errorBlock(@{@"network_error": @"Engine Failed to Load Channels"});
        
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
    }];
    
    [self enqueueOperation: networkOperation];
    
    return networkOperation;
}


#pragma mark - Search


- (MKNetworkOperation *) searchVideosForTerm: (NSString *) searchTerm
                                     inRange: (NSRange) range
                                  onComplete: (MKNKSearchSuccessBlock) completeBlock
{
    if (searchTerm == nil || [searchTerm isEqualToString: @""])
    {
        return nil;
    }
    
    NSMutableDictionary *tempParameters = [NSMutableDictionary dictionary];
    
    tempParameters[@"q"] = searchTerm;
    tempParameters[@"start"] = [NSString stringWithFormat: @"%i", range.location];
    tempParameters[@"size"] = [NSString stringWithFormat: @"%i", range.length];
    [tempParameters addEntriesFromDictionary: [self getLocaleParam]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary: tempParameters];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithPath: kAPISearchVideos
                                                       params: parameters];
    networkOperation.shouldNotCacheResponse = YES;
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        
        if (!dictionary)
        {
            return;
        }
        
        [self.appDelegate.searchRegistry performInBackground: ^BOOL (NSManagedObjectContext *backgroundContext) {
            BOOL registryResultOk = [self.searchRegistry registerVideosFromDictionary: dictionary];
            
            return registryResultOk;
        } completionBlock: ^(BOOL registryResultOk) {
            int itemsCount = 0;
            
            NSNumber * totalNumber = (NSNumber *) dictionary[@"videos"][@"total"];
            
            if (totalNumber && [totalNumber isKindOfClass: [NSNumber class]])
            {
                itemsCount = totalNumber.intValue;
            }
            if (!registryResultOk)
            {
                return;
            }
            
            completeBlock(itemsCount);
        }];
    } errorHandler: ^(NSError *error) {
        DebugLog(@"Update Videos Screens Request Failed");
        
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
    }];
    
    [self enqueueOperation: networkOperation];
    
    return networkOperation;
}


- (MKNetworkOperation *) searchUsersForTerm: (NSString *) searchTerm
                                   andRange: (NSRange) range
                                byAppending: (BOOL) append
                                 onComplete: (MKNKSearchSuccessBlock) completeBlock
{
    if (searchTerm == nil || [searchTerm isEqualToString: @""])
    {
        return nil;
    }
    
    NSMutableDictionary *tempParameters = [NSMutableDictionary dictionary];
    
    tempParameters[@"q"] = searchTerm;
    tempParameters[@"start"] = [NSString stringWithFormat: @"%i", range.location];
    tempParameters[@"size"] = [NSString stringWithFormat: @"%i", range.length];
    [tempParameters addEntriesFromDictionary: [self getLocaleParam]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary: tempParameters];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithPath: kAPISearchUsers
                                                       params: parameters];
    networkOperation.shouldNotCacheResponse = YES;
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        
        if (!dictionary)
        {
            return;
        }
        
        [self.appDelegate.searchRegistry performInBackground: ^BOOL (NSManagedObjectContext *backgroundContext) {
            BOOL registryResultOk = [self.searchRegistry registerUsersFromDictionary: dictionary
                                                                         byAppending: append];
            
            return registryResultOk;
        } completionBlock: ^(BOOL registryResultOk) {
            int itemsCount = 0;
            
            NSNumber * totalNumber = (NSNumber *) dictionary[@"users"][@"total"];
            
            if (totalNumber && [totalNumber isKindOfClass: [NSNumber class]])
            {
                itemsCount = totalNumber.intValue;
            }
            
            if (!registryResultOk)
            {
                return;
            }
            
            completeBlock(itemsCount);
        }];
    } errorHandler: ^(NSError *error) {
        DebugLog(@"Update Videos Screens Request Failed");
        
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
    }];
    
    [self enqueueOperation: networkOperation];
    
    return networkOperation;
}


- (MKNetworkOperation *) searchChannelsForTerm: (NSString *) searchTerm
                                      andRange: (NSRange) range
                                    onComplete: (MKNKSearchSuccessBlock) completeBlock
{
    if (searchTerm == nil || [searchTerm isEqualToString: @""])
    {
        return nil;
    }
    
    NSMutableDictionary *tempParameters = [NSMutableDictionary dictionary];
    
    tempParameters[@"q"] = searchTerm;
    tempParameters[@"start"] = [NSString stringWithFormat: @"%i", range.location];
    tempParameters[@"size"] = [NSString stringWithFormat: @"%i", range.length];
    [tempParameters addEntriesFromDictionary: [self getLocaleParam]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary: tempParameters];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithPath: kAPISearchChannels
                                                       params: parameters];
    networkOperation.shouldNotCacheResponse = YES;
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        if (!dictionary)
        {
            return;
        }

        
        [self.appDelegate.searchRegistry performInBackground: ^BOOL (NSManagedObjectContext *backgroundContext) {
            BOOL registryResultOk = [self.searchRegistry registerChannelsFromDictionary: dictionary];
            
            return registryResultOk;
        } completionBlock: ^(BOOL registryResultOk) {
            int itemsCount = 0;
            
            NSNumber * totalNumber = (NSNumber *) dictionary[@"channels"][@"total"];
            
            if (totalNumber && [totalNumber isKindOfClass: [NSNumber class]])
            {
                itemsCount = totalNumber.intValue;
            }
            
            if (!registryResultOk)
            {
                return;
            }
            
            completeBlock(itemsCount);
        }];
        
        
    } errorHandler: ^(NSError *error) {
        DebugLog(@"Update Videos Screens Request Failed");
        
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
    }];
    
    [self enqueueOperation: networkOperation];
    
    return networkOperation;
}


#pragma mark - Autocomplete

- (MKNetworkOperation *) getAutocompleteForHint: (NSString *) hint
                                    forResource: (EntityType) entityType
                                   withComplete: (MKNKAutocompleteProcessBlock) completionBlock
                                       andError: (MKNKErrorBlock) errorBlock
{
    if (!hint)
    {
        return nil;
    }
    
    // Register the class to be used for this operation only
    [self registerOperationSubclass: [SYNNetworkOperationJsonObjectParse class]];
    
    NSDictionary *parameters = [self getLocaleParamWithParams: @{@"q": hint}];
    
    NSString *apiForEntity;
    
    if(entityType == EntityTypeAny)
    {
        apiForEntity = kAPICompleteAll;
    }
    else if (entityType == EntityTypeVideoInstance || entityType == EntityTypeVideo) // we never really search for videos
    {
        apiForEntity = kAPICompleteVideos;
    }
    else if (entityType == EntityTypeChannel)
    {
        apiForEntity = kAPICompleteChannels;
    }
    else if(entityType == EntityTypeUser)
    {
        apiForEntity = kAPICompleteUsers;
    }
    else
    {
        return nil; // do not accept any unknown type
    }
    
    SYNNetworkOperationJsonObjectParse *networkOperation =
    (SYNNetworkOperationJsonObjectParse *) [self operationWithPath: apiForEntity
                                                            params: parameters];
    
    [networkOperation addJSONCompletionHandler: ^(NSArray *array) {
        completionBlock(array);
    } errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
    
    // Go back to the original operation class
    [self registerOperationSubclass: [SYNNetworkOperationJsonObject class]];
    
    return networkOperation;
}


#pragma mark - Channel owner

- (void) channelOwnerDataForChannelOwner: (ChannelOwner *) channelOwner
                              onComplete: (MKNKUserSuccessBlock) completeBlock
                                 onError: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID": channelOwner.uniqueId};
    
    // same as for User
    NSString *apiString = [kAPIGetUserDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity: 3];
    
    parameters[@"start"] = @(0);
    parameters[@"size"] = @(1000);
    parameters[@"locale"] = self.localeString;
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *) [self operationWithPath: apiString
                                                                                                         params: parameters];
    
    [networkOperation addJSONCompletionHandler: ^(id dictionary) {
        NSString *possibleError = dictionary[@"error"];
        
        if (possibleError)
        {
            errorBlock(@{@"error": possibleError});
            return;
        }
        
        completeBlock(dictionary);
    } errorHandler: ^(NSError *error) {
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
        
        errorBlock(error);
    }];
    
    [self enqueueOperation: networkOperation];
}


#pragma mark - Subscriber

- (void) channelOwnerSubscriptionsForOwner: (ChannelOwner *) channelOwner
                                  forRange: (NSRange) range
                         completionHandler: (MKNKUserSuccessBlock) completionBlock
                              errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID": channelOwner.uniqueId};
    
    NSDictionary *params = [self paramsForStart: range.location
                                           size: range.length];

    // we are not using the subscriptions_url returned from user info data but using a std one.
    NSString *apiString = [kAPIGetUserSubscriptions stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *) [self operationWithPath: apiString
                                                                                                         params: [self getLocaleParamWithParams: params]];
    
    
    [networkOperation addJSONCompletionHandler: ^(id dictionary) {
        if (!dictionary)
        {
            errorBlock(dictionary);
            return;
        }
        
        completionBlock(dictionary);
    } errorHandler: ^(NSError *error) {
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
        
        errorBlock(error);
    }];
    
    [self enqueueOperation: networkOperation];
}


- (void) subscribersForUserId: (NSString *) userId
                    channelId: (NSString *) channelId
                     forRange: (NSRange) range
                  byAppending: (BOOL) append
            completionHandler: (MKNKSearchSuccessBlock) completionBlock
                 errorHandler: (MKNKBasicFailureBlock) errorBlock
{
    if (!userId || !channelId)
    {
        return;
    }
    
    NSMutableDictionary *tempParameters = [NSMutableDictionary dictionary];
    
    tempParameters[@"start"] = [NSString stringWithFormat: @"%i", range.location];
    tempParameters[@"size"] = [NSString stringWithFormat: @"%i", range.length];
    [tempParameters addEntriesFromDictionary: [self getLocaleParam]];
    
    NSDictionary *apiSubstitutionDictionary = @{
                                                @"USERID": userId, @"CHANNELID": channelId
                                                };
    NSString *apiString = [kAPISubscribersForChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary: tempParameters];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithPath: apiString
                                                       params: parameters];
    networkOperation.shouldNotCacheResponse = YES;
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        
        if (!dictionary)
        {
            return;
        }
        
        [self.appDelegate.searchRegistry performInBackground: ^BOOL (NSManagedObjectContext *backgroundContext) {
            BOOL registryResultOk = [self.searchRegistry registerSubscribersFromDictionary: dictionary
                                                                               byAppending: append];
            
            return registryResultOk;
        } completionBlock: ^(BOOL registryResultOk) {
            int itemsCount = 0;
            
            NSNumber * totalNumber = (NSNumber *) dictionary[@"users"][@"total"];
            
            if (totalNumber && [totalNumber isKindOfClass: [NSNumber class]])
            {
                itemsCount = totalNumber.intValue;
            }
            
            if (!registryResultOk)
            {
                return;
            }
            
            completionBlock(itemsCount);
        }];
    } errorHandler: ^(NSError *error) {
    }];
    
    [self enqueueOperation: networkOperation];
}


#pragma mark - Video player HTML update

- (void) updatePlayerSourceWithCompletionHandler: (MKNKUserSuccessBlock) completionBlock
                                    errorHandler: (MKNKUserErrorBlock) errorBlock
{
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithPath: kHTMLVideoPlayerSource
                                                       params: [self getLocaleParam]
                                                   httpMethod: @"GET"];
    
    networkOperation.ignoreCachedResponse = YES;
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        completionBlock(dictionary);
    } errorHandler: ^(NSError *error) {
        DebugLog(@"API request failed");
    }];
    
    [self enqueueOperation: networkOperation];
}


#pragma mark - Facebook deep linking

- (void) resolveFacebookLink: (NSString *) facebookLink
           completionHandler: (MKNKUserSuccessBlock) completionBlock
                errorHandler: (MKNKUserErrorBlock) errorBlock
{
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithURLString: facebookLink
                                                            params: nil //@{@"rockpack_redirect" : @"true"}
                                                        httpMethod: @"GET"];
    
    
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        completionBlock(dictionary);
    } errorHandler: ^(NSError *error) {
        DebugLog(@"API request failed");
        errorBlock(error);
    }];
    
    [self enqueueOperation: networkOperation];
}




@end
