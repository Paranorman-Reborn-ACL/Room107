//
//  Room107ViewController.m
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107ViewController.h"
#import "AuthenticateViewController.h"
#import "SearchTipLabel.h"
#import "SCGIFImageView.h"
#import "HistoryBalanceViewController.h"
#import "Room107GradientLayer.h"
#import "NSNumber+Additions.h"
#import "SystemAgent.h"
#import "Room107UserDefaults.h"
#import "SendPaperContractViewController.h"
#import "CustomButton.h"
#import "OnlineContractCommitmentViewController.h"
#import "CustomImageView.h"
#import "PopImageAdsView.h"
#import "NSString+Encoded.h"
#import "LoginAndRegisterViewController.h"

static CGFloat loadingViewDuration = 1.0; //定时器时长

@interface Room107ViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *leftButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightButtonItem;
@property (nonatomic) HeaderType headerType;
@property (nonatomic, strong) SearchTipLabel *contentLabel;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) void (^alertCompletionHandler)(void);
@property (nonatomic, strong) UIAlertView *appealsBreachAlertView;
@property (nonatomic, strong) NSDictionary *messageInfo;
@property (nonatomic, strong) CustomImageView *networkFailedImageView;
@property (nonatomic, strong) void (^viewDidRefreshHandler)();
@property (nonatomic, strong) NSTimer *loadingViewTimer; //loading的定时器
@property (nonatomic, strong) SCGIFImageView *loadingImageView;
@property (nonatomic) NSTimeInterval beginLoadingTime; //loading的起始时间点

@end

@implementation Room107ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor room107ViewBackgroundColor]];
    //控制右滑区域大小
    self.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge = 50;
    
    NSArray *appPopups = [[SystemAgent sharedInstance] getPopupPropertiesFromLocal];
    for (AppPopupModel *appPopup in appPopups) {
        NSURL *url = [NSURL URLWithString:appPopup.activatedUri];
        if ([[url scheme] isEqualToString:@"room107"]) {
            NSString *module = [url host];
            NSString *fragment = [url fragment];
            if (fragment && ![fragment isEqualToString:@""]) {
                module = [module stringByAppendingFormat:@"#%@", fragment];
            }
            if ([self isKindOfClass:[[[NXURLHandler sharedInstance] viewControllerFromModule:module] class]]) {
                if ([self isKindOfClass:[OnlineContractCommitmentViewController class]]) {
                    if ([(OnlineContractCommitmentViewController *)self onlineContractCommitmentViewType] == OnlineContractCommitmentViewTypeManage) {
                        break;
                    }
                }
                
                NSString *popupKey = [NSStringFromClass([self class]) stringByAppendingFormat:@"id%@type%@", appPopup.id, appPopup.type];
                id object = [Room107UserDefaults getValueFromUserDefaultsWithKey:popupKey];
                //frequency，频率，必填，0表示首次弹出，1表示每次弹出，type，弹窗类型，0表示文本弹窗，1表示图片弹窗
                if (([appPopup.frequency isEqual:@1] || ![object isEqual:@1])) {
                    [Room107UserDefaults saveUserDefaultsWithKey:popupKey andValue:@1];
                    WEAK_SELF weakSelf = self;
                    WEAK(appPopup) weakAppPopup = appPopup;
                    if ([appPopup.type isEqual:@0]) {
                        //文本弹窗
                        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"OK") action:^{
                            //目标页面，为空表示不跳转
                            if (weakAppPopup.targetUri && ![weakAppPopup.targetUri isEqualToString:@""]) {
                                NSString *schemeUrl = [weakSelf schemeUrlFromAppPopup:weakAppPopup];
                                [[NXURLHandler sharedInstance] handleOpenURL:schemeUrl params:nil context:weakSelf];
                            }
                        }];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appPopup.title message:appPopup.popupDescription cancelButtonItem:nil otherButtonItems:otherButtonItem, nil];
                        [alert show];
                    } else if ([appPopup.type isEqual:@1]) {
                        //图片弹窗
                        NSString *schemeUrl = [self schemeUrlFromAppPopup:weakAppPopup];
                        PopImageAdsView *popImageAdsView = [[PopImageAdsView alloc] initWithAdsImageURL:appPopup.image andHtmlURL:schemeUrl];
                        
                        [popImageAdsView setAdsImageDidClickHandler:^(NSString *htmlURL) {
                            if (weakAppPopup.targetUri && ![weakAppPopup.targetUri isEqualToString:@""]) {
                                [[NXURLHandler sharedInstance] handleOpenURL:htmlURL params:nil context:weakSelf];
                            }
                        }];
                    }
                }
                break;
            }
        }
    }
}

- (NSString *)schemeUrlFromAppPopup:(AppPopupModel *)appPopup {
    return [NSString stringWithFormat:@"%@?url=%@&title=%@&authority=%@", appPopup.targetUri ? appPopup.targetUri : @"", appPopup.targetParams ? appPopup.targetParams[@"url"] ? appPopup.targetParams[@"url"] : @"" : @"", appPopup.targetParams ? appPopup.targetParams[@"title"] ? appPopup.targetParams[@"title"] : @"" : @"", appPopup.targetParams ? appPopup.targetParams[@"authority"] ? appPopup.targetParams[@"authority"] : @"none" : @"none"];
}

/*
 URLParams:{
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:CurrentViewControllerDidChangeNotification object:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setHeaderType:(HeaderType)type {
    _headerType = type;
    
    if (HeaderTypeGreenBack == _headerType || HeaderTypeWhiteBack == _headerType) {
        CGFloat originX = 11;
        CGFloat originY = statusBarHeight;
        CGFloat buttonWidth = 22.0f;
        originY += (navigationBarHeight - buttonWidth) / 2;
        CustomButton *leftButton = [[CustomButton alloc] initWithFrame:(CGRect){originX, originY, buttonWidth, buttonWidth}];
        [leftButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [leftButton.titleLabel setFont:[UIFont room107FontFour]];
        [leftButton setTitleColor:HeaderTypeGreenBack == _headerType ? [UIColor room107GreenColor] : [UIColor whiteColor] forState:UIControlStateNormal];
        [leftButton setTitle:@"\ue60c" forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(leftButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:leftButton];
    }
}

- (IBAction)leftButtonDidClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (CGFloat)originX {
    return 22;
}

- (CGFloat)spacingY {
    return 8;
}

- (CGFloat)heightOfNavigationBar {
    return 0;
}

- (CGFloat)heightOfSegmentedControl {
    return 40;
}

- (CGFloat)heightOfTradingProcessView {
    return navigationBarHeight + [self spacingY] + 2 * [self spacingY];
}

- (void)refreshData {
    
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    
}

- (void)setRightBarButtonTitle:(NSString *)title {
    if (!title) {
        _rightButtonItem = nil;
    } else {
        if (title.length == 1) {
            _rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage makeImageFromText:title font:[UIFont room107FontFour] color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonDidClick:)];
        } else {
            _rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonDidClick:)];
        }
    }
    self.navigationItem.rightBarButtonItem = _rightButtonItem;
}

- (void)pushLoginAndRegisterViewController {
    [Room107UserDefaults clearUserDefaults];
    LoginAndRegisterViewController *loginAndRegisterViewController = [[LoginAndRegisterViewController alloc] init];
    loginAndRegisterViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginAndRegisterViewController animated:YES];
}

- (void)pushAuthenticateViewController {
    AuthenticateViewController *authenticateViewController = [[AuthenticateViewController alloc] init];
    authenticateViewController.hidesBottomBarWhenPushed = YES; //具体到每一次push都需要设置
    [self.navigationController pushViewController:authenticateViewController animated:YES];
}

- (BOOL)pushViewController:(UIViewController *)viewControllerToPush {
    NSArray *viewControllers = @[@"LoginAndRegisterViewController", @"HouseSearchViewController", @"HouseSubscribesViewController", @"HouseDetailViewController", @"HomeViewController", @"SuggestionViewController", @"MessageCenterViewController", @"MessageSublistViewController", @"MessageDetailViewController", @"NXWebViewController", @"AboutViewController", @"OnlineContractCommitmentViewController", @"HelpCenterViewController"]; //无登录权限的窗口类
    
    if (([viewControllers indexOfObject:NSStringFromClass([viewControllerToPush class])] < maxUInteger) || [[AppClient sharedInstance] isLogin]) {
        viewControllerToPush.hidesBottomBarWhenPushed = YES; //具体到每一次push都需要设置
        [self.navigationController pushViewController:viewControllerToPush animated:YES];
        
        return YES;
    } else {
       [self pushLoginAndRegisterViewController];
        
       return NO;
    }
}

- (BOOL)isLoginStateError:(NSNumber *)errorCode {
    if ([errorCode unsignedIntegerValue] == unLoginCode) {
        [self pushLoginAndRegisterViewController];
        return YES;
    } else if ([errorCode unsignedIntegerValue] == unAuthenticateCode) {
        [self pushAuthenticateViewController];
        return YES;
    }
    
    return NO;
}

- (UILabel *)showContent:(NSString *)content withFrame:(CGRect)frame {
    if (!_contentLabel) {
        _contentLabel = [[SearchTipLabel alloc] init];
        [_contentLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_contentLabel];
    }
    [_contentLabel setFrame:frame];
    _contentLabel.hidden = NO;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    paragraphStyle.alignment = _contentLabel.textAlignment;
    NSDictionary *attributes = @{NSFontAttributeName:_contentLabel.font,
                                 NSParagraphStyleAttributeName:paragraphStyle};
    _contentLabel.attributedText = [[NSAttributedString alloc] initWithString:content ? content : @"" attributes:attributes];
    [self.view bringSubviewToFront:_contentLabel];
    
    return _contentLabel;
}

- (void)showNetworkFailedWithFrame:(CGRect)frame andRefreshHandler:(void(^)())handler {
    [self showErrorViewWithFrame:frame];
    [_networkFailedImageView setImageWithName:@"networkFailed.png"];
    _viewDidRefreshHandler = handler;
}

- (void)showUnknownErrorWithFrame:(CGRect)frame andRefreshHandler:(void(^)())handler {
    [self showErrorViewWithFrame:frame];
    [_networkFailedImageView setImageWithName:@"unknownError.png"];
    _viewDidRefreshHandler = handler;
}

- (void)showErrorViewWithFrame:(CGRect)frame {
    if (!_networkFailedImageView) {
        _networkFailedImageView = [[CustomImageView alloc] initWithFrame:(CGRect){0, 0, 80, 116}];
        [self.view addSubview:_networkFailedImageView];
        
        _networkFailedImageView.userInteractionEnabled = YES ;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewControllerWillRefresh)];
        [_networkFailedImageView addGestureRecognizer:tapGesture];
    }
    
    _networkFailedImageView.hidden = NO;
    _networkFailedImageView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
}

- (void)viewControllerWillRefresh {
    [self hideNetworkFailedImageView];
    
    if (_viewDidRefreshHandler) {
        _viewDidRefreshHandler();
    }
}

- (void)hideNetworkFailedImageView {
    _networkFailedImageView.hidden = YES;
}

- (void)createLoadingView {
    //网络加载Loading
    CGRect frame = [[UIScreen mainScreen] bounds];
    _loadingView = [[UIView alloc] initWithFrame:frame];
    Room107GradientLayer *gradientLayer = [[Room107GradientLayer alloc] initWithFrame:[_loadingView bounds] andStartAlpha:0.3f andEndAlpha:0.3f];
    [_loadingView.layer insertSublayer:gradientLayer atIndex:0];
    _loadingView.hidden = YES;
    [[App window] addSubview:_loadingView]; //铺满整个屏幕
}

- (void)showLoadingView {
    if (!_loadingView) {
        [self createLoadingView];
    }

    [[App window] bringSubviewToFront:_loadingView];
    _loadingView.hidden = NO;
    
    if (!_loadingViewTimer) {
        //1s内读取完毕，无loading，1s后还在读取，出现loading
        _loadingViewTimer = [NSTimer scheduledTimerWithTimeInterval:loadingViewDuration target:self selector:@selector(showLoadingImageView) userInfo:nil repeats:NO];
    }
}

- (void)showLoadingImageView {
    if (!_loadingImageView) {
        CGFloat imageViewWidth = 100;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"loading.gif" ofType:nil];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        _loadingImageView = [[SCGIFImageView alloc] initWithFrame:(CGRect){0, 0, imageViewWidth, imageViewWidth}];
        //为loading动画View添加圆角 防止四角出现黑色
        [_loadingImageView setBackgroundColor:[UIColor clearColor]];
        _loadingImageView.layer.cornerRadius = 5.0f;
        _loadingImageView.layer.masksToBounds = YES ;
        _loadingImageView.center = CGPointMake(_loadingView.frame.size.width / 2, _loadingView.frame.size.height / 2);
        [_loadingImageView setData:imageData];
        [_loadingView addSubview:_loadingImageView];
    }
    _loadingImageView.hidden = NO;
    _beginLoadingTime = [[NSDate date] timeIntervalSince1970];
}

- (void)hideLoadingView {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    double timeValue = time - _beginLoadingTime;
    if (timeValue >= 0.5) {
        _loadingView.hidden = YES;
        _loadingImageView.hidden = YES;
        
        [_loadingViewTimer invalidate];
        _loadingViewTimer = nil;
    } else {
        //开始loading后，未超过0.5s则补到0.5s
        [NSTimer scheduledTimerWithTimeInterval:0.5 - timeValue target:self selector:@selector(hideLoadingView) userInfo:nil repeats:NO];
    }
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:lang(@"OK"), nil];
    [alert show];
}

- (void)showServerErrorWithMessage:(NSString *)message {
    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"OK") action:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil cancelButtonItem:nil otherButtonItems:otherButtonItem, nil];
    [alert show];
}

//开启或禁用返回手势
- (void)enabledPopGesture:(BOOL)enabled {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = enabled;
    }
}

- (CGFloat)menuWidth {
    return 100;
}

- (CGFloat)menuOriginX {
    return self.view.frame.size.width - 11 - [self menuWidth];
}

- (void)viewTenantExplanation {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/explanation/tenant"], @"title":lang(@"TenantExplanation")} context:self];
}

- (void)viewLandlordExplanation {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/explanation/renting"], @"title":lang(@"LandlordExplanation")} context:self];
}

- (void)viewPricingRules {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/explanation/insurance"], @"title":lang(@"PricingRules")} context:self];
}

- (void)viewContractBycontractID:(NSNumber *)contractID {
    NSString *url = [[[AppClient sharedInstance] baseDomain] stringByAppendingFormat:@"/app/html/contract/?contractId=%@", contractID];
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":url, @"title":lang(@"ViewContract")} context:self];
}

- (void)sendContractBycontractID:(NSNumber *)contractID {
    SendPaperContractViewController *sendContractViewController = [[SendPaperContractViewController alloc] initWithContractId:contractID];
    sendContractViewController.hidesBottomBarWhenPushed = YES; //具体到每一次push都需要设置
    [self.navigationController pushViewController:sendContractViewController animated:YES];
}

- (void)viewHistoryPayment {
    HistoryBalanceViewController *historyBalanceController = [[HistoryBalanceViewController alloc] init];
    [historyBalanceController setTitle:lang(@"HistoryBalance")];
    historyBalanceController.hidesBottomBarWhenPushed = YES; //具体到每一次push都需要设置
    [self.navigationController pushViewController:historyBalanceController animated:YES];
}

- (void)viewContractHistoryPaymentBycontractID:(NSNumber *)contractID {
    HistoryBalanceViewController *historyBalanceController = [[HistoryBalanceViewController alloc] initWithContractID:contractID];
    [historyBalanceController setTitle:lang(@"HistoryPayment")];
    historyBalanceController.hidesBottomBarWhenPushed = YES; //具体到每一次push都需要设置
    [self.navigationController pushViewController:historyBalanceController animated:YES];
}

- (void)viewRepairExplanation {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/explanation/repair"], @"title":lang(@"RepairExplanation")} context:self];
}

- (void)viewAppealsBreach {
    if (!_appealsBreachAlertView) {
        _appealsBreachAlertView = [[UIAlertView alloc] initWithTitle:lang(@"AppealsBreachTips")
                                                                    message:[[SystemAgent sharedInstance] getPropertiesFromLocal].supportPhone
                                                                        delegate:self
                                                               cancelButtonTitle:lang(@"Cancel")
                                                            otherButtonTitles:lang(@"Dial"), nil];
    }
    [_appealsBreachAlertView show];
}

- (void)viewSignExplanation {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/explanation/contract"], @"title":lang(@"SignExplanation")} context:self];
}

- (void)viewProtocalExplanation {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/explanation/protocal"], @"title":lang(@"ProtocalExplanation")} context:self];
}

- (void)viewMonthlyPaymentExplanation {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/explanation/monthlyPayment"], @"title":lang(@"MonthlyPaymentExplanation")} context:self];
}

- (void)viewWalletExplanation {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/explanation/wallet"], @"title":lang(@"WalletExplanation")} context:self];
}

- (void)viewPaymentExplanation {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/explanation/payment"], @"title":lang(@"PaymentExplanation")} context:self];
}

- (void)viewAnxinyuExplanation {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/explanation/anxinyu"], @"title":lang(@"RelievedHouse")} context:self];
}

- (void)viewSupportCenter {
    [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:@{@"url":[[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/supportCenter/menu"], @"title":lang(@"SupportCenter")} context:self];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([alertView isEqual:_appealsBreachAlertView]) {
            [CommonFuncs callTelephone:[[SystemAgent sharedInstance] getPropertiesFromLocal].supportPhone];
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
