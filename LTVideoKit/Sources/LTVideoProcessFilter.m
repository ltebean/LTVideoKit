//
//  LTVideoMonoFilter.m
//  LTVideoKit
//
//  Created by ltebean on 16/3/25.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import "LTVideoProcessFilter.h"

@implementation LTVideoProcessFilter
- (NSString *)name
{
    return @"Process";
}

- (CIImage *)imageByProcessImage:(CIImage *)image
{
    return [image imageByApplyingFilter:@"CIPhotoEffectProcess" withInputParameters:nil];
}
@end
