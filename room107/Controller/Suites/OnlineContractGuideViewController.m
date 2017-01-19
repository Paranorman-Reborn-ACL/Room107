//
//  OnlineContractGuideViewController.m
//  room107
//
//  Created by 107间 on 16/3/2.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "OnlineContractGuideViewController.h"
#import "CustomImageView.h"
#import "CustomButton.h"
#import "RoundedGreenButton.h"
#import "InterestListItemModel.h"
#import "AppTextModel.h"
#import "SystemAgent.h"
#import "AuthenticationAgent.h"
#import "TenantTradingViewController.h"

@interface OnlineContractGuideViewController ()

@property (nonatomic, strong) NSNumber *houseID;
@property (nonatomic, strong) NSNumber *roomID;
@property (nonatomic) BOOL isInterest;
@property (nonatomic) BOOL isRelet; //是否为租客续租
@property (nonatomic) BOOL isOnlineSigned; //是否为线上签约
@property (nonatomic, strong) NSNumber *contractID;

@end

@implementation OnlineContractGuideViewController

- (id)initWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID isInterest:(BOOL)isInterest isOnlineSigned:(BOOL)isOnlineSigned {
    self = [super init];
    if (self != nil) {
        _houseID = houseID;
        _roomID = roomID;
        _isInterest = isInterest;
        _isOnlineSigned = isOnlineSigned;
        _isRelet = NO;
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
    _houseID = URLParams[@"houseId"];
    _roomID = URLParams[@"roomId"];
    _isOnlineSigned = [URLParams[@"isOnlineSigned"] boolValue];
    _isRelet = [URLParams[@"isRelet"] boolValue];
    _isInterest = !_isRelet;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"OnlineAgreement")];
    
    UIScrollView *bgScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    bgScrollView.showsVerticalScrollIndicator= NO;
    [self.view addSubview:bgScrollView];
    
    UIImage *image = [UIImage imageNamed:@"guide"];
    CGFloat imageWidth = self.view.frame.size.width;
    CGFloat imageHeight = imageWidth * image.size.height/image.size.width;
    CustomImageView *serviceGuideImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
    [serviceGuideImageView setImageWithName:@"guide"];
    [bgScrollView addSubview:serviceGuideImageView];
    
    CustomButton *learnMoreButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [learnMoreButton setFrame:CGRectMake(11, CGRectGetMaxY(serviceGuideImageView.frame), imageWidth - 22, 20)];
    //按钮内容靠右显示
    [learnMoreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [learnMoreButton setTitle:[lang(@"LearnMore") stringByAppendingString:@">>"] forState:UIControlStateNormal];
    [learnMoreButton.titleLabel setFont:[UIFont room107SystemFontTwo]];
    [learnMoreButton addTarget:self action:@selector(learnMoreButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgScrollView addSubview:learnMoreButton];
    
    CGFloat originX = 11.0;
    RoundedGreenButton *bottomNextStepButton = [[RoundedGreenButton alloc]initWithFrame:CGRectMake(originX, CGRectGetMaxY(learnMoreButton.frame) + originX*2, imageWidth - originX * 2 , 53)];
    [bottomNextStepButton setBackgroundColor:[UIColor room107GreenColor]];
    [bottomNextStepButton.titleLabel setFont:[UIFont room107FontFour]];
    [bottomNextStepButton setTitle:lang(@"ApplyForOnlieContract") forState:UIControlStateNormal];
    [bgScrollView addSubview:bottomNextStepButton];
    [bottomNextStepButton addTarget:self action:@selector(nextStepButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgScrollView setContentSize:CGSizeMake(0, CGRectGetMaxY(bottomNextStepButton.frame) + 44 + navigationBarHeight + statusBarHeight)];
}

- (IBAction)learnMoreButtonDidClick:(id)sender {
    [self viewSignExplanation];
}

- (IBAction)nextStepButtonDidClick:(id)sender {
    if (_isOnlineSigned) {
        if (![[AppClient sharedInstance] isLogin]) {
            //未登录
            [self pushLoginAndRegisterViewController];
            return;
        }
        
        [self showLoadingView];
        [[AuthenticationAgent sharedInstance] getUserInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserInfoModel *userInfo, SubscribeModel *subscribe) {
            [self hideLoadingView];
            
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
                
            if (!errorCode) {
                if (![[AppClient sharedInstance] isAuthenticated]) {
                    //未认证
                    [self pushAuthenticateViewController];
                } else {
                    //签约流程
                    TenantTradingViewController *tenantTradingViewController = [[TenantTradingViewController alloc] initWithHouseID:_houseID andRoomID:_roomID isInterest:_isInterest];
                    [self.navigationController pushViewController:tenantTradingViewController animated:YES];
                }
            } else {
                if ([self isLoginStateError:errorCode]) {
                    return;
                }
            }
        }];
    } else {
        //不可线上签约
        AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@11];
        if (!appText) {
            [[SystemAgent sharedInstance] getTextPropertiesFromServer];
            return;
        }
        [self showAlertViewWithTitle:appText.title message:appText.text];
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
