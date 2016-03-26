//
//  LTVideoPlainFilter.m
//  LTVideoKit
//
//  Created by ltebean on 16/3/24.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import "LTVideoPlainFilter.h"

@implementation LTVideoPlainFilter

- (NSString *)name
{
    return @"Plain";
}

- (CIImage *)imageByProcessImage:(CIImage *)image
{
    return image;
}


@end
