//
//  TodayViewController.m
//  wonder-today-extension
//
//  Created by Cong on 07/08/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "VideoInstance.h"
#import "AbstractCommon.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>
#import "SYNTrackingManager.h"
#import <Reachability.h>
@import CoreTelephony;

#define IS_IPHONE ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
#define IS_IPAD ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
static const NSInteger TrackingDimensionConnection = 6;

@interface TodayViewController () <NCWidgetProviding>
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *videoButton;
@property (strong, nonatomic) NSDictionary *videoDictionary;
@property (strong, nonatomic) IBOutlet UIButton *curatedByButton;
@property (strong, nonatomic) IBOutlet UILabel *watchLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelRight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topPlayImage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftPlayImage;
@property (strong, nonatomic) CTTelephonyNetworkInfo *networkInfo;
@property (nonatomic, strong) Reachability *reachability;

@end

@implementation TodayViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultsDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpVideo];

    self.networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *hostname = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIHostName"];
    self.reachability = [Reachability reachabilityWithHostname:hostname];
    [self.reachability startNotifier];

    if ([[UIScreen mainScreen] bounds].size.width > 600) {
        [self.labelRight setConstant:223];
        [self.labelTop setConstant:12];
        [self.topPlayImage setConstant:97];
        [self.leftPlayImage setConstant:122];
        [self.videoWidth setConstant:320];
        [self.videoHeight setConstant:190];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpVideo];
    [self widgetTracking];
}

- (void)setUpVideo{
    
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wonderapps"];
    self.videoDictionary = [[mySharedDefaults dictionaryForKey:@"videoData"] mutableCopy];
    
    if ([mySharedDefaults boolForKey:@"isVideo"]) {
        [self setUpVideoDescription];
        
        [self.titleLabel setText:self.videoDictionary[@"title"]];
        
        UIImage* myImage = [UIImage imageWithData:
                            [NSData dataWithContentsOfURL:
                             [NSURL URLWithString: [mySharedDefaults objectForKey:@"thumbnailURL"]]]];
        
        [self.videoButton setImage:myImage forState:UIControlStateNormal];
        
        [self.curatedByButton setTitle:self.videoDictionary[@"channelOwnerName"] forState:UIControlStateNormal];
        [self.watchLabel setText:self.videoDictionary[@"duration"]];
        
        self.titleLabel.hidden = NO;
        self.videoButton.hidden = NO;
        self.curatedByButton.hidden = NO;
        self.watchLabel.hidden = NO;
    }
}

- (void)setUpViews :(BOOL) isVideo {
    self.titleLabel.hidden = isVideo;
    self.videoButton.hidden = isVideo;
    self.curatedByButton.hidden = isVideo;
    self.watchLabel.hidden = isVideo;
}

- (void)setUpVideoDescription {
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wonderapps"];

    NSString *videoDescription = [mySharedDefaults objectForKey:@"videoDescription"];
    self.descriptionLabel.hidden = ([videoDescription length] == 0);
    self.descriptionLabel.hidden = NO;
    [self.descriptionLabel setText:[self stringByStrippingHTMLFromString:videoDescription]];

    
    if (videoDescription.length > 0) {
        if (IS_IPAD) {
            self.preferredContentSize = CGSizeMake(0, 330);
        } else {
            self.preferredContentSize = CGSizeMake(0, 210);
        }
    } else {
        if (IS_IPAD) {
            self.preferredContentSize = CGSizeMake(0, 260);
        } else {
            self.preferredContentSize = CGSizeMake(0, 170);
        }
    }
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self setUpVideo];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self setUpVideo];
    completionHandler(NCUpdateResultNewData);
}

- (IBAction)openApp:(id)sender {
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wonderapps"];

    if ([mySharedDefaults boolForKey:@"isVideo"]) {
        
        NSString *channelId = [mySharedDefaults objectForKey:@"channelId"];
        NSString *videoId = [mySharedDefaults objectForKey:@"videoId"];

        NSString *urlString = [NSString stringWithFormat:@"wonderpl://-/channels/%@/videos/%@/", channelId,videoId];
        NSURL *url = [NSURL URLWithString:urlString];
        [self.extensionContext openURL:url completionHandler:nil];
    }
}

-(NSString *) stringByStrippingHTMLFromString:(NSString*)s {
    NSRange r;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

#pragma mark - Tracking

- (void) widgetTracking {
    [self setUpGATracking];
    
    [[self defaultTracker] set:kGAIScreenName value:@"Widget"];
    [[self defaultTracker] send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) setUpGATracking {
    GAI *gai = [GAI sharedInstance];
    [gai trackerWithTrackingId:kGoogleAnalyticsId];
    gai.trackUncaughtExceptions = YES;
    gai.dispatchInterval = 30;
    [self setConnectionDimension:[self currentConnectionString]];
}

- (id<GAITracker>)defaultTracker {
    return [[GAI sharedInstance] defaultTracker];
}

- (void)setConnectionDimension:(NSString *)connection {
    [[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionConnection] value:connection];
}

- (NSString *)currentConnectionString {
    if ([self.reachability isReachableViaWiFi]) {
        return @"wifi";
    }
    if ([self.reachability isReachableViaWWAN]) {
        return [self cellTechnologyGeneration:self.networkInfo.currentRadioAccessTechnology];
    }
    return @"none";
}

- (NSString *)cellTechnologyGeneration:(NSString *)technology {
    return (@{ CTRadioAccessTechnologyGPRS         : @"2g",
               CTRadioAccessTechnologyEdge         : @"2g",
               CTRadioAccessTechnologyWCDMA        : @"3g",
               CTRadioAccessTechnologyHSDPA        : @"3g",
               CTRadioAccessTechnologyHSUPA        : @"3g",
               CTRadioAccessTechnologyCDMA1x       : @"3g",
               CTRadioAccessTechnologyCDMAEVDORev0 : @"3g",
               CTRadioAccessTechnologyCDMAEVDORevA : @"3g",
               CTRadioAccessTechnologyCDMAEVDORevB : @"3g",
               CTRadioAccessTechnologyeHRPD        : @"3g",
               CTRadioAccessTechnologyLTE          : @"4g" }[technology] ?: @"unknown");
}

@end
