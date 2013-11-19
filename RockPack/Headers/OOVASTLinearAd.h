/**
 * @class      OOVASTLinearAd OOVASTLinearAd.h "OOVASTLinearAd.h"
 * @brief      OOVASTLinearAd
 * @details    OOVASTLinearAd.h in OoyalaSDK
 * @date       12/8/11
 * @copyright  Copyright (c) 2012 Ooyala, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "OOTBXML.h"
#import "OOPlayableItem.h"

@interface OOVASTLinearAd : NSObject <OOPlayableItem> {
@protected
  Float64 duration;
  NSMutableDictionary *trackingEvents;
  NSString *parameters;
  NSString *clickThroughURL;
  NSMutableArray *clickTrackingURLs;
  NSMutableArray *customClickURLs;
  NSMutableArray *streams;
}

@property(readonly, nonatomic) Float64 duration;                            /**< The duration of the ad in seconds */
@property(readonly, nonatomic, strong) NSMutableDictionary *trackingEvents; /**< The tracking events in an NSMutableDictionary of event name to NSMutableArray of NSString */
@property(readonly, nonatomic, strong) NSString *parameters;                /**< The additional ad parameters */
@property(readonly, nonatomic, strong) NSString *clickThroughURL;           /**< The click through url */
@property(readonly, nonatomic, strong) NSMutableArray *clickTrackingURLs;   /**< The click tracking urls in an NSMutableArray of NSString */
@property(readonly, nonatomic, strong) NSMutableArray *customClickURLs;     /**< The custom click urls in an NSMutableArray of NSString */
@property(readonly, nonatomic, strong) NSMutableArray *streams;             /**< The streams in an NSMutableArray of OOStream */

/** @internal
 * Initialize a OOVASTLinearAd using the specified xml (subclasses should override this)
 * @param[in] xml the OOTBXMLElement containing the xml to use to initialize this OOVASTLinearAd
 * @returns the initialized OOVASTLinearAd
 */
- (id)initWithXML:(OOTBXMLElement *)xml;

@end
