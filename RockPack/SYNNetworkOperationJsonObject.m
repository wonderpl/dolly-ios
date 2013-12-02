//
//  SYNNetworkOperationJsonObjectFetch.m
//  rockpack
//
//  Created by Michael Michailidis on 15/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNNetworkOperationJsonObject.h"

@implementation SYNNetworkOperationJsonObject

@synthesize ignoreCachedResponse;

- (void) addJSONCompletionHandler: (JSONResponseBlock) responseBlock
                     errorHandler: (MKNKErrorBlock) errorBlock
{
    BOOL ignore = self.ignoreCachedResponse;
    
    [self addCompletionHandler: ^(MKNetworkOperation *completedOperation) {
        if (ignore)
        {
            if(completedOperation.isCachedResponse)
                return;
            
        }
        
        
        
        if (completedOperation.HTTPStatusCode == 204)
        {
            responseBlock(@{@"response": @"NO CONTENT"});
            return;
        }
        
        // We need to enable fragments, as the JSON may not be fully formed
        [completedOperation responseJSONWithOptions: NSJSONReadingAllowFragments
                                  completionHandler: ^(id jsonObject) {
                                      // We need to check to see if the response is signalled as blank
                                      if (!jsonObject)
                                      {
                                          // check whether an object is returned before calling the completeBlock
                                          NSError *noObjectParsedError = [NSError errorWithDomain: @"JSON Object Not Parsed"
                                                                                             code: 0
                                                                                         userInfo: nil];
                                          errorBlock(noObjectParsedError);
                                          return;
                                      }
                                      
                                      responseBlock(jsonObject);
                                  }];
    } errorHandler: ^(MKNetworkOperation *errorOp, NSError *error) {
        if (error.code == 400)   // api error, response has Json Data
        {
            [errorOp responseJSONWithOptions: NSJSONReadingAllowFragments
                           completionHandler: ^(id jsonObject)
             {
                 if (!jsonObject)
                 {
                     errorBlock(error);
                     return;
                 }
                 
                 responseBlock(jsonObject);
             }];
        }
        else if (error.code == 401)
        {
            // Invalid or expired token
            [errorOp responseJSONWithOptions: NSJSONReadingAllowFragments
                           completionHandler: ^(id jsonObject)
             {
                 if (!jsonObject)
                 {
                     errorBlock(error);
                     return;
                 }
                 
                 responseBlock(jsonObject);
             }];
        }
        else
        {
            errorBlock(error);
        }
    }];
}



@end
