//
//  RHPlayerFailedView.h
//  AVPlayerDemo
//
//  Created by 郭人豪 on 2017/3/31.
//  Copyright © 2017年 Abner_G. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RHPlayerFailedViewDelegate;
@interface RHPlayerFailedView : UIView

@property (nonatomic, weak) id<RHPlayerFailedViewDelegate> delegate;
@end
@protocol RHPlayerFailedViewDelegate <NSObject>

@optional
- (void)failedViewDidReplay:(RHPlayerFailedView *)failedView;
@end
