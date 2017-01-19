//
//  Room107ViewController.h
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertView+Blocks.h"
#import "SystemMutualBottomView.h"
#import "CBStoreHouseRefreshControl.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

typedef enum {
    HeaderTypeNone = 2000, //无任何样式
    HeaderTypeGreenBack, //按钮为返回（绿色）
    HeaderTypeWhiteBack, //按钮为返回（白色）
    HeaderTypeWhiteMenu, //按钮为菜单（白色）
} HeaderType;

@interface Room107ViewController : UIViewController

- (void)setHeaderType:(HeaderType)type;
- (HeaderType)headerType;
- (CGFloat)originX;
- (CGFloat)spacingY;
- (CGFloat)heightOfNavigationBar;
- (CGFloat)heightOfSegmentedControl;
- (CGFloat)heightOfTradingProcessView;
- (void)refreshData; //由外部指定当前页刷新数据
- (void)setRightBarButtonTitle:(NSString *)title;
- (void)pushLoginAndRegisterViewController;
- (void)pushAuthenticateViewController;
- (BOOL)pushViewController:(UIViewController *)viewControllerToPush;
- (BOOL)isLoginStateError:(NSNumber *)errorCode; //登录态是否异常
- (UILabel *)showContent:(NSString *)content withFrame:(CGRect)frame;
//显示网络异常
- (void)showNetworkFailedWithFrame:(CGRect)frame andRefreshHandler:(void(^)())handler;
//显示未知错误
- (void)showUnknownErrorWithFrame:(CGRect)frame andRefreshHandler:(void(^)())handler;
- (void)hideNetworkFailedImageView;
- (void)showLoadingView;
- (void)hideLoadingView;
- (CGFloat)menuWidth;
- (CGFloat)menuOriginX;
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
//弹出服务器相关的错误，用户点击后返回上一级
- (void)showServerErrorWithMessage:(NSString *)message;
//开启或禁用返回手势
- (void)enabledPopGesture:(BOOL)enabled;
- (void)viewTenantExplanation; //租客说明
- (void)viewLandlordExplanation; //出租说明
- (void)viewPricingRules; //定价规则
- (void)viewContractBycontractID:(NSNumber *)contractID; //查看合同
- (void)sendContractBycontractID:(NSNumber *)contractID; //邮寄合同
- (void)viewHistoryPayment; //历史收支
- (void)viewContractHistoryPaymentBycontractID:(NSNumber *)contractID; //历史账单
- (void)viewRepairExplanation; //维修申请
- (void)viewAppealsBreach; //违约申诉
- (void)viewSignExplanation; //签约说明
- (void)viewProtocalExplanation; //用户协议
- (void)viewMonthlyPaymentExplanation; //月付协议
- (void)viewWalletExplanation; //钱包说明
- (void)viewPaymentExplanation; //支付说明
- (void)viewAnxinyuExplanation;//安心寓
- (void)viewSupportCenter;//帮助中心
- (IBAction)leftButtonDidClick:(id)sender; //右侧返回箭头按钮
@end
