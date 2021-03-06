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


- (void) videoForChannelForUserId: (NSString *) userId
                        channelId: (NSString *) channelId
                       instanceId: (NSString *) instanceId
                completionHandler: (MKNKUserSuccessBlock) completionBlock
                     errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{ @"USERID": userId,
                                                 @"CHANNELID": channelId,
                                                 @"INSTANCEID": instanceId};
    
    NSString *apiString = [kAPIGetVideoDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    apiString = [NSString stringWithFormat: @"%@?locale=%@", apiString, self.localeString];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *) [self operationWithPath: apiString
                                                                                                         params: nil
                                                                                                     httpMethod: @"GET"
                                                                                                            ssl: FALSE];
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

#pragma mark - Search

- (MKNetworkOperation *) usersForGenreId: (NSString *) genreId
                                forRange: (NSRange) range
                       completionHandler: (MKNKSearchSuccessBlock) completionBlock;
{

    NSMutableDictionary *parameters = @{}.mutableCopy;
    
    if(![genreId isEqualToString:kPopularGenreUniqueId]) // else -> 'POPULAR' SubGenre passed, do not create a 'category' argument
        parameters[@"category"] = genreId;
    
    
    parameters[@"start"] = [NSString stringWithFormat: @"%@", @(range.location)];
    parameters[@"size"] = [NSString stringWithFormat: @"%@", @(range.length)];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithPath: kAPIUsers
                                                       params: [self getLocaleParamWithParams:parameters]];
    networkOperation.shouldNotCacheResponse = YES;
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        
        if (!dictionary)
            return;
        
        [self.appDelegate.searchRegistry performInBackground: ^BOOL (NSManagedObjectContext *backgroundContext) {
            
            BOOL registryResultOk = [self.searchRegistry registerUsersFromDictionary: dictionary];
            
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
        
        DebugLog(@"Update Videos Screens Request Failed");
        
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
    }];
    
    [self enqueueOperation: networkOperation];
    
    return networkOperation;
}

- (MKNetworkOperation *) videosForGenreId: (NSString *) genreId
                                 forRange: (NSRange) range
                        completionHandler: (MKNKSearchSuccessBlock) completionBlock
{
    
    if(!genreId)
        return nil;
    
    NSMutableDictionary *parameters = @{}.mutableCopy;
    if(![genreId isEqualToString:kPopularGenreUniqueId]) // else -> 'POPULAR' SubGenre passed, do not create a 'category' argument
        parameters[@"category"] = genreId;
    
    parameters[@"start"] = [NSString stringWithFormat: @"%@", @(range.location)];
    parameters[@"size"] = [NSString stringWithFormat: @"%@", @(range.length)];
    
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *) [self operationWithPath: kAPIVideos
                                                                                                         params: [self getLocaleParamWithParams:parameters]];
    networkOperation.shouldNotCacheResponse = YES;
    
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        
        if (!dictionary)
            return;
        
        
        [self.appDelegate.searchRegistry performInBackground: ^BOOL (NSManagedObjectContext *backgroundContext) {
            
            BOOL registryResultOk = [self.searchRegistry registerVideoInstancesFromDictionary: dictionary];
            
            return registryResultOk;
            
        } completionBlock: ^(BOOL registryResultOk) {
            
            int itemsCount = 0;
            
            NSNumber * totalNumber = (NSNumber *) dictionary[@"total"];
            
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
        
        DebugLog(@"Update Videos Screens Request Failed");
        
        if (error.code >= 500 && error.code < 600)
        {
            [self showErrorPopUpForError: error];
        }
    }];
    
    [self enqueueOperation: networkOperation];
    
    return networkOperation;
    
    
}

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
    tempParameters[@"start"] = [NSString stringWithFormat: @"%@", @(range.location)];
    tempParameters[@"size"] = [NSString stringWithFormat: @"%@", @(range.length)];
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
            
            BOOL registryResultOk = [self.searchRegistry registerVideoInstancesFromDictionary: dictionary];
            
            return registryResultOk;
            
        } completionBlock: ^(BOOL registryResultOk) {
            
            int itemsCount = 0;
            
            NSNumber * totalNumber = (NSNumber *) dictionary[@"total"];
            
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
                                 onComplete: (MKNKSearchSuccessBlock) completeBlock
{
    if (searchTerm == nil || [searchTerm isEqualToString: @""])
    {
        return nil;
    }
    
    NSMutableDictionary *tempParameters = [NSMutableDictionary dictionary];
    
    tempParameters[@"q"] = searchTerm;
    tempParameters[@"start"] = [NSString stringWithFormat: @"%@", @(range.location)];
    tempParameters[@"size"] = [NSString stringWithFormat: @"%@", @(range.length)];
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
            
            BOOL registryResultOk = [self.searchRegistry registerUsersFromDictionary: dictionary];
            
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



- (void)likesForVideoId:(NSString *)videoId
				inRange:(NSRange)range
	  completionHandler:(MKNKUserSuccessBlock)completionBlock
		   errorHandler:(MKNKErrorBlock)errorBlock {
	
    NSDictionary *apiSubstitutionDictionary = @{ @"VIDEOID": videoId};
    
    NSString *URLString = [kAPIVideoLikes stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
	
	NSDictionary *parameters = @{
								 @"start" : [NSString stringWithFormat:@"%@", @(range.location)],
								 @"size"  : [NSString stringWithFormat:@"%@", @(range.length)]
								 };
	
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *)[self operationWithPath:URLString params:parameters];
    networkOperation.shouldNotCacheResponse = YES;
	
	[networkOperation addJSONCompletionHandler:^(NSDictionary *response) {
		completionBlock(response);
	} errorHandler:^(NSError *error) {
		errorBlock(error);
	}];
	
	[self enqueueOperation:networkOperation];
}

- (void)channelsForVideoId:(NSString *)videoId
				   inRange:(NSRange)range
		 completionHandler:(MKNKUserSuccessBlock)completionBlock
			  errorHandler:(MKNKErrorBlock)errorBlock {
	
    NSDictionary *apiSubstitutionDictionary = @{ @"VIDEOID": videoId};
    
    NSString *URLString = [kAPIVideoChannels stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
	
	NSDictionary *parameters = @{
								 @"start" : [NSString stringWithFormat:@"%@", @(range.location)],
								 @"size"  : [NSString stringWithFormat:@"%@", @(range.length)]
								 };
	
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject *)[self operationWithPath:URLString params:parameters];
    networkOperation.shouldNotCacheResponse = YES;
	
	[networkOperation addJSONCompletionHandler:^(NSDictionary *response) {
		completionBlock(response);
	} errorHandler:^(NSError *error) {
		errorBlock(error);
	}];
	
	[self enqueueOperation:networkOperation];
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
//    parameters[@"size"] = @(MAXIMUM_REQUEST_LENGTH);
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
        
		[self showErrorPopUpForError: error];
    }];
    
    [self enqueueOperation: networkOperation];
}

- (void) channelsForUserId: (NSString *) userId
                   inRange: (NSRange) range
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
        parameters[@"start"] = @(range.location);
        parameters[@"size"] = @(48);
    
    parameters[@"locale"] = self.localeString;
    
    NSString *apiString = [kAPIGetUserDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: parameters
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: NO];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    
    
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
    
    tempParameters[@"start"] = [NSString stringWithFormat: @"%@", @(range.location)];
    tempParameters[@"size"] = [NSString stringWithFormat: @"%@", @(range.length)];
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
            return;
        
        
        [self.appDelegate.searchRegistry performInBackground: ^BOOL (NSManagedObjectContext *backgroundContext) {
            
            BOOL registryResultOk = [self.searchRegistry registerSubscribersFromDictionary: dictionary];
            
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

- (void) videosForUserId: (NSString *) userId
                 inRange: (NSRange) range
       completionHandler: (MKNKUserSuccessBlock) completionBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    NSString *apiString = [kAPIGetUserVideos stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"start"] = @(range.location);
    parameters[@"size"] = @(range.length);
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: parameters
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: NO];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    
    
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

- (void) getCommentsForUsedId:(NSString*)userId
                    channelId:(NSString*)channelId
                   andVideoId:(NSString*)videoId
                      inRange:(NSRange)range
              withForceReload:(BOOL)forceReload
            completionHandler:(MKNKUserSuccessBlock) completionBlock
                 errorHandler:(MKNKUserErrorBlock) errorBlock
{
    
    NSDictionary *apiSubstitutionDictionary = @{@"USERID": userId, @"CHANNELID" : channelId, @"VIDEOINSTANCEID" : videoId};
    
    NSString *apiString = [kAPIComments stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"start"] = [NSString stringWithFormat: @"%@", @(range.location)];
    parameters[@"size"] = [NSString stringWithFormat: @"%@", @(range.length)];
    
    [parameters addEntriesFromDictionary: [self getLocaleParam]];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject *) [self operationWithPath: apiString
                                                       params: parameters
                                                   httpMethod: @"GET"];
    
    [networkOperation addJSONCompletionHandler: completionBlock
                                  errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
    
}

- (void) subscriptionsForUserId: (NSString *) userId
						inRange: (NSRange) range
			  completionHandler: (MKNKUserSuccessBlock) completionBlock
				   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIGetUserSubscriptions stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
	
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"start"] = @(range.location);
    params[@"size"] = @(range.length);
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: NO];
    
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueOperation:networkOperation];
}



@end
