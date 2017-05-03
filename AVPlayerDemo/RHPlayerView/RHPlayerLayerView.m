//
//  RHPlayerLayerView.m
//  AVPlayerDemo
//
//  Created by 郭人豪 on 2017/3/29.
//  Copyright © 2017年 Abner_G. All rights reserved.
//

#import "RHPlayerLayerView.h"

@interface RHPlayerLayerView ()

@property (nonatomic, strong) AVPlayerLayer * playerLayer;
@end
@implementation RHPlayerLayerView

- (void)addPlayerLayer:(AVPlayerLayer *)playerLayer {
    
    _playerLayer = playerLayer;
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _playerLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:_playerLayer];
}



- (void)layoutSublayersOfLayer:(CALayer *)layer {
    
    [super layoutSublayersOfLayer:layer];
    
    _playerLayer.frame = self.bounds;
}

@end
