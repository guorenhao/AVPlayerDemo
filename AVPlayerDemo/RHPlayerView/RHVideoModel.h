//
//  RHVideoModel.h
//  AVPlayerDemo
//
//  Created by 郭人豪 on 2017/3/29.
//  Copyright © 2017年 Abner_G. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RHVideoPlayStyle) {
    
    RHVideoPlayStyleLocal = 0,       //播放本地视频
    RHVideoPlayStyleNetwork,         //播放网络视频
    RHVideoPlayStyleNetworkSD,       //播放网络标清视频
    RHVideoPlayStyleNetworkHD,       //播放网络高清视频
};
@interface RHVideoModel : NSObject

@property (nonatomic, copy, readonly) NSString * videoId;
@property (nonatomic, copy, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSURL * url;
@property (nonatomic, assign) RHVideoPlayStyle style;
@property (nonatomic, assign) NSTimeInterval currentTime;

/**
 创建本地视频模型

 @param videoId     视频ID
 @param title       标题
 @param videoPath   播放文件路径
 @param currentTime 当前播放时间
 @return            本地视频模型
 */
- (instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title videoPath:(NSString *)videoPath currentTime:(NSTimeInterval)currentTime;

/**
 创建网络视频模型
 
 @param videoId     视频ID
 @param title       标题
 @param url         视频地址
 @param currentTime 当前播放时间
 @return            网络视频模型
 */
- (instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title url:(NSString *)url currentTime:(NSTimeInterval)currentTime;

/**
 创建网络视频模型
 
 @param videoId     视频ID
 @param title       标题
 @param sdUrl       标清地址
 @param hdUrl       高清地址
 @param currentTime 当前播放时间
 @return            网络视频模型
 */
- (instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title sdUrl:(NSString *)sdUrl hdUrl:(NSString *)hdUrl currentTime:(NSTimeInterval)currentTime;
@end
