//
//  BalanceViewController.m
//  room107
//
//  Created by Naitong Yu on 15/9/11.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "BalanceViewController.h"
#import "InventoryItemView.h"
#import "UserAccountAgent.h"
#import "WithdrawViewController.h"
#import "WalletView.h"

@interface BalanceViewController ()<UIScrollViewDelegate>

@property (nonatomic) UIButton *withdrawButton;  //提现按钮

@property (nonatomic) UILabel *balanceHistoryTextLabel;//账户明细
@property (nonatomic) NSMutableArray *balanceHistoryItems;
@property (nonatomic, strong) WalletView *balanceView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *wideLineView;

@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;
@property (nonatomic, assign) BOOL hasData; //标记 是否有数据
@end

@implementation BalanceViewController

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
    /**
     *  A.第一次进入页面 B.网络异常点击重新加载 C.服务器异常点击重新加载 D.下拉刷新 E.返回该页面
        A.B.C 显示loading  D.E 不显示loading
     */
    if (!_hasData) {
        [self showLoadingView];
    }
    [[UserAccountAgent sharedInstance] getBalanceInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *balanceInfo) {
        [self hideLoadingView];
        WEAK_SELF weakSelf = self;
        if (errorMsg) {
            if (self.hasData) {
                
            } else {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    //网络异常
                    [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf loadDataDrag:NO];
                    }];
                } else {
                    //服务器异常
                    
                    [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf loadDataDrag:NO];
                    }];
                }
            }
            if (drag) {
                
            }
        }
        
        if (balanceInfo) {
            self.scrollView.hidden = NO;
            //第一次请求数据成功后 置成YES ；
            self.hasData = YES;
            
            [self.balanceView setAmount:balanceInfo[@"balance"]];  //当前可用于租房
            [self.balanceView setTotalBalance:balanceInfo[@"totalBalance"]]; //历史总额
            [self.balanceView setexpenses:balanceInfo[@"expenses"]]; //已用金额
            [self.balanceView setwithdrawal:balanceInfo[@"withdrawal"]];  //提现金额

            
            for (UIView *balanceItemView in self.balanceHistoryItems) {
                [balanceItemView removeFromSuperview];
            }
            [self.balanceHistoryItems removeAllObjects];
            
            NSArray *histories = balanceInfo[@"histories"];
            if (histories && [histories count] > 0) {
                self.balanceHistoryTextLabel.hidden = NO;
                for (NSDictionary *inventory in histories) {
                    NSString *title = inventory[@"title"];
                    NSString *date = inventory[@"date"];
                    double amount = [inventory[@"amount"] doubleValue] / 100.0f;
                    InventoryItemView *inventoryItem = [[InventoryItemView alloc] initWithTitle:title date:date amount:amount];
                    [self.balanceHistoryItems addObject:inventoryItem];
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
    [self setTitle:lang(@"Balance")];
    [self setRightBarButtonTitle:lang(@"WalletExplanation")];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.scrollView target:self refreshAction:@selector(refreshTriggered:) plist:@"Property" color:[UIColor room107GrayColorD] lineWidth:1.5 dropHeight:95 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
    
    self.balanceView = [[WalletView alloc] initWithFrame:CGRectMake(0, 0, width, 196)];
    [_balanceView setWalletViewType:BalanceType];
    [_scrollView addSubview:_balanceView];
    
    CGFloat originY = CGRectGetMaxY(_balanceView.frame);
    self.wideLineView = [[UIView alloc] init];
    [_wideLineView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
    [_wideLineView setFrame:CGRectMake(0, originY, width, 11)];
    [_scrollView addSubview:_wideLineView];

    originY += 11;
    self.balanceHistoryTextLabel = [[UILabel alloc] init];
    [_balanceHistoryTextLabel setBackgroundColor:[UIColor whiteColor]];
    [_balanceHistoryTextLabel setTextColor:[UIColor room107GrayColorC]];
    [_balanceHistoryTextLabel setFont:[UIFont room107SystemFontTwo]];
    [_balanceHistoryTextLabel setFrame:CGRectMake(0, originY, width, 36)];
    [_balanceHistoryTextLabel setHidden:YES];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lang(@"RedBagBalanceDetails")];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    [paragraphStyle setFirstLineHeadIndent:22];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    _balanceHistoryTextLabel.attributedText = attributedString;
    [_scrollView addSubview:_balanceHistoryTextLabel];

    _withdrawButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_withdrawButton setFrame:CGRectMake(width - 70 - 22, 95.5, 70, 30)];
    _withdrawButton.backgroundColor = [UIColor room107YellowColor];
    [_withdrawButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_withdrawButton setTitle:lang(@"Withdraw") forState:UIControlStateNormal];
    _withdrawButton.titleLabel.font = [UIFont room107SystemFontTwo];
    _withdrawButton.layer.cornerRadius = 4.0f;
    _withdrawButton.layer.masksToBounds = YES;
    [_withdrawButton addTarget:self action:@selector(withdrawButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_withdrawButton];
    
    _balanceHistoryItems = [[NSMutableArray alloc] init];
}

- (void)viewDidLayoutSubviews {
    CGFloat width = self.view.bounds.size.width;
    CGFloat originY = CGRectGetMaxY(_balanceHistoryTextLabel.frame);
    
    for (InventoryItemView *inventoryItemView in self.balanceHistoryItems) {
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

- (void)withdrawButtonClicked:(UIButton *)sender {
    WithdrawViewController *wvc = [[WithdrawViewController alloc] init];
    [self.navigationController pushViewController:wvc animated:YES];
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
    //    [self performSelector:@selector(loadDataDrag:) withObject:@1 afterDelay:0 inModes:@[NSRunLoopCommonModes]];
    [self loadDataDrag:YES];
}


@end
