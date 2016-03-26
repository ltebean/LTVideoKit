//
//  LTVideoFilter.h
//  LTVideoKit
//
//  Created by ltebean on 16/3/24.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@protocol LTVideoFilter <NSObject>
- (NSString *)name;
- (CIImage *)imageByProcessImage:(CIImage *)image;
@end
