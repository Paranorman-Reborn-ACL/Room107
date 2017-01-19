//
//  TenantContractManageViewController.m
//  room107
//
//  Created by ningxia on 15/8/5.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "TenantContractManageViewController.h"
#import "DZNSegmentedControl.h"
#import "UIScrollView+DZNSegmentedControl.h"
#import "SuiteAgent.h"
#import "TenantRentInfoViewController.h"
#import "TenantToPayBillsViewController.h"
#import "TenantPendingChargesViewController.h"
#import "PaymentAgent.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "CMBNetPayViewController.h"
#import "RightMenuView.h"
#import "RightMenuViewItem.h"
#import "PaymentFuncs.h"

@interface TenantContractManageViewController ()

@property (nonatomic, strong) NSNumber *contractID;
@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DZNSegmentedControl *segmentedControl;
@property (nonatomic, strong) RentedHouseItemModel *rentedHouseItem;
@property (nonatomic, strong) TenantRentInfoViewController *rentInfoViewController;
@property (nonatomic, strong) TenantToPayBillsViewController *toPayBillsViewController;
@property (nonatomic, strong) TenantPendingChargesViewController *pendingChargesViewController;
@property (nonatomic, strong) RightMenuView *rightMenuItem; //右上角黑色下拉按钮
@property (nonatomic) BOOL isCMBNetPay; //是否跳转至招行快捷支付页

@end

@implementation TenantContractManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"RentalManage")];
    [self setRightBarButtonTitle:lang(@"More")];
    _isCMBNetPay = NO;
    
    if([WXApi isWXAppInstalled]) {
        // 判断 用户是否安装微信
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWechatPayResult:) name:WechatPayNotification object:nil];//监听一个通知
    }
    
    [self getRentedHouseItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_isCMBNetPay) {
        //检查招行快捷支付的状态
        [self getPaymentStatusWithPaymentType:[NSNumber numberWithUnsignedInteger:CMBNetPaymentType]];
        
        _isCMBNetPay = NO;
    }
}

- (id)initWithContractID:(NSNumber *)contractID andSelectedIndex:(NSInteger)index {
    self = [super init];
    if (self != nil) {
        _contractID = contractID;
        _selectedSegmentIndex = index;
    }
    
    return self;
}

/*
 URLParams:{
 contractId = 10;
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
    _contractID = URLParams[@"contractId"];
    NSArray *array = @[@"info", @"expense", @"income"];
    if (URLParams[@"fragment"] && ![URLParams[@"fragment"] isEqualToString:@""]) {
        _selectedSegmentIndex = [array indexOfObject:URLParams[@"fragment"]];
    } else {
        _selectedSegmentIndex = 0;
    }
}

- (void)creatRightItem {
    //租客须知
    RightMenuViewItem *viewtenantExplanationItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"TenantExplanation") clickComplete:^{
        [self viewTenantExplanation];
    }];
    //查看合同
    RightMenuViewItem *viewContractItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title: lang(@"ViewContract") clickComplete:^{
        [self viewContractBycontractID:_contractID];
    }];
    //邮寄可同
    RightMenuViewItem *sendContractItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"SendContract") clickComplete:^{
        [self sendContractBycontractID:_contractID];
    }];
    //历史账单
    RightMenuViewItem *historyPaymentItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"HistoryPayment") clickComplete:^{
        [self viewContractHistoryPaymentBycontractID:_contractID];
    }];
    //维修申请
    RightMenuViewItem *repairExplanationItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"RepairExplanation") clickComplete:^{
        [self viewRepairExplanation];
    }];
    //违约申诉
    RightMenuViewItem *appealsBreachItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"AppealsBreach") clickComplete:^{
        [self viewAppealsBreach];
    }];
    //月付协议
    RightMenuViewItem *monthlyPaymentExplanationItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"MonthlyPaymentExplanation") clickComplete:^{
        [self viewMonthlyPaymentExplanation];
    }];
    //支付帮助
    RightMenuViewItem *paymentExplanationItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"PaymentExplanation") clickComplete:^{
        [self viewPaymentExplanation];
    }];
    self.rightMenuItem = [[RightMenuView alloc] initWithItems:@[viewtenantExplanationItem, viewContractItem, sendContractItem, historyPaymentItem, repairExplanationItem, appealsBreachItem, monthlyPaymentExplanationItem, paymentExplanationItem] itemHeight:40];
    [self.view addSubview:_rightMenuItem];
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    if (!self.rightMenuItem) {
        [self creatRightItem];
    } else {
        if (self.rightMenuItem.hidden) {
            [_rightMenuItem showMenuView];
        } else {
            [_rightMenuItem dismissMenuView];
        }
    }
}

- (void)getRentedHouseItem {
    [self showLoadingView];
    [[SuiteAgent sharedInstance] getTenantHouseManageWithContractID:_contractID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, RentedHouseItemModel *item) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            _rentedHouseItem = item;
            [self createTopView];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
            
            if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                    [self getRentedHouseItem];
                }];
            } else {
                [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                    [self getRentedHouseItem];
                }];
            }
        }
    }];
}

- (void)createTopView {
    if (!_segmentedControl) {
        CGFloat originY = 0;
        CGRect frame = self.view.frame;
        frame.origin.y = originY;
        frame.size.height = 40.0f;
        
        self.segmentedControl = [[DZNSegmentedControl alloc] initWithFrame:frame];
        self.segmentedControl.items = @[lang(@"RentInfo"), lang(@"ToPayBills"), lang(@"PendingCharges")];
        self.segmentedControl.showsCount = NO;
        self.segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
        [self.segmentedControl setTintColor:[UIColor room107GreenColor]];
        [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateNormal];
        [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateDisabled];
        [self.view addSubview:_segmentedControl];
        
        originY += CGRectGetHeight(_segmentedControl.bounds);
        
        frame = self.view.frame;
        frame.origin.y = originY;
        frame.size.height -= frame.origin.y;
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES; //支持左右滑动时segmentedControl跟着一起走
        self.scrollView.segmentedControl = self.segmentedControl;
        [self.view addSubview:_scrollView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    __block CGFloat originX = 0.0;
    WEAK_SELF weakSelf = self;
    
    [self.segmentedControl.items enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = originX;
        frame.origin.y = 0.5;
        
        switch (idx) {
            case 0:
                if (!_rentInfoViewController) {
                    _rentInfoViewController = [[TenantRentInfoViewController alloc] initWithRentedHouseItem:_rentedHouseItem];
                    [_rentInfoViewController setNavigationController:self.navigationController];
                    _rentInfoViewController.view.frame = frame;
                    [self.scrollView addSubview:_rentInfoViewController.view];
                    
                    WEAK_SELF weakSelf = self;
                    [_rentInfoViewController setRoundedGreenButtonDidClickHandler:^{
                        //租客续租（跳转到租客签约流程中）
                        [[NXURLHandler sharedInstance] handleOpenURL:contractTenantStatusURI params:@{@"contractId":weakSelf.contractID, @"isRelet":@1} context:weakSelf];
                    }];
                }
                break;
            case 1:
                if (!_toPayBillsViewController) {
                    _toPayBillsViewController = [[TenantToPayBillsViewController alloc] init];
                    [_toPayBillsViewController setNavigationController:self.navigationController];
                    [_toPayBillsViewController setRentedHouseItem:_rentedHouseItem];
                    _toPayBillsViewController.view.frame = frame;
                    [self.scrollView addSubview:_toPayBillsViewController.view];
                    
                    //代付款项的第一步支付按钮的回调
                    [_toPayBillsViewController setSubmitPaymentButtonDidClickHandler:^(NSNumber *amount, NSString *ordersString) {
                        if (!ordersString) {
                            return;
                        }
                        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
                        [info setObject:amount forKey:@"amount"];
                        [info setObject:weakSelf.rentedHouseItem.couponCost forKey:@"couponCost"];
                        [info setObject:weakSelf.rentedHouseItem.balanceCost forKey:@"balanceCost"];
                        [info setObject:weakSelf.rentedHouseItem.paymentCost forKey:@"paymentCost"];
                        [info setObject:ordersString forKey:@"orders"];
                        
                        [weakSelf showLoadingView];
                        [[PaymentAgent sharedInstance] submitAccountPaymentWithInfo:info completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo) {
                            [weakSelf hideLoadingView];
                            if (errorTitle || errorMsg) {
                                [PopupView showTitle:errorTitle message:errorMsg];
                            }
                
                            if (!errorCode) {
                                weakSelf.rentedHouseItem.paymentId = paymentInfo.paymentId;
                                [weakSelf refreshRentedHouseItemWithPaymentInfo:paymentInfo];
                            } else {
                                if ([weakSelf isLoginStateError:errorCode]) {
                                    return;
                                }
                            }
                        }];
                    }];
                    
                    //代付款项的第二步支付按钮的回调
                    [_toPayBillsViewController setPayPaymentButtonDidClickHandler:^(NSNumber *paymentType) {
                        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
                        [info setObject:weakSelf.rentedHouseItem.paymentId forKey:@"paymentId"];
                        if ([weakSelf.rentedHouseItem.paymentCost intValue] > 0) {
                            [info setObject:paymentType forKey:@"paymentType"];
                        }
                        [info setObject:[CommonFuncs deviceIPAdress] forKey:@"ip"];
                        
                        [weakSelf showLoadingView];
                        [[PaymentAgent sharedInstance] payAccountPaymentWithInfo:info completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo, NSDictionary *params, NSNumber *paymentType) {
                            [weakSelf hideLoadingView];
                            if (errorTitle || errorMsg) {
                                [PopupView showTitle:errorTitle message:errorMsg];
                            }
                
                            if (!errorCode) {
                                if ([paymentInfo.paymentCost isEqual:@0]) {
                                    [weakSelf.toPayBillsViewController showSuccessView];
                                } else {
                                    switch ([paymentType unsignedIntegerValue]) {
                                        case WechatPaymentType:
                                        {
                                            //微信支付
                                            if([WXApi isWXAppInstalled]) {
                                                PayReq *wxreq = [[PayReq alloc] init];
                                                wxreq.partnerId = params[@"partnerid"];
                                                wxreq.prepayId = params[@"prepayid"];
                                                wxreq.nonceStr = params[@"noncestr"];
                                                wxreq.timeStamp = [params[@"timestamp"] intValue];
                                                wxreq.package = params[@"package"];
                                                wxreq.sign = params[@"sign"];
                                                [WXApi sendReq:wxreq];
                                            } else {
                                                [weakSelf showAlertViewWithTitle:lang(@"WXAppIsNotInstalled") message:@""];
                                            }
                                        }
                                            break;
                                        case AlipayPaymentType:
                                        {
                                            //支付宝支付，应用注册scheme，在AlixPayDemo-Info.plist定义URL types
                                            NSString *appScheme = @"alisdkdemo";
                                            NSURL *appSchemeURL = [NSURL URLWithString:@"alisdkdemo://location?id=1"];
                                            BOOL hasAlipay = [[UIApplication sharedApplication] canOpenURL:appSchemeURL];
                                            if (hasAlipay) {
                                                [[AlipaySDK defaultService] payOrder:params[@"orderInfo"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                                                    LogDebug(@"reslut = %@", resultDic);
                                                    [weakSelf getPaymentStatusWithPaymentType:paymentType];
                                                }];
                                            } else {
                                                [weakSelf showAlertViewWithTitle:lang(@"AlipayIsNotInstalled") message:@""];
                                            }
                                        }
                                            break;
                                        case CMBNetPaymentType:
                                        {
                                            //招行快捷支付
                                            CMBNetPayViewController *CMBNetPayVC = [[CMBNetPayViewController alloc] initWithParams:params];
                                            _isCMBNetPay = YES;
                                            [weakSelf.navigationController pushViewController:CMBNetPayVC animated:YES];
                                        }
                                            break;
                                        default:
                                            [weakSelf.toPayBillsViewController showSuccessView];
                                            break;
                                    }
                                }
                            } else {
                                if ([weakSelf isLoginStateError:errorCode]) {
                                    return;
                                }
                            }
                        }];
                    }];
                    
                    [_toPayBillsViewController setCancelPaymentButtonDidClickHandler:^{
                        [weakSelf showLoadingView];
                        [[PaymentAgent sharedInstance] cancelAccountPaymentWithPaymentID:weakSelf.rentedHouseItem.paymentId completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo) {
                            [weakSelf hideLoadingView];
                            if (errorTitle || errorMsg) {
                                [PopupView showTitle:errorTitle message:errorMsg];
                            }
                
                            if (!errorCode) {
                                weakSelf.rentedHouseItem.paymentId = nil;
                                [weakSelf refreshRentedHouseItemWithPaymentInfo:paymentInfo];
                            } else {
                                if ([weakSelf isLoginStateError:errorCode]) {
                                    return;
                                }
                            }
                        }];
                    }];
                    
                    [_toPayBillsViewController setViewLatestBillButtonDidClickHandler:^() {
                        [weakSelf getLatestBill];
                    }];
                }
                break;
            default:
                if (!_pendingChargesViewController) {
                    _pendingChargesViewController = [[TenantPendingChargesViewController alloc] initWithRentedHouseItem:_rentedHouseItem];
                    [_pendingChargesViewController setNavigationController:self.navigationController];
                    _pendingChargesViewController.view.frame = frame;
                    [self.scrollView addSubview:_pendingChargesViewController.view];
                }
                break;
        }
        
        originX += CGRectGetWidth(frame);
    }];
    
    self.scrollView.contentSize = CGSizeMake(originX, self.scrollView.frame.size.height);
    [self.segmentedControl setSelectedSegmentIndex:_selectedSegmentIndex];
    CGRect frame = _scrollView.frame;
    frame.origin.x = _segmentedControl.selectedSegmentIndex * frame.size.width;
    [self.scrollView scrollRectToVisible:frame animated:NO];
}

- (void)refreshRentedHouseItemWithPaymentInfo:(PaymentInfoModel *)paymentInfo {
    _rentedHouseItem.coupon = paymentInfo.coupon;
    _rentedHouseItem.balance = paymentInfo.balance;
    _rentedHouseItem.couponCost = paymentInfo.couponCost;
    _rentedHouseItem.balanceCost = paymentInfo.balanceCost;
    _rentedHouseItem.paymentCost = paymentInfo.paymentCost;
    _rentedHouseItem.expenseOrders = paymentInfo.expenseOrders;
    _rentedHouseItem.incomeOrders = paymentInfo.incomeOrders;
    _rentedHouseItem.deadline = paymentInfo.deadline;
    
    [_toPayBillsViewController setRentedHouseItem:_rentedHouseItem];
}

- (void)getWechatPayResult:(NSNotification *)notification {
    if ([notification.object isEqualToString:@"success"]) {
        LogDebug(@"支付成功");
    } else {
        LogDebug(@"支付失败");
    }
    
    [self getPaymentStatusWithPaymentType:[NSNumber numberWithUnsignedInteger:WechatPaymentType]];
}

- (void)getPaymentStatusWithPaymentType:(NSNumber *)paymentType {
    [self showLoadingView];
    [[PaymentAgent sharedInstance] statusAccountPaymentWithPaymentID:_rentedHouseItem.paymentId andPaymentType:paymentType completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo, NSNumber *paymentType) {
        [self hideLoadingView];
        if (!errorCode) {
            if ([paymentInfo.status isEqual:@2]) {
                [_toPayBillsViewController showSuccessView];
            }
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (void)getLatestBill {
    [self showLoadingView];
    [[SuiteAgent sharedInstance] getTenantHouseManageWithContractID:_contractID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, RentedHouseItemModel *item) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            _rentedHouseItem = item;
            [_toPayBillsViewController setRentedHouseItem:_rentedHouseItem];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (_scrollView.segmentedControl) {
        //判断contentOffsetKey是否被注册
        [_scrollView removeObserver:_scrollView forKeyPath:contentOffsetKey];
    }
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
