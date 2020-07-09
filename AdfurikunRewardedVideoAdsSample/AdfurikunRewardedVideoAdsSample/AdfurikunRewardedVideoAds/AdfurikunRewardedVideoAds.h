//
//  AdfurikunRewardedVideoAds.h
//  AdfurikunRewardedVideoAdsSample
//
//  Created by Dolice on 2020/07/09.
//

#import <UIKit/UIKit.h>
#import <ADFMovieReward/ADFmyMovieReward.h>
#import "DefineManager.h"

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
