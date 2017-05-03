//
//  RHProgressSlider.h
//  AVPlayerDemo
//
//  Created by 郭人豪 on 2017/3/29.
//  Copyright © 2017年 Abner_G. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RHSliderDirection) {
    
    RHSliderDirectionHorizonal = 0,
    RHSliderDirectionVertical  = 1
};
@interface RHProgressSlider : UIControl

// 最小值
@property (nonatomic, assign) CGFloat minValue;
// 最大值
@property (nonatomic, assign) CGFloat maxValue;
// 滑动值
@property (nonatomic, assign) CGFloat value;
// 滑动百分比
@property (nonatomic, assign) CGFloat sliderPercent;
// 缓冲的百分比
@property (nonatomic, assign) CGFloat progressPercent;
// 是否正在滑动  如果在滑动的是偶外面监听的回调不应该设置sliderPercent progressPercent 避免绘制混乱
@property (nonatomic, assign) BOOL isSliding;
// 方向
@property (nonatomic, assign) RHSliderDirection direction;

- (instancetype)initWithFrame:(CGRect)frame direction:(RHSliderDirection)direction;
@end
