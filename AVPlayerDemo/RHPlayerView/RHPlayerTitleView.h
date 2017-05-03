//
//  RHPlayerTitleView.h
//  MCSchool
//
//  Created by 郭人豪 on 2017/4/14.
//  Copyright © 2017年 Abner_G. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RHPlayerTitleViewDelegate;
@interface RHPlayerTitleView : UIView

@property (nonatomic, weak) id<RHPlayerTitleViewDelegate> delegate;
@property (nonatomic, copy) NSString * title;

- (void)showBackButton;
- (void)hideBackButton;
@end
@protocol RHPlayerTitleViewDelegate <NSObject>

@optional
- (void)titleViewDidExitFullScreen:(RHPlayerTitleView *)titleView;
@end
