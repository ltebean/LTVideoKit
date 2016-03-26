//
//  LTVideoViewerViewController.m
//  LTVideoKit
//
//  Created by ltebean on 16/3/24.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import "LTVideoViewerViewController.h"

@interface LTVideoViewerViewController ()
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@end

@implementation LTVideoViewerViewController
+ (instancetype)instance
{
    NSBundle *bundle = [NSBundle bundleForClass:[LTVideoViewerViewController class]];
    return [[UIStoryboard storyboardWithName:@"Main" bundle:bundle] instantiateViewControllerWithIdentifier:@"viewer"];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.playerLayer];
    [self.player play];

    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf.player seekToTime:kCMTimeZero];
        [weakSelf.player play];
    }];
}





- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
