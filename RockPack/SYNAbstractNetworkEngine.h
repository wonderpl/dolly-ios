//
//  SYNAbstractNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 18/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "SYNMainRegistry.h"
#import "SYNNetworkOperationJsonObject.h"
#import "SYNSearchRegistry.h"
#import "User.h"

@class SYNNetworkOperationJsonObject;

@interface SYNAbstractNetworkEngine : MKNetworkEngine {
    NSString* hostName;
}

@property (nonatomic, strong) NSString *localeString;
@property (nonatomic, strong) NSString *locationString;
@property (nonatomic, strong) SYNMainRegistry* registry;
@property (nonatomic, strong) SYNSearchRegistry* searchRegistry;
@property (nonatomic, readonly) NSString* hostName;

- (id) initWithDefaultSettings;


- (void) addCommonHandlerToNetworkOperation: (SYNNetworkOperationJsonObject *) networkOperation
                          completionHandler: (MKNKUserSuccessBlock) completionBlock
                               errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) addCommonHandlerToNetworkOperation:  (SYNNetworkOperationJsonObject *) networkOperation
                          completionHandler: (MKNKUserSuccessBlock) completionBlock
                               errorHandler: (MKNKUserErrorBlock) errorBlock
                           retryInputStream: (NSInputStream*) retryInputStream;

- (void) refreshOAuthTokenWithCompletionHandler: (MKNKUserErrorBlock) completionBlock
                                       errorHandler: (MKNKUserSuccessBlock) errorBlock;


- (NSDictionary *) paramsForStart: (NSUInteger) start
                             size: (NSUInteger) size;

- (NSDictionary *) paramsAndLocaleForStart: (NSUInteger) start
                                      size: (NSUInteger) size;

-(NSDictionary*) getLocaleParam;

-(NSDictionary*) getLocaleParamWithParams: (NSDictionary*) parameters;

// common operations for both engines

- (MKNetworkOperation *) updateChannel: (NSString *) resourceURL
                       forVideosLength: (NSInteger) length
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) getCommentsForUsedId:(NSString*)userId
                    channelId:(NSString*)channelId
                   andVideoId:(NSString*)videoId
                      inRange:(NSRange)range
              withForceReload:(BOOL)forceReload
            completionHandler:(MKNKUserSuccessBlock) completionBlock
                 errorHandler:(MKNKUserErrorBlock) errorBlock;

- (void) enqueueSignedOperation: (MKNetworkOperation *) request;

#pragma mark - HTTP status 5xx errors
-(void)showErrorPopUpForError:(NSError*)error;

-(void)trackSessionWithMessage:(NSString*)message;

@end
