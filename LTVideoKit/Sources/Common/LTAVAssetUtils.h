//
//  LTAVAssetUtils.h
//  LTVideoKit
//
//  Created by ltebean on 16/3/23.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LTAVAssetUtils : NSObject
+ (NSURL *)urlForVideoWithUuid:(NSString *)uuid;
+ (AVAsset *)assetWithUuid:(NSString *)uuid;
+ (AVAsset *)assetByMergeAssets:(NSArray *)assets;
+ (AVMutableComposition *)mixCompositionWithAsset:(AVAsset *)asset;
+ (void)scaleComposition:(AVMutableComposition *)composition atSeconds:(Float64)startSeconds duration:(Float64)duration withScaleFactor:(Float64)factor;
@end
