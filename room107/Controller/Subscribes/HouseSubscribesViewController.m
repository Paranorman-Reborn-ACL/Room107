//
//  HouseSubscribesViewController.m
//  room107
//
//  Created by ningxia on 16/3/15.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "HouseSubscribesViewController.h"
#import "Room107TableView.h"
#import "SuiteSearchTableViewCell.h"
#import "HouseDetailViewController.h"
#import "SuiteAgent.h"
#import "HouseListItemModel.h"
#import "ManageSubscribesViewController.h"
#import "RightMenuView.h"
#import "RightMenuViewItem.h"

@interface HouseSubscribesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Room107TableView *itemsTableView; //房间列表
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) RightMenuView *menuItem;

@end

@implementation HouseSubscribesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"MySubscribes")];
    [self setRightBarButtonTitle:lang(@"More")];
    [self getSubscribes];
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    if (!_menuItem) {
        [self creatRightMenu];
    } else {
        if (_menuItem.hidden) {
            [_menuItem showMenuView];
        } else {
            [_menuItem dismissMenuView];
        }
    }
}

/**
 *  创建右上角下拉菜单
 */
- (void)creatRightMenu {
    WEAK_SELF weakSelf = self;
    //管理订阅
    RightMenuViewItem *manageSubscribesItem = [[RightMenuViewItem alloc] initWithTitle:lang(@"ManageSubscribes") clickComplete:^{
        ManageSubscribesViewController *manageSubscribesViewController = [[ManageSubscribesViewController alloc] init];
        [weakSelf.navigationController pushViewController:manageSubscribesViewController animated:YES];
    }];
    //清空已读
    RightMenuViewItem *clearReadItem = [[RightMenuViewItem alloc] initWithTitle:lang(@"ClearRead") clickComplete:^{
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
        }];
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
            [[SuiteAgent sharedInstance] clearAllReadSubscribes];
            [weakSelf.items removeAllObjects];
            weakSelf.items = [NSMutableArray arrayWithArray:[[SuiteAgent sharedInstance] getSubscribesFromLocal]];
            [weakSelf.itemsTableView reloadData];
            if (weakSelf.items.count == 0) {
                _itemsTableView.hidden = YES;
                [weakSelf showContent:lang(@"HasNoSubscribes") withFrame:[CommonFuncs tableViewFrame]];
            }
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"ClearReadTitle") message:lang(@"ClearReadMessage") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
        [alert show];
    }];
    
    _menuItem = [[RightMenuView alloc] initWithItems:@[manageSubscribesItem, clearReadItem]];
    [self.view addSubview:_menuItem];
}

- (void)getSubscribes {
    //订阅数据
    WEAK_SELF weakSelf = self;
    [self showLoadingView];
    [[SuiteAgent sharedInstance] getSubscribes:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items) {
        [weakSelf hideLoadingView];
        
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            if (items.count > 0) {
                weakSelf.items = [NSMutableArray arrayWithArray:items];
                [weakSelf createItemsTableView];
            } else {
                [weakSelf showContent:lang(@"HasNoSubscribes") withFrame:[CommonFuncs tableViewFrame]];
            }
            weakSelf.itemsTableView.hidden = weakSelf.items.count == 0;
            [weakSelf.itemsTableView reloadData];
            
            NSNumber *newHomesCount = [Room107UserDefaults subscribeNewHomesCount];
            //类型必须为NSInteger，避免NSUInteger为负数时强转为大整型
            NSInteger countDiff = newHomesCount ? weakSelf.items.count - [newHomesCount unsignedIntegerValue] : weakSelf.items.count;
            //更新新房推送数目
            [Room107UserDefaults saveSubscribeNewHomesCount:[NSNumber numberWithUnsignedInteger:weakSelf.items.count]];
            
            if (countDiff > 0) {
                //第一次显示新房推送或新房推送数目增加，则出现弹窗
                [weakSelf showAlertViewWithTitle:[NSString stringWithFormat:lang(@"HasSubscribeTitle"), countDiff] message:lang(@"HasSubscribeMessage")];
            }
        } else {
            if ([weakSelf isLoginStateError:errorCode]) {
                return;
            }
            
            if (weakSelf.items.count == 0) {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [weakSelf showNetworkFailedWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf showLoadingView];
                        [weakSelf getSubscribes];
                    }];
                } else {
                    [weakSelf showUnknownErrorWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf showLoadingView];
                        [weakSelf getSubscribes];
                    }];
                }
            }
        }
    }];
}

- (void)createItemsTableView {
    if (!_itemsTableView) {
        _itemsTableView = [[Room107TableView alloc] initWithFrame:[CommonFuncs tableViewFrame] style:UITableViewStyleGrouped];
        [_itemsTableView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
        _itemsTableView.delegate = self;
        _itemsTableView.dataSource = self;
        [self.view addSubview:_itemsTableView];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SuiteSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuiteSearchTableViewCell"];
    if (!cell) {
        cell = [[SuiteSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteSearchTableViewCell"];
    }
    
    if (_items && _items.count > indexPath.row) {
        //避免数组越界
        HouseListItemModel *houseListItem = _items[indexPath.row];
        NSDictionary *itemDic = @{@"cover":[houseListItem.hasCover boolValue] ? houseListItem.cover ? houseListItem.cover : [CommonFuncs newCoverDic] : [CommonFuncs newCoverDic], @"faviconUrl":houseListItem.faviconUrl ? houseListItem.faviconUrl : @"", @"tagIds":houseListItem.tagIds, @"isRead":houseListItem.isRead ? houseListItem.isRead : @0, @"isInterest":houseListItem.isInterest, @"price":houseListItem.price, @"viewCount":houseListItem.viewCount ? houseListItem.viewCount : @0, @"city":houseListItem.city, @"position":houseListItem.position, @"houseName":houseListItem.houseName, @"roomName":houseListItem.roomName, @"rentType":houseListItem.rentType, @"requiredGender":houseListItem.requiredGender, @"distance":houseListItem.distance ? houseListItem.distance : @0, @"modifiedTime":houseListItem.modifiedTime};
        [cell setItemDic:itemDic];
        WEAK_SELF weakSelf = self;
        [cell setViewHouseTagExplanationHandler:^(NSDictionary *params) {
            [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:params context:weakSelf];
        }];
        [cell setItemFavoriteHandler:^{
            if (![[AppClient sharedInstance] isLogin]) {
                [weakSelf pushLoginAndRegisterViewController];
                return;
            }
            
            NSNumber *houseID = houseListItem.id;
            NSNumber *roomID = [houseListItem.rentType isEqual:@1] ? houseListItem.roomId : nil;
            if ([houseListItem.isInterest boolValue]) {
                RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
                    
                }];
                RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Delete") action:^{
                    [weakSelf showLoadingView];
                    [[SuiteAgent sharedInstance] removeInterestWithHouseID:houseID andRoomID:roomID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                        [weakSelf hideLoadingView];
                        if (errorTitle || errorMsg) {
                            [PopupView showTitle:errorTitle message:errorMsg];
                            if ([errorCode unsignedIntegerValue] == BusinessErrorCode) {
                                //业务限制
                                return;
                            }
                        }
                        if (!errorCode) {
                            houseListItem.isInterest = [NSNumber numberWithBool:![houseListItem.isInterest boolValue]];
                            [weakSelf.itemsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf showAlertViewWithTitle:lang(@"SuiteHasBeenDeleted") message:nil];
                        }
                    }];
                }];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"WhetherDeleteTargetSuite")
                                                                message:@"" cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
                [alert show];
            } else {
                [weakSelf showLoadingView];
                [[SuiteAgent sharedInstance] addInterestWithHouseID:houseID andRoomID:roomID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                    [weakSelf hideLoadingView];
                    if (errorTitle || errorMsg) {
                        [PopupView showTitle:errorTitle message:errorMsg];
                        if ([errorCode unsignedIntegerValue] == BusinessErrorCode) {
                            //业务限制
                            return;
                        }
                    }
                    if (!errorCode) {
                        houseListItem.isInterest = [NSNumber numberWithBool:![houseListItem.isInterest boolValue]];
                        [weakSelf.itemsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [weakSelf showAlertViewWithTitle:lang(@"JoinedBeSignedListTitle") message:lang(@"JoinedBeSignedListMessage")];
                    }
                }];
            }
        }];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CommonFuncs houseCardHeight] + 11;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]};
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 11;
    SearchTipLabel *titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 5, headerView.frame.size.width - 2 * originX, headerView.frame.size.height}];
    [titleLabel setFont:[UIFont room107FontOne]];
    [titleLabel setTextColor:[UIColor room107GrayColorE]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:[NSString stringWithFormat:lang(@"NewHomesNumber"), _items.count]];
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_items && _items.count > indexPath.row) {
        //避免数组越界
        HouseDetailViewController *houseDetailViewController = [[HouseDetailViewController alloc] init];
        HouseListItemModel *houseListItem = _items[indexPath.row];
        [houseDetailViewController setItem:houseListItem];
        [houseDetailViewController setHouseInterestHandler:^(NSNumber *isInterest) {
            houseListItem.isInterest = isInterest;
            [_itemsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        if ([houseListItem.isRead isEqual:@0]) {
            houseListItem.isRead = @1;
        }
        [_itemsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.navigationController pushViewController:houseDetailViewController animated:YES];
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
