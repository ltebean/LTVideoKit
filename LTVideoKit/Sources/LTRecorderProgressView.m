//
//  LTRecorderProgressView.m
//  Video
//
//  Created by ltebean on 16/3/23.
//  Copyright © 2016年 glow. All rights reserved.
//

#import "LTRecorderProgressView.h"
@interface LTRecorderProgressView()
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation LTRecorderProgressView
- (void)startUpdate
{
    [self stopUpdate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopUpdate
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)tick:(CADisplayLink *)displayLink
{
    [self update];
}

- (void)update
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    NSTimeInterval timeElapsed = 0;
    NSMutableArray *separators = [NSMutableArray array];
    
    for (LTVideoSegment *segment in self.videoSegments) {
        timeElapsed += (segment.running ? now : segment.endTime) - segment.startTime;
        if (!segment.running) {
            CGFloat progress = timeElapsed / self.totalSeconds;
            CGFloat left = progress * rect.size.width;
            
            UIBezierPath *separator = [UIBezierPath bezierPathWithRect:CGRectMake(left, 0, 1, rect.size.height)];
            [separators addObject:separator];
        }
    }
    
    CGFloat progress = timeElapsed / self.totalSeconds;
    if (progress >= 1) {
        [self.delegate didReachedTotalSeconds];
        progress = 1;
    }
    CGFloat width = progress * rect.size.width;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, rect.size.height)];
    [self.color setFill];
    [path fill];
    
    for (UIBezierPath *separator in separators) {
        [[UIColor whiteColor] setFill];
        [separator fill];
    }
}
@end
