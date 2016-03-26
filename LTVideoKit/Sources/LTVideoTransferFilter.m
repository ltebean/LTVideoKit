//
//  LTVideoTransferFilter.m
//  LTVideoKit
//
//  Created by ltebean on 16/3/25.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import "LTVideoTransferFilter.h"

@implementation LTVideoTransferFilter
- (NSString *)name
{
    return @"Transfer";
}

- (CIImage *)imageByProcessImage:(CIImage *)image
{
    return [image imageByApplyingFilter:@"CIPhotoEffectTransfer" withInputParameters:nil];
}
@end
