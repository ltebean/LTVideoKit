//
//  LTVideoSliderView.m
//  LTVideoKit
//
//  Created by ltebean on 16/4/3.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import "LTVideoProgressSlider.h"

@interface LTVideoProgressSlider()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *images;
@end

@implementation LTVideoProgressSlider
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];
}

- (void)layoutSubviews
{
    self.scrollView.frame = self.bounds;
    CGFloat inset = self.bounds.size.width / 2;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, inset, 0, inset);
}


- (void)reloadWithImages:(NSArray *)images
{
    self.images = images;
    CGFloat x = 0;
    CGFloat y = (self.bounds.size.height - self.thumbnailSize.height) / 2;
    for (UIImage *image in self.images) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(x, y, self.thumbnailSize.width, self.thumbnailSize.height);
        x += self.thumbnailSize.width;
        [self.scrollView addSubview:imageView];
    }
    self.scrollView.contentSize = CGSizeMake(self.thumbnailSize.width * self.images.count, self.thumbnailSize.height);
    
}
@end
