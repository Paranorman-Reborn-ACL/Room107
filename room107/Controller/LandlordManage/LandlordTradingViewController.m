//
//  LandlordTradingViewController.m
//  room107
//
//  Created by ningxia on 15/8/13.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LandlordTradingViewController.h"
#import "SignedProcessAgent.h"
#import "LandlordTradingFillInViewController.h"
#import "LandlordTradingContractConfirmViewController.h"
#import "TradingAuditStatusViewController.h"
#import "LandlordContractManageViewController.h"
#import "RightMenuViewItem.h"
#import "RightMenuView.h"

@interface LandlordTradingViewController ()

@property (nonatomic, strong) NSNumber *houseID;
@property (nonatomic, strong) NSNumber *contractID;
@property (nonatomic, strong) UserIdentityModel *userIdentity;
@property (nonatomic, strong) ContractInfoModel *contractInfo;
@property (nonatomic, strong) NSArray *diff;
@property (nonatomic, strong) LandlordTradingFillInViewController *firstStep;
@property (nonatomic, strong) LandlordTradingContractConfirmViewController *secondStep;
@property (nonatomic, strong) TradingAuditStatusViewController *thirdStep;
@property (nonatomic, strong) UIAlertView *discardContractAlertView;
@property (nonatomic, strong) RightMenuView *secondMenu;
@property (nonatomic, strong) RightMenuView *thirdMenu;

@end

@implementation LandlordTradingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"LandlordSign")];
    
    [self landlordGetContractStatus];
}

- (void)landlordGetContractStatus {
    [self showLoadingView];
    [[SignedProcessAgent sharedInstance] landlordGetContractStatusWithContractID:_contractID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo, NSArray *diff, NSString *auditNote) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            if ([contractStatus isEqual:@3] || [contractStatus isEqual:@4]) {
                [self showAlertViewWithTitle:lang(@"AuditRefused") message:nil];
                return;
            }
            
            _userIdentity = userIdentity ? userIdentity : _userIdentity;
            _contractInfo = contractInfo ? contractInfo : [ContractInfoModel createObject];
            _diff = diff;
            if (_userIdentity) {
                _contractInfo.landlordIdCard = _userIdentity.idCard;
                _contractInfo.landlordName = _userIdentity.name;
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
            self.tradingProcessView.hidden = YES;
            if ([self isLoginStateError:errorCode]) {
                return;
            }
            
            if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                    [self landlordGetContractStatus];
                }];
            } else {
                [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                    [self landlordGetContractStatus];
                }];
            }
        }
    }];
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

- (id)initWithContractID:(NSNumber *)contractID {
    self = [super init];
    if (self != nil) {
        _contractID = contractID;
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
}

- (void)showStepForIndex:(NSInteger)index animated:(BOOL)animated {
    [super showStepForIndex:index animated:animated];
    
    if (index > 0) {
        [self setRightBarButtonTitle:lang(@"More")];
    } else {
        [self setRightBarButtonTitle:lang(@"LandlordExplanation")];
    }
}

- (void)saveUserIdentity:(UserIdentityModel *)userIdentity contractInfo:(ContractInfoModel *)contractInfo {
    _userIdentity = userIdentity ? userIdentity : _userIdentity;
    _contractInfo = contractInfo ? contractInfo : _contractInfo;
    //房东签约第一次进去签约页面得到 idcard name 值
    if (_userIdentity) {
        _contractInfo.landlordIdCard = _userIdentity.idCard;
        _contractInfo.landlordName = _userIdentity.name;
    }
}

- (NSArray *)stepViewControllers {
    _firstStep = [[LandlordTradingFillInViewController alloc] init];
    WEAK_SELF weakSelf = self;
    [_firstStep setVerifyButtonDidClickHandler:^{
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setValue:weakSelf.contractInfo.contractId forKey:@"contractId"];
        [info setValue:weakSelf.contractInfo.monthlyPrice forKey:@"price"];
        [info setValue:weakSelf.contractInfo.rentAddress forKey:@"address"];
        [info setValue:weakSelf.contractInfo.landlordMoreinfo forKey:@"moreinfo"];
        
        [weakSelf showLoadingView];
        [[SignedProcessAgent sharedInstance] landlordUpdateContractWithInfo:info completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo) {
            [weakSelf hideLoadingView];
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
                
            if (!errorCode) {
                [weakSelf saveUserIdentity:userIdentity contractInfo:contractInfo];
                [weakSelf showStepForIndex:1 animated:YES];
                [weakSelf.secondStep setContractInfo:weakSelf.contractInfo andDifferent:weakSelf.diff];
            } else {
                if ([weakSelf isLoginStateError:errorCode]) {
                    return;
                }
            }
        }];
    }];
    
    _secondStep = [[LandlordTradingContractConfirmViewController alloc] init];
    [_secondStep setConfirmContractButtonDidClickHandler:^(UserIdentityModel *userIdentity, ContractInfoModel *contractInfo, NSNumber *contractStatus) {
        [weakSelf saveUserIdentity:userIdentity contractInfo:contractInfo];
        [weakSelf showNextStep];
        [weakSelf setThirdStepStatus:contractStatus];
    }];
    
    [_secondStep setChangeContractButtonDidClickHandler:^{
        [weakSelf showStepForIndex:0 animated:YES];
        [weakSelf.firstStep setContractInfo:weakSelf.contractInfo];
    }];
    
    _thirdStep = [[TradingAuditStatusViewController alloc] init];
    [_thirdStep setRent:NO];
    [_thirdStep setChangeContractButtonDidClickHandler:^{
        [weakSelf showStepForIndex:0 animated:YES];
        [weakSelf.firstStep setContractInfo:weakSelf.contractInfo];
    }];
    
    [_thirdStep setManageButtonDidClickHandler:^{
        LandlordContractManageViewController *landlordContractManageViewController = [[LandlordContractManageViewController alloc] initWithContractID:weakSelf.contractInfo.contractId andSelectedIndex:0];
        [weakSelf.navigationController pushViewController:landlordContractManageViewController animated:YES];
    }];
    
    [_thirdStep setSendContractButtonDidClickHandler:^{
        [weakSelf sendContractBycontractID:weakSelf.contractInfo.contractId];
    }];
    
    return @[_firstStep, _secondStep, _thirdStep];
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

- (void)creatSecondRightItem {
    //出租须知
    RightMenuViewItem *landlordExplanationItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"LandlordExplanation") clickComplete:^{
        [self viewLandlordExplanation];
    }];
    //查看合同
    RightMenuViewItem *viewContractItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"ViewContract") clickComplete:^{
        [self viewContractBycontractID:_contractInfo.contractId];
    }];
    //拒绝签约
    RightMenuViewItem *refuseInvitationItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"RefuseInvitation") clickComplete:^{
         [self refuseInvitation];
    }];
    self.secondMenu = [[RightMenuView alloc] initWithItems:@[landlordExplanationItem, viewContractItem, refuseInvitationItem] itemHeight:40];
    [self.view addSubview:_secondMenu];
}

- (void)creatThirdRightItem {
    //出租须知
    RightMenuViewItem *landlordExplanationItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"LandlordExplanation") clickComplete:^{
        [self viewLandlordExplanation];
    }];
    //查看合同
    RightMenuViewItem *viewContractItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"ViewContract") clickComplete:^{
        [self viewContractBycontractID:_contractInfo.contractId];
    }];
    self.thirdMenu = [[RightMenuView alloc] initWithItems:@[landlordExplanationItem, viewContractItem] itemHeight:40];
    [self.view addSubview:_thirdMenu];

}
- (IBAction)rightBarButtonDidClick:(id)sender {
    if ([self currentStep] > 0) {
        if ([self currentStep] == 1) {
            if (!self.secondMenu) {
                [self creatSecondRightItem];
            }
            if (self.secondMenu.hidden) {
                [self.secondMenu showMenuView];
            }else {
                [self.secondMenu dismissMenuView];
            }
        }else if ([self currentStep] == 2) {
            if (!self.thirdMenu) {
                [self creatThirdRightItem];
            }
            if (self.thirdMenu.hidden) {
                [self.thirdMenu showMenuView];
            }else {
                [self.thirdMenu dismissMenuView];
            }
        }
    } else {
        [self viewLandlordExplanation];
    }
}

- (void)refuseInvitation {
    if (!self.discardContractAlertView) {
        self.discardContractAlertView = [[UIAlertView alloc] initWithTitle:lang(@"WhetherRefuseInvitation")
                                                                       message:lang(@"")
                                                                      delegate:self
                                                             cancelButtonTitle:lang(@"Cancel")
                                                             otherButtonTitles:lang(@"Confirm"), nil];
        
        self.discardContractAlertView.alertViewStyle = UIAlertViewStyleDefault;
    }
    
    [self.discardContractAlertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([alertView isEqual:_discardContractAlertView]) {
            [self showLoadingView];
            [[SignedProcessAgent sharedInstance] landlordDiscardContractWithContractID:_contractInfo.contractId completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                [self hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                
                if (!errorCode) {
                    [self.navigationController popViewControllerAnimated:YES];
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
