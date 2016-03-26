//
//  LTVideoEditorViewController.h
//  LTVideoKit
//
//  Created by ltebean on 16/3/24.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LTVideoEditorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic, strong) NSURL *assetUrl;
@property (copy, nonatomic) NSString *exportSessionPreset;
+ (instancetype)instance;
@end
