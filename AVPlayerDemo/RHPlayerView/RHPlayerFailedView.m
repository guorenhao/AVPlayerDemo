//
//  RHPlayerFailedView.m
//  AVPlayerDemo
//
//  Created by 郭人豪 on 2017/3/31.
//  Copyright © 2017年 Abner_G. All rights reserved.
//

#import "RHPlayerFailedView.h"

@interface RHPlayerFailedView ()

@property (nonatomic, strong) UIButton * reloadButton;

@end
@implementation RHPlayerFailedView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    
    [self addSubview:self.reloadButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(@40);
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
}

- (void)clickReloadButton:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(failedViewDidReplay:)]) {
        
        [self.delegate failedViewDidReplay:self];
    }
}

- (UIButton *)reloadButton {
    
    if (!_reloadButton) {
        
        UIButton * button = [[UIButton alloc] init];
        [button setTitle:@"视频加载失败，点击重新加载" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickReloadButton:) forControlEvents:UIControlEventTouchUpInside];
        _reloadButton = button;
    }
    return _reloadButton;
}






@end
