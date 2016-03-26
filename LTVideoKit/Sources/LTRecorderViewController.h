//
//  LTRecorderViewController.h
//  LTVideoKit
//
//  Created by ltebean on 16/3/23.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTRecorderProgressView.h"

@interface LTRecorderViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *shootingButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *torchButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteSegmentButton;
@property (weak, nonatomic) IBOutlet LTRecorderProgressView *progressView;
@property (copy, nonatomic) NSString *captureSessionPreset;
@property (copy, nonatomic) NSString *exportSessionPreset;
+ (instancetype)instance;
@end
