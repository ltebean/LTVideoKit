//
//  LTVideoViewerViewController.h
//  LTVideoKit
//
//  Created by ltebean on 16/3/24.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LTVideoViewerViewController : UIViewController
@property (nonatomic, strong) AVAsset *asset;
+ (instancetype)instance;
@end
