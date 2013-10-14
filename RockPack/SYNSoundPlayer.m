//
//  SYNSoundPlayer.m
//  rockpack
//
//  Created by Michael Michailidis on 26/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNSoundPlayer.h"


#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@implementation SYNSoundPlayer
@synthesize soundEnabled;

+ (instancetype) sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    [sharedInstance setSoundEnabled:YES];
    return sharedInstance;
}

-(void)playSoundByName:(NSString*)soundName
{
    if (![self soundEnabled]) {
        DebugLog(@"Trying to play sound '%@' while dissabled", soundName);
        return;
    }

    NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType: @"aif"];
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);

}





@end
