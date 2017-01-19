//
//  ManageSubscribesViewController.m
//  room107
//
//  Created by ningxia on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "ManageSubscribesViewController.h"
#import "ManageSubscribesTableViewCell.h"
#import "AddDataTableViewCell.h"
#import "Room107TableView.h"
#import "EditSubscribeViewController.h"
#import "SuiteAgent.h"

@interface ManageSubscribesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Room107TableView *subscribesTableView; //订阅列表
@property (nonatomic, strong) NSMutableArray *subscribes;

@end

@implementation ManageSubscribesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"ManageSubscribes")];
    [self setRightBarButtonTitle:lang(@"ClearSubscribes")];
    [self getSubscribeConditions];
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
    }];
    WEAK_SELF weakSelf = self;
    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
        //清空订阅条件
        [weakSelf showLoadingView];
        [[SuiteAgent sharedInstance] cancelSubscribeWithID:nil completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
            [weakSelf hideLoadingView];
            
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
            
            if (!errorCode) {
                [weakSelf.subscribes removeAllObjects];
                [weakSelf.subscribesTableView reloadData];
            } else {
                if ([self isLoginStateError:errorCode]) {
                    return;
                }
            }
        }];
    }];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:lang(@"ClearSubscribesMessage") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
    [alert show];
}

- (void)getSubscribeConditions {
    //获取订阅条件
    WEAK_SELF weakSelf = self;
    [self showLoadingView];
    [[SuiteAgent sharedInstance] getSubscribeConditions:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *subscribes) {
        [weakSelf hideLoadingView];
        
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            [weakSelf createSubscribesTableView];
            weakSelf.subscribes = [subscribes mutableCopy];
            [_subscribesTableView reloadData];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
    [self createSubscribesTableView];
}

- (void)createSubscribesTableView {
    if (!_subscribesTableView) {
        _subscribesTableView = [[Room107TableView alloc] initWithFrame:[CommonFuncs tableViewFrame] style:UITableViewStyleGrouped];
        [_subscribesTableView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
        _subscribesTableView.delegate = self;
        _subscribesTableView.dataSource = self;
        [self.view addSubview:_subscribesTableView];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MIN(5, _subscribes.count + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_subscribes && _subscribes.count > indexPath.row) {
        //避免数组越界
        ManageSubscribesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ManageSubscribesTableViewCell"];
        if (!cell) {
            cell = [[ManageSubscribesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ManageSubscribesTableViewCell"];
        }
        
        SubscribeModel *subscribe = _subscribes[indexPath.row];
        [cell setPosition:subscribe.position];
        NSString *genderText = [CommonFuncs genderPickerText:[CommonFuncs indexOfGender:subscribe.gender]];
        NSString *rentTypeText = [CommonFuncs rentTypeSwitchText:[CommonFuncs indexOfRentType:subscribe.rentType]];
        NSString *priceRangeText = [CommonFuncs priceRangeSliderText:[subscribe.minPrice intValue] andRightValue:[subscribe.maxPrice intValue]];
        NSString *roomsText = [CommonFuncs roomsPickerText:[subscribe.roomNumber integerValue]];
        [cell setContent:[NSString stringWithFormat:@"%@ %@ %@ %@", genderText, rentTypeText, priceRangeText, roomsText]];
        [cell setViewDidLongPressHandler:^{
            RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
            }];
            WEAK_SELF weakSelf = self;
            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
                if (weakSelf.subscribes.count > indexPath.row) {
                    SubscribeModel *subscribe = weakSelf.subscribes[indexPath.row];
                    //取消订阅条件
                    [weakSelf showLoadingView];
                    [[SuiteAgent sharedInstance] cancelSubscribeWithID:subscribe.id completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                        [weakSelf hideLoadingView];
                        
                        if (errorTitle || errorMsg) {
                            [PopupView showTitle:errorTitle message:errorMsg];
                        }
                
                        if (!errorCode) {
                            [PopupView showMessage:lang(@"StopSubscribeSuccess")];
                            [weakSelf.subscribes removeObjectAtIndex:indexPath.row];
                            [weakSelf.subscribesTableView reloadData];
                        } else {
                            if ([self isLoginStateError:errorCode]) {
                                return;
                            }
                        }
                    }];
                }
            }];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"StopSubscribeTitle") message:lang(@"StopSubscribeMessage") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
            [alert show];
        }];
        
        return cell;
    } else {
        AddDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddDataTableViewCell"];
        if (!cell) {
            cell = [[AddDataTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddDataTableViewCell"];
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_subscribes && _subscribes.count > indexPath.row) {
        return manageSubscribesTableViewCellHeight;
    } else {
        return addDataTableViewCellHeight;
    }
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
    [titleLabel setTextColor:[UIColor room107GrayColorC]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:lang(@"ManageSubscribesTips")];
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAK_SELF weakSelf = self;
    if (_subscribes && _subscribes.count > indexPath.row) {
        //避免数组越界，更新订阅
        SubscribeModel *subscribe = _subscribes[indexPath.row];
        NSMutableDictionary *condition = [[NSMutableDictionary alloc] init];
        [condition setObject:subscribe.id ? subscribe.id : @0 forKey:@"id"];
        [condition setObject:subscribe.position ? subscribe.position : @"" forKey:@"position"];
        [condition setObject:subscribe.gender ? subscribe.gender : [CommonFuncs requiredGender:0] forKey:@"gender"];
        [condition setObject:subscribe.rentType ? subscribe.rentType : [CommonFuncs rentTypeConvert:0] forKey:@"rentType"];
        [condition setObject:subscribe.roomNumber ? subscribe.roomNumber : @0 forKey:@"roomNumber"]; //0：不限，1，2，3，4+
        [condition setObject:subscribe.minPrice ? subscribe.minPrice : @0 forKey:@"minPrice"];
        [condition setObject:subscribe.maxPrice ? subscribe.maxPrice : @10000 forKey:@"maxPrice"]; //10000需要显示为10000+
        EditSubscribeViewController *editSubscribeViewController = [[EditSubscribeViewController alloc] initWithCondition:condition];
        [editSubscribeViewController setSubscribeConditionChangeHandler:^(SubscribeModel *subscribe) {
            [weakSelf getSubscribeConditions];
        }];
        [self.navigationController pushViewController:editSubscribeViewController animated:YES];
    } else {
        //添加订阅
        EditSubscribeViewController *editSubscribeViewController = [[EditSubscribeViewController alloc] initWithCondition:nil];
        [editSubscribeViewController setSubscribeConditionChangeHandler:^(SubscribeModel *subscribe) {
            [weakSelf getSubscribeConditions];
        }];
        [self.navigationController pushViewController:editSubscribeViewController animated:YES];
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
