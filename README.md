# アドフリくんの動画リワード広告導入手順

iPhoneアプリに[アドフリくん](https://adfurikun.jp/ "アドフリくん")の動画リワード広告を表示するサンプルです。

[公式マニュアル](https://github.com/glossom-dev/AdfurikunSDK-iOS/wiki "公式マニュアル")を参考にさせていただきました。ご使用の際は広告枠IDを指定してください。

## 導入準備

### 1. 広告枠IDの保持

```objective-c
NSString *const ADFURIKUN_REWARD_UNIT_ID = @"広告枠ID";
```

### 2. アプリ起動時に初期化

#### AppDelegate.h

```objective-c
#import <ADFMovieReward/ADFmyMovieReward.h>
```

#### AppDelegate.m

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // アドフリくん動画リワード広告初期化
    [ADFmyMovieReward initializeWithAppID:ADFURIKUN_REWARD_UNIT_ID];
    
    return YES;
}
```

### e.x. Info.plistの編集

[AdMob](https://admob.google.com/intl/ja/home/ "AdMob")を使用する場合は *Info.plist*に *GADApplicationIdentifier*の設定値を追加してください。

### 動画リワード広告の読み込み

```objective-c
[[AdfurikunRewardedVideoAds sharedManager] loadRewardedVideoAds:self];
```

## ソースコード

### AdfurikunRewardedVideoAds.h

```objective-c
#import <UIKit/UIKit.h>
#import <ADFMovieReward/ADFmyMovieReward.h>

@interface AdfurikunRewardedVideoAds : NSObject <ADFmyMovieRewardDelegate> {
    BOOL isCompletePlaying;
}

#pragma mark - property
@property (nonatomic)         ADFmyMovieReward *adfurikunRewardedAd;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIView                  *overlay;
@property (nonatomic, assign) BOOL                    showOverlay;

#pragma mark - enumerator
typedef NS_ENUM(NSUInteger, activityIndicatorStyles) {
    AI_GRAY        = 1,
    AI_WHITE       = 2,
    AI_WHITE_LARGE = 3
};

#pragma mark - public method
+ (id)sharedManager;
- (void)loadRewardedVideoAds:(UIViewController *)viewController;

@end
```

### AdfurikunRewardedVideoAds.m

```objective-c
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
```

## リワードの提供

当方は動画リワード広告が最後まで再生されたら3日間広告を表示しないという設定にしています。

また、リワードが提供されたことをユーザーにお知らせするため、リワード期限日を文字列で取得できるようにしています。

まず下記のようにリワードを提供します。

```objective-c
// 動画リワード広告再生完了時の処理
+ (void)onCompleteRewardedVideoAds
{
    // 視聴済みフラグを立てる
    [Common sharedManager].isRewarded = YES;
    
    // ユーザーデフォルト更新
    [[Common sharedManager].userDefaults setBool:[Common sharedManager].isRewarded forKey:UD_REWARDED_KEY];
    [[Common sharedManager].userDefaults synchronize];
    
    // リワード受取日と期限日の保存
    NSDate *const rewardDateReceived   = [NSDate date];
    NSDate *const rewardExpirationDate = [Common rewardExpirationDate];
    
    [[Common sharedManager].userDefaults setObject:rewardDateReceived forKey:UD_REWARD_DATE_RECEIVED_KEY];
    [[Common sharedManager].userDefaults setObject:rewardExpirationDate forKey:UD_REWARD_EXPIRATION_KEY];
    [[Common sharedManager].userDefaults synchronize];
    
    // TODO: バナー削除
    
}

// リワード期限日の取得
+ (NSDate *)rewardExpirationDate
{
    NSDate *const rewardDateReceived = [NSDate date];
    
    return [rewardDateReceived initWithTimeInterval:[Common sharedManager].rewardPeriod * 24 * 60 * 60 sinceDate:rewardDateReceived];
}

// リワード期限日を文字列で取得
+ (NSString *)rewardExpirationDateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    NSDate   *const expirationDate    = [Common rewardExpirationDate];
    NSString *const expirationDateStr = [dateFormatter stringFromDate:expirationDate];
    
    return [NSString stringWithFormat:@"（有効期限: %@）", expirationDateStr];
}
```

## リワード期間中であるか判定

アプリ起動時にリワード期間中であるか判定し、フラグを更新します。

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // リワード期間であれば期限切れであるか判定
    if ([Common sharedManager].isRewarded) {
        // リワード受取日とリワード期限日の取得
        NSDate *const rewardDateReceived   = [[Common sharedManager].userDefaults objectForKey:UD_REWARD_DATE_RECEIVED_KEY];
        NSDate *const rewardExpirationDate = [[Common sharedManager].userDefaults objectForKey:UD_REWARD_EXPIRATION_KEY];
        
        // 現在時刻がリワード期間であるか判定
        NSDate *const now = [NSDate date];
        [Common sharedManager].isRewarded = [now compare:rewardDateReceived] == NSOrderedDescending && [now compare:rewardExpirationDate] == NSOrderedAscending;
        
        // ユーザーデフォルト更新
        [[Common sharedManager].userDefaults setBool:[Common sharedManager].isRewarded forKey:UD_REWARDED_KEY];
        [[Common sharedManager].userDefaults synchronize];
    }
    
    return YES;
}
```

以上で動画リワード広告の実装は完了になります。