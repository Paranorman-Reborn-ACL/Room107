//
//  RapidAuthenticateViewController.m
//  room107
//
//  Created by ningxia on 16/3/25.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "RapidAuthenticateViewController.h"
#import "Room107TableView.h"
#import "PaymentTypeTableViewCell.h"
#import "SelectOtherTypeTableViewCell.h"
#import "AuthenticationAgent.h"
#import "PaymentFuncs.h"
#import "YellowColorTextLabel.h"
#import "SeparatedView.h"
#import "CustomImageView.h"
#import "LicenseAgreementView.h"
#import "SystemAgent.h"
#import "TitleGreenColorTextLabel.h"
#import "NXPaymentSwitch.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "CMBNetPayViewController.h"
#import "PaymentInfoModel.h"
#import "PaymentAgent.h"

@interface RapidAuthenticateViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Room107TableView *authenticateTableView;
@property (nonatomic) BOOL isUnfoldMorePaymentType; //是否展开了更多付款方式
@property (nonatomic, strong) NSMutableArray *paymentTypes; //多种付款方式
@property (nonatomic, strong) CustomImageView *explanationImageView;
@property (nonatomic, strong) YellowColorTextLabel *validityLabel; //有效期
@property (nonatomic, strong) CustomImageView *successImageView;
@property (nonatomic, strong) UIScrollView *resultView;
@property (nonatomic, strong) PaymentInfoModel *paymentInfo; //极速认证的账单信息
@property (nonatomic) BOOL isCMBNetPay; //是否跳转至招行快捷支付页

@end

@implementation RapidAuthenticateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UserInfoModel *userInfo = [[AuthenticationAgent sharedInstance] getUserInfoFromLocal];
    [self showStep:[userInfo.verifyStatus isEqual:@3] ? 2 : 1];
    _isCMBNetPay = NO;
    
    if([WXApi isWXAppInstalled]) {
        // 判断 用户是否安装微信
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWechatPayResult:) name:WechatPayNotification object:nil];//监听一个通知
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_isCMBNetPay) {
        //检查招行快捷支付的状态
        [self getPaymentStatusWithPaymentID:_paymentInfo.paymentId andPaymentType:[NSNumber numberWithUnsignedInteger:CMBNetPaymentType]];
        
        _isCMBNetPay = NO;
    }
}

- (void)showStep:(NSUInteger)step {
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    if (step == 1) {
        if (!_authenticateTableView) {
            _authenticateTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStylePlain];
            _authenticateTableView.delegate = self;
            _authenticateTableView.dataSource = self;
            [self.view addSubview:_authenticateTableView];
        }
        _isUnfoldMorePaymentType = NO;
        _paymentTypes = [PaymentFuncs recommendedPaymentTypes];
        _authenticateTableView.tableHeaderView = [self createTableHeaderView];
        _authenticateTableView.tableFooterView = [self createTableFooterView];
        [_authenticateTableView reloadData];
        _authenticateTableView.hidden = NO;
        _resultView.hidden = YES;
    } else {
        if (!_resultView) {
            _resultView = [[UIScrollView alloc] initWithFrame:frame];
            [_resultView setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:_resultView];
            
            CGFloat originY = 33.0f;
            YellowColorTextLabel *successLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.view.bounds), 18} withTitle:lang(@"RapidAuthenticateSuccess") withTitleColor:[UIColor room107GreenColor]];
            [_resultView addSubview:successLabel];
            
            UserInfoModel *userInfo = [[AuthenticationAgent sharedInstance] getUserInfoFromLocal];
            AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@22];
            if (!appText) {
                [[SystemAgent sharedInstance] getTextPropertiesFromServer];
            }
            originY += CGRectGetHeight(successLabel.bounds) + 22;
            _validityLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.view.bounds), 85} withTitle:[lang(@"AuthenticateValidity") stringByAppendingFormat:@"%@-%@%@", userInfo.rapidVerifyStart ? userInfo.rapidVerifyStart : @"", userInfo.rapidVerifyFinish ? userInfo.rapidVerifyFinish : @"", [NSString stringWithFormat:@"\n\n%@", appText.text ? appText.text : @""]] withTitleColor:[UIColor room107GrayColorC]];
            [_validityLabel setFont:[UIFont room107SystemFontOne]];
            [_resultView addSubview:_validityLabel];
            
            AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
            if (!appProperties) {
                [[SystemAgent sharedInstance] getPropertiesFromServer];
            }
            
            CGFloat originX = 11;
            originY += CGRectGetHeight(_validityLabel.bounds) + 33;
            CGFloat height = 100;
            if (appProperties.rapidVerifyPicture && appProperties.rapidVerifyPicture[@"height"] && appProperties.rapidVerifyPicture[@"width"]) {
                height = (CGRectGetWidth(_resultView.bounds) - 2 * originX) * [appProperties.rapidVerifyPicture[@"height"] floatValue] / [appProperties.rapidVerifyPicture[@"width"] floatValue];
            }
            _successImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth(_resultView.bounds) - 2 * originX, height}];
            _successImageView.contentMode = UIViewContentModeCenter;
            WEAK_SELF weakSelf = self;
            [_successImageView setImageWithURL:appProperties.rapidVerifyPicture ? appProperties.rapidVerifyPicture[@"url"] : @"" placeholderImage:[UIImage imageNamed:@"imageLoading.png"] withCompletionHandler:^(UIImage *image) {
                if (image) {
                    weakSelf.successImageView.contentMode = UIViewContentModeScaleToFill;
                }
            }];
            [_resultView addSubview:_successImageView];
            
            [_resultView setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), originY + CGRectGetHeight(_successImageView.bounds))];
        }
        
        //获取认证有效期
        UserInfoModel *userInfo = [[AuthenticationAgent sharedInstance] getUserInfoFromLocal];
        //获取极速认证成功后文案
        AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@22];
        if (!appText) {
            [[SystemAgent sharedInstance] getTextPropertiesFromServer];
        }
        if (userInfo && userInfo.rapidVerifyStart && userInfo.rapidVerifyFinish) {
            [_validityLabel setTitle:[lang(@"AuthenticateValidity") stringByAppendingFormat:@"%@-%@%@", userInfo.rapidVerifyStart ? userInfo.rapidVerifyStart : @"", userInfo.rapidVerifyFinish ? userInfo.rapidVerifyFinish : @"", [NSString stringWithFormat:@"\n\n%@", appText.text ? appText.text : @""]] withTitleColor:[UIColor room107GrayColorC]];
        } else {
            [[AuthenticationAgent sharedInstance] getUserInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserInfoModel *userInfo, SubscribeModel *subscribe) {
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                
                if (!errorCode) {
                    [_validityLabel setTitle:[lang(@"AuthenticateValidity") stringByAppendingFormat:@"%@-%@%@", userInfo.rapidVerifyStart ? userInfo.rapidVerifyStart : @"", userInfo.rapidVerifyFinish ? userInfo.rapidVerifyFinish : @"",[NSString stringWithFormat:@"\n\n%@", appText.text ? appText.text : @""]] withTitleColor:[UIColor room107GrayColorC]];
                }
            }];
        }
        _authenticateTableView.hidden = YES;
        _resultView.hidden = NO;
    }
}

- (UIView *)createTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 0}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 22.0f;
    CGFloat originY = 22.0f;
    
    TitleGreenColorTextLabel *titleGreenTextColorLabel = [[TitleGreenColorTextLabel alloc] initWithFrame:CGRectMake(0, originY, CGRectGetWidth(headerView.bounds), 100) withTitle:lang(@"WhyAuthenticate") withContent:lang(@"ReasonAuthenticate")];
    [headerView addSubview:titleGreenTextColorLabel];
    
    originY += CGRectGetHeight(titleGreenTextColorLabel.frame) + 22;
    UIView *separatedView = [[UIView alloc] initWithFrame:CGRectMake(22, originY, self.view.frame.size.width - 44, 1)];
    [separatedView setBackgroundColor:[UIColor room107GrayColorC]];
    [headerView addSubview:separatedView];
    
    originY += CGRectGetHeight(separatedView.bounds) + 33;
    CGFloat maxDisplayWidth = CGRectGetWidth(headerView.bounds) - originX * 2;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5; //字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont room107SystemFontThree],
                                 NSParagraphStyleAttributeName:paragraphStyle};
    AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@12];
    if (!appText) {
        [[SystemAgent sharedInstance] getTextPropertiesFromServer];
    }
    YellowColorTextLabel *explanationTitleLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){originX, originY, maxDisplayWidth, [CommonFuncs rectWithText:appText.text ? appText.text : @"" andMaxDisplayWidth:maxDisplayWidth andAttributes:attributes].size.height} withTitle:appText.text ? appText.text : @"" withTitleColor:[UIColor room107GrayColorD]];
    [headerView addSubview:explanationTitleLabel];
    
    originY += CGRectGetHeight(explanationTitleLabel.bounds) + 22;
    attributes = @{NSFontAttributeName:[UIFont room107SystemFontOne],
                   NSParagraphStyleAttributeName:paragraphStyle};
    appText = [[SystemAgent sharedInstance] getTextPropertyByID:@13];
    if (!appText) {
        [[SystemAgent sharedInstance] getTextPropertiesFromServer];
    }
    YellowColorTextLabel *explanationTextLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){originX, originY, maxDisplayWidth, [CommonFuncs rectWithText:appText.text ? appText.text : @"" andMaxDisplayWidth:maxDisplayWidth andAttributes:attributes].size.height} withTitle:appText.text ? appText.text : @"" withTitleColor:[UIColor room107GrayColorD] withAlignment:NSTextAlignmentLeft];
    [explanationTextLabel setFont:[UIFont room107SystemFontOne]];
    [headerView addSubview:explanationTextLabel];
    
    AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
    if (!appProperties) {
        [[SystemAgent sharedInstance] getPropertiesFromServer];
    }
    
    originY += CGRectGetHeight(explanationTextLabel.bounds) + 22;
    CGFloat height = 100;
    if (appProperties.rapidVerifyPicture && appProperties.rapidVerifyPicture[@"height"] && appProperties.rapidVerifyPicture[@"width"]) {
        height = (maxDisplayWidth + originX) * [appProperties.rapidVerifyPicture[@"height"] floatValue] / [appProperties.rapidVerifyPicture[@"width"] floatValue];
    }
    _explanationImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX / 2, originY, maxDisplayWidth + originX, height}];
    _explanationImageView.contentMode = UIViewContentModeCenter;
    WEAK_SELF weakSelf = self;
    [_explanationImageView setImageWithURL:appProperties.rapidVerifyPicture ? appProperties.rapidVerifyPicture[@"url"] : @"" placeholderImage:[UIImage imageNamed:@"imageLoading.png"] withCompletionHandler:^(UIImage *image) {
        if (image) {
            weakSelf.explanationImageView.contentMode = UIViewContentModeScaleToFill;
        }
    }];
    [headerView addSubview:_explanationImageView];
    
    originY += CGRectGetHeight(_explanationImageView.bounds) + 22;
    CGFloat labelWidth = 100;
    CGFloat labelHeight = 30;
    SearchTipLabel *titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
    [titleLabel setText:lang(@"Pay")];
    [headerView addSubview:titleLabel];
    
    SearchTipLabel *contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){CGRectGetWidth(headerView.bounds) - labelWidth - originX, originY, labelWidth, labelHeight}];
    [contentLabel setText:[CommonFuncs moneyStrByDouble:appProperties.rapidVerifyAmount ? [appProperties.rapidVerifyAmount doubleValue] / 100 : 0]];
    [contentLabel setTextAlignment:NSTextAlignmentRight];
    [contentLabel setFont:[UIFont room107SystemFontTwo]];
    [contentLabel setTextColor:[UIColor room107GrayColorD]];
    [headerView addSubview:contentLabel];

    CGRect frame = headerView.frame;
    frame.size.height = originY + labelHeight + 11;
    [headerView setFrame:frame];
    return headerView;
}

- (UIView *)createTableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 300.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 22.0f;
    CGFloat originY = 22;
    CGFloat maxDisplayWidth = CGRectGetWidth(footerView.bounds) - originX * 2;
    LicenseAgreementView *licenseAgreementView = [[LicenseAgreementView alloc] initWithFrame:(CGRect){originX - 2, originY, maxDisplayWidth + 6, 45} withContent:lang(@"AcceptRapidAuthenticate")];
    [footerView addSubview:licenseAgreementView];
    
    originY += CGRectGetHeight(licenseAgreementView.bounds) + 22;
    CGRect frame = (CGRect){0, originY, CGRectGetWidth(footerView.bounds), 100};
    SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"RapidAuthenticate") andAssistantButtonTitle:@""];
    [footerView addSubview:mutualBottomView];
    WEAK_SELF weakSelf = self;
    [mutualBottomView setMainButtonDidClickHandler:^{
        if (licenseAgreementView.status) {
            [weakSelf mainButtonDidClick];
        } else {
            [CommonFuncs showAlertViewWithTitle:lang(@"UncommittedRapidAuthenticateTitle") message:lang(@"UncommittedRapidAuthenticateMessage")];
        }
    }];
    
    return footerView;
}

- (void)mainButtonDidClick {
    //支付按钮
    NSNumber *paymentType = @0;
    for (NSMutableDictionary *paymentTypeDic in _paymentTypes) {
        if ([paymentTypeDic[@"selected"] boolValue]) {
            paymentType = paymentTypeDic[@"paymentType"];
            break;
        }
    }
    
    AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
    if (!appProperties || !appProperties.rapidVerifyAmount) {
        [[SystemAgent sharedInstance] getPropertiesFromServer];
        return;
    }
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:appProperties.rapidVerifyAmount forKey:@"amount"];
    if ([appProperties.rapidVerifyAmount intValue] > 0) {
        [info setObject:paymentType forKey:@"paymentType"];
    }
    [info setObject:[CommonFuncs deviceIPAdress] forKey:@"ip"];
    
    [self showLoadingView];
    WEAK_SELF weakSelf = self;
    [[PaymentAgent sharedInstance] payRapidVerifyWithInfo:info completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo, NSDictionary *params, NSNumber *paymentType) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        
        if (!errorCode) {
            _paymentInfo = paymentInfo;
            
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
                            [weakSelf getPaymentStatusWithPaymentID:_paymentInfo.paymentId andPaymentType:paymentType];
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
                    [weakSelf showStep:2];
                    break;
            }
        }
    }];
}

- (void)getPaymentStatusWithPaymentID:(NSNumber *)paymentId andPaymentType:(NSNumber *)paymentType {
    [self showLoadingView];
    [[PaymentAgent sharedInstance] statusAccountPaymentWithPaymentID:paymentId andPaymentType:paymentType completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo, NSNumber *paymentType) {
        [self hideLoadingView];
        if (!errorCode) {
            if ([paymentInfo.status isEqual:@2]) {
                [self showStep:2];
            }
        }
    }];
}

- (void)getWechatPayResult:(NSNotification *)notification {
    if ([notification.object isEqualToString:@"success"]) {
        LogDebug(@"支付成功");
    } else {
        LogDebug(@"支付失败");
    }
    
    [self getPaymentStatusWithPaymentID:_paymentInfo.paymentId andPaymentType:[NSNumber numberWithUnsignedInteger:WechatPaymentType]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _isUnfoldMorePaymentType ? _paymentTypes.count : _paymentTypes.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    if (_isUnfoldMorePaymentType) {
        return paymentTypeTableViewCellHeight;
    } else {
        return indexPath.row == 1 ? selectOtherTypeTableViewCellHeight : paymentTypeTableViewCellHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
                [_authenticateTableView reloadData];
            }
        }
    } else {
        if (indexPath.row == 1) {
            _isUnfoldMorePaymentType = YES;
            _paymentTypes = [PaymentFuncs allPaymentTypes];
            [_authenticateTableView reloadData];
        }
    }
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
