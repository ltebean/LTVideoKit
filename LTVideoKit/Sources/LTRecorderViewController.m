//
//  LTRecorderViewController.m
//  LTVideoKit
//
//  Created by ltebean on 16/3/23.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "LTRecorderViewController.h"
#import "LTVideoSegment.h"
#import "LTAVAssetUtils.h"
#import "LTVideoViewerViewController.h"
#import "LTVideoEditorViewController.h"

@interface LTRecorderViewController () <AVCaptureFileOutputRecordingDelegate, LTRecorderProgressViewDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) NSMutableArray *videoSegments;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic) NSTimeInterval maxSeconds;
@property (nonatomic) BOOL running;
@end

@implementation LTRecorderViewController
+ (instancetype)instance
{
    NSBundle *bundle = [NSBundle bundleForClass:[LTRecorderViewController class]];
    return [[UIStoryboard storyboardWithName:@"Main" bundle:bundle] instantiateViewControllerWithIdentifier:@"recorder"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.captureSessionPreset = AVCaptureSessionPreset1280x720;
    self.exportSessionPreset = AVAssetExportPreset1280x720;
    
    self.maxSeconds = 15;

    self.videoSegments = [NSMutableArray array];
    
    self.progressView.totalSeconds = self.maxSeconds;
    self.progressView.delegate = self;
    
    self.finishButton.alpha = 0;
    self.deleteSegmentButton.alpha = 0;

    // config capture session
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = self.captureSessionPreset ?: AVCaptureSessionPresetiFrame960x540;
    
    // add audio input
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    [self.session addInput:audioInput];
    
    // add video input
    self.videoDevice = [self captureDeviceWithPosition:AVCaptureDevicePositionBack];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
    [self.session addInput:videoInput];
    
    // add movie output
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [self.session addOutput:self.movieFileOutput];


    // preview layer
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    // tap to focus
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.progressView.videoSegments = self.videoSegments;
    [self.progressView update];
    self.shootingButton.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeAllVideoSegments];
    [self.session stopRunning];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.view.bounds;
    [self updateOrientation];
}

# pragma mark - Video segment

- (void)startSegment
{
    self.running = YES;
    LTVideoSegment *segment = [LTVideoSegment new];
    segment.startTime = [[NSDate date] timeIntervalSince1970];
    segment.running = YES;
    segment.url = [LTAVAssetUtils urlForVideoWithUuid:[[NSUUID UUID] UUIDString]];
    
    [self.videoSegments addObject:segment];
    [self.movieFileOutput startRecordingToOutputFileURL:segment.url recordingDelegate:self];
    [self.progressView startUpdate];
}

- (void)stopSegment
{
    self.running = NO;
    LTVideoSegment *segment = [self.videoSegments lastObject];
    segment.endTime = [[NSDate date] timeIntervalSince1970];
    segment.running = NO;
    [self.progressView update];
    [self.progressView stopUpdate];
    [self.movieFileOutput stopRecording];
}

- (void)removeAllVideoSegments
{
    for (LTVideoSegment *segment in self.videoSegments) {
        [[NSFileManager defaultManager] removeItemAtURL:segment.url error:nil];
    }
    self.videoSegments = [NSMutableArray array];
}

- (void)didReachedTotalSeconds
{
    if (self.running) {
        [self stopSegment];
        self.shootingButton.enabled = NO;
    }
}

# pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error) {
        NSLog(@"error capture video");
        return;
    }
}

# pragma mark - IBAction
- (IBAction)deleteSegmentButtonPressed:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete last segment?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        LTVideoSegment *segment = [self.videoSegments lastObject];
        [[NSFileManager defaultManager] removeItemAtURL:segment.url error:nil];
        [self.videoSegments removeLastObject];
        [self.progressView update];
        self.shootingButton.enabled = YES;
    }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)shootingButtonTouchDown:(UIButton *)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        sender.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
    [self startSegment];
}

- (IBAction)shootingButtonTouchUp:(UIButton *)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        sender.transform = CGAffineTransformIdentity;
        self.finishButton.alpha = 1;
        self.deleteSegmentButton.alpha = 1;
    }];
    [self stopSegment];
}

- (IBAction)torchButtonPressed:(id)sender
{
    AVCaptureDevice *device = self.videoDevice;
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (device.torchMode == AVCaptureTorchModeOn) {
            [device setTorchMode:AVCaptureTorchModeOff];
        } else {
            [device setTorchMode:AVCaptureTorchModeOn];
        }
        [device unlockForConfiguration];
    }
}

- (IBAction)switchCameraButtonPressed:(id)sender
{
    [self.session beginConfiguration];
    AVCaptureDeviceInput *videoInput = [self.session.inputs objectAtIndex:1];
    [self.session removeInput:videoInput];
    if (videoInput.device.position == AVCaptureDevicePositionBack) {
        self.videoDevice = [self captureDeviceWithPosition:AVCaptureDevicePositionFront];
    } else {
        self.videoDevice = [self captureDeviceWithPosition:AVCaptureDevicePositionBack];
    }
    NSError *error = nil;
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.videoDevice error:&error];
    [self.session addInput:newVideoInput];
    [self.session commitConfiguration];
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [recognizer locationInView:recognizer.view];
        if([self.videoDevice isFocusPointOfInterestSupported] && [self.videoDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
            [self.videoDevice lockForConfiguration:nil];
            CGPoint poi = [self.previewLayer captureDevicePointOfInterestForPoint:point];
            [self.videoDevice setFocusPointOfInterest:poi];
            [self.videoDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            [self.videoDevice unlockForConfiguration];
        }
    }
}

- (IBAction)finishButtonPressed:(id)sender
{
    NSMutableArray *assets = [NSMutableArray array];
    for (LTVideoSegment *segment in self.videoSegments) {
        [assets addObject:[AVAsset assetWithURL:segment.url]];
    }
    AVAsset *asset = [LTAVAssetUtils assetByMergeAssets:assets];
    NSURL *outputUrl = [LTAVAssetUtils urlForVideoWithUuid:[[NSUUID UUID] UUIDString]];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:self.exportSessionPreset ?: AVAssetExportPreset960x540];
    exportSession.outputURL = outputUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [SVProgressHUD show];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self goToEditorWithUrl:outputUrl];
        });
    }];
}

# pragma mark - Go to other page

- (void)goToEditorWithUrl:(NSURL *)url
{
    LTVideoEditorViewController *vc = [LTVideoEditorViewController instance];
    vc.assetUrl = url;
    vc.exportSessionPreset = self.exportSessionPreset;
    [self presentViewController:vc animated:YES completion:nil];
}

# pragma mark - Helpers

- (AVCaptureDevice *)captureDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            if([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
                [device lockForConfiguration:nil];
                [device setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                [device unlockForConfiguration];
            }
            return device;
        }
    }
    return nil;
}

- (void)updateOrientation
{
    AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if([connection isVideoOrientationSupported]) {
        [connection setVideoOrientation:[self interfaceToVideoOrientation]];
        self.previewLayer.connection.videoOrientation = [self interfaceToVideoOrientation];
    }
}

- (AVCaptureVideoOrientation)interfaceToVideoOrientation
{
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        default:
            return AVCaptureVideoOrientationPortrait;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


@end
