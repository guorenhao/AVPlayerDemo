//
//  RHProgressSlider.m
//  AVPlayerDemo
//
//  Created by 郭人豪 on 2017/3/29.
//  Copyright © 2017年 Abner_G. All rights reserved.
//

#import "RHProgressSlider.h"

@interface RHProgressSlider ()

//整条线的颜色
@property (nonatomic, strong) UIColor *lineColor;
//滑动过的线的颜色
@property (nonatomic, strong) UIColor *slidedLineColor;
//预加载线的颜色
@property (nonatomic, strong) UIColor *progressLineColor;
//圆的颜色
@property (nonatomic, strong) UIColor *circleColor;

//线的宽度
@property (nonatomic, assign) CGFloat lineWidth;
//圆的半径
@property (nonatomic, assign) CGFloat circleRadius;
@end
@implementation RHProgressSlider

- (instancetype)initWithFrame:(CGRect)frame direction:(RHSliderDirection)direction {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _minValue = 0;
        _maxValue = 1;
        
        _direction = direction;
        _lineColor = [UIColor whiteColor];
        _slidedLineColor = Color_RGB(255, 130, 86);
        _circleColor = [UIColor whiteColor];
        _progressLineColor = [UIColor grayColor];
        
        _sliderPercent = 0.0;
        _lineWidth = 2;
        _circleRadius = 6;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //画总体的线
    //画笔颜色
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    //线的宽度
    CGContextSetLineWidth(context, _lineWidth);
    
    //起点
    CGFloat startLineX = (_direction == RHSliderDirectionHorizonal ? _circleRadius : (self.frame.size.width - _lineWidth) / 2);
    CGFloat startLineY = (_direction == RHSliderDirectionHorizonal ? (self.frame.size.height - _lineWidth) / 2 : _circleRadius);
    //终点
    CGFloat endLineX = (_direction == RHSliderDirectionHorizonal ? self.frame.size.width - _circleRadius : (self.frame.size.width - _lineWidth) / 2);
    CGFloat endLineY = (_direction == RHSliderDirectionHorizonal ? (self.frame.size.height - _lineWidth) / 2 : self.frame.size.height- _circleRadius);
    
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, endLineX, endLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    
    //绘制缓冲进度的线
    //画笔颜色
    CGContextSetStrokeColorWithColor(context, _progressLineColor.CGColor);
    //线的宽度
    CGContextSetLineWidth(context, _lineWidth);
    
    CGFloat progressLineX = (_direction == RHSliderDirectionHorizonal ? MAX(_circleRadius, (_progressPercent * self.frame.size.width - _circleRadius)) : startLineX);
    
    CGFloat progressLineY = (_direction == RHSliderDirectionHorizonal ? startLineY : MAX(_circleRadius, (_progressPercent * self.frame.size.height - _circleRadius)));
    
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, progressLineX, progressLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    
    //画已滑动进度的线
    //画笔颜色
    CGContextSetStrokeColorWithColor(context, _slidedLineColor.CGColor);
    //线的宽度
    CGContextSetLineWidth(context, _lineWidth);
    
    CGFloat slidedLineX = (_direction == RHSliderDirectionHorizonal ? MAX(_circleRadius, (_sliderPercent * (self.frame.size.width - 2*_circleRadius) + _circleRadius)) : startLineX);
    
    CGFloat slidedLineY = (_direction == RHSliderDirectionHorizonal ? startLineY : MAX(_circleRadius, (_sliderPercent * self.frame.size.height - _circleRadius)));
    
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, slidedLineX, slidedLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    //画圆
    CGFloat penWidth = 1.f;
    CGFloat circleX = (_direction == RHSliderDirectionHorizonal ? MAX(_circleRadius + penWidth, slidedLineX - penWidth ) : startLineX);
    CGFloat circleY = (_direction == RHSliderDirectionHorizonal ? startLineY : MAX(_circleRadius + penWidth, slidedLineY - penWidth));
    
    CGContextSetStrokeColorWithColor(context, nil);
    CGContextSetLineWidth(context, 0);
    CGContextSetFillColorWithColor(context, _circleColor.CGColor);
    CGContextAddArc(context, circleX, circleY, _circleRadius, 0, 2 * M_PI, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark - touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}

- (void)updateTouchPoint:(NSSet*)touches {
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    self.sliderPercent = (_direction == RHSliderDirectionHorizonal ? touchPoint.x : touchPoint.y) / (_direction == RHSliderDirectionHorizonal ? self.frame.size.width : self.frame.size.height);
}

- (void)callbackTouchEnd:(BOOL)isTouchEnd {
    
    _isSliding = !isTouchEnd;
    if (isTouchEnd == YES) {
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - setter

- (void)setSliderPercent:(CGFloat)sliderPercent {
    
    if (_sliderPercent != sliderPercent) {
        
        _sliderPercent = sliderPercent;
        self.value = _minValue + sliderPercent * (_maxValue - _minValue);
    }
}

- (void)setProgressPercent:(CGFloat)progressPercent {
    
    if (_progressPercent != progressPercent) {
        
        _progressPercent = progressPercent;
        [self setNeedsDisplay];
    }
}

- (void)setValue:(CGFloat)value {
    
    if (value != _value) {
        
        if (value < _minValue) {
            
            _value = _minValue;
            return;
        } else if (value > _maxValue) {
            
            _value = _maxValue;
            return;
        }
        _value = value;
        _sliderPercent = (_value - _minValue)/(_maxValue - _minValue);
        [self setNeedsDisplay];
    }
}



@end
