/**
 * @class      OOVASTAd OOVASTAd.h "OOVASTAd.h"
 * @brief      OOVASTAd
 * @details    OOVASTAd.h in OoyalaSDK
 * @date       12/8/11
 * @copyright  Copyright (c) 2012 Ooyala, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "OOTBXML.h"

@interface OOVASTAd : NSObject {
@protected
  NSString *adID;
  NSString *system;
  NSString *systemVersion;
  NSString *title;
  NSString *description;
  NSMutableArray *surveyURLs;
  NSMutableArray *errorURLs;
  NSMutableArray *impressionURLs;
  __block NSMutableArray *sequence;
  NSDictionary *extensions;
}

@property(readonly, nonatomic, strong) NSString *adID;                   /**< the ID of the Ad */
@property(readonly, nonatomic, strong) NSString *system;                 /**< the System */
@property(readonly, nonatomic, strong) NSString *systemVersion;          /**< the System Version */
@property(readonly, nonatomic, strong) NSString *title;                  /**< the title of the Ad */
@property(readonly, nonatomic, strong) NSString *description;            /**< the description of the Ad */
@property(readonly, nonatomic, strong) NSMutableArray *surveyURLs;       /**< the survey URLs of the Ad */
@property(readonly, nonatomic, strong) NSMutableArray *errorURLs;        /**< the error URLs of the Ad */
@property(readonly, nonatomic, strong) NSMutableArray *impressionURLs;   /**< the impression URLs of the Ad */
@property(readonly, nonatomic, strong) __block NSMutableArray *sequence; /**< the ordered sequence of the Ad (NSMutableArray of OOVASTSequenceItem) */
@property(readonly, nonatomic) NSDictionary *extensions;                 /**< the extensions of the Ad */

/** @internal
 * Initialize a OOVASTAd using the specified xml (subclasses should override this)
 * @param[in] xml the OOTBXMLElement containing the xml to use to initialize this OOVASTAd
 * @returns the initialized OOVASTAd
 */
- (id)initWithXML:(OOTBXMLElement *)xml;

/** @internal
 * Update the OOVASTAd using the specified xml (subclasses should override this)
 * @param[in] xml the OOTBXMLElement containing the xml to use to update this OOVASTAd
 * @returns YES if the XML was properly formatter, NO if not
 */
- (BOOL)updateWithXML:(OOTBXMLElement *)xml;

@end
