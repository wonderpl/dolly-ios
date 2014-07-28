//
//  SYNRockpackNotification.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "Appirater.h"
#import <ISO8601DateFormatter.h>
#import "NSDate+RFC1123.h"
#import "SYNAppDelegate.h"
#import "SYNNotification.h"
#import "SYNActivityManager.h"

@interface SYNNotification ()

@property (nonatomic) kNotificationObjectType objectType;

@end


@implementation SYNNotification

#pragma mark - Object lifecycle

+ (id) notificationWithDictionary: (NSDictionary *) dictionary
{
    return [[self alloc] initWithNotificationData: dictionary];
}


- (id) initWithNotificationData: (NSDictionary *) data
{
    if (self = [super init])
    {
        
        
        if(![data isKindOfClass:[NSDictionary class]])
            return nil;
        
        SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
        NSNumber *identifierNumber = data[@"id"];
        
        if (![identifierNumber isKindOfClass: [NSNumber class]])
        {
            DebugLog(@"Did not find a valid notification id: %@", data);
            return nil;
        }
        
        self.identifier = [identifierNumber integerValue];
        
        
        self.messageType = data[@"message_type"];
        
        
        // Work out what type of object we are
        if ([self.messageType isEqualToString: @"subscribed"])
        {
            [Appirater userDidSignificantEvent: FALSE];
            self.objectType = kNotificationObjectTypeUserSubscibedToYourChannel;
        }
        else if ([self.messageType isEqualToString: @"starred"])
        {
            self.objectType = kNotificationObjectTypeUserLikedYourVideo;
        }
        else if ([self.messageType isEqualToString: @"joined"])
        {
            self.objectType = kNotificationObjectTypeFacebookFriendJoined;
        }
        
        else if ([self.messageType isEqualToString: @"repack"])
        {
            
            self.objectType = kNotificationObjectTypeUserAddedYourVideo;
        }
        
        else if ([self.messageType isEqualToString: @"unavailable"])
        {
            self.objectType = kNotificationObjectTypeYourVideoNotAvailable;
        }

        else if ([self.messageType isEqualToString: @"comment_mention"])
        {
            self.objectType = kNotificationObjectTypeCommentMention;
        }
		else if ([self.messageType isEqualToString:@"video_shared"]) {
			self.objectType = kNotificationObjectTypeShareVideo;
		}
		else if ([self.messageType isEqualToString:@"channel_shared"]) {
			self.objectType = kNotificationObjectTypeShareChannel;
		}
        else
        {
            // Unexpected object, this is used so that the message can be safely ignored by receipients
            self.objectType = kNotificationObjectTypeUnknown;
        }
		
        NSString *dateString = data[@"date_created"];
        if(dateString)
            self.dateDifferenceString = [self parseDateString:dateString];
        
        NSNumber *readNumber = data[@"read"];
        
        if (readNumber)
        {
            self.read = [readNumber boolValue];
        }
        
        NSDictionary *messageDictionary = data[@"message"];
        
        if (messageDictionary && [messageDictionary isKindOfClass: [NSDictionary class]])
        {
            // the response can either have a channel tag or a video tag, in the second case the video tag will include a channel tag //
            
            
            

            // case 1 : Channel Tag
            NSDictionary *channelDictionary = messageDictionary[@"channel"];
            
            if (channelDictionary && [channelDictionary isKindOfClass: [NSDictionary class]])
            {
                self.channelId = channelDictionary[@"id"];
                self.channelResourceUrl = channelDictionary[@"resource_url"];
                self.channelThumbnailUrl = channelDictionary[@"thumbnail_url"];
            }
            
            NSDictionary *videoDictionary = messageDictionary[@"video"];
            
            if (videoDictionary && [videoDictionary isKindOfClass: [NSDictionary class]])
            {
                
                self.videoId = videoDictionary[@"id"];
                self.videoThumbnailUrl = videoDictionary[@"thumbnail_url"];
                self.videoTitle = videoDictionary[@"title"];
                
                
                if (data[@"tracking_code"]) {
                    NSDictionary* trackingDict = @{@"tracking_code" : data[@"tracking_code"],
                                                   @"position": data[@"position"],
                                                   @"id" : videoDictionary[@"id"]
                                                   };
                    
                    [[SYNActivityManager sharedInstance] addObjectFromDict:trackingDict];
                }
                
                NSDictionary *channelDictionary = videoDictionary[@"channel"];
                
                if (channelDictionary && [channelDictionary isKindOfClass: [NSDictionary class]])
                {
                    self.channelId = channelDictionary[@"id"];
                    self.channelResourceUrl = channelDictionary[@"resource_url"];
                    // no thumbnail url in case of a channel object within a video object
                }
            }
            
            NSDictionary *userDictionary = messageDictionary[@"user"];
            
            if (userDictionary && [userDictionary isKindOfClass: [NSDictionary class]])
            {
                
                self.channelOwner = [ChannelOwner instanceFromDictionary: userDictionary
                                               usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                                     ignoringObjectTypes: kIgnoreChannelObjects];
                
                if (data[@"tracking_code"]) {
                    
                    NSDictionary* trackingDict = @{@"tracking_code" : data[@"tracking_code"],
                                                   @"position": data[@"position"],
                                                   @"id" : userDictionary[@"id"]
                                                   };
                    
                    [[SYNActivityManager sharedInstance] addObjectFromDict:trackingDict];
                    
                }
                
                self.channelOwner.viewId = kSideNavigationViewId;
            }
        }
    }
    
    return self;
}

- (NSString *)thumbnailUrl {
    return (self.videoThumbnailUrl ? self.videoThumbnailUrl : self.channelThumbnailUrl);
}

#pragma mark - Parsing Date

-(NSString*)parseDateString:(NSString*)dateString
{
    if(!dateString)
        return nil;
    
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    
    NSDate *date = [formatter dateFromString: dateString];
    
    if(!date)
        return dateString;
    
    // find difference from today
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [timeZone secondsFromGMTForDate: date];
    date = [NSDate dateWithTimeInterval: seconds
                              sinceDate: date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSUInteger componentflags =
    NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit;
    NSDateComponents *components = [calendar components: componentflags
                                               fromDate: date
                                                 toDate: [NSDate date]
                                                options: 0];
    
    NSMutableString *dateDifferenceMutableString = [[NSMutableString alloc] init];
    
    if (components.year > 0)
    {
        [dateDifferenceMutableString appendString: @"More than a year ago"];
    }
    else if (components.month > 0)
    {
        [dateDifferenceMutableString appendString: [NSString stringWithFormat: @"%@ month%@", @(components.month), (components.month > 1 ? @"s" : @"")]];
        
        if (components.day > 0)
        {
            [dateDifferenceMutableString appendString: [NSString stringWithFormat: @" and %@ day%@ ago", @(components.day), (components.day > 1 ? @"s" : @"")]];
        }
    }
    else if (components.day > 0)
    {
        [dateDifferenceMutableString appendString: [NSString stringWithFormat: @"%@ day%@", @(components.day), (components.day > 1 ? @"s" : @"")]];
        
        if (components.hour > 0)
        {
            [dateDifferenceMutableString appendString: [NSString stringWithFormat: @" and %@ hour%@ ago", @(components.hour), (components.hour > 1 ? @"s" : @"")]];
        }
    }
    else if (components.hour > 0)
    {
        [dateDifferenceMutableString appendString: [NSString stringWithFormat: @"%@ hour%@", @(components.hour), (components.hour > 1 ? @"s" : @"")]];
        
        if (components.minute > 0)
        {
            [dateDifferenceMutableString appendString: [NSString stringWithFormat: @" and %@ minute%@ ago", @(components.minute), (components.minute > 1 ? @"s" : @"")]];
        }
    }
    else
    {
        [dateDifferenceMutableString appendString: [NSString stringWithFormat: @"%@ minute%@ ago", @(components.minute), (components.minute > 1 ? @"s" : @"")]];
    }
    
    return [NSString stringWithString: dateDifferenceMutableString];
}

#pragma mark - Helper Methods

-(BOOL)isEqual:(id)object
{
    if(![object isKindOfClass:[SYNNotification class]])
        return NO;
    
    if(object == self)
        return YES;
    
    SYNNotification* notificationToCompare = (SYNNotification*)object;
    
    if(self.identifier != notificationToCompare.identifier)
        return NO;
    
    if(self.objectType != notificationToCompare.objectType)
        return NO;
    
    if(![self.messageType isEqualToString:notificationToCompare.messageType])
        return NO;
    
    // check conditioanlly for either types
    if(self.videoId)
    {
        if(![self.videoId isEqualToString:notificationToCompare.videoId])
            return NO;
        
        if(![self.videoThumbnailUrl isEqualToString:notificationToCompare.videoThumbnailUrl])
            return NO;
    }
    else
    {
        if(![self.channelThumbnailUrl isEqualToString:notificationToCompare.channelThumbnailUrl])
            return NO;
    }
    
    if(![self.channelId isEqualToString:notificationToCompare.channelId])
        return NO;
    
    if(![self.channelResourceUrl isEqualToString:notificationToCompare.channelResourceUrl])
        return NO;
    
    
    
    if(![self.channelOwner.uniqueId isEqualToString:notificationToCompare.channelOwner.uniqueId])
        return NO;
    
    
    
    return YES;
    
}

- (NSString *) description
{
    NSMutableString *descriptionToReturn = [[NSMutableString alloc] init];
    
    [descriptionToReturn appendFormat: @"<SYNRockpackNotification: %p (identifier:'%@', type:%@,", self, @(self.identifier), @(self.objectType)];
    [descriptionToReturn appendFormat: @" channelOwner:'%@')", self.channelOwner.displayName];
    [descriptionToReturn appendFormat: @" videoThumbnailUrl:'%@')", self.videoThumbnailUrl];
    [descriptionToReturn appendString: @">"];
    return descriptionToReturn;
}


@end
