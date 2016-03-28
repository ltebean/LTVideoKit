//
//  LTAVAssetUtils.m
//  LTVideoKit
//
//  Created by ltebean on 16/3/23.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import "LTAVAssetUtils.h"

@implementation LTAVAssetUtils

+ (NSURL *)urlForVideoWithUuid:(NSString *)uuid
{
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", uuid];
    NSString *documentsDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsDirPath stringByAppendingPathComponent:videoName];
    return [NSURL fileURLWithPath:path];
}

+ (AVAsset *)assetWithUuid:(NSString *)uuid
{
    return [AVAsset assetWithURL:[self urlForVideoWithUuid:uuid]];
}

+ (AVAsset *)assetByMergeAssets:(NSArray *)assets
{
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID: kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime insertTime = kCMTimeZero;
    for (AVAsset *asset in assets) {
        AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        
        [compositionVideoTrack setPreferredTransform:videoTrack.preferredTransform];
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        
        [compositionVideoTrack insertTimeRange:timeRange
                                       ofTrack:videoTrack
                                        atTime:insertTime
                                         error:nil];
        
        [compositionAudioTrack insertTimeRange:timeRange
                                       ofTrack:audioTrack
                                        atTime:insertTime
                                         error:nil];
        
        insertTime = CMTimeAdd(insertTime, asset.duration);
    }
    return mixComposition;
}

+ (AVMutableComposition *)mixCompositionWithAsset:(AVAsset *)asset
{
    CMTimeRange range = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    // video track
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionVideoTrack insertTimeRange:range
                                   ofTrack:videoTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    [compositionVideoTrack setPreferredTransform:videoTrack.preferredTransform];
    
    // audio track
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionAudioTrack insertTimeRange:range
                                   ofTrack:audioTrack
                                    atTime:kCMTimeZero
                                     error:nil];

    return mixComposition;
}

+ (void)scaleComposition:(AVMutableComposition *)composition atSeconds:(Float64)startSeconds duration:(Float64)duration withScaleFactor:(Float64)factor
{
    CMTimeScale timescale = composition.duration.timescale;
    duration = fmin(duration, CMTimeGetSeconds(composition.duration) - startSeconds);
    
    Float64 start = startSeconds;
    Float64 end = startSeconds + duration;
    
    CMTime startTime = CMTimeMakeWithSeconds(start, timescale);
    CMTime durationTime = CMTimeMakeWithSeconds(end - start, timescale);
    
    Float64 finalDuration = (end - start) * factor;
    
    [composition scaleTimeRange:CMTimeRangeMake(startTime, durationTime) toDuration:CMTimeMakeWithSeconds(finalDuration, timescale)];
}

@end
