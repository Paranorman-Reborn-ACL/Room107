//
//  InterestSuiteViewController.m
//  room107
//
//  Created by ningxia on 15/9/24.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "InterestSuiteViewController.h"
#import "Room107TableView.h"
#import "InterestSuiteTableViewCell.h"
#import "SuiteAgent.h"
#import "InterestListItemModel.h"
#import "SuiteReportViewController.h"
#import "AuthenticationAgent.h"
#import "OnlyImageTableViewCell.h"
#import "HouseDetailViewController.h"
#import "IconMutualView.h"
#import "AppTextModel.h"
#import "SystemAgent.h"
#import "OnlineContractGuideViewController.h"
#import "NSString+Encoded.h"
#import "TenantTradingViewController.h"

@interface InterestSuiteViewController () <UITableViewDataSource, UITableViewDelegate, InterestSuiteTableViewCellDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) Room107TableView *interestSuiteTableView;
@property (nonatomic, strong) NSMutableArray *interestItems;
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;
@property (nonatomic, strong) NSDictionary *bottomAd;

@end

@implementation InterestSuiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"InterestSuite")];
    [self setRightBarButtonTitle:lang(@"SignExplanation")];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getInterestItemsByDrag:NO];
}

- (void)getInterestItemsByDrag:(BOOL)drag {
    if (!_interestItems) {
        [self showLoadingView];
    }
    
    [[SuiteAgent sharedInstance] getInterest:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *interestItems, NSDictionary *bottomAd) {
        [self hideLoadingView];
        
        if (drag) {
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
        }
                
        if (!errorCode) {
            _interestItems = [interestItems mutableCopy];
            _bottomAd = bottomAd;
            
            if (!_interestSuiteTableView) {
                CGRect frame = self.view.frame;
                frame.origin.y = 0;
                _interestSuiteTableView = [[Room107TableView alloc] initWithFrame:frame];
                _interestSuiteTableView.delegate = self;
                _interestSuiteTableView.dataSource = self;
                _interestSuiteTableView.tableFooterView = [[UIView alloc] initWithFrame:(CGRect){self.view.bounds.origin, CGRectGetWidth(self.view.bounds), navigationBarHeight}];
                [self.view addSubview:_interestSuiteTableView];
                self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:_interestSuiteTableView target:self refreshAction:@selector(refreshTriggered:) plist:@"Property" color:[UIColor room107GrayColorD] lineWidth:1.5 dropHeight:95 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
            }
            [_interestSuiteTableView reloadData];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
            
            WEAK_SELF weakSelf = self;
            if (!_interestItems) {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf getInterestItemsByDrag:NO];
                    }];
                } else {
                    [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf getInterestItemsByDrag:NO];
                    }];
                }
            }
        }
        
        if (drag) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDragAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.storeHouseRefreshControl finishingLoadingAndComplete:^{
                    _interestSuiteTableView.scrollEnabled = YES;
                    [self enabledPopGesture:YES];
                }];
            });
        }
    }];
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    [self viewSignExplanation];
}

#pragma mark - BeSignedOnlineTableViewCellDelegate
- (void)reportButtonDidClick:(InterestSuiteTableViewCell *)interestSuiteTableViewCell {
    if (![[AppClient sharedInstance] isAuthenticated]) {
        //未认证
        [self pushAuthenticateViewController];
        return;
    }
    
    NSIndexPath *indexPath = [_interestSuiteTableView indexPathForCell:interestSuiteTableViewCell];
    InterestListItemModel *interestItem = _interestItems[indexPath.row];
    NSNumber *roomID = [interestItem.rentType isEqual:@1] ? interestItem.roomId : nil;
    SuiteReportViewController *suiteReportViewController = [[SuiteReportViewController alloc] initWithHouseID:interestItem.id andRoomID:roomID];
    [self.navigationController pushViewController:suiteReportViewController animated:YES];
}

- (void)contactOwnerButtonDidClick:(InterestSuiteTableViewCell *)interestSuiteTableViewCell {
    if (![[AppClient sharedInstance] isLogin]) {
        [self pushLoginAndRegisterViewController];
        return;
    }
    
    NSIndexPath *indexPath = [_interestSuiteTableView indexPathForCell:interestSuiteTableViewCell];
    InterestListItemModel *interestItem = _interestItems[indexPath.row];
    [self showLoadingView];
    [[SuiteAgent sharedInstance] getContactWithHouseID:interestItem.id completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *contact, NSNumber *authStatus) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
            if ([errorCode unsignedIntegerValue] == BusinessErrorCode) {
                //业务限制
                return;
            }
        }
        if (!errorCode) {
            NSString *telephone = contact[@"telephone"];
            NSString *wechat = contact[@"wechat"];
            NSString *qq = contact[@"qq"];
            
            IconMutualView *iconMutualView = [[IconMutualView alloc] initWithIcons:@[@{@"title":@"\ue618", @"color":telephone && ![telephone isEqualToString:@""] ? [UIColor room107GreenColor] : [UIColor room107GrayColorC]}, @{@"title":@"\ue616", @"color":qq && ![qq isEqualToString:@""] ? [UIColor room107GreenColor] : [UIColor room107GrayColorC]}, @{@"title":@"\ue612", @"color":wechat && ![wechat isEqualToString:@""] ? [UIColor room107GreenColor] : [UIColor room107GrayColorC]}]];
            [iconMutualView setIconButtonDidClickHandler:^(NSInteger index) {
                switch (index) {
                    case 0:
                        if (telephone && ![telephone isEqualToString:@""]) {
                            NSString *title = telephone;
                            NSString *message = @"";
                            NSString *cancelButtonTitle = lang(@"Cancel");
                            NSString *otherButtonTitle = lang(@"Dial");
                            RIButtonItem *cancelButtonItem = [cancelButtonTitle isEqualToString:@""] ? nil : [RIButtonItem itemWithLabel:cancelButtonTitle action:^{
                            }];
                            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:otherButtonTitle action:^{
                                [CommonFuncs callTelephone:telephone];
                                AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@17];
                                if (!appText) {
                                    [[SystemAgent sharedInstance] getTextPropertiesFromServer];
                                } else {
                                    [self showAlertViewWithTitle:appText.title message:appText.text];
                                }
                            }];
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
                            [alert show];
                        } else {
                            [PopupView showMessage:lang(@"NoSuchContactInfo")];
                        }
                        break;
                    default:
                    {
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];//系统剪贴板
                        NSString *title = @"";
                        NSString *message = @"";
                        BOOL hasSuchContactInfo = NO;
                        if (index == 1) {
                            if (qq && ![qq isEqualToString:@""]) {
                                pasteboard.string = qq;
                                title = qq;
                                message = lang(@"CopyLandlordQQ");
                                hasSuchContactInfo = YES;
                            }
                        } else {
                            if (wechat && ![wechat isEqualToString:@""]) {
                                pasteboard.string = wechat;
                                title = wechat;
                                message = lang(@"CopyLandlordWechat");
                                hasSuchContactInfo = YES;
                            }
                        }
                        
                        if (hasSuchContactInfo) {
                            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"OK") action:^{
                                AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@17];
                                if (!appText) {
                                    [[SystemAgent sharedInstance] getTextPropertiesFromServer];
                                } else {
                                    [self showAlertViewWithTitle:appText.title message:appText.text];
                                }
                            }];
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message cancelButtonItem:nil otherButtonItems:otherButtonItem, nil];
                            [alert show];
                        } else {
                            [PopupView showMessage:lang(@"NoSuchContactInfo")];
                        }
                        
                        break;
                    }
                }
            }];
        } else {
            if ([errorCode unsignedIntegerValue] == unAuthenticateCode) {
                //未认证
                [self pushAuthenticateViewController];
            }
        }
    }];
}

- (void)signedDealButtonDidClick:(InterestSuiteTableViewCell *)interestSuiteTableViewCell {
    NSIndexPath *indexPath = [_interestSuiteTableView indexPathForCell:interestSuiteTableViewCell];
    InterestListItemModel *interestItem = _interestItems[indexPath.row];
    if ([interestItem.buttonType intValue] != 2) {
        NSNumber *roomID = [interestItem.rentType isEqual:@1] ? interestItem.roomId : nil;
        if ([interestItem.hasContract boolValue]) {
            TenantTradingViewController *tenantTradingViewController = [[TenantTradingViewController alloc] initWithHouseID:interestItem.id andRoomID:roomID isInterest:YES];
            [self.navigationController pushViewController:tenantTradingViewController animated:YES];
        } else {
            OnlineContractGuideViewController *onlineContractGuideViewController = [[OnlineContractGuideViewController alloc] initWithHouseID:interestItem.id andRoomID:roomID isInterest:YES isOnlineSigned:[interestItem.buttonType intValue] == 1 ? NO : YES];
            [self.navigationController pushViewController:onlineContractGuideViewController animated:YES];
        }
    }
}

- (void)deleteSuiteButtonDidClick:(InterestSuiteTableViewCell *)interestSuiteTableViewCell {
    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
    }];
    WEAK_SELF weakSelf = self;
    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Delete") action:^{
        NSIndexPath *indexPath = [weakSelf.interestSuiteTableView indexPathForCell:interestSuiteTableViewCell];
        if (weakSelf.interestItems.count > indexPath.row) {
            InterestListItemModel *interestItem = weakSelf.interestItems[indexPath.row];
            NSNumber *roomID = [interestItem.rentType isEqual:@1] ? interestItem.roomId : nil;
            
            [weakSelf showLoadingView];
            [[SuiteAgent sharedInstance] removeInterestWithHouseID:interestItem.id andRoomID:roomID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                [weakSelf hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                
                if (!errorCode) {
                    [weakSelf showAlertViewWithTitle:lang(@"SuiteHasBeenDeleted") message:nil];
                    [weakSelf.interestItems removeObjectAtIndex:indexPath.row];
                    [weakSelf.interestSuiteTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"WhetherDeleteTargetSuite")
                                                    message:@"" cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
    [alert show];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_bottomAd) {
        return _interestItems.count + 1;
    } else {
        return _interestItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _interestItems.count) {
        InterestSuiteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InterestSuiteTableViewCell"];
        if (!cell) {
            cell = [[InterestSuiteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InterestSuiteTableViewCell"];
            cell.delegate = self;
        }
        
        InterestListItemModel *interestItem = _interestItems[indexPath.row];
        NSDictionary *itemDic = @{@"cover":[interestItem.hasCover boolValue] ? interestItem.cover ? interestItem.cover : [CommonFuncs newCoverDic] : [CommonFuncs newCoverDic], @"faviconUrl":interestItem.faviconUrl ? interestItem.faviconUrl : @"", @"tagIds":interestItem.tagIds, @"isInterest":interestItem.isInterest, @"price":interestItem.price, @"city":interestItem.city, @"position":interestItem.position, @"houseName":interestItem.houseName, @"roomName":interestItem.roomName, @"rentType":interestItem.rentType, @"requiredGender":interestItem.requiredGender, @"modifiedTime":interestItem.modifiedTime};
        [cell setItemDic:itemDic];
        [cell setButtonType:interestItem.buttonType];
        [cell setNewUpdate:interestItem.hasNewUpdate];
        [cell setViewHouseTagExplanationHandler:^(NSDictionary *params) {
            [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:params context:self];
        }];
        
        return cell;
    } else {
        OnlyImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyImageTableViewCell"];
        if (nil == cell) {
            cell = [[OnlyImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OnlyImageTableViewCell"];
        }
        CGFloat height = [CommonFuncs houseCardHeight];
        if (_bottomAd[@"height"] && _bottomAd[@"width"]) {
            height = ([[UIScreen mainScreen] bounds].size.width - 2 * 11) * [_bottomAd[@"height"] floatValue] / [_bottomAd[@"width"] floatValue];
        }
        [cell setImageURL:_bottomAd[@"url"] andHeight:height];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _interestItems.count) {
        CGFloat height = [CommonFuncs houseCardHeight];
        if (_bottomAd) {
            if (_bottomAd[@"height"] && _bottomAd[@"width"]) {
                height = ([[UIScreen mainScreen] bounds].size.width - 2 * 11) * [_bottomAd[@"height"] floatValue] / [_bottomAd[@"width"] floatValue];
            }
        }
        return height;
    } else {
        return [CommonFuncs houseCardHeight] + 11 + 33 + 11;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_interestItems && _interestItems.count > indexPath.row) {
        HouseDetailViewController *houseDetailViewController = [[HouseDetailViewController alloc] init];
        [houseDetailViewController setItem:_interestItems[indexPath.row]];
        [self.navigationController pushViewController:houseDetailViewController animated:YES];
    } else {
        if (_bottomAd && _bottomAd[@"targetUri"] && ![_bottomAd[@"targetUri"] isEqualToString:@""]) {
            //有广告位
            [[NXURLHandler sharedInstance] handleOpenURL:_bottomAd[@"targetUri"] params:nil context:self];
        }
    }
}

#pragma mark - Notifying refresh control of scrolling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _interestSuiteTableView) {
        [_storeHouseRefreshControl scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == _interestSuiteTableView) {
        [_storeHouseRefreshControl scrollViewDidEndDragging];
    }
}

#pragma mark - Listening for the user to trigger a refresh
//下拉动画开始执行 调接口 请求数据 关闭tableView滑动效果
- (void)refreshTriggered:(id)sender {
    _interestSuiteTableView.scrollEnabled = NO;
    [self enabledPopGesture:NO];
    
    [self getInterestItemsByDrag:YES];
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
