//
//  MyAccountViewController.m
//  room107
//
//  Created by 107间 on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "MyAccountViewController.h"
#import "ChangeBindingViewController.h" //更换手机号绑定
#import "AuthenticationAgent.h" //账户信息
#import "UserInfoModel.h" //账户信息model
#import "SevenTemplateTableViewCell.h"
#import "TwoTemplateTableViewCell.h"
#import "WXApi.h"
#import "AuthenticationAgent.h"

@interface MyAccountViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *accountTableView;
@property (nonatomic, strong) NSArray *accountCardInfoArray;
@property (nonatomic, strong) UserInfoModel *userInfo;
@property (nonatomic, strong) TwoTemplateTableViewCell *telephoneCell;
@end

@implementation MyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"MyAccount")];
    
    [self getUserInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWechatGrantResult:) name:WechatGrantNotification object:nil];//监听微信授权登录回调通知
}

- (void)getUserInfo{
    WEAK_SELF weakSelf = self;
    [[AuthenticationAgent sharedInstance] getUserInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserInfoModel *userInfo, SubscribeModel *subscribe) {
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        if (!errorCode) {
            weakSelf.userInfo = userInfo;
            NSString *verifyStatus;
            if ([weakSelf.userInfo.verifyStatus isEqual:@0]) { ////UNVERIFIED, VERIFIED_EMAIL, VERIFIED_CREDENTIAL, VERIFIED_RAPID
                verifyStatus = lang(@"Unauthenticated");
            } else if ([_userInfo.verifyStatus isEqual:@3]){
                verifyStatus = [lang(@"Authenticated") stringByAppendingFormat:@"(%@/%@)", weakSelf.userInfo.rapidVerifyNumber, weakSelf.userInfo.rapidVerifyBase];
            } else {
                verifyStatus = lang(@"Authenticated");
            }
            
            if ([WXApi isWXAppInstalled]) {
                weakSelf.accountCardInfoArray = @[@[@{@"imageCode":@"\ue66d", @"text":lang(@"BindingTelephone"), @"tailText":  weakSelf.userInfo.telephone ?  weakSelf.userInfo.telephone : @""},
                                                    @{@"imageCode":@"\ue684", @"text":lang(@"BindWeChat"), @"tailText": weakSelf.userInfo.wechatName ? weakSelf.userInfo.wechatName : @"", @"tailImageUrl": weakSelf.userInfo.wechatFavicon ? weakSelf.userInfo.wechatFavicon : @"", @"tailImageType":@1}],
                                          @[@{@"imageCode":@"\ue683", @"text":lang(@"AuthenticationStatus"), @"tailText":verifyStatus}],
                                          @[@{@"text":lang(@"LogoutTheLogin")}]];
            } else {
                weakSelf.accountCardInfoArray = @[@[@{@"imageCode":@"\ue66d", @"text":lang(@"BindingTelephone"), @"tailText":  weakSelf.userInfo.telephone ?  weakSelf.userInfo.telephone : @""}],
                                          @[@{@"imageCode":@"\ue683", @"text":lang(@"AuthenticationStatus"), @"tailText":verifyStatus}],
                                          @[@{@"text":lang(@"LogoutTheLogin")}]];
            }
            
            [weakSelf creatAccountTableView];
        }
    }];
}

- (void)creatAccountTableView {
    if (!_accountTableView) {
        self.accountTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _accountTableView.dataSource = self;
        _accountTableView.delegate = self;
        [_accountTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_accountTableView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
        [self.view addSubview:_accountTableView];
    }
    [_accountTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _accountCardInfoArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_accountCardInfoArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        static NSString *cellID = @"SevenTemplateTableViewCell";
        SevenTemplateTableViewCell *sevenTemplateTableViewCell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (nil == sevenTemplateTableViewCell) {
            sevenTemplateTableViewCell = [[SevenTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        [sevenTemplateTableViewCell setSevenTemplateInfo:_accountCardInfoArray[indexPath.section][indexPath.row]];
        [sevenTemplateTableViewCell settTitleColor:[UIColor redColor]];
        return sevenTemplateTableViewCell;
    } else {
        static NSString *cellID = @"TwoTemplateTableViewCell";
        TwoTemplateTableViewCell *twoTemplateTableViewCell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (nil == twoTemplateTableViewCell) {
            twoTemplateTableViewCell = [[TwoTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        [twoTemplateTableViewCell setTwoTemplateInfo:_accountCardInfoArray[indexPath.section][indexPath.row]];
        if (!_telephoneCell && indexPath.section == 0 && indexPath.row == 0) {
            _telephoneCell = twoTemplateTableViewCell;
        }
        return twoTemplateTableViewCell;
    }
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 11;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //若tableView是Group类型 返回值是0,则会返回默认值  所以保证隐藏footerInsection 给一极小值。
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return sevenTemplateTableViewCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]};
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [headerView setBackgroundColor:[UIColor room107GrayColorA]];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        //更换绑定
        WEAK_SELF weakSelf = self;
        RIButtonItem *confirmButtonItem= [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
            ChangeBindingViewController *changeBindingViewController = [[ChangeBindingViewController alloc] init];
            [changeBindingViewController setCurrentTelephoneNumber:weakSelf.userInfo.telephone];
            changeBindingViewController.bindingSuccessful = ^ (NSString *telephone) {
                [weakSelf.telephoneCell setTwoTemplateInfo:@{@"imageCode":@"\ue66d", @"text":lang(@"BindingTelephone"), @"tailText":telephone ? telephone : @""}];
            };
            [self.navigationController pushViewController:changeBindingViewController animated:YES];
        }];
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:[lang(@"Cancel") substringToIndex:2] action:^{
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"ChangeTelephoneNumber") message:[NSString stringWithFormat:@"%@%@%@", lang(@"CurrentTelephoneNumber") ,_userInfo.telephone ? _userInfo.telephone : @"", lang(@"WhetherChangeTelephoneNumber")] cancelButtonItem:otherButtonItem otherButtonItems:confirmButtonItem, nil];
        [alert show];

    } else if (indexPath.section == 0 && indexPath.row == 1) {
        //绑定微信
        [self grantBind];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        //认证
        if ([_userInfo.verifyStatus isEqual:@0] || [_userInfo.verifyStatus isEqual:@3]) {
            [self pushAuthenticateViewController];
        }
    } else if (indexPath.section == 2) {
        //退出登录
        RIButtonItem *confirmButtonItem= [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
            [Room107UserDefaults clearUserDefaults];
            [[NSNotificationCenter defaultCenter] postNotificationName:ClientDidLogoutNotification object:self];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:[lang(@"Cancel") substringToIndex:2] action:^{
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"LogoutTheLogin") message:lang(@"ruSureLogout") cancelButtonItem:otherButtonItem otherButtonItems:confirmButtonItem, nil];
        [alert show];
    }
}

- (void)grantBind {
    WEAK_SELF weakSelf = self;
    if (self.userInfo.wechatFavicon && ![self.userInfo.wechatFavicon isEqualToString:@""] && self.userInfo.wechatName && ![self.userInfo.wechatName isEqualToString:@""]) {
        RIButtonItem *confirmButtonItem= [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
            [weakSelf getGrantParams];
        }];
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:[lang(@"Cancel") substringToIndex:2] action:^{
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"RebindWechat") message:lang(@"ConfirmRebindWechat") cancelButtonItem:otherButtonItem otherButtonItems:confirmButtonItem, nil];
        [alert show];
    } else {
        [weakSelf getGrantParams];
    }
}

- (void)getGrantParams {
    [[AuthenticationAgent sharedInstance] getGrantParamsWithOauthPlatform:@3 comlpetion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *params, NSNumber *oauthPlatform) {
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        if (!errorCode) {
            NSString *scope = params[@"scope"];
            NSString *state = params[@"state"];
            SendAuthReq *req = [[SendAuthReq alloc] init];
            req.scope = scope;
            req.state = state;
            //第三方向微信终端发送一个SendAuthReq消息结构
            [WXApi sendReq:req];
        }
    }];
}

//微信回调
- (void)getWechatGrantResult:(NSNotification *)notification {
    if (notification.object) {
        WEAK_SELF weakSelf = self;
        [[AuthenticationAgent sharedInstance] grantBindWithOauthPlatform:@3 andCode:notification.object comlpetion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
            if (!errorCode) {
                [weakSelf getUserInfo];
            }
        }];
        
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
