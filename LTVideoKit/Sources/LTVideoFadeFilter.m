//
//  LTVideoFadeFilter.m
//  LTVideoKit
//
//  Created by ltebean on 16/3/25.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import "LTVideoFadeFilter.h"

@implementation LTVideoFadeFilter
- (NSString *)name
{
    return @"Instant";
}

- (CIImage *)imageByProcessImage:(CIImage *)image
{
    return [image imageByApplyingFilter:@"CIPhotoEffectFade" withInputParameters:nil];
}
@end
