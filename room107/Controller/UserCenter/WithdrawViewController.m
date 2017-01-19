//
//  WithdrawViewController.m
//  room107
//
//  Created by Naitong Yu on 15/9/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "WithdrawViewController.h"
#import "DZNSegmentedControl.h"
#import "UIScrollView+DZNSegmentedControl.h"
#import "WithdrawDebitCardView.h"
#import "WithdrawAlipayView.h"
#import "UserAccountAgent.h"
#import "AddAlipayViewController.h"
#import "AddDebitCardViewController.h"
#import "WithdrawInfo.h"
#import "RightMenuView.h"
#import "RightMenuViewItem.h"

@interface WithdrawViewController ()<WithdrawAlipayViewDelegate, WithdrawDebitCardewDelegate>
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) DZNSegmentedControl *segmentedControl;

@property (nonatomic) WithdrawAlipayView *withdrawAlipayView;
@property (nonatomic) WithdrawDebitCardView *withdrawDebitCardView;

@property (nonatomic, strong) RightMenuView *rightMenuItem; //右上角黑色下拉按钮
@property (nonatomic, strong) WithdrawInfo *withdrawInfo;

@end

@implementation WithdrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:lang(@"Withdraw")];
    [self createTopView];
    [self setRightBarButtonTitle:lang(@"CustomerBinding")];
    
    self.withdrawInfo = [[WithdrawInfo alloc]init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
}

- (void)creatRightItem {
//    self.menuItem = [[MenuView alloc] init];
//    [_menuItem addButtonTitleArray:@[lang(@"Alipay"),lang(@"DebitCard")] buttonColor:[UIColor room107GreenColor] textFont:[UIFont systemFontOfSize:15.0]];
//    _menuItem.delegate = self;
//    [self.view addSubview:_menuItem];
//    [self.view bringSubviewToFront:_menuItem];
    //支付宝
    RightMenuViewItem *alipayItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"Alipay") clickComplete:^{
        [self addAliPay];
    }];
    //银行卡
    RightMenuViewItem *debitCardItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"DebitCard") clickComplete:^{
        [self addDebitCard];
    }];
    self.rightMenuItem = [[RightMenuView alloc] initWithItems:@[alipayItem, debitCardItem] itemHeight:40];
    [self.view addSubview:_rightMenuItem];
}
/**
 *  添加或者更换支付宝帐号
 */
- (void)addAliPay {
    if (_withdrawInfo.alipayNumber) {
        //有支付宝帐号，弹窗提示
        RIButtonItem *cancelBtn = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
            
        }];
        RIButtonItem *confirmBtn = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
            AddAlipayViewController *addAliVC = [[AddAlipayViewController alloc] initWithName:_withdrawInfo.name idCard:_withdrawInfo.idCard];
            [self.navigationController pushViewController:addAliVC animated:YES];
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"ChangeBinding") message:lang(@"ExchangeAlipay") cancelButtonItem:cancelBtn otherButtonItems:confirmBtn, nil];
        [alert show];
        
    } else {
        //无支付宝帐号，新添加
        AddAlipayViewController *addAliVC = [[AddAlipayViewController alloc] initWithName:_withdrawInfo.name idCard:_withdrawInfo.idCard];
        [self.navigationController pushViewController:addAliVC animated:YES];
    }
}

/**
 *  添加或者更换银行卡号
 */
- (void)addDebitCard {
    if (_withdrawInfo.debitCard) {
        //有银行卡号，弹窗提示
        RIButtonItem *cancelBtn = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
            
        }];
        RIButtonItem *confirmBtn = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
            AddDebitCardViewController *addDebitVC = [[AddDebitCardViewController alloc] initWithName:_withdrawInfo.name idCard:_withdrawInfo.idCard];
            [self.navigationController pushViewController:addDebitVC animated:YES];
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"ChangeBinding") message:lang(@"ExchangeDebit") cancelButtonItem:cancelBtn otherButtonItems:confirmBtn, nil];
        [alert show];

    } else {
        //无银行卡号，新添加
        AddDebitCardViewController *addDebitVC = [[AddDebitCardViewController alloc] initWithName:_withdrawInfo.name idCard:_withdrawInfo.idCard];
        [self.navigationController pushViewController:addDebitVC animated:YES];
    }
}

#pragma mark - rightBarButtonDidClick
- (IBAction)rightBarButtonDidClick:(id)sender {
    [self.view endEditing:YES];
    if (!self.rightMenuItem) {
        [self creatRightItem];
    } else {
        if (self.rightMenuItem.hidden) {
            [self.rightMenuItem showMenuView];
        } else {
            [self.rightMenuItem dismissMenuView];
        }
    }
}

- (void)createTopView {
    self.segmentedControl = [[DZNSegmentedControl alloc] initWithItems:@[lang(@"WithdrawToAlipay"), lang(@"WithdrawToDebitCard")]];
    self.segmentedControl.showsCount = NO;
    self.segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
    [self.segmentedControl setTintColor:[UIColor room107GreenColor]];
    [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateNormal];
    [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateDisabled];
    [self.view addSubview:self.segmentedControl];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    //self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.segmentedControl = self.segmentedControl;
    [self.view addSubview:self.scrollView];
}

- (void)loadData {
    [self showLoadingView];
    WEAK_SELF weakSelf = self;
    [[UserAccountAgent sharedInstance] getWithdrawInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *withdrawInfo) {
        [weakSelf hideLoadingView];
        if (errorMsg) {
            
        }
        
        [weakSelf.withdrawInfo setValuesForKeysWithDictionary:withdrawInfo];
        weakSelf.withdrawDebitCardView.maxWithdrawAmount = [withdrawInfo[@"balance"] doubleValue] / 100.0f;
        weakSelf.withdrawAlipayView.maxWithdrawAmount = [withdrawInfo[@"balance"] doubleValue] / 100.0f;
        
        //银行卡号
        NSString *debitCard = withdrawInfo[@"debitCard"];
        if (debitCard) {
            weakSelf.withdrawDebitCardView.hasCreditCard = YES;
            weakSelf.withdrawDebitCardView.debitCard = debitCard;
        } else {
            weakSelf.withdrawDebitCardView.hasCreditCard = NO;
        }
        
        //支付宝帐号
        NSString *alipayNumber = withdrawInfo[@"alipayNumber"];
        if (alipayNumber) {
            weakSelf.withdrawAlipayView.hasAlipay = YES;
            weakSelf.withdrawAlipayView.alipayNumber = alipayNumber;
        } else {
            weakSelf.withdrawAlipayView.hasAlipay = NO;
        }
        
        //姓名
        NSString *name = withdrawInfo[@"name"];
        if (name) {
            weakSelf.withdrawDebitCardView.name = name;
            weakSelf.withdrawAlipayView.name = name;
        }
        
        //身份证号
        NSString *idCard = withdrawInfo[@"idCard"];
        if (idCard) {
            weakSelf.withdrawDebitCardView.idCard = idCard;
            weakSelf.withdrawAlipayView.idCard = idCard;
        }
        
        //银行图片
        NSString *bankImage = withdrawInfo[@"bankImage"];
        if (bankImage) {
            weakSelf.withdrawDebitCardView.bankImage = bankImage;
        }
        
        //银行名称
        NSString *bankName = withdrawInfo[@"bankName"];
        if (bankName) {
            weakSelf.withdrawDebitCardView.bankName = bankName;
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat originY = 0;
    CGRect frame = self.view.frame;
    frame.origin.y = originY;
    frame.size.height = [self heightOfSegmentedControl];
    
    self.segmentedControl.frame = frame;
    
    originY += CGRectGetHeight(self.segmentedControl.bounds);
    
    frame = self.view.frame;
    frame.origin.y = originY;
    frame.size.height -= frame.origin.y;
    
    self.scrollView.frame = frame;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    __block CGFloat originX = 0.0f;
    WEAK_SELF weakSelf = self;
    [self.segmentedControl.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = originX;
        frame.origin.y = 0.5;
        
        if (idx == 0) {
            if (!weakSelf.withdrawAlipayView) {
                weakSelf.withdrawAlipayView = [[WithdrawAlipayView alloc] initWithFrame:frame];
                weakSelf.withdrawAlipayView.controller = self;
                [_scrollView addSubview:weakSelf.withdrawAlipayView];
                weakSelf.withdrawAlipayView.clickAliPay = ^(void){
                    //点击更换AliPay
                    [weakSelf addAliPay];
                };
                weakSelf.withdrawAlipayView.delegate = self; //设置withdrawAlipayView的代理 监听button点击方法
            }
        } else {
            if (!weakSelf.withdrawDebitCardView) {
                weakSelf.withdrawDebitCardView = [[WithdrawDebitCardView alloc] initWithFrame:frame];
                weakSelf.withdrawDebitCardView.controller = self;
                [_scrollView addSubview:weakSelf.withdrawDebitCardView];
                weakSelf.withdrawDebitCardView.clickDebit = ^(void){
                    //点击更换银行卡
                    [weakSelf addDebitCard];
                };
                weakSelf.withdrawDebitCardView.delegate = self;
            }
        }

        originX += CGRectGetWidth(frame);
    }];
    self.scrollView.contentSize = CGSizeMake(originX, self.scrollView.frame.size.height);
}

- (void)dealloc {
    if (_scrollView.segmentedControl) {
        //判断contentOffsetKey是否被注册
        [_scrollView removeObserver:_scrollView forKeyPath:contentOffsetKey];
    }
}

//点击alertView确定按钮 执行此方法
- (void)withdrawAlipayViewClickConfirmButton{
    [self loadData];
}

- (void)withdrawDebitCardViewClickConfirmButton{
    [self loadData];
}

@end
