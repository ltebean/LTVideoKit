//
//  LTVideoEditorViewController.m
//  LTVideoKit
//
//  Created by ltebean on 16/3/24.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import <LTInfiniteScrollView/LTInfiniteScrollView.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "LTVideoEditorViewController.h"
#import "LTVideoViewerViewController.h"
#import "LTVideoFilter.h"
#import "LTVideoPlainFilter.h"
#import "LTVideoInstantFilter.h"
#import "LTVideoProcessFilter.h"
#import "LTVideoFadeFilter.h"
#import "LTVideoTransferFilter.h"
#import "LTVideoProgressSlider.h"

#import "LTAVAssetUtils.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface LTVideoEditorViewController () <LTInfiniteScrollViewDataSource, LTInfiniteScrollViewDelegate>
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (strong, nonatomic) LTInfiniteScrollView *scrollView;

@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, strong) AVMutableComposition *mixComposition;
@property (nonatomic, strong) AVMutableComposition *originalMixComposition;
@property (nonatomic, strong) AVVideoComposition *videoComposition;
//@property (weak, nonatomic) IBOutlet LTVideoProgressSlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeControl;
@end

@implementation LTVideoEditorViewController

+ (instancetype)instance
{
    NSBundle *bundle = [NSBundle bundleForClass:[LTVideoEditorViewController class]];
    return [[UIStoryboard storyboardWithName:@"Main" bundle:bundle] instantiateViewControllerWithIdentifier:@"editor"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.assetUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mp4"];
    
    self.asset = [AVAsset assetWithURL:self.assetUrl];
    
    self.filters = @[
        [LTVideoPlainFilter new],
        [LTVideoInstantFilter new],
        [LTVideoProcessFilter new],
        [LTVideoTransferFilter new],
        [LTVideoFadeFilter new]
    ];
    
    // filter scroll view
    self.scrollView = [[LTInfiniteScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.dataSource = self;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view insertSubview:self.scrollView aboveSubview:self.playerView];
    
    self.slider.minimumValue = 0;
    self.slider.maximumValue = CMTimeGetSeconds(self.asset.duration);
    
//    self.progressSlider.thumbnailSize = CGSizeMake(36, 64);
    
    self.player = [[AVPlayer alloc] init];
    
    self.originalMixComposition = [LTAVAssetUtils mixCompositionWithAsset:self.asset];
    
    self.mixComposition = [self.originalMixComposition mutableCopy];
    [self resetPlayerItemWithAsset:self.mixComposition];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.view.bounds;
    [self.playerView.layer addSublayer:self.playerLayer];
    
    self.slider.hidden = YES;

}

- (void)resetPlayerItemWithAsset:(AVAsset *)asset
{
    // video composition
    CIContext *context = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace : [NSNull null], kCIContextOutputColorSpace : [NSNull null]}];
    self.videoComposition = [AVVideoComposition videoCompositionWithAsset:asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        CIImage *image = request.sourceImage.imageByClampingToExtent;
        id<LTVideoFilter> filter = [self currentFilter];
        image = [filter imageByProcessImage:image];
        [request finishWithImage:image context:context];
    }];
    
    // config player
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    self.playerItem.videoComposition = self.videoComposition;
    self.playerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmTimeDomain;
    
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:nil usingBlock:^(NSNotification *note) {
        [self.player seekToTime:kCMTimeZero];
        [self.player play];
    }];
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scrollView reloadDataWithInitialIndex:0];
    [self.player play];
//    [LTAVAssetUtils generateImagesFromAsset:self.asset interval:1 completionHandler:^(NSArray *images) {
//        NSLog(@"%ld", images.count);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.progressSlider reloadWithImages:images];
//        });
//    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.player pause];
}

# pragma mark - LTInfiniteScrollView data source

- (NSInteger)numberOfViews
{
    return self.filters.count;
}

- (NSInteger)numberOfVisibleViews
{
    return 1;
}

- (UIView *)viewAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    id<LTVideoFilter> filter = self.filters[index];
    if (view) {
        UILabel *label = (UILabel *)view;
        label.text = [filter name];
        return view;
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:30];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [filter name];
        return label;
    }
}

# pragma mark - IBAction
- (IBAction)closeButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editorModeChanged:(id)sender {
    self.mixComposition = [self.originalMixComposition mutableCopy];
    [self resetPlayerItemWithAsset:self.mixComposition];

    NSInteger mode = self.modeControl.selectedSegmentIndex;
    if (mode == 0) {
        self.slider.hidden = YES;
    } else {
        self.slider.hidden = NO;
    }
}


- (IBAction)sliderEditingDidBegin:(UISlider *)sender {
    [self.player pause];
    self.mixComposition = [self.originalMixComposition mutableCopy];
    [self resetPlayerItemWithAsset:self.mixComposition];
}

- (IBAction)sliderEditingDidEnd:(UISlider *)sender {
    [self.player pause];
    
    self.mixComposition = [self.originalMixComposition mutableCopy];
    [LTAVAssetUtils scaleComposition:self.mixComposition atSeconds:sender.value duration:0.5 withScaleFactor:5.0];
    [self resetPlayerItemWithAsset:self.mixComposition];
    
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (IBAction)sliderEditingChanged:(UISlider *)sender {
    CMTimeScale timescale = self.player.currentItem.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(self.slider.value, timescale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (IBAction)finishButtonPressed:(id)sender {
    
    NSURL *outputUrl = [LTAVAssetUtils urlForVideoWithUuid:[[NSUUID UUID] UUIDString]];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:self.mixComposition presetName:self.exportSessionPreset ?: AVAssetExportPreset960x540];
    exportSession.videoComposition = self.playerItem.videoComposition;
    exportSession.outputURL = outputUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [SVProgressHUD show];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [[NSFileManager defaultManager] removeItemAtURL:self.assetUrl error:nil];
            [self goToEditorWithUrl:outputUrl];
        });
    }];
}




# pragma mark - Go to other page

- (void)goToEditorWithUrl:(NSURL *)url
{
    LTVideoViewerViewController *vc = [LTVideoViewerViewController instance];
    vc.asset = [AVAsset assetWithURL:url];
    [self presentViewController:vc animated:YES completion:nil];
}

# pragma mark - LTInfiniteScrollView delegate

- (void)updateView:(UIView *)view withProgress:(CGFloat)progress scrollDirection:(ScrollDirection)direction
{
    if (progress == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            view.alpha = 0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            view.alpha = 1;
        }];
    }
}

#pragma mark - helpers
- (id<LTVideoFilter>)currentFilter
{
    return self.filters[self.scrollView.currentIndex];
}


@end
