//
//  UserCenterViewController.m
//  room107
//
//  Created by Naitong Yu on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "UserCenterViewController.h"
#import "SubsidyInfoView.h"
#import "UserAccountAgent.h"
#import "AuthenticateViewController.h"
#import "RedBagViewController.h"
#import "BalanceViewController.h"
#import "RightMenuViewItem.h"
#import "RightMenuView.h"
#import "WalletView.h"

@interface UserCenterViewController () <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) SubsidyInfoView *subsidyInfoView;
@property (nonatomic, strong) UserAccountInfoModel *accountInfoModel;
@property (nonatomic, strong) WalletView *walletView;
@property (nonatomic, strong) RightMenuView *rightMenuItem; //右上角黑色下拉按钮
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;
@property (nonatomic, assign) BOOL hasData; //标记 是否有数据

@end

@implementation UserCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:lang(@"MyWallet")];
    [self setRightBarButtonTitle:lang(@"More")];
    
    [self createTopView];
    self.scrollView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadDataDrag:NO];
}

- (void)creatRightItem {
    //钱包说明
    RightMenuViewItem *walletExplanationItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"WalletExplanation") clickComplete:^{
        [self viewWalletExplanation];
    }];
    //代付款项
    RightMenuViewItem *toPayBillsItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"ToPayBills") clickComplete:^{
        if (_accountInfoModel &&  _accountInfoModel.unpaidContractId) {
            NSString *url = @"";
            NSDictionary *params = @{@"contractId":_accountInfoModel.unpaidContractId};
            switch ([_accountInfoModel.unpaidUserType intValue]) {
                case 1:
                    url = @"room107://houseTenantManage#expense";
                    break;
                case 2:
                    url = @"room107://houseLandlordManage#expense";
                    break;
                default:
                    [PopupView showMessage:lang(@"NoToPayBills")];
                    return;
                    break;
            }
            [[NXURLHandler sharedInstance] handleOpenURL:url params:params context:self];
        }

    }];
    //历史收支
    RightMenuViewItem *historyBalanceItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"HistoryBalance") clickComplete:^{
        [self viewHistoryPayment];
    }];
    self.rightMenuItem = [[RightMenuView alloc] initWithItems:@[walletExplanationItem, toPayBillsItem, historyBalanceItem] itemHeight:40];
    [self.view addSubview:_rightMenuItem];
}

- (void)createTopView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.scrollView target:self refreshAction:@selector(refreshTriggered:) plist:@"Property" color:[UIColor room107GrayColorD] lineWidth:1.5 dropHeight:95 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
    
    WEAK_SELF weakSelf = self;
    self.walletView = [[WalletView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 196)];
    _walletView.walletViewType = WalletType;
    [_walletView settapCouponHandler:^{
        RedBagViewController *redBagViewController = [[RedBagViewController alloc] init];
        [weakSelf.navigationController pushViewController:redBagViewController animated:YES];
    }];
    [_walletView settapBalanceHandler:^{
        BalanceViewController *balanceViewController = [[BalanceViewController alloc] init];
        [weakSelf.navigationController pushViewController:balanceViewController animated:YES];
    }];
    [self.scrollView addSubview:_walletView];
}

- (void)loadDataDrag:(BOOL)drag {
    if (!_accountInfoModel) {
        [self showLoadingView];
    }
    WEAK_SELF weakSelf = self;
    [[UserAccountAgent sharedInstance] getAccountInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserAccountInfoModel *accountInfoModel) {
        [weakSelf hideLoadingView];
        //网络请求错误。
        if (errorMsg) {
            if (weakSelf.hasData) {
                //不是第一次进入 从自页面返回  无蛙 无提示 无阻隔
            } else {
                //第一次进入 显示🐸  无提示
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [weakSelf showNetworkFailedWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf loadDataDrag:NO];
                    }];
                } else {
                    
                    [weakSelf showUnknownErrorWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf loadDataDrag:NO];
                    }];
                }
            }
            //下拉刷新 无网弹提示
            if (drag) {
                
            }
        }
        //网络请求有数据
        if (accountInfoModel) {
            weakSelf.scrollView.hidden = NO;
            //第一次请求数据成功后 置成YES ；
            weakSelf.hasData = YES;
            _accountInfoModel = accountInfoModel;
            [weakSelf.walletView setAmount:accountInfoModel.amount];
            [weakSelf.walletView setCouponBag:accountInfoModel.coupon];
            [weakSelf.walletView setBalance:accountInfoModel.balance];
            [weakSelf.walletView setcouponNewUpdate:accountInfoModel.couponNewUpdate];
            [weakSelf.walletView setbalanceNewUpdate:accountInfoModel.balanceNewUpdate];
            }
        if (drag) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDragAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.storeHouseRefreshControl finishingLoadingAndComplete:^{
                    weakSelf.scrollView.scrollEnabled = YES ;
                    [weakSelf enabledPopGesture:YES]; //打开返回手势
                }];
            });
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat originY = 0;
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.origin.y = originY;
    frame.size.height -= frame.origin.y;
    
    self.scrollView.frame = frame;
    self.scrollView.contentSize = frame.size;
    self.subsidyInfoView.frame = self.scrollView.bounds;
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    if (!self.rightMenuItem) {
        [self creatRightItem];
    } else {
        if(self.rightMenuItem.hidden){
            [self.rightMenuItem showMenuView];
        }else{
            [self.rightMenuItem dismissMenuView];
        }
    }
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
    [self enabledPopGesture:NO];//禁用返回手势
//    [self performSelector:@selector(loadDataDrag:) withObject:@1 afterDelay:0 inModes:@[NSRunLoopCommonModes]];
    [self loadDataDrag:YES];
}

//模拟下拉刷新（备用）
- (void)dragInfo {
    //有数据 说明列表已经显示 进入控制器 模拟下拉刷新。
    if (self.hasData) {
        [self.scrollView setContentOffset:CGPointMake(0, -95) animated:YES];
        //setContentOffset设置scrollView偏移量 停止后并不会调用拖拽停止代理方法 需手动调用执行107间动画
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.storeHouseRefreshControl scrollViewDidEndDragging];
        });
        //只不过是将scrollView坐标系内的一块指定区域移到scrollView的窗口中，如果这部分已经存在于窗口中，则什么也不做。
        //[self.scrollView scrollRectToVisible:CGRectMake(0, -110, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
    } else {
        //第一次进入控制器 请求数据
        [self loadDataDrag:NO];
    }
}
@end
