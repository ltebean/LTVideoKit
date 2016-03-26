//
//  LTRecorderProgressView.h
//  Video
//
//  Created by ltebean on 16/3/23.
//  Copyright © 2016年 glow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTVideoSegment.h"

@protocol LTRecorderProgressViewDelegate <NSObject>
- (void)didReachedTotalSeconds;
@end

IB_DESIGNABLE
@interface LTRecorderProgressView : UIView
@property (nonatomic, strong) IBInspectable UIColor *color;
@property (nonatomic, strong) NSArray *videoSegments;
@property (nonatomic) NSTimeInterval totalSeconds;
@property (nonatomic, weak) id<LTRecorderProgressViewDelegate> delegate;
- (void)update;
- (void)startUpdate;
- (void)stopUpdate;
@end
