//
//  LTVideoSegment.h
//  Video
//
//  Created by ltebean on 16/3/23.
//  Copyright © 2016年 glow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTVideoSegment : NSObject
@property (nonatomic, copy) NSURL *url;
@property (nonatomic) BOOL running;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;
@end
