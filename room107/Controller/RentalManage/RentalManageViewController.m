//
//  RentalManageViewController.m
//  room107
//
//  Created by ningxia on 15/7/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RentalManageViewController.h"
#import "RentalManageTableViewCell.h"
#import "Room107TableView.h"
#import "HouseDetailViewController.h"
#import "SuiteAgent.h"
#import "RentedHouseListItemModel.h"
#import "HouseListItemModel.h"
#import "TenantContractManageViewController.h"
#import "OnlyTextTableViewCell.h"

@interface RentalManageViewController () <UITableViewDataSource, UITableViewDelegate, RentalManageTableViewCellDelegate>

@property (nonatomic, strong) Room107TableView *rentSuiteTableView;
@property (nonatomic, strong) NSMutableArray *rentItems;
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;
@property (nonatomic, assign) BOOL hasData; //标记 是否有数据

@end

@implementation RentalManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"RentalManage")];
    [self setRightBarButtonTitle:lang(@"TenantExplanation")];
    
    _rentSuiteTableView = [[Room107TableView alloc] initWithFrame:[CommonFuncs tableViewFrame]];
    _rentSuiteTableView.delegate = self;
    _rentSuiteTableView.dataSource = self;
    [self.view addSubview:_rentSuiteTableView];
    _rentSuiteTableView.hidden = YES ;
    self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.rentSuiteTableView  target:self refreshAction:@selector(refreshTriggered:) plist:@"Property" color:[UIColor room107GrayColorD] lineWidth:1.5 dropHeight:95 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getTenantHouseListDrag:NO];
}

- (void)getTenantHouseListDrag:(BOOL)drag {
    if (!_hasData) {
        [self showLoadingView];
    }
    [[SuiteAgent sharedInstance] getTenantHouseList:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items) {
        [self hideLoadingView];
        WEAK_SELF weakSelf = self;
        //网络请求正常 有数据
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            self.rentSuiteTableView.hidden = NO;
            self.hasData = YES ;
            _rentItems = [NSMutableArray arrayWithArray:items];
            
            if (!_rentItems || _rentItems.count == 0) {
//                [self showContent:lang(@"HasNotRentingRoom") withFrame:_rentSuiteTableView.frame];
            } else {
                [_rentSuiteTableView reloadData];
            }
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
            
            //网络请求错误
            if (self.hasData) {
                //不是第一次进入 从自页面返回  无蛙 无提示 无阻隔
            } else {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf getTenantHouseListDrag:NO];
                    }];
                } else {
                    
                    [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf getTenantHouseListDrag:NO];
                    }];
                }
            }
            if (drag) {
                
            }
        }
        
        if (drag) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDragAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.storeHouseRefreshControl finishingLoadingAndComplete:^{
                    weakSelf.rentSuiteTableView.scrollEnabled = YES ;
                    [self enabledPopGesture:YES];
                }];
            });
        }
    }];
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    [self viewTenantExplanation];
}

#pragma mark - RentalManageTableViewCellDelegate
- (void)rentalManageButtonDidClick:(RentalManageTableViewCell *)rentalManageTableViewCell {
    NSIndexPath *indexPath = [_rentSuiteTableView indexPathForCell:rentalManageTableViewCell];
    if (indexPath.row < _rentItems.count) {
        RentedHouseListItemModel *rentedHouseListItem = _rentItems[indexPath.row];
        TenantContractManageViewController *tenantContractManageViewController = [[TenantContractManageViewController alloc] initWithContractID:rentedHouseListItem.contractId andSelectedIndex:rentedHouseListItem.orderPrice && rentedHouseListItem.orderTime ? 1 : 0];
        [self.navigationController pushViewController:tenantContractManageViewController animated:YES ];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rentItems.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _rentItems.count) {
        RentalManageTableViewCell *cell = [tableView    dequeueReusableCellWithIdentifier:@"RentalManageTableViewCell"];
        if (!cell) {
            cell = [[RentalManageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RentalManageTableViewCell"];
            cell.delegate = self;
        }
        
        if (_rentItems.count > 0) {
            RentedHouseListItemModel *rentedHouseListItem = _rentItems[indexPath.row];
            HouseListItemModel *houseListItem = rentedHouseListItem.houseListItem;
            NSDictionary *itemDic = @{@"cover":[houseListItem.hasCover boolValue] ? houseListItem.cover ? houseListItem.cover : [CommonFuncs newCoverDic] : [CommonFuncs newCoverDic], @"faviconUrl":houseListItem.faviconUrl ? houseListItem.faviconUrl:@"", @"monthlyPrice":rentedHouseListItem.monthlyPrice ? rentedHouseListItem.monthlyPrice:@0, @"address":rentedHouseListItem.address, @"name":houseListItem.name, @"houseName":houseListItem.houseName, @"roomName":houseListItem.roomName, @"checkinTime":rentedHouseListItem.checkinTime ? rentedHouseListItem.checkinTime:@"", @"exitTime":rentedHouseListItem.exitTime ? rentedHouseListItem.exitTime:@""};
            [cell setItemDic:itemDic];
            [cell setNextPaymentMoney:rentedHouseListItem.orderPrice andDate:rentedHouseListItem.orderTime];
            [cell setRentedHouseStatus:rentedHouseListItem.status];
            [cell setNewUpdate:rentedHouseListItem.hasNewUpdate];
        }
        
        return cell;
    } else {
        OnlyTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyTextTableViewCell"];
        if (!cell) {
            cell = [[OnlyTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OnlyTextTableViewCell"];
        }
        
        [cell setContent:lang(@"HasNotRentingRoom") andHeight: _rentItems ? [CommonFuncs houseCardHeight] + 11 + 33 + 11 : self.view.frame.size.height] ;

        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _rentItems.count) {
        RentedHouseListItemModel *rentedHouseListItem = _rentItems[indexPath.row];
        
        if (rentedHouseListItem.orderPrice && rentedHouseListItem.orderTime) {
            return [CommonFuncs houseCardHeight] + 11 + 22 + 11 + 33 + 11;
        } else {
            //无待付账单
            return [CommonFuncs houseCardHeight] + 11 + 33 + 11;
        }
    }
    
    return [CommonFuncs houseCardHeight] + 11 + 33 + 11;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_rentItems && _rentItems.count > indexPath.row) {
        HouseDetailViewController *houseDetailViewController = [[HouseDetailViewController alloc] init];
        [houseDetailViewController setItem:(ItemModel *)[_rentItems[indexPath.row] houseListItem]];
        houseDetailViewController.hidesBottomBarWhenPushed = YES; //具体到每一次push都需要设置
        [self.navigationController pushViewController:houseDetailViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifying refresh control of scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.rentSuiteTableView) {
        [self.storeHouseRefreshControl scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.rentSuiteTableView) {
        [self.storeHouseRefreshControl scrollViewDidEndDragging];
    }
}

#pragma mark - Listening for the user to trigger a refresh

//下拉动画开始执行 调接口口 请求数据 关闭tableView滑动效果
- (void)refreshTriggered:(id)sender {
    _rentSuiteTableView.scrollEnabled = NO ;
    [self enabledPopGesture:NO];
    //    [self performSelector:@selector(loadDataDrag:) withObject:@1 afterDelay:0 inModes:@[NSRunLoopCommonModes]];
    [self getTenantHouseListDrag:YES];
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

