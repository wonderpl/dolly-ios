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
#import "UIFont+SYNFont.h"

@interface TodayViewController () <NCWidgetProviding>
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *clickToMoreButton;
@property (strong, nonatomic) IBOutlet UIButton *videoButton;
@property (strong, nonatomic) NSDictionary *videoDictionary;
@property (strong, nonatomic) IBOutlet UILabel *addedByLabel;
@property (strong, nonatomic) IBOutlet UIButton *curatedByButton;
@property (strong, nonatomic) IBOutlet UILabel *watchLabel;

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
    self.preferredContentSize = CGSizeMake(0, 180);
    [self setUpVideo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpVideo];
}

- (void)setUpVideo{
    
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wonderapps"];
    self.videoDictionary = [[mySharedDefaults dictionaryForKey:@"videoData"] mutableCopy];
    
    if ([mySharedDefaults boolForKey:@"isVideo"]) {
        [self setUpClickToMore];
        [self setUpVideoDescription];
        
        [self.titleLabel setText:self.videoDictionary[@"title"]];
        
        UIImage* myImage = [UIImage imageWithData:
                            [NSData dataWithContentsOfURL:
                             [NSURL URLWithString: [mySharedDefaults objectForKey:@"thumbnailURL"]]]];
        
        [self.videoButton setImage:myImage forState:UIControlStateNormal];
        
        [self.addedByLabel setText:self.videoDictionary[@"label"]];
        [self.curatedByButton setTitle:self.videoDictionary[@"channelOwnerName"] forState:UIControlStateNormal];
        [self.watchLabel setText:self.videoDictionary[@"duration"]];
        
        self.titleLabel.hidden = NO;
        self.videoButton.hidden = NO;
        self.addedByLabel.hidden = NO;
        self.curatedByButton.hidden = NO;
        self.watchLabel.hidden = NO;
    }
}

- (void)setUpViews :(BOOL) isVideo {
    self.titleLabel.hidden = isVideo;
    self.videoButton.hidden = isVideo;
    self.clickToMoreButton.hidden = isVideo;
    self.addedByLabel.hidden = isVideo;
    self.curatedByButton.hidden = isVideo;
    self.watchLabel.hidden = isVideo;
}

- (void)setUpVideoDescription {
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wonderapps"];

    NSString *videoDescription = [mySharedDefaults objectForKey:@"videoDescription"];
    self.descriptionLabel.hidden = ([videoDescription length] == 0);
    self.descriptionLabel.hidden = NO;
    [self.descriptionLabel setText:[self stringByStrippingHTMLFromString:videoDescription]];
}

- (void)setUpClickToMore {
    self.clickToMoreButton.layer.cornerRadius = 5.0;
    NSString *linkTitle = self.videoDictionary[@"linkTitle"];
    self.clickToMoreButton.hidden = ([linkTitle length] == 0);
    [self.clickToMoreButton setTitle:linkTitle forState:UIControlStateNormal];
}

- (IBAction)avatarButtonTapped:(id)sender {
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wonderapps"];
    
    NSString *channelOwnerId = [mySharedDefaults objectForKey:@"channelOwnerId"];
    
    NSString *urlString = [NSString stringWithFormat:@"wonderpldev://-/%@/",channelOwnerId];
    NSURL *url = [NSURL URLWithString:urlString];
    [self.extensionContext openURL:url completionHandler:nil];

}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self setUpVideo];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void)openURL:(NSURL *)URL
completionHandler:(void (^)(BOOL success))completionHandler {
    
}

- (IBAction)clickToMoreButton:(id)sender {
    
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wonderapps"];
    
    
        NSString *channelId = [mySharedDefaults objectForKey:@"channelId"];
        NSString *videoId = [mySharedDefaults objectForKey:@"videoId"];
        
        NSString *urlString = [NSString stringWithFormat:@"wonderpldev://-/channels/%@/videos/%@/-/", channelId,videoId];
        NSURL *url = [NSURL URLWithString:urlString];
        [self.extensionContext openURL:url completionHandler:nil];

}

- (IBAction)followButton:(id)sender {
}

- (IBAction)openApp:(id)sender {
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wonderapps"];

    if ([mySharedDefaults boolForKey:@"isVideo"]) {
        
        NSString *channelId = [mySharedDefaults objectForKey:@"channelId"];
        NSString *videoId = [mySharedDefaults objectForKey:@"videoId"];

        NSString *urlString = [NSString stringWithFormat:@"wonderpldev://-/channels/%@/videos/%@/", channelId,videoId];
        NSURL *url = [NSURL URLWithString:urlString];
        [self.extensionContext openURL:url completionHandler:nil];
    }

}

- (UIColor*)dollyGreen {
        return [UIColor colorWithRed: 74.0f / 255.0f
                               green: 175.0f / 255.0f
                                blue: 92.0f / 255.0f
                               alpha: 1.0f];
}

-(NSString *) stringByStrippingHTMLFromString:(NSString*)s {
    NSRange r;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end
