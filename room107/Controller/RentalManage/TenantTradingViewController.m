//
//  TenantTradingViewController.m
//  room107
//
//  Created by ningxia on 15/8/13.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "TenantTradingViewController.h"
#import "SignedProcessAgent.h"
#import "TenantTradingFillInViewController.h"
#import "TenantTradingContractConfirmViewController.h"
#import "TradingAuditStatusViewController.h"
#import "TenantContractManageViewController.h"
#import "RightMenuView.h"
#import "RightMenuViewItem.h"

@interface TenantTradingViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSNumber *houseID;
@property (nonatomic, strong) NSNumber *roomID;
@property (nonatomic) BOOL isInterest;
@property (nonatomic) BOOL isRelet; //是否为租客续租
@property (nonatomic, strong) NSNumber *contractID;
@property (nonatomic, strong) UserIdentityModel *userIdentity;
@property (nonatomic, strong) ContractInfoModel *contractInfo;
@property (nonatomic, strong) NSArray *diff;
@property (nonatomic, strong) TenantTradingFillInViewController *firstStep;
@property (nonatomic, strong) TenantTradingContractConfirmViewController *secondStep;
@property (nonatomic, strong) TradingAuditStatusViewController *thirdStep;
@property (nonatomic, strong) UIAlertView *inputPasswordAlertView;
@property (nonatomic, strong) RightMenuView *rightMenuItem; //右上角黑色下拉按钮

@end

@implementation TenantTradingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"TenantSign")];
    
    [self tenantGetContractStatus];
}

- (void)tenantGetContractStatus {
    [self showLoadingView];
    if (_isRelet) {
        //租客续租
        [[SignedProcessAgent sharedInstance] tenantReletContractWithContractID:_contractID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo) {
            [self hideLoadingView];
            [self showContractStepWithErrorTitle:errorTitle andErrorMsg:errorMsg andErrorCode:errorCode andContractStatus:contractStatus andContractEditStatus:contractEditStatus andUserIdentity:userIdentity andContractInfo:contractInfo andDiff:nil andAuditNote:nil];
        }];
    } else {
        //租客正常签约
        [[SignedProcessAgent sharedInstance] tenantGetContractStatusWithHouseID:_houseID andRoomID:_roomID andContractID:_contractID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo, NSArray *diff, NSString *auditNote) {
            [self hideLoadingView];
            [self showContractStepWithErrorTitle:errorTitle andErrorMsg:errorMsg andErrorCode:errorCode andContractStatus:contractStatus andContractEditStatus:contractEditStatus andUserIdentity:userIdentity andContractInfo:contractInfo andDiff:diff andAuditNote:auditNote];
        }];
    }
}

- (void)showContractStepWithErrorTitle:(NSString *)errorTitle andErrorMsg:(NSString *)errorMsg andErrorCode:(NSNumber *)errorCode andContractStatus:(NSNumber *)contractStatus andContractEditStatus:(NSNumber *)contractEditStatus andUserIdentity:(UserIdentityModel *)userIdentity andContractInfo:(ContractInfoModel *)contractInfo andDiff:(NSArray *)diff andAuditNote:(NSString *)auditNote {
    if (errorTitle || errorMsg) {
        [PopupView showTitle:errorTitle message:errorMsg];
    }
                
    if (!errorCode) {
        if ([contractStatus isEqual:@3] || [contractStatus isEqual:@4]) {
            [self showAlertViewWithTitle:lang(@"AuditRefused") message:nil];
            return;
        }
        
        if (!_isInterest) {
            [self showAlertViewWithTitle:lang(@"JoinedBeSignedListTitle") message:lang(@"JoinedBeSignedListMessage")];
        }
        
        _userIdentity = userIdentity ? userIdentity : _userIdentity;
        _contractInfo = contractInfo ? contractInfo : [ContractInfoModel createObject];
        _diff = diff;
        if (_userIdentity) {
            _contractInfo.tenantIdCard = _userIdentity.idCard;
            _contractInfo.tenantName = _userIdentity.name;
        }
        
        switch ([contractEditStatus integerValue]) {
            case 0:
            case 1:
                [self showStepForIndex:[contractEditStatus integerValue] animated:NO];
                if ([contractEditStatus isEqual:@0]) {
                    [_firstStep setContractInfo:_contractInfo];
                } else {
                    [_secondStep setContractInfo:_contractInfo andDifferent:_diff];
                    _diff = nil;
                }
                break;
            default:
                [self showStepForIndex:2 animated:NO];
                [_thirdStep setAuditNote:auditNote];
                if ([contractEditStatus integerValue] > 3) {
                    [_thirdStep setStatus:2];
                } else {
                    [self setThirdStepStatus:contractStatus];
                }
                break;
        }
    } else {
        if ([self isLoginStateError:errorCode]) {
            return;
        }
        
        self.tradingProcessView.hidden = YES;
        if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
            [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                [self tenantGetContractStatus];
            }];
        } else {
            [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                [self tenantGetContractStatus];
            }];
        }
    }
}

/**
 *  创建右侧batbuttom下拉菜单
 */
- (void)creatRightMenu {
//    self.menuItem = [[MenuView alloc]init];
//    [self.menuItem addButtonTitleArray:@[lang(@"TenantExplanation"),lang(@"ViewContract")] buttonColor:[UIColor room107GreenColor] textFont:[UIFont room107SystemFontThree]];
//    self.menuItem.delegate = self;
//    [self.view addSubview:self.menuItem];
//    [self.view bringSubviewToFront:self.menuItem];
    //租客须知
    RightMenuViewItem *viewtenantExplanationItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"TenantExplanation") clickComplete:^{
        [self viewTenantExplanation];
    }];
    //查看合同
    RightMenuViewItem *tenantExplanationItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"ViewContract") clickComplete:^{
        [self viewContractBycontractID:_contractInfo.contractId];
    }];
    self.rightMenuItem = [[RightMenuView alloc] initWithItems:@[viewtenantExplanationItem, tenantExplanationItem] itemHeight:40];
    [self.view addSubview:_rightMenuItem];

}

- (void)setThirdStepStatus:(NSNumber *)contractStatus {
    //status 审核状态：0、正在审核中；1、审核成功；2、审核失败，3、审核彻底失败
    switch ([contractStatus integerValue]) {
        case 2:
        case 3:
        case 4:
        case 6:
            [_thirdStep setStatus:2];
            break;
        case 5:
            [_thirdStep setStatus:3];
            break;
        default:
            [_thirdStep setStatus:[contractStatus integerValue]];
            break;
    }
}

- (id)initWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID isInterest:(BOOL)isInterest {
    self = [super init];
    if (self != nil) {
        _houseID = houseID;
        _roomID = roomID;
        _isInterest = isInterest;
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
    _isRelet = [URLParams[@"isRelet"] boolValue];
    _isInterest = !_isRelet;
}

- (void)showStepForIndex:(NSInteger)index animated:(BOOL)animated {
    [super showStepForIndex:index animated:animated];
    
    if (index > 0) {
        [self setRightBarButtonTitle:lang(@"More")];
    } else {
        [self setRightBarButtonTitle:lang(@"TenantExplanation")];
    }
}

//跳到合同确认页面
- (void)stepConfirmContract {
    WEAK_SELF weakSelf = self;
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setValue:weakSelf.contractInfo.contractId forKey:@"contractId"];
    [info setValue:weakSelf.houseID forKey:@"houseId"];
    [info setValue:weakSelf.roomID forKey:@"roomId"];
    [info setValue:weakSelf.contractInfo.tenantName forKey:@"name"];
    [info setValue:weakSelf.contractInfo.tenantIdCard forKey:@"idCard"];
    [info setValue:weakSelf.contractInfo.checkinTime forKey:@"checkinTime"];
    [info setValue:weakSelf.contractInfo.exitTime forKey:@"exitTime"];
    [info setValue:weakSelf.contractInfo.payingType forKey:@"payingType"];
    [info setValue:weakSelf.contractInfo.tenantMoreinfo forKey:@"moreinfo"];
    
    [weakSelf showLoadingView];
    [[SignedProcessAgent sharedInstance] tenantUpdateContractWithInfo:info completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo) {
        [weakSelf hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            [weakSelf saveUserIdentity:userIdentity contractInfo:contractInfo];
            [weakSelf showStepForIndex:1 animated:YES];
            [weakSelf.secondStep setContractInfo:weakSelf.contractInfo andDifferent:weakSelf.diff];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (NSArray *)stepViewControllers {
    _firstStep = [[TenantTradingFillInViewController alloc] init];
    WEAK_SELF weakSelf = self;
    [_firstStep setVerifyButtonDidClickHandler:^{
        
        [weakSelf showLoadingView];
        //点击确认 让服务器判断是否为整月 如是 下一步(StepConfirmContract) 如不是 弹弹窗
        [[SignedProcessAgent sharedInstance] tenantGetContractPeriodWithCheckTime:weakSelf.contractInfo.checkinTime andExitTime:weakSelf.contractInfo.exitTime completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *year, NSNumber *month, NSNumber *day, NSString *finishDate, NSString *title, NSString *content) {
            [weakSelf hideLoadingView];

            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
                
            if (!errorCode) {
                if ([day isEqual:@(0)]) {
                    //没有推荐日期，继续跳到合同确认页面
                    [weakSelf stepConfirmContract];
                } else {
                    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
                    }];
                    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
                        //点击确认 继续跳到合同确认页面
                        [weakSelf stepConfirmContract];
                    }];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
                    [alert show];
                }
            } else {
                if ([weakSelf isLoginStateError:errorCode]) {
                    return;
                }
                
                
            }
        }];
    }];
    
    _secondStep = [[TenantTradingContractConfirmViewController alloc] init];
    [_secondStep setConfirmContractButtonDidClickHandler:^{
        if (!weakSelf.inputPasswordAlertView) {
            weakSelf.inputPasswordAlertView = [[UIAlertView alloc] initWithTitle:lang(@"InputLoginPassword")
                                                                         message:lang(@"")
                                                                        delegate:weakSelf
                                                               cancelButtonTitle:lang(@"Cancel")
                                                               otherButtonTitles:lang(@"Confirm"), nil];
            weakSelf.inputPasswordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
            [[weakSelf.inputPasswordAlertView textFieldAtIndex:0] setTintColor:[UIColor room107GreenColor]];
            [[weakSelf.inputPasswordAlertView textFieldAtIndex:0] becomeFirstResponder];
        }
        [[weakSelf.inputPasswordAlertView textFieldAtIndex:0] setText:@""];
        [weakSelf.inputPasswordAlertView show];
    }];
    
    [_secondStep setChangeContractButtonDidClickHandler:^{
        [weakSelf showStepForIndex:0 animated:YES];
        [weakSelf.firstStep setContractInfo:weakSelf.contractInfo];
    }];
    
    _thirdStep = [[TradingAuditStatusViewController alloc] init];
    [_thirdStep setRent:YES];
    [_thirdStep setChangeContractButtonDidClickHandler:^{
        [weakSelf showStepForIndex:0 animated:YES];
        [weakSelf.firstStep setContractInfo:weakSelf.contractInfo];
    }];
    
    [_thirdStep setManageButtonDidClickHandler:^{
        TenantContractManageViewController *tenantContractManageViewController = [[TenantContractManageViewController alloc] initWithContractID:weakSelf.contractInfo.contractId andSelectedIndex:0];
        [weakSelf.navigationController pushViewController:tenantContractManageViewController animated:YES];
    }];
    
    [_thirdStep setSendContractButtonDidClickHandler:^{
        [weakSelf sendContractBycontractID:weakSelf.contractInfo.contractId];
    }];
    
    return @[_firstStep, _secondStep, _thirdStep];
}

- (void)saveUserIdentity:(UserIdentityModel *)userIdentity contractInfo:(ContractInfoModel *)contractInfo {
    _userIdentity = userIdentity ? userIdentity : _userIdentity;
    _contractInfo = contractInfo ? contractInfo : _contractInfo;
}

- (NSArray *)stepTitles {
    return @[lang(@"CompleteInfo"), lang(@"ContractConfirm"), lang(@"SignedAudit")];
}

- (void)finishedAllSteps {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)canceled {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    if ([self currentStep] > 0) {
        if (!self.rightMenuItem) {
            [self creatRightMenu];
        } else {
            if (self.rightMenuItem.hidden) {
                [self.rightMenuItem showMenuView];
            }else {
                [self.rightMenuItem dismissMenuView];
            }
        }
    } else {
        [self viewTenantExplanation];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([alertView isEqual:_inputPasswordAlertView]) {
            if ([[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
                [PopupView showMessage:lang(@"InvalidPassword")];
                return;
            }
            
            [self showLoadingView];
            [[SignedProcessAgent sharedInstance] tenantConfirmContractWithContractID:_contractInfo.contractId andPassword:[[alertView textFieldAtIndex:0] text] completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo) {
                [self hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                    
                if (!errorCode) {
                    [self saveUserIdentity:userIdentity contractInfo:contractInfo];
                    [self showStepForIndex:2 animated:YES];
                    [self setThirdStepStatus:contractStatus];
                }
            }];
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
