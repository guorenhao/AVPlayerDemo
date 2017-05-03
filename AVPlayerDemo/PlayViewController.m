//
//  PlayViewController.m
//  AVPlayerDemo
//
//  Created by 郭人豪 on 2017/4/27.
//  Copyright © 2017年 Abner_G. All rights reserved.
//

#import "PlayViewController.h"
#import "RHPlayerView.h"

@interface PlayViewController () <RHPlayerViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RHPlayerView * player;
@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * dataArr;
@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    [self addSubviews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        
        NSLog(@"pop pop pop pop pop");
        [_player stop];
    }
}

- (void)loadData {
    
    NSArray * titleArr = @[@"视频一", @"视频二", @"视频三"];
    NSArray * urlArr = @[@"http://test.miaocaiwang.com/app/rm.mp4", @"http://test.miaocaiwang.com/app/rm.mp4", @"http://test.miaocaiwang.com/app/rm.mp4"];
    
    for (int i = 0; i < titleArr.count; i++) {
        
        RHVideoModel * model = [[RHVideoModel alloc] initWithVideoId:[NSString stringWithFormat:@"%03d", i + 1] title:titleArr[i] url:urlArr[i] currentTime:0];
        [self.dataArr addObject:model];
    }
    [self.player setVideoModels:self.dataArr playVideoId:@""];
    [self.tableView reloadData];
}

- (void)addSubviews {
    
    [self.view addSubview:self.player];
    [self.view addSubview:self.tableView];
    
    [self makeConstraintsForUI];
}

- (void)makeConstraintsForUI {
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(@(9 * Screen_Width / 16));
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.bottom.mas_equalTo(@0);
    }];
}

#pragma mark - player view delegate

// 是否允许播放
- (BOOL)playerViewShouldPlay {
    
    return YES;
}
// 当前播放的
- (void)playerView:(RHPlayerView *)playView didPlayVideo:(RHVideoModel *)videoModel index:(NSInteger)index {
    
    
}
// 当前播放结束的
- (void)playerView:(RHPlayerView *)playView didPlayEndVideo:(RHVideoModel *)videoModel index:(NSInteger)index {
    
    
}
// 当前正在播放的  会调用多次  更新当前播放时间
- (void)playerView:(RHPlayerView *)playView didPlayVideo:(RHVideoModel *)videoModel playTime:(NSTimeInterval)playTime {
    
    
}
#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_ID"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < _dataArr.count) {
        
        RHVideoModel * model = _dataArr[indexPath.row];
        cell.textLabel.text = model.title;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RHVideoModel * model = _dataArr[indexPath.row];
    [_player playVideoWithVideoId:model.videoId];
}

#pragma mark - setter and getter

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        UITableView * tableView = [[UITableView alloc] init];
        tableView.dataSource = self;
        tableView.delegate = self;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell_ID"];
        tableView.tableFooterView = [[UIView alloc] init];
        _tableView = tableView;
    }
    return _tableView;
}

- (RHPlayerView *)player {
    
    if (!_player) {
        
        _player = [[RHPlayerView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 9 * Screen_Width / 16) currentVC:self];
        _player.delegate = self;
    }
    return _player;
}

- (NSMutableArray *)dataArr {
    
    if (!_dataArr) {
        
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
