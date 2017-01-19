//
//  PostSuiteViewController.m
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "PostSuiteViewController.h"
#import "HouseInfoFillInViewController.h"
#import "RoomInfoFillInViewController.h"
#import "AuditStatusForPostViewController.h"
#import "HouseManageAgent.h"
#import "HouseLandlordListViewController.h"

@interface PostSuiteViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSDictionary *district2UserCount;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *imageToken;
@property (nonatomic, strong) NSString *imageKeyPattern;
@property (nonatomic, strong) NSMutableDictionary *houseJSON;//描述房子信息（包含房子信息），json格式，json对应的数据结构为LandlordSuiteItem，json整体进行urlEncode
@property (nonatomic, strong) NSArray *houseKeysArray;
@property (nonatomic, strong) HouseInfoFillInViewController *firstStep;   //房子信息
@property (nonatomic, strong) RoomInfoFillInViewController *secondStep;   //房间信息
@property (nonatomic, strong) AuditStatusForPostViewController *thirdStep;//等待审核
@property (nonatomic, strong) UIViewController *rootViewController;

@end

@implementation PostSuiteViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    
    [self setTitle:lang(@"PostSuite")];
    [self getInfoForAddHouse];
}

//获取发房状态
- (void)getInfoForAddHouse {
    [self showLoadingView];
    [[HouseManageAgent sharedInstance] getInfoForAddHouseWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *district2UserCount, NSString *telephone, NSString *imageToken, NSString *imageKeyPattern) {
        [self hideLoadingView];
        
        NSString *title = lang(@"SuiteDraftTips");
        NSString *message = @"";
        NSString *cancelButtonTitle = lang(@"Cancel");
        NSString *otherTitle = lang(@"Confirm");
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            self.tradingProcessView.hidden = NO;
            
            _district2UserCount = district2UserCount;  //表示区对应找房人数
            _telephone = telephone;     
            _imageToken = imageToken;
            _imageKeyPattern = imageKeyPattern;
            _houseJSON = [[HouseManageAgent sharedInstance] getHouseJSON];  //获取本地房子草稿
            if (!_houseJSON[@"id"]) {
                [_houseJSON setObject:@0 forKey:@"id"];
                [self showSuiteInfo];
            } else {
                RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:cancelButtonTitle action:^{
                    //点击取消 删除草稿
                    _houseJSON = [[NSMutableDictionary alloc] init];
                    [[HouseManageAgent sharedInstance] deleteHouseJSON];
                    [self showSuiteInfo];
                }];
                RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:otherTitle action:^{
                    //点击确认 显示草稿内容
                    [self showSuiteInfo];
                }];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
                [alert show];
            }
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
            
            self.tradingProcessView.hidden = YES;
            if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                    [self getInfoForAddHouse];
                }];
            } else {
                
                [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                    [self getInfoForAddHouse];
                }];
            }
        }
    }];
}

- (void)showSuiteInfo {
    _houseKeysArray = @[@"district", @"position", @[@"roomNumber", @"hallNumber", @"kitchenNumber", @"toiletNumber"], @"area", @"floor", @"suiteDescription", @"facilities", @[@"telephone", @"wechat", @"qq"], @[@"rentType", @"price", @"requiredGender"], @"checkinTime", @"extraFees", @"kitchenPhotos", @"hallPhotos", @"toiletPhotos", @"otherPhotos", @"rooms"];
    
    for (NSUInteger i = 1; i < 6; i++) {
        id object = _houseJSON[_houseKeysArray[_houseKeysArray.count - i]];
        if ([object isKindOfClass:[NSNull class]]) {
            if (i > 1) {
                [_houseJSON setObject:@"" forKey:_houseKeysArray[_houseKeysArray.count - i]];
            } else {
                [_houseJSON setObject:[[NSMutableArray alloc] init] forKey:_houseKeysArray[_houseKeysArray.count - i]];
            }
        }
    }
    
    [_firstStep setDistrict2UserCount:_district2UserCount andTelephone:_telephone andImageToken:_imageToken andImageKeyPattern:_imageKeyPattern andHouseJSON:_houseJSON andHouseKeysArray:_houseKeysArray];
    
    [_thirdStep setHouseJSON:_houseJSON];
}

//设置发房的1.2.3步 分别在不同控制器里处理
- (NSArray *)stepViewControllers {
    _firstStep = [[HouseInfoFillInViewController alloc] init];
    WEAK_SELF weakSelf = self;
    [_firstStep setVerifyInfoButtonDidClickHandler:^{
        //传递最新的houseJSON
        [weakSelf.secondStep setImageToken:weakSelf.imageToken andImageKeyPattern:weakSelf.imageKeyPattern andHouseJSON:weakSelf.houseJSON andHouseKeysArray:weakSelf.houseKeysArray];
        [weakSelf showNextStep];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasPost"];
    }];
    
    _secondStep = [[RoomInfoFillInViewController alloc] init];
    [_secondStep setPrevStepButtonDidClickHandler:^{
        [weakSelf showPreviousStep];
    }];
    [_secondStep setPostSuiteButtonDidClickHandler:^{
        [weakSelf showNextStep];
    }];
    
    _thirdStep = [[AuditStatusForPostViewController alloc] init];
    [_thirdStep setDoneButtonDidClickHandler:^{
        [weakSelf openPostSuiteManageView];
    }];
    
    return @[_firstStep, _secondStep, _thirdStep];
}

/*
 URLParams:{
 "rootViewController":viewController
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
    _rootViewController = URLParams[@"rootViewController"];
}

- (id)initWithRootViewController:(UIViewController *)viewController {
    self = [super init];
    if (self != nil) {
        _rootViewController = viewController;
    }
    
    return self;
}

- (void)openPostSuiteManageView {
    if (_rootViewController) {
        if ([_rootViewController isKindOfClass:[HouseLandlordListViewController class]]) {
            [(HouseLandlordListViewController *)_rootViewController setAddHouseFlag:YES];
            [self.navigationController popToViewController:_rootViewController animated:YES];
        } else {
            UINavigationController *navigationController = _rootViewController.navigationController; //避免pop后为空
            [self.navigationController popToRootViewControllerAnimated:YES];
            HouseLandlordListViewController *houseLandlordListViewController = [[HouseLandlordListViewController alloc] initWithAddHouseFlag:YES];
            houseLandlordListViewController.hidesBottomBarWhenPushed = YES;
            [navigationController pushViewController:houseLandlordListViewController animated:YES];
        }
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (NSArray *)stepTitles {
    return @[lang(@"HouseInfo"), lang(@"RoomInfo"), lang(@"BeChecking")];
}

- (void)finishedAllSteps {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)canceled {
    [self.navigationController popViewControllerAnimated:YES];
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
