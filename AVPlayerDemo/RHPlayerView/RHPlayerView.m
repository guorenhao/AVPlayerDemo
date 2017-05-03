//
//  RHPlayerView.m
//  PlayerDemo
//
//  Created by 郭人豪 on 2016/10/31.
//  Copyright © 2016年 Abner_G. All rights reserved.
//

#import "RHPlayerView.h"
#import "RHFullViewController.h"
#import "RHPlayerTitleView.h"
#import "RHPlayerToolView.h"
#import "RHPlayerFailedView.h"
#import "RHPlayerLayerView.h"

@interface RHPlayerView () <RHPlayerToolViewDelegate, RHPlayerTitleViewDelegate, RHPlayerFailedViewDelegate>

@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerItem * playerItem;
@property (nonatomic, strong) AVPlayerLayer * playerLayer;

@property (nonatomic, strong) RHFullViewController * fullVC;
@property (nonatomic, weak) UIViewController * currentVC;

@property (nonatomic, strong) RHPlayerTitleView * titleView;
@property (nonatomic, strong) RHPlayerToolView * toolView;
@property (nonatomic, strong) RHPlayerFailedView * failedView;
@property (nonatomic, strong) RHPlayerLayerView * layerView;
@property (nonatomic, strong) UIActivityIndicatorView * activity;
@property (nonatomic, strong) UIImageView * coverImageView;

@property (nonatomic, strong) CADisplayLink * link;
@property (nonatomic, assign) NSTimeInterval lastTime;

@property (nonatomic, strong) NSTimer * toolViewShowTimer;
@property (nonatomic, assign) NSTimeInterval toolViewShowTime;

// 当前是否显示控制条
@property (nonatomic, assign) BOOL isShowToolView;
// 是否第一次播放
@property (nonatomic, assign) BOOL isFirstPlay;
// 是否重播
@property (nonatomic, assign) BOOL isReplay;

@property (nonatomic, strong) NSArray * videoArr;
@property (nonatomic, strong) RHVideoModel * videoModel;

@property (nonatomic) CGRect playerFrame;
@end
@implementation RHPlayerView

#pragma mark - public

// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame currentVC:(UIViewController *)controller {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        self.currentVC = controller;
        _isShowToolView = YES;
        _isFirstPlay = YES;
        _isReplay = NO;
        _playerFrame = frame;
        [self addSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}
// 设置覆盖的图片
- (void)setCoverImage:(NSString *)imageUrl {
    
    _coverImageView.hidden = NO;
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@""]];
}

// 设置要播放的视频列表和要播放的视频
- (void)setVideoModels:(NSArray<RHVideoModel *> *)videoModels playVideoId:(NSString *)videoId {
    
    self.videoArr = [NSArray arrayWithArray:videoModels];
    
    if (videoId.length > 0) {
        
        for (RHVideoModel * model in self.videoArr) {
            
            if ([model.videoId isEqualToString:videoId]) {
                
                NSInteger index = [self.videoArr indexOfObject:model];
                self.videoModel = self.videoArr[index];
                break;
            }
        }
    } else {
        
        self.videoModel = self.videoArr.firstObject;
    }
    _titleView.title = self.videoModel.title;
    _isFirstPlay = YES;
}
// 点击目录要播放的视频id
- (void)playVideoWithVideoId:(NSString *)videoId {
    
    if (![self.delegate respondsToSelector:@selector(playerViewShouldPlay)]) {
        
        return;
    }
    [self.delegate playerViewShouldPlay];
    
    for (RHVideoModel * model in self.videoArr) {
        
        if ([model.videoId isEqualToString:videoId]) {
            
            NSInteger index = [self.videoArr indexOfObject:model];
            self.videoModel = self.videoArr[index];
            break;
        }
    }
    _titleView.title = self.videoModel.title;

    if (_isFirstPlay) {
        
        _coverImageView.hidden = YES;
        [self setPlayer];
        [self addToolViewTimer];
        
        _isFirstPlay = NO;
    } else {
        
        [self.player pause];
        [self replaceCurrentPlayerItemWithVideoModel:self.videoModel];
        [self addToolViewTimer];
    }
}
// 暂停
- (void)pause {
    
    [self.player pause];
    self.link.paused = YES;
    _toolView.playSwitch.selected = NO;
    [self removeToolViewTimer];
}
// 停止
- (void)stop {
    
    [self.player pause];
    [self.link invalidate];
    _toolView.playSwitch.selected = NO;
    [self removeToolViewTimer];
}

#pragma mark - add subviews and make constraints

- (void)addSubviews {
    
    // 播放的layerView
    [self addSubview:self.layerView];
    // 菊花
    [self addSubview:self.activity];
    // 加载失败
    [self addSubview:self.failedView];
    // 覆盖的图片
    [self addSubview:self.coverImageView];
    // 下部工具栏
    [self addSubview:self.toolView];
    // 上部标题栏
    [self addSubview:self.titleView];
    // 添加约束
    [self makeConstraintsForUI];
}

- (void)makeConstraintsForUI {
    
    [_layerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(@0);
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.bottom.mas_equalTo(@0);
    }];
    
    [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(@0);
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.height.mas_equalTo(@44);
    }];
    
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(@0);
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.height.mas_equalTo(@44);
    }];
    
    [_activity mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [_failedView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(@0);
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.bottom.mas_equalTo(@0);
    }];
    
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(@0);
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.bottom.mas_equalTo(@0);
    }];
}

- (void)layoutSubviews {
    
    [self.superview bringSubviewToFront:self];
}

#pragma mark - notification

// 视频播放完成通知
- (void)videoPlayEnd {
    
    NSLog(@"播放完成");
    
    _toolView.playSwitch.selected = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [_toolView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.mas_equalTo(@0);
        }];
        [_titleView mas_updateConstraints:^(MASConstraintMaker *make) {
           
            make.top.mas_equalTo(@0);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        _isShowToolView = YES;
    }];
    
    self.videoModel.currentTime = 0;
    NSInteger index = [self.videoArr indexOfObject:self.videoModel];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didPlayEndVideo:index:)]) {
        
        [self.delegate playerView:self didPlayEndVideo:self.videoModel index:index];
    }
    
    if (index != self.videoArr.count - 1) {
        
        [self.player pause];
        self.videoModel = self.videoArr[index + 1];
        _titleView.title = self.videoModel.title;
        [self replaceCurrentPlayerItemWithVideoModel:self.videoModel];
        [self addToolViewTimer];
    } else {
        
        _isReplay = YES;
        [self.player pause];
        self.link.paused = YES;
        [self removeToolViewTimer];
        _coverImageView.hidden = NO;
        _toolView.slider.sliderPercent = 0;
        _toolView.slider.enabled = NO;
        [_activity stopAnimating];
    }
}

#pragma mark - 监听视频缓冲和加载状态
//注册观察者监听状态和缓冲
- (void)addObserverWithPlayerItem:(AVPlayerItem *)playerItem {
    
    if (playerItem) {
        
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
}

//移除观察者
- (void)removeObserverWithPlayerItem:(AVPlayerItem *)playerItem {
    
    if (playerItem) {
        
        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [playerItem removeObserver:self forKeyPath:@"status"];
    }
}

// 监听变化方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    AVPlayerItem * playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSTimeInterval loadedTime = [self availableDurationWithplayerItem:playerItem];
        NSTimeInterval totalTime = CMTimeGetSeconds(playerItem.duration);
        
        if (!_toolView.slider.isSliding) {
            
            _toolView.slider.progressPercent = loadedTime/totalTime;
        }
        
    } else if ([keyPath isEqualToString:@"status"]) {
        
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            
            NSLog(@"playerItem is ready");
            
            [self.player play];
            self.link.paused = NO;
            CMTime seekTime = CMTimeMake(self.videoModel.currentTime, 1);
            [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
                
                if (finished) {
                    
                    NSTimeInterval current = CMTimeGetSeconds(self.player.currentTime);
                    _toolView.currentTimeLabel.text = [self convertTimeToString:current];
                }
            }];
            _toolView.slider.enabled = YES;
            _toolView.playSwitch.enabled = YES;
            _toolView.playSwitch.selected = YES;
        } else{
            
            NSLog(@"load break");
            self.failedView.hidden = NO;
        }
    }
}

#pragma mark - private

// 设置播放器
- (void)setPlayer {
    
    if (self.videoModel) {
        
        if (self.videoModel.url) {
            
            if (![self checkNetwork]) {
                
                return;
            }
            AVPlayerItem * item = [AVPlayerItem playerItemWithURL:self.videoModel.url];
            self.playerItem = item;
            [self addObserverWithPlayerItem:self.playerItem];
            
            if (self.player) {
                
                [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
            } else {
                
                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
            }
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            [_layerView addPlayerLayer:self.playerLayer];
            
            NSInteger index = [self.videoArr indexOfObject:self.videoModel];
            if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didPlayVideo:index:)]) {
                
                [self.delegate playerView:self didPlayVideo:self.videoModel index:index];
            }
            self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateSlider)];
            [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        } else {
            
            _failedView.hidden = NO;
        }
        
    } else {
        
        _failedView.hidden = NO;
    }
}

//切换当前播放的内容
- (void)replaceCurrentPlayerItemWithVideoModel:(RHVideoModel *)model {
    
    if (self.player) {
        
        if (model) {
            
            if (![self checkNetwork]) {
                
                return;
            }
            //由暂停状态切换时候 开启定时器，将暂停按钮状态设置为播放状态
            self.link.paused = NO;
            _toolView.playSwitch.selected = YES;
            
            //移除当前AVPlayerItem对"loadedTimeRanges"和"status"的监听
            [self removeObserverWithPlayerItem:self.playerItem];
            
            if (model.url) {
                
                AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:model.url];
                self.playerItem = playerItem;
                [self addObserverWithPlayerItem:self.playerItem];
                //更换播放的AVPlayerItem
                [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
                NSInteger index = [self.videoArr indexOfObject:self.videoModel];
                if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didPlayVideo:index:)]) {
                    
                    [self.delegate playerView:self didPlayVideo:self.videoModel index:index];
                }
                _toolView.playSwitch.enabled = NO;
                _toolView.slider.enabled = NO;
            } else {
                
                _toolView.playSwitch.selected = NO;
                _failedView.hidden = NO;
            }
            
        } else {
            
            _toolView.playSwitch.selected = NO;
            _failedView.hidden = NO;
        }
    } else {
        
        _toolView.playSwitch.selected = NO;
        _failedView.hidden = NO;
    }
}

//转换时间成字符串
- (NSString *)convertTimeToString:(NSTimeInterval)time {
    
    if (time <= 0) {
        
        return @"00:00";
    }
    int minute = time / 60;
    int second = (int)time % 60;
    NSString * timeStr;
    
    if (minute >= 100) {
        
        timeStr = [NSString stringWithFormat:@"%d:%02d", minute, second];
    }else {
        
        timeStr = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    }
    return timeStr;
}

// 获取缓冲进度
- (NSTimeInterval)availableDurationWithplayerItem:(AVPlayerItem *)playerItem {
    
    NSArray * loadedTimeRanges = [playerItem loadedTimeRanges];
    // 获取缓冲区域
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
    NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
    // 计算缓冲总进度
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

- (void)addToolViewTimer {

    [self removeToolViewTimer];
    _toolViewShowTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateToolViewShowTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_toolViewShowTimer forMode:NSRunLoopCommonModes];
}

- (void)removeToolViewTimer {

    [_toolViewShowTimer invalidate];
    _toolViewShowTimer = nil;
    _toolViewShowTime = 0;
}

- (BOOL)checkNetwork {
    
    // 这里做网络监测
    return YES;
}

#pragma mark - slider event

- (void)progressValueChange:(RHProgressSlider *)slider {
    
    [self addToolViewTimer];
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        
        NSTimeInterval duration = slider.sliderPercent * CMTimeGetSeconds(self.player.currentItem.duration);
        CMTime seekTime = CMTimeMake(duration, 1);
        
        [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
            
            if (finished) {
                
                NSTimeInterval current = CMTimeGetSeconds(self.player.currentTime);
                 _toolView.currentTimeLabel.text = [self convertTimeToString:current];
            }
        }];
    }
}

#pragma mark - timer event
// 更新进度条
- (void)updateSlider {
    
    NSTimeInterval current = CMTimeGetSeconds(self.player.currentTime);
    NSTimeInterval total = CMTimeGetSeconds(self.player.currentItem.duration);
    //如果用户在手动滑动滑块，则不对滑块的进度进行设置重绘
    if (!_toolView.slider.isSliding) {
        
        _toolView.slider.sliderPercent = current/total;
    }
    
    if (current != self.lastTime) {
        
        [_activity stopAnimating];
        _toolView.currentTimeLabel.text = [self convertTimeToString:current];
        _toolView.totleTimeLabel.text = isnan(total) ? @"00:00" : [self convertTimeToString:total];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didPlayVideo:playTime:)]) {
            
            [self.delegate playerView:self didPlayVideo:self.videoModel playTime:current];
        }
    }else{
        
        [_activity startAnimating];
    }
    // 记录当前播放时间 用于区分是否卡顿显示缓冲动画
    self.lastTime = current;
}

- (void)updateToolViewShowTime {
    
    _toolViewShowTime++;

    if (_toolViewShowTime == 5) {

        [self removeToolViewTimer];
        _toolViewShowTime = 0;
        [self showOrHideBar];
    }
}

#pragma mark - failedView delegate
// 重新播放
- (void)failedViewDidReplay:(RHPlayerFailedView *)failedView {
    
    _failedView.hidden = YES;
    
    [self replaceCurrentPlayerItemWithVideoModel:self.videoModel];
}

#pragma mark - titleView delegate

- (void)titleViewDidExitFullScreen:(RHPlayerTitleView *)titleView {
    
    [_toolView exitFullScreen];
}

#pragma mark - toolView delegate

- (void)toolView:(RHPlayerToolView *)toolView playSwitch:(BOOL)isPlay {
    
    if (_isFirstPlay) {
        
        if (![self.delegate playerViewShouldPlay]) {
            
            _toolView.playSwitch.selected = !_toolView.playSwitch.selected;
            return;
        }
        
        _coverImageView.hidden = YES;
        if (!self.videoModel.videoId) {
            
            _coverImageView.hidden = NO;
            _toolView.playSwitch.selected = !_toolView.playSwitch.selected;
            return;
        }
        [self setPlayer];
        [self addToolViewTimer];
        
        _isFirstPlay = NO;
    } else if (_isReplay) {
        
        _coverImageView.hidden = YES;
        self.videoModel = self.videoArr.firstObject;
        _titleView.title = self.videoModel.title;
        [self addToolViewTimer];
        [self replaceCurrentPlayerItemWithVideoModel:self.videoModel];
        
        _isReplay = NO;
    } else {
        
        if (!isPlay) {
            
            [self.player pause];
            self.link.paused = YES;
            [_activity stopAnimating];
            [self removeToolViewTimer];
        } else {
            
            [self.player play];
            self.link.paused = NO;
            [self addToolViewTimer];
        }
    }
}

- (void)toolView:(RHPlayerToolView *)toolView fullScreen:(BOOL)isFull {
    
    [self addToolViewTimer];
    //弹出全屏播放器
    if (isFull) {
        
        [_currentVC presentViewController:self.fullVC animated:NO completion:^{
            
            [_titleView showBackButton];
            [self.fullVC.view addSubview:self];
            self.center = self.fullVC.view.center;
            
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                
                self.frame = self.fullVC.view.bounds;
                _layerView.frame = self.bounds;
            } completion:nil];
        }];
    } else {
        
        [_titleView hideBackButton];
        [self.fullVC dismissViewControllerAnimated:NO completion:^{
            [_currentVC.view addSubview:self];
            
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                
                self.frame = _playerFrame;
                _layerView.frame = self.bounds;
            } completion:nil];
        }];
    }
}

#pragma mark - touch event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self removeToolViewTimer];
    [self showOrHideBar];
}

- (void)showOrHideBar {
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [_toolView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.mas_equalTo(@(_isShowToolView ? 44 : 0));
        }];
        [_titleView mas_updateConstraints:^(MASConstraintMaker *make) {
           
            make.top.mas_equalTo(@(_isShowToolView ? -44 : 0));
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        _isShowToolView = !_isShowToolView;
        if (_isShowToolView) {
            
            [self addToolViewTimer];
        }
    }];
    
}

- (void)dealloc {
    
    NSLog(@"player view dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserverWithPlayerItem:self.playerItem];
}

#pragma mark - setter and getter

- (UIImageView *)coverImageView {
    
    if (!_coverImageView) {
        
        UIImageView * coverImageView = [[UIImageView alloc] init];
        coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        coverImageView.clipsToBounds = YES;
        _coverImageView = coverImageView;
    }
    return _coverImageView;
}

- (RHFullViewController *)fullVC {
    
    if (!_fullVC) {
        
        RHFullViewController * fullVC = [[RHFullViewController alloc] init];
        _fullVC = fullVC;
    }
    return _fullVC;
}

- (RHPlayerLayerView *)layerView {
    
    if (!_layerView) {
        
        RHPlayerLayerView * layerView = [[RHPlayerLayerView alloc] init];
        _layerView = layerView;
    }
    return _layerView;
}

- (UIActivityIndicatorView *)activity {
    
    if (!_activity) {
        
        UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activity.color = [UIColor redColor];
        // 指定进度轮中心点
        [activity setCenter:self.center];
        // 设置进度轮显示类型
        [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activity = activity;
    }
    return _activity;
}

- (RHPlayerFailedView *)failedView {
    
    if (!_failedView) {
        
        RHPlayerFailedView * failedView = [[RHPlayerFailedView alloc] init];
        failedView.delegate = self;
        _failedView = failedView;
        _failedView.hidden = YES;
    }
    return _failedView;
}

- (RHPlayerToolView *)toolView {
    
    if (!_toolView) {
        
        RHPlayerToolView * toolView = [[RHPlayerToolView alloc] init];
        toolView.delegate = self;
        [toolView.slider addTarget:self action:@selector(progressValueChange:) forControlEvents:UIControlEventValueChanged];
        _toolView = toolView;
    }
    return _toolView;
}

- (RHPlayerTitleView *)titleView {
    
    if (!_titleView) {
        
        RHPlayerTitleView * titleView = [[RHPlayerTitleView alloc] init];
        titleView.delegate = self;
        _titleView = titleView;
    }
    return _titleView;
}

@end
