//
//  RHVideoModel.m
//  AVPlayerDemo
//
//  Created by 郭人豪 on 2017/3/29.
//  Copyright © 2017年 Abner_G. All rights reserved.
//

#import "RHVideoModel.h"

@interface RHVideoModel ()

@property (nonatomic, copy) NSString * sdUrl;
@property (nonatomic, copy) NSString * hdUrl;
@end
@implementation RHVideoModel

- (instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title videoPath:(NSString *)videoPath currentTime:(NSTimeInterval)currentTime {
    
    self = [super init];
    
    if (self) {
        
        _videoId = [videoId copy];
        _title = [title copy];
        _currentTime = currentTime;
        _url = [[NSURL fileURLWithPath:videoPath] copy];
        _style = RHVideoPlayStyleLocal;
    }
    return self;
}

- (instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title url:(NSString *)url currentTime:(NSTimeInterval)currentTime {
    
    self = [super init];
    
    if (self) {
        
        _videoId = [videoId copy];
        _title = [title copy];
        _currentTime = currentTime;
        _url = [[NSURL URLWithString:url] copy];
        _style = RHVideoPlayStyleNetwork;
    }
    return self;
}

- (instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title sdUrl:(NSString *)sdUrl hdUrl:(NSString *)hdUrl currentTime:(NSTimeInterval)currentTime {
    
    self = [super init];
    
    if (self) {
        
        _videoId = [videoId copy];
        _title = [title copy];
        _currentTime = currentTime;
        _sdUrl = [sdUrl copy];
        _hdUrl = [hdUrl copy];
        self.style = RHVideoPlayStyleNetworkHD;
    }
    return self;
}

- (void)setStyle:(RHVideoPlayStyle)style {
    
    _style = style;
    
    if (_style == RHVideoPlayStyleNetworkSD) {
        
        _url = [[NSURL URLWithString:_sdUrl] copy];
        NSLog(@"%@", _sdUrl);
    } else if (_style == RHVideoPlayStyleNetworkHD) {
        
        _url = [[NSURL URLWithString:_hdUrl] copy];
        NSLog(@"%@", _hdUrl);
    }
}

@end
