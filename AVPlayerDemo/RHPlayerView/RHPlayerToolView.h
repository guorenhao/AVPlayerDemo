//
//  RHPlayerToolView.h
//  PlayerDemo
//
//  Created by 郭人豪 on 2016/10/31.
//  Copyright © 2016年 Abner_G. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RHProgressSlider.h"

@protocol RHPlayerToolViewDelegate;
@interface RHPlayerToolView : UIView

@property (nonatomic, weak) id<RHPlayerToolViewDelegate> delegate;

@property (nonatomic, strong) UIButton * playSwitch;
@property (nonatomic, strong) UIButton * fullScreen;
@property (nonatomic, strong) UILabel * currentTimeLabel;
@property (nonatomic, strong) UILabel * totleTimeLabel;
@property (nonatomic, strong) RHProgressSlider * slider;

- (void)exitFullScreen;
@end
@protocol RHPlayerToolViewDelegate <NSObject>

@optional
- (void)toolView:(RHPlayerToolView *)toolView playSwitch:(BOOL)isPlay;
- (void)toolView:(RHPlayerToolView *)toolView fullScreen:(BOOL)isFull;
@end
