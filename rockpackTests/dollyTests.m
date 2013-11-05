//
//  rockpackTests.m
//  rockpackTests
//
//  Created by Nick Banks on 19/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "dollyTests.h"
#import "SYNNetworkEngine.h"
#import "SYNMainRegistry.h"
#import "SYNAppDelegate.h"
#import "SYNSearchRegistry.h"
#import "SYNActivityViewController.h"
#import "SYNNotification.h"
#import <CoreData/CoreData.h>

@implementation dollyTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

// Search Test

-(void)testSearchResults
{
    //SYNNetworkEngine* ne = [[SYNNetworkEngine alloc] initWithDefaultSettings];
    
    
}

-(void)testNotificationCreation
{
    NSDictionary* notificationData = @{
                                       @"read" : @NO,
                                       @"id" : @80664,
                                       @"message_type" : @"subscribed",
                                       @"date_created" : @"2013-09-19T13:38:50.217180",
                                       @"message" : @{
                                               @"user" : @{
                                                       @"display_name" : @"qwe",
                                                       @"avatar_thumbnail_url" : @"",
                                                       @"id" : @"Klb_4-r_5KpP0RpcySoz2A",
                                                       @"resource_url" : @"http://api.demo.rockpack.com/ws/Klb_4-r_5KpP0RpcySoz2A/"
                                                       },
                                               @"channel" : @{
                                                       @"id" : @"ch9HaxNJur3YMGUqcEB3mVSw",
                                                       @"resource_url" : @"https://secure.demo.rockpack.com/ws/3pLbs-wsQX64ORXcO2YRYg/channels/ch9HaxNJur3YMGUqcEB3mVSw/",
                                                       @"thumbnail_url" : @"http://media.dev.rockpack.com/images/channel/thumbnail_medium/8TQPfDOMkKfTD_1TLn_LHw.jpg"
                                                       }
                                               }
                                       };
    SYNNotification* firstNotification = [SYNNotification notificationWithDictionary:notificationData];
    STAssertEquals(firstNotification.identifier, 80664, @"Notification Identifier not set correctly");
    STAssertEquals(firstNotification.messageType, @"subscribed", @"Notification Identifier not set correctly"); // messageType sets the objectType below
    STAssertEquals(firstNotification.objectType, kNotificationObjectTypeUserSubscibedToYourChannel, @"Notification 'subsribed' type not set correctly");
    STAssertEquals(firstNotification.channelId, @"ch9HaxNJur3YMGUqcEB3mVSw", @"Notification Channel Id not set correctly");
  
    
}

-(void)testNotificationsResults
{
    
    NSString *jsonFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"NotificationsForUser" ofType:@"json"];
    
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath];
    
    STAssertNotNil(jsonData, @"NSData could not be created from JSON file: 'NotificationsForUser'");
    
    NSError *error;
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:0
                                                                     error:&error];

    
    STAssertNotNil(jsonDictionary, @"NSDictionary was not created from JSON file 'NotificationsForUser.json'");
    
    
    SYNActivityViewController* avc = [[SYNActivityViewController alloc] initWithViewId:@"TestActivityViewId"];
    [avc parseNotificationsFromDictionary:jsonDictionary];
    
    NSUInteger totalC = avc.notifications.count;
    STAssertEquals(totalC, (NSUInteger)52, [NSString stringWithFormat:@"Not all Notifications where parsed, expected 52 got %i", totalC]);
    
    // Fake Notification
    NSDictionary* notificationData = @{
        @"read" : @NO,
        @"id" : @80664,
        @"message_type" : @"subscribed",
        @"date_created" : @"2013-09-19T13:38:50.217180",
        @"message" : @{
            @"user" : @{
                @"display_name" : @"qwe",
                @"avatar_thumbnail_url" : @"",
                @"id" : @"Klb_4-r_5KpP0RpcySoz2A",
                @"resource_url" : @"http://api.demo.rockpack.com/ws/Klb_4-r_5KpP0RpcySoz2A/"
            },
            @"channel" : @{
                @"id" : @"ch9HaxNJur3YMGUqcEB3mVSw",
                @"resource_url" : @"https://secure.demo.rockpack.com/ws/3pLbs-wsQX64ORXcO2YRYg/channels/ch9HaxNJur3YMGUqcEB3mVSw/",
                @"thumbnail_url" : @"http://media.dev.rockpack.com/images/channel/thumbnail_medium/8TQPfDOMkKfTD_1TLn_LHw.jpg"
            }
        }
    };
    SYNNotification* firstNotification = [SYNNotification notificationWithDictionary:notificationData];
    
    STAssertEqualObjects(firstNotification, avc.notifications[0], @"Notifications not parsed correctly, first in array does not contain correct data");
    
}

-(void)testSearchVideosRegistration
{
    // for: http://api.rockpack.com/ws/search/videos/?locale=en_gb&q=Michael&start=0&size=10 as received on 23 of December 2013
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    STAssertNotNil(appDelegate, @"AppDelegate does not exist...");
    
    NSString *jsonFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SearchVideosResultsForMichael" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath];
    
    
    NSError *error;
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:0
                                                                     error:&error];
    
    
    [appDelegate.searchRegistry registerVideoInstancesFromDictionary:jsonDictionary];
    
    // Get the objects from core data
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: kVideoInstance
                                      inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", kSearchViewId]];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    
    NSArray* fetchedObjects = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest error: &error];
    
    STAssertNil(error, @"Error occured while fetching the data");
    
    STAssertEquals(fetchedObjects.count, (NSUInteger)10, @"Not all objects parsed");
    
    // == Clear the Search Registry == //
    
    BOOL success = [appDelegate.searchRegistry clearImportContextFromEntityName: @"VideoInstance"];
    
    STAssertTrue(success, @"Could not clear search registry from VideoInstance");
    
    
    // == Do it Again! == //
    
    [appDelegate.searchRegistry registerVideoInstancesFromDictionary:jsonDictionary];
    
    fetchedObjects = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest error: &error];
    
    STAssertNil(error, @"Error occured while fetching the data for the second time (after clearing db)");
    
    STAssertEquals(fetchedObjects.count, (NSUInteger)10, @"Not all objects parsed for the second time (after clearing db)");
    
    
    
    
}

@end
