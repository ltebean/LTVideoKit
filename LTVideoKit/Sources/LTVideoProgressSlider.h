//
//  LTVideoSliderView.h
//  LTVideoKit
//
//  Created by ltebean on 16/4/3.
//  Copyright © 2016年 ltebean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LTVideoProgressSlider : UIView
@property (nonatomic) CGSize thumbnailSize;
- (void)reloadWithImages:(NSArray *)images;
@end
