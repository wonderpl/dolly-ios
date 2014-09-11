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
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnail;
@property (strong, nonatomic) IBOutlet UIButton *clickToMoreButton;
@property (strong, nonatomic) IBOutlet UIView *videoThumbnail;
@property (strong, nonatomic) IBOutlet UIButton *videoButton;

@property (strong, nonatomic) NSDictionary *videoDictionary;
@property (strong, nonatomic) NSDictionary *channelDictionary;
@property (strong, nonatomic) IBOutlet UIButton *avatarButton;
@property (strong, nonatomic) IBOutlet UILabel *channelLabel;
@property (strong, nonatomic) IBOutlet UILabel *channelTitle;
@property (strong, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;
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
    self.preferredContentSize = CGSizeMake(0, 220);
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
        self.clickToMoreButton.layer.cornerRadius = (CGRectGetHeight(self.clickToMoreButton.frame) / 2.0);
        self.clickToMoreButton.layer.borderColor = [[self dollyGreen] CGColor];
        self.clickToMoreButton.layer.borderWidth = 2.0;
        self.clickToMoreButton.tintColor = [self dollyGreen];
        
        NSString *linkTitle = self.videoDictionary[@"linkTitle"];
        NSString *videoDescription = [mySharedDefaults objectForKey:@"videoDescription"];

        self.clickToMoreButton.hidden = ([linkTitle length] == 0);
        [self.clickToMoreButton setTitle:linkTitle forState:UIControlStateNormal];
        
        self.descriptionLabel.hidden = ([videoDescription length] == 0);
        self.descriptionLabel.hidden = NO;
        [self.descriptionLabel setText:[self stringByStrippingHTMLFromString:videoDescription]];
        
        [self.titleLabel setText:self.videoDictionary[@"title"]];
        
        UIImage* myImage = [UIImage imageWithData:
                            [NSData dataWithContentsOfURL:
                             [NSURL URLWithString: [mySharedDefaults objectForKey:@"thumbnailURL"]]]];
        
        [self.videoButton setImage:myImage forState:UIControlStateNormal];
    
        self.titleLabel.hidden = NO;
        self.thumbnail.hidden = NO;
        self.videoButton.hidden = NO;
        
        self.followButton.hidden = YES;
        self.avatarButton.hidden = YES;
        self.channelLabel.hidden = YES;
        self.channelTitle.hidden = YES;

    } else {
        self.channelDictionary = [mySharedDefaults dictionaryForKey:@"channelData"] ;
        UIImage* myImage2 = [UIImage imageWithData:
                            [NSData dataWithContentsOfURL:
                             [NSURL URLWithString: [mySharedDefaults objectForKey:@"avatarURL"]]]];

        [self.avatarButton setImage:myImage2 forState:UIControlStateNormal];
        NSString *channelOwnerString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"A collection of great new videos from ", nil), [mySharedDefaults objectForKey:@"channelOwnerDisplayName"]];

        self.channelLabel.text = channelOwnerString;
        self.channelTitle.text = [mySharedDefaults objectForKey:@"channelTitle"];
        self.titleLabel.hidden = YES;
        self.videoButton.hidden = YES;
        self.clickToMoreButton.hidden = YES;
        
//        self.followButton.selected = NO;
//        self.followButton.layer.cornerRadius = (CGRectGetHeight(self.followButton.frame) / 2.0);
//        self.followButton.layer.borderWidth = 2.0;
//
//        if (self.followButton.selected) {
//            self.followButton.layer.borderColor = [[self dollyGreen] CGColor];
//            self.followButton.backgroundColor = [self dollyGreen];
//            [self setTitle:NSLocalizedString(@"unfollow", nil)];
//            [self.followButton setTitleColor: [UIColor whiteColor]
//                       forState: UIControlStateNormal];
//            [self.followButton setTitleColor: [UIColor whiteColor]
//                       forState: UIControlStateSelected];
//        } else {
//            self.followButton.layer.borderColor = [[self dollyGreen] CGColor];
//            self.followButton.backgroundColor = [UIColor clearColor];
//            [self.followButton setTitle:NSLocalizedString(@"follow", nil) forState:UIControlStateNormal];
//            [self.followButton setTitleColor: [self dollyGreen]
//                       forState: UIControlStateNormal];
//            [self.followButton setTitleColor: [self dollyGreen]
//                       forState: UIControlStateSelected];
//        }
    }


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
