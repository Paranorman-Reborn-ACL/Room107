//
//  RedBagViewController.m
//  room107
//
//  Created by Naitong Yu on 15/8/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RedBagViewController.h"
#import "InventoryItemView.h"
#import "UserAccountAgent.h"
#import "WalletView.h"

@interface RedBagViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *redBagHistoryTextLabel;
@property (nonatomic, strong) NSMutableArray *redBagBalanceItems;
@property (nonatomic, strong) WalletView *couponView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *wideLineView;

//@property (nonatomic) double currentAvailable;
//@property (nonatomic) double totalRedBag;
//@property (nonatomic) double usedRedBag;
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;
@property (nonatomic, assign) BOOL hasData;

@end

@implementation RedBagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self.scrollView setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadDataDrag:NO];
}

- (void)loadDataDrag:(BOOL)drag {
    if (!_hasData) {
        [self showLoadingView];
    }
    [[UserAccountAgent sharedInstance] getCouponInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *couponInfo) {
        [self hideLoadingView];
        WEAK_SELF weakSelf = self;
        //网络请求错误
        if (errorMsg) {
            if (self.hasData) {
                //不是第一次进入 无蛙 显示提示
            } else {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf loadDataDrag:NO];
                    }];
                } else {
                    
                    [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf loadDataDrag:NO];
                    }];
                }
            }
            if (drag) {
                
            }
        }
        //网络请求有数据
        if (couponInfo) {
            self.scrollView.hidden = NO;
            //第一次请求数据成功后 置成YES ；
            self.hasData = YES;

            [_couponView setAmount:couponInfo[@"coupon"]];             //可用于支付租房
            [_couponView setCouponBag:couponInfo[@"totalCoupon"]];     //历史总额
            [_couponView setBalance:couponInfo[@"usedCoupon"]];        //已用金额
            
            for (UIView *redBagView in self.redBagBalanceItems) {
                [redBagView removeFromSuperview];
            }
            [self.redBagBalanceItems removeAllObjects];
            
            NSArray *histories = couponInfo[@"histories"]; //历史账单
            if (histories && [histories count] > 0) {
                self.redBagHistoryTextLabel.hidden = NO;
                for (NSDictionary *inventory in histories) {
                    NSString *title = inventory[@"title"];
                    NSString *date = inventory[@"date"];
                    double amount = [inventory[@"amount"] doubleValue] / 100.0f;
                    InventoryItemView *inventoryItem = [[InventoryItemView alloc] initWithTitle:title date:date amount:amount];
                    [self.redBagBalanceItems addObject:inventoryItem];
                    [self.scrollView addSubview:inventoryItem];
                }
            }
            [self.view setNeedsLayout];
        }
        if (drag) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDragAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.storeHouseRefreshControl finishingLoadingAndComplete:^{
                    weakSelf.scrollView.scrollEnabled = YES ;
                    [self enabledPopGesture:YES];
                }];
            });
        }
    }];
}

- (void)setup {
    [self setTitle:lang(@"RedBag")];
    [self setRightBarButtonTitle:lang(@"WalletExplanation")];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
     self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.scrollView target:self refreshAction:@selector(refreshTriggered:) plist:@"Property" color:[UIColor room107GrayColorD] lineWidth:1.5 dropHeight:85 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
    
    self.couponView = [[WalletView alloc] initWithFrame:CGRectMake(0, 0, width, 196)];
    [_couponView setWalletViewType:CouponType];
    [_scrollView addSubview:_couponView];
    
    CGFloat originY = CGRectGetMaxY(_couponView.frame);
    self.wideLineView = [[UIView alloc] init];
    [_wideLineView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
    [_wideLineView setFrame:CGRectMake(0, originY, width, 11)];
    [_scrollView addSubview:_wideLineView];
    
    originY += 11;
    self.redBagHistoryTextLabel = [[UILabel alloc] init];
    [_redBagHistoryTextLabel setBackgroundColor:[UIColor whiteColor]];
    [_redBagHistoryTextLabel setTextColor:[UIColor room107GrayColorC]];
    [_redBagHistoryTextLabel setFont:[UIFont room107SystemFontTwo]];
    [_redBagHistoryTextLabel setFrame:CGRectMake(0, originY, width, 36)];
    [_redBagHistoryTextLabel setHidden:YES];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lang(@"RedBagBalanceDetails")];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    [paragraphStyle setFirstLineHeadIndent:22];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    _redBagHistoryTextLabel.attributedText = attributedString;
    [_scrollView addSubview:_redBagHistoryTextLabel];
    
    _redBagBalanceItems = [[NSMutableArray alloc] init];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat originY = CGRectGetMaxY(_redBagHistoryTextLabel.frame);
    CGFloat width = self.view.frame.size.width;
    for (InventoryItemView *inventoryItemView in self.redBagBalanceItems) {
        inventoryItemView.frame = CGRectMake(0, originY, width, [inventoryItemView getHeight]);
        originY += [inventoryItemView getOriginY];
    }
    
    _scrollView.contentSize = CGSizeMake(width, originY + 11 + 11 + 38);
}

- (NSString *)currencyStyleStringOfValue:(double)value {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSString *currencyString = [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
    currencyString = [currencyString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return currencyString;
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    [self viewWalletExplanation];
}

#pragma mark - Notifying refresh control of scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        [self.storeHouseRefreshControl scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.scrollView) {
        [self.storeHouseRefreshControl scrollViewDidEndDragging];
    }
}

#pragma mark - Listening for the user to trigger a refresh

//下拉动画开始执行 调接口口 请求数据 关闭tableView滑动效果
- (void)refreshTriggered:(id)sender {
    _scrollView.scrollEnabled = NO ;
    [self enabledPopGesture:NO];
//    [self performSelector:@selector(loadData) withObject:nil afterDelay:0 inModes:@[NSRunLoopCommonModes]];
    [self loadDataDrag:YES];
}

@end
