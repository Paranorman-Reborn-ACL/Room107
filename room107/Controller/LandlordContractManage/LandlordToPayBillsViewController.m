//
//  LandlordToPayBillsViewController.m
//  room107
//
//  Created by ningxia on 15/9/11.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LandlordToPayBillsViewController.h"
#import "Room107TableView.h"
#import "ExpenseOrderTableViewCell.h"
#import "SystemAgent.h"
#import "AppPropertiesModel.h"
#import "ExpenseOrderLargeItemView.h"
#import "TotalPriceView.h"
#import "SearchTipLabel.h"
#import "NXPaymentSwitch.h"
#import "YellowColorTextLabel.h"
#import "NSString+AttributedString.h"
#import "PaymentTypeTableViewCell.h"
#import "SelectOtherTypeTableViewCell.h"
#import "PaymentFuncs.h"
#import "SuiteTitleView.h"
#import "PaymentBottomView.h"
#import "PaymentCostView.h"

static CGFloat bottomViewHeight = 49.0f;
static CGFloat payingHeaderViewHeight = 146.5;

@interface LandlordToPayBillsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) Room107TableView *sectionsTableView;
@property (nonatomic, strong) Room107TableView *payingTableView; //支付中的页面
@property (nonatomic, strong) LandlordHouseItemModel *landlordHouseItem;
@property (nonatomic, strong) NXPaymentSwitch *couponTextSwitch;
@property (nonatomic, strong) NXPaymentSwitch *balanceTextSwitch;
@property (nonatomic) int amount; //总金额，单位为“分”
@property (nonatomic) int paymentCost; //待支付金额，单位为“分”
@property (nonatomic, strong) NSString *ordersString;
@property (nonatomic, strong) void (^submitPaymentButtonHandlerBlock)(NSNumber *amount, NSString *ordersString);
@property (nonatomic, strong) void (^payPaymentButtonHandlerBlock)(NSNumber *paymentType);
@property (nonatomic, strong) void (^cancelPaymentButtonHandlerBlock)();
@property (nonatomic, strong) void (^viewLatestBillButtonHandlerBlock)();
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) SystemMutualBottomView *mutualBottomView;
@property (nonatomic, strong) ExpenseOrderTableViewCell *staticExpenseOrderTableViewCell;
@property (nonatomic) BOOL isUnfoldMorePaymentType; //是否展开了更多付款方式
@property (nonatomic, strong) NSMutableArray *paymentTypes; //多种付款方式
@property (nonatomic, strong) PaymentBottomView *paymentBottomView;

@end

@implementation LandlordToPayBillsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _staticExpenseOrderTableViewCell = [[ExpenseOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ExpenseOrderTableViewCell"];
}

- (void)showSuccessView {
    _sectionsTableView.hidden = YES;
    _payingTableView.hidden = YES;
    _paymentBottomView.hidden = YES;
    
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    _contentLabel = [self showContent:lang(@"PaySuccess") withFrame:frame];
    _contentLabel.hidden = NO;
    
    if (!_mutualBottomView) {
        frame.origin.y = CGRectGetHeight(self.view.bounds) - 100;
        frame.size.height = 100;
        _mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"ViewLatestBill") andAssistantButtonTitle:@""];
        [self.view addSubview:_mutualBottomView];
        [self.view bringSubviewToFront:_mutualBottomView];
        
        WEAK_SELF weakSelf = self;
        [_mutualBottomView setMainButtonDidClickHandler:^{
            if (weakSelf.viewLatestBillButtonHandlerBlock) {
                weakSelf.viewLatestBillButtonHandlerBlock();
            }
        }];
    }
    _mutualBottomView.hidden = NO;
}

- (void)setLandlordHouseItem:(LandlordHouseItemModel *)landlordHouseItem {
    _landlordHouseItem = landlordHouseItem;
    _contentLabel.hidden = YES;
    _mutualBottomView.hidden = YES;
    _sectionsTableView.hidden = YES;
    _payingTableView.hidden = YES;
    if ((!landlordHouseItem || !landlordHouseItem.expenseOrders) && !landlordHouseItem.paymentId) {
        CGRect frame = App.window.frame;
        frame.origin.x = 0;
        frame.size.height -= statusBarHeight + navigationBarHeight + [self heightOfSegmentedControl];
        _contentLabel = [self showContent:lang(@"HasNoPayment") withFrame:frame];
        _contentLabel.hidden = NO;
        
        return;
    }
    
    if (!_paymentBottomView) {
        _paymentBottomView = [[PaymentBottomView alloc] initWithFrame:(CGRect){0, CGRectGetHeight(App.window.frame) - (statusBarHeight + navigationBarHeight + [self heightOfSegmentedControl] + bottomViewHeight), CGRectGetWidth(self.view.bounds), bottomViewHeight}];
        [self.view addSubview:_paymentBottomView];
    }
    
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    if (landlordHouseItem.paymentId) {
        if (!_payingTableView) {
            _payingTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStylePlain];
            _payingTableView.delegate = self;
            _payingTableView.dataSource = self;
            [_payingTableView setBackgroundColor:self.view.backgroundColor];
            [self.view addSubview:_payingTableView];
        }
        _isUnfoldMorePaymentType = NO;
        _paymentTypes = [PaymentFuncs recommendedPaymentTypes];
        _payingTableView.hidden = NO;
        _payingTableView.tableHeaderView = [self createPayingTableHeaderView];
        _payingTableView.tableFooterView = [self createPayingTableFooterView];
        [self.view bringSubviewToFront:_payingTableView];
        [_payingTableView reloadData];
        
        NSString *paymentCancelText = [lang(@"CancelPayment") stringByAppendingFormat:@"\n%@", lang(@"ReselectRedBagOrBalance")];
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:paymentCancelText];
        NSArray *components = [paymentCancelText componentsSeparatedByString:@"\n"];
        NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorD], NSFontAttributeName:[UIFont room107SystemFontThree]};
        [attributedTitle addAttributes:attrs range:NSMakeRange(0, [(NSString *)components[0] length])];
        attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorC], NSFontAttributeName:[UIFont room107SystemFontOne]};
        [attributedTitle addAttributes:attrs range:NSMakeRange([(NSString *)components[0] length] + 1, [(NSString *)components[1] length])];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        attrs = @{NSParagraphStyleAttributeName:paragraphStyle};
        [attributedTitle addAttributes:attrs range:NSMakeRange(0, attributedTitle.length)];
        [_paymentBottomView setLeftButtonAttributedTitle:attributedTitle];
        [_paymentBottomView setRightButtonTitle:lang(@"ConfirmPay")];
        WEAK_SELF weakSelf = self;
        [_paymentBottomView setLeftButtonDidClickHandler:^{
            if (weakSelf.cancelPaymentButtonHandlerBlock) {
                weakSelf.cancelPaymentButtonHandlerBlock();
            }
        }];
        [_paymentBottomView setRightButtonDidClickHandler:^() {
            [weakSelf rightButtonDidClick];
        }];
    } else {
        if (!_sectionsTableView) {
            _sectionsTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
            [_sectionsTableView setBackgroundColor:self.view.backgroundColor];
            _sectionsTableView.delegate = self;
            _sectionsTableView.dataSource = self;
            _sectionsTableView.tableHeaderView = [self createHeaderView];
            _sectionsTableView.tableFooterView = [self createFooterView];
            [self.view addSubview:_sectionsTableView];
        }
        _sectionsTableView.hidden = NO;
        [self.view bringSubviewToFront:_sectionsTableView];
        
        if (!_sections) {
            _sections = [[NSMutableArray alloc] init];
        }
        [_sections removeAllObjects];
        
        if (!landlordHouseItem.expenseOrders) {
            return;
        }
        
        AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
        //按照orderType顺序排序
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"orderType" ascending:YES];
        landlordHouseItem.expenseOrders = [landlordHouseItem.expenseOrders sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
        
        _ordersString = @"";
        NSNumber *orderType = landlordHouseItem.expenseOrders[0][@"orderType"];
        NSMutableArray *expenseOrders = [[NSMutableArray alloc] init];
        for (NSDictionary *expenseOrder in landlordHouseItem.expenseOrders) {
            if (![expenseOrder[@"orderType"] isEqual:orderType]) {
                double price = 0;
                for (NSMutableDictionary *expenseOrder in expenseOrders) {
                    price += [expenseOrder[@"value"] doubleValue];
                }
                [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:appProperties.orderTypeNames[[orderType integerValue]], @"key", orderType, @"orderType", expenseOrders, @"value", [NSNumber numberWithDouble:price / 100], @"price", nil]];
                
                orderType = expenseOrder[@"orderType"];
                expenseOrders = [[NSMutableArray alloc] init];
            }
            
            [expenseOrders addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:expenseOrder[@"name"], @"key", expenseOrder[@"orderType"], @"orderType", expenseOrder[@"price"], @"value", nil]];
            
            _ordersString = [_ordersString stringByAppendingFormat:@"%@|", expenseOrder[@"orderId"]];
        }
        if (![_ordersString isEqualToString:@""]) {
            _ordersString = [_ordersString substringToIndex:_ordersString.length - 1];
        }
        
        if (expenseOrders.count > 0) {
            double price = 0;
            for (NSMutableDictionary *expenseOrder in expenseOrders) {
                price += [expenseOrder[@"value"] doubleValue];
            }
            [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:appProperties.orderTypeNames[[orderType integerValue]], @"key", expenseOrders[0][@"orderType"], @"orderType", expenseOrders, @"value", [NSNumber numberWithDouble:price / 100], @"price", nil]];
        }
        [_sectionsTableView reloadData];
        
        [self changePaymentCost];
        [_paymentBottomView setRightButtonTitle:lang(@"ToPay")];
        WEAK_SELF weakSelf = self;
        [_paymentBottomView setRightButtonDidClickHandler:^() {
            [weakSelf rightButtonDidClick];
        }];
    }
    [self.view bringSubviewToFront:_paymentBottomView];
}

- (void)changePaymentCost {
    int paymentCost = _amount;
    if (_couponTextSwitch.isOn) {
        paymentCost -= [_landlordHouseItem.coupon intValue];
    }
    if (_balanceTextSwitch.isOn) {
        paymentCost -= [_landlordHouseItem.balance intValue];
    }
    _paymentCost = paymentCost;
    _paymentCost = _paymentCost > 0 ? _paymentCost : 0;
    _paymentCost = _paymentCost < _amount ? _paymentCost : _amount;
    
    NSString *paymentCostText = [[CommonFuncs moneyStrByDouble:(double)_paymentCost / 100] stringByAppendingFormat:@"\n%@",  lang(@"ThirdPartyPayment")];
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:paymentCostText];
    NSArray *components = [paymentCostText componentsSeparatedByString:@"\n"];
    NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor room107GreenColor], NSFontAttributeName:[UIFont room107SystemFontFour]};
    [attributedTitle addAttributes:attrs range:NSMakeRange(0, [(NSString *)components[0] length])];
    attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorC], NSFontAttributeName:[UIFont room107SystemFontOne]};
    [attributedTitle addAttributes:attrs range:NSMakeRange([(NSString *)components[0] length] + 1, [(NSString *)components[1] length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attrs = @{NSParagraphStyleAttributeName:paragraphStyle};
    [attributedTitle addAttributes:attrs range:NSMakeRange(0, attributedTitle.length)];
    [_paymentBottomView setLeftButtonAttributedTitle:attributedTitle];
}

- (void)scrollToTop {
    [_sectionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (UIView *)createHeaderView {
    CGFloat spaceY = 11;
    CGFloat titleViewHeight = 36.5;
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, spaceY + titleViewHeight}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    SuiteTitleView *titleView = [[SuiteTitleView alloc] initWithFrame:(CGRect){0, spaceY, CGRectGetWidth(headerView.bounds), titleViewHeight} andTitle:lang(@"PendingSettlement")];
    [headerView addSubview:titleView];
    
    return headerView;
}

- (UIView *)createPayingTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, payingHeaderViewHeight}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 0;
    CGFloat originY = 11;
    PaymentCostView *paymentCostView = [[PaymentCostView alloc] initWithFrame:(CGRect){originX, originY, headerView.frame.size.width - 2 * originX, 88}];
    [paymentCostView setPaymentInfo:[CommonFuncs moneyStrByDouble:(double)[_landlordHouseItem.paymentCost intValue] / 100] andDate:_landlordHouseItem.deadline];
    [headerView addSubview:paymentCostView];
    
    originY += CGRectGetHeight(paymentCostView.bounds) + 11;
    SuiteTitleView *titleView = [[SuiteTitleView alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(headerView.bounds), 36.5} andTitle:lang(@"ChoosePaymentType")];
    [headerView addSubview:titleView];
    
    return headerView;
}

- (UIView *)createFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 240.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    TotalPriceView *totalPriceView = [[TotalPriceView alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth(footerView.bounds), 64}];
    NSString *deadline = @"";
    _amount = 0;
    for (NSMutableDictionary *expenseOrder in _landlordHouseItem.expenseOrders) {
        _amount += [expenseOrder[@"price"] intValue];
        
        if ([deadline isEqualToString:@""]) {
            deadline = expenseOrder[@"deadline"];
        }
        
        if ([expenseOrder[@"deadline"] compare:deadline] == NSOrderedAscending) {
            //获取最近截止日期
            deadline = expenseOrder[@"deadline"];
        }
    }
    
    NSString *content = [lang(@"Total") stringByAppendingString:[CommonFuncs moneyStrByDouble:(double)_amount / 100]];
    content = [[content stringByAppendingString:@"\n"] stringByAppendingFormat:lang(@"MustCompletePaymentBefore%@"), [TimeUtil friendlyDateTimeFromDateTime:deadline withFormat:@"%Y/%m/%d"]];
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
    NSArray *components = [content componentsSeparatedByString:@"\n"];
    NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorE], NSFontAttributeName:[UIFont room107SystemFontThree]};
    [attributedContent addAttributes:attrs range:NSMakeRange(0, 2)];
    attrs = @{NSForegroundColorAttributeName:[UIColor room107GreenColor], NSFontAttributeName:[UIFont room107SystemFontFour]};
    [attributedContent addAttributes:attrs range:NSMakeRange(2, [(NSString *)components[0] length] - 1)];
    attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorD], NSFontAttributeName:[UIFont room107SystemFontOne]};
    [attributedContent addAttributes:attrs range:NSMakeRange([(NSString *)components[0] length] + 1, [(NSString *)components[1] length])];
    [totalPriceView setAttributedContent:attributedContent];
    [footerView addSubview:totalPriceView];
    
    originY += CGRectGetHeight(totalPriceView.bounds) + 11;
    CGFloat titleViewHeight = 36.5;
    SuiteTitleView *titleView = [[SuiteTitleView alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(footerView.bounds), titleViewHeight} andTitle:lang(@"SelectRedBagOrBalance")];
    [footerView addSubview:titleView];
    
    originY += CGRectGetHeight(titleView.bounds);
    CGFloat textSwitchWidth = CGRectGetWidth(footerView.bounds);
    CGFloat textSwitchHeight = 44.0f;
    _couponTextSwitch = [[NXPaymentSwitch alloc] initWithFrame:(CGRect){originX, originY, textSwitchWidth, textSwitchHeight} withSwitch:YES];
    [_couponTextSwitch setIconText:@"\ue630"];
    [_couponTextSwitch setTitle:lang(@"RedBag")];
    [_couponTextSwitch setContent:[CommonFuncs moneyStrByDouble:[_landlordHouseItem.coupon doubleValue] / 100]];
    [footerView addSubview:_couponTextSwitch];
    if (0 == [_landlordHouseItem.coupon doubleValue]) {
        //红包为0 开关关闭
        [_couponTextSwitch setOn:NO];
    } else {
        //红包不为0 开关打开
        [_couponTextSwitch setOn:YES];
        [_couponTextSwitch setIconColor:[UIColor redColor]];
    }
    WEAK_SELF weakSelf = self;
    WEAK(_couponTextSwitch) weakCouponTextSwitch = _couponTextSwitch;
    [_couponTextSwitch setSwitchActionHandler:^(BOOL isOn) {
        //如果红包为0 点击无效果 给弹窗
        if (0 == [_landlordHouseItem.coupon doubleValue]) {
            [weakCouponTextSwitch setOn:NO];
            [PopupView showMessage:lang(@"RedBagHaveNoMoney")];
        } else {
            //开关好使则走老逻辑
            [weakSelf changePaymentCost];
            if (isOn) {
                [weakCouponTextSwitch setIconColor:[UIColor redColor]];
            }
        }
    }];
    
    originY += CGRectGetHeight(_couponTextSwitch.bounds);
    _balanceTextSwitch = [[NXPaymentSwitch alloc] initWithFrame:(CGRect){originX, originY, textSwitchWidth, textSwitchHeight} withSwitch:YES];
    [_balanceTextSwitch setIconText:@"\ue631"];
    [_balanceTextSwitch setTitle:lang(@"Balance")];
    [_balanceTextSwitch setContent:[CommonFuncs moneyStrByDouble:[_landlordHouseItem.balance  doubleValue] / 100]];
    
    if ([_landlordHouseItem.coupon intValue] >= _amount) {
        //红包够支付账单 并不需要余额 关闭开关 （优先使用红包）
        [_balanceTextSwitch setOn:NO];
    } else {
        //红包不够支付 采用余额
        if (0 == [_landlordHouseItem.balance  doubleValue]) {
            //余额为0 关闭按钮 不可打开
            [_balanceTextSwitch setOn:NO];
        } else {
            //有余额可用 打开按钮
            [_balanceTextSwitch setOn:YES];
            [_balanceTextSwitch setIconColor:[UIColor room107YellowColor]];
        }
    }
    [footerView addSubview:_balanceTextSwitch];
    WEAK(_balanceTextSwitch) weakBalanceTextSwitch = _balanceTextSwitch;
    [_balanceTextSwitch setSwitchActionHandler:^(BOOL isOn) {
        //余额为0 点击无效果 给弹窗
        if (0 == [_landlordHouseItem.balance  doubleValue]) {
            [weakBalanceTextSwitch setOn:NO];
            [PopupView showMessage:lang(@"BalanceHaveNoMoney")];
        } else {
            if (isOn) {
                [weakBalanceTextSwitch setIconColor:[UIColor room107YellowColor]];
            }
            [weakSelf changePaymentCost];
        }
    }];
    [self changePaymentCost];
    
    return footerView;
}

- (UIView *)createPayingTableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 260.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    if ([_landlordHouseItem.paymentCost intValue] >= maxPaymentCost) {
        CGFloat originX = 22;
        CGFloat originY = 11;
        CGFloat maxDisplayWidth = CGRectGetWidth(footerView.bounds) - originX * 2;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5; //字体的行间距
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont room107SystemFontOne],
                                     NSParagraphStyleAttributeName:paragraphStyle};
        CGFloat maxPaymentCostTipsLabelHeight = [CommonFuncs rectWithText:lang(@"MaxPaymentCostTips") andMaxDisplayWidth:maxDisplayWidth andAttributes:attributes].size.height + 10;
        UIView *backgroundView = [[UIView alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(footerView.bounds), maxPaymentCostTipsLabelHeight}];
        [backgroundView setBackgroundColor:[UIColor whiteColor]];
        [footerView addSubview:backgroundView];
        YellowColorTextLabel *maxPaymentCostTipsLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){originX, 0, maxDisplayWidth, maxPaymentCostTipsLabelHeight} withTitle:lang(@"MaxPaymentCostTips") withTitleColor:[UIColor room107YellowColor]];
        [maxPaymentCostTipsLabel setFont:[UIFont room107SystemFontOne]];
        [backgroundView addSubview:maxPaymentCostTipsLabel];
    }
    
    return footerView;
}

- (void)setSubmitPaymentButtonDidClickHandler:(void(^)(NSNumber *amount, NSString *ordersString))handler {
    _submitPaymentButtonHandlerBlock = handler;
}

- (void)setPayPaymentButtonDidClickHandler:(void (^)(NSNumber *paymentType))handler {
    _payPaymentButtonHandlerBlock = handler;
}

- (void)setCancelPaymentButtonDidClickHandler:(void (^)())handler {
    _cancelPaymentButtonHandlerBlock = handler;
}

- (void)setViewLatestBillButtonDidClickHandler:(void(^)())handler {
    _viewLatestBillButtonHandlerBlock = handler;
}

- (void)leftButtonDidClick {
    
}

// "去支付按钮" 方法
- (void)rightButtonDidClick {
    if (!_payingTableView || _payingTableView.hidden) {
        //支付中页面未显示:第一步
        //通过红包或者余额按钮的开关属性 确定最后订单的价格详情
        if (_couponTextSwitch.isOn) {
            _landlordHouseItem.couponCost = [_landlordHouseItem.coupon intValue] > _amount ? [NSNumber numberWithInt:_amount] : _landlordHouseItem.coupon;
        } else {
            _landlordHouseItem.couponCost = @0;
        }
        if (_balanceTextSwitch.isOn) {
            if (_couponTextSwitch.isOn) {
                if ([_landlordHouseItem.coupon intValue] >= _amount) {
                    _landlordHouseItem.balanceCost = @0;
                } else {
                    _landlordHouseItem.balanceCost = [NSNumber numberWithInt:_amount - _paymentCost - [_landlordHouseItem.coupon intValue]];
                }
            } else {
                _landlordHouseItem.balanceCost = [_landlordHouseItem.balance intValue] > _amount ? [NSNumber numberWithInt:_amount] : _landlordHouseItem.balance;
            }
        } else {
            _landlordHouseItem.balanceCost = @0;
        }
        _landlordHouseItem.paymentCost = [NSNumber numberWithInt:_paymentCost];
        
        //提交最新订单
        if (_submitPaymentButtonHandlerBlock) {
            _submitPaymentButtonHandlerBlock([NSNumber numberWithInt:_amount], _ordersString);
        }
    } else {
        //支付按钮
        if (_payPaymentButtonHandlerBlock) {
            NSNumber *paymentType = @0;
            for (NSMutableDictionary *paymentTypeDic in _paymentTypes) {
                if ([paymentTypeDic[@"selected"] boolValue]) {
                    paymentType = paymentTypeDic[@"paymentType"];
                    break;
                }
            }
            _payPaymentButtonHandlerBlock(paymentType);
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:_sectionsTableView]) {
        return _sections.count;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_sectionsTableView]) {
        return [(NSMutableArray *)_sections[section][@"value"] count];
    } else {
        return _isUnfoldMorePaymentType ? _paymentTypes.count : _paymentTypes.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_sectionsTableView]) {
        ExpenseOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpenseOrderTableViewCell"];
        if (!cell) {
            cell = [[ExpenseOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ExpenseOrderTableViewCell"];
        }
        [cell setName:_sections[indexPath.section][@"value"][indexPath.row][@"key"]];
        [cell setContent:[CommonFuncs moneyStrByDouble:[_sections[indexPath.section][@"value"][indexPath.row][@"value"] doubleValue] / 100]];
        
        return cell;
    } else {
        if (_isUnfoldMorePaymentType) {
            return [self cellForRowAtIndexPath:indexPath andTableView:tableView];
        } else {
            if (indexPath.row == 1) {
                SelectOtherTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectOtherTypeTableViewCell"];
                if (!cell) {
                    cell = [[SelectOtherTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectOtherTypeTableViewCell"];
                }
                [cell setDisplayText:lang(@"SelectOtherPaymentType")];
                
                return cell;
            } else {
                return [self cellForRowAtIndexPath:indexPath andTableView:tableView];
            }
        }
    }
}

- (PaymentTypeTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView {
    PaymentTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentTypeTableViewCell"];
    if (!cell) {
        cell = [[PaymentTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PaymentTypeTableViewCell"];
    }
    [cell setPaymentTypeImageName:_paymentTypes[indexPath.row][@"imageName"]];
    [cell setPaymentTypeTitle:_paymentTypes[indexPath.row][@"title"]];
    [cell setPaymentTypeSeleted:[_paymentTypes[indexPath.row][@"selected"] boolValue]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_sectionsTableView]) {
        return [_staticExpenseOrderTableViewCell getCellHeightWithName:_sections[indexPath.section][@"value"][indexPath.row][@"key"]];
    } else {
        if (_isUnfoldMorePaymentType) {
            return paymentTypeTableViewCellHeight;
        } else {
            return indexPath.row == 1 ? selectOtherTypeTableViewCellHeight : paymentTypeTableViewCellHeight;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView isEqual:_payingTableView]) {
        if (_isUnfoldMorePaymentType) {
            if (_paymentTypes.count > indexPath.row) {
                if (![_paymentTypes[indexPath.row][@"selected"] boolValue]) {
                    for (NSMutableDictionary *paymentTypeDic in _paymentTypes) {
                        if ([paymentTypeDic[@"selected"] boolValue]) {
                            [paymentTypeDic setObject:@NO forKey:@"selected"];
                            break;
                        }
                    }
                    [_paymentTypes[indexPath.row] setObject:@YES forKey:@"selected"];
                    [_payingTableView reloadData];
                }
            }
        } else {
            if (indexPath.row == 1) {
                _isUnfoldMorePaymentType = YES;
                _paymentTypes = [PaymentFuncs allPaymentTypes];
                [_payingTableView reloadData];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_sectionsTableView]) {
        return 30.5;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]};
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:frame];
    [sectionHeaderView setBackgroundColor:[UIColor whiteColor]];
    
    if ([tableView isEqual:_sectionsTableView]) {
        CGFloat originY = 5.5;
        ExpenseOrderLargeItemView *expenseOrderLargeItemView = [[ExpenseOrderLargeItemView alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(frame), CGRectGetHeight(frame) - originY} withButton:NO];
        [expenseOrderLargeItemView setTitle:_sections[section][@"key"]];
        [expenseOrderLargeItemView setContent:[CommonFuncs moneyStrByDouble:[_sections[section][@"price"] doubleValue]]];
        [sectionHeaderView addSubview:expenseOrderLargeItemView];
    }
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([tableView isEqual:_sectionsTableView]) {
        return 0.5;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForFooterInSection:section]};
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    if ([tableView isEqual:_sectionsTableView]) {
        [view setBackgroundColor:[UIColor room107GrayColorA]];
    }
    
    return view;
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
