//
//  AdfurikunRewardedVideoAds.m
//  AdfurikunRewardedVideoAdsSample
//
//  Created by Dolice on 2020/07/09.
//

#import "AdfurikunRewardedVideoAds.h"

@implementation AdfurikunRewardedVideoAds

#pragma mark - Shared Manager

static id sharedInstance = nil;

+ (id)sharedManager
{
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

#pragma mark - Adfurikun Rewarded Video Ads

// 動画リワード広告広告読み込み
- (void)loadRewardedVideoAds:(UIViewController *)viewController
{
    if (![viewController isEqual:self.rootViewController]) {
        self.rootViewController = viewController;
    }
    
    // Adfurikun動画リワード広告読み込み
    self.adfurikunRewardedAd = [ADFmyMovieReward getInstance:ADFURIKUN_REWARD_UNIT_ID delegate:self];
    [self.adfurikunRewardedAd load];
    
    // アクティビティインジケータのアニメーション開始
    CGFloat const screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat const screenHeight = [[UIScreen mainScreen] bounds].size.height;
    [self startActivityIndicator:self.rootViewController.view center:CGPointMake(screenWidth / 2, screenHeight / 2)
                         styleId:AI_WHITE hidesWhenStopped:YES showOverlay:YES];
    
    // 再生完了フラグを下ろす
    isCompletePlaying = NO;
}

// 広告取得成功時に呼ばれる
- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp
{
    //NSLog(@"AdfurikunRewardedVideoAds: AdsFetchCompleted");
    
    if ([self.adfurikunRewardedAd isPrepared]) {
        [self.adfurikunRewardedAd playWithPresentingViewController:self.rootViewController];
    }
}

// 広告取得失敗時に呼ばれる
- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error
{
    //NSLog(@"AdfurikunRewardedVideoAds: AdsFetchFailed");
    
    // 再生完了フラグを下ろす
    isCompletePlaying = NO;
    
    // アクティビティインジケーターのアニメーション停止
    [self stopActivityIndicator];
}

// 広告表示開始時に呼ばれる
- (void)AdsDidShow:(NSString *)appID adNetworkKey:(NSString *)adNetworkKey
{
    //NSLog(@"AdfurikunRewardedVideoAds: AdsDidShow");
    
    // 再生完了フラグを下ろす
    isCompletePlaying = NO;
}

// 広告表示失敗時に呼ばれる
- (void)AdsPlayFailed:(NSString *)appID
{
    //NSLog(@"AdfurikunRewardedVideoAds: AdsPlayFailed");
    
    // 再生完了フラグを下ろす
    isCompletePlaying = NO;
    
    // アクティビティインジケーターのアニメーション停止
    [self stopActivityIndicator];
}

// 広告を最後まで視聴した時に呼ばれる
- (void)AdsDidCompleteShow:(NSString *)appID
{
    //NSLog(@"AdfurikunRewardedVideoAds: AdsDidCompleteShow");
    
    // TODO: リワード提供
    
    
    // 再生完了フラグを立てる
    isCompletePlaying = YES;
}

// 広告を閉じた時に呼ばれる
- (void)AdsDidHide:(NSString *)appID
{
    //NSLog(@"AdfurikunRewardedVideoAds: AdsDidHide");
    
    // TODO: 再生が完了していればお知らせアラート表示
    if (isCompletePlaying) {
        
    }
}

#pragma mark - Activity Indicator

// アクティビティインジケーターのアニメーション開始
- (void)startActivityIndicator:(id)view center:(CGPoint)center styleId:(NSInteger)styleId hidesWhenStopped:(BOOL)hidesWhenStopped showOverlay:(BOOL)showOverlay
{
    // インジケーター初期化
    _activityIndicator = [[UIActivityIndicatorView alloc] init];
    
    // スタイルを設定
    switch (styleId) {
        case AI_GRAY:
            _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            
            break;
        case AI_WHITE:
            _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            
            break;
        case AI_WHITE_LARGE:
            _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            
            break;
    }
    
    // スタイルに応じて寸法変更
    if (_activityIndicator.activityIndicatorViewStyle == UIActivityIndicatorViewStyleWhiteLarge) {
        _activityIndicator.frame = CGRectMake(0, 0, 50.0, 50.0);
    } else {
        _activityIndicator.frame = CGRectMake(0, 0, 20.0, 20.0);
    }
    
    // 座標をセンターに指定
    _activityIndicator.center = center;
    
    // 停止した時に隠れるよう設定
    _activityIndicator.hidesWhenStopped = hidesWhenStopped;
    
    // インジケーターアニメーション開始
    [_activityIndicator startAnimating];
    
    // オーバーレイ表示フラグ保持
    _showOverlay = showOverlay;
    
    // オーバーレイ表示
    if (_showOverlay) {
        _overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _overlay.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5f];
        [view addSubview:_overlay];
    }
    
    // 画面に追加
    [view addSubview:_activityIndicator];
}

// アクティビティインジケーターのアニメーション停止
- (void)stopActivityIndicator
{
    if (_showOverlay) {
        [_overlay removeFromSuperview];
    }
    [_activityIndicator stopAnimating];
}

@end
