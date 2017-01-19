//
//  EditSubscribeViewController.m
//  room107
//
//  Created by ningxia on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "EditSubscribeViewController.h"
#import "Room107TableView.h"
#import "FullAddressTableViewCell.h"
#import "CustomSwitchTableViewCell.h"
#import "CustomPickerComponentTableViewCell.h"
#import "CustomRangeSliderTableViewCell.h"
#import "SuiteSearchFromSubwayViewController.h"
#import "SuiteAgent.h"

static CGFloat cellOffsetY = 33;

@interface EditSubscribeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Room107TableView *conditionTableView; //筛选条件列表
@property (nonatomic, strong) NSMutableDictionary *conditionDic;
@property (nonatomic, strong) FullAddressTableViewCell *fullAddressTableViewCell;
@property (nonatomic, strong) CustomPickerComponentTableViewCell *genderPickerComponentTableViewCell;
@property (nonatomic, strong) CustomSwitchTableViewCell *rentTypeSwitchTableViewCell;
@property (nonatomic, strong) CustomPickerComponentTableViewCell *roomsPickerComponentTableViewCell;
@property (nonatomic, strong) CustomRangeSliderTableViewCell *rangeSliderTableViewCell;
@property (nonatomic, strong) void (^subscribeConditionChangeHandler)(SubscribeModel *subscribe);

@end

@implementation EditSubscribeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"EditSubscribe")];
    [self setRightBarButtonTitle:lang(@"Confirm")];
    [self createConditionTableView];
}

- (id)initWithCondition:(NSMutableDictionary *)condition {
    self = [super init];
    if (self != nil) {
        if (condition) {
            _conditionDic = condition;
        } else {
            [self initConditionDic];
        }
    }
    
    return self;
}

- (void)setSubscribeConditionChangeHandler:(void(^)(SubscribeModel *subscribe))handler {
    _subscribeConditionChangeHandler = handler;
}

- (void)initConditionDic {
    if (!_conditionDic) {
        _conditionDic = [[NSMutableDictionary alloc] init];
        [_conditionDic setObject:@"" forKey:@"position"];
        [_conditionDic setObject:[CommonFuncs requiredGender:0] forKey:@"gender"];
        [_conditionDic setObject:[CommonFuncs rentTypeConvert:0] forKey:@"rentType"];
        [_conditionDic setObject:@0 forKey:@"roomNumber"]; //0：不限，1，2，3，4+
        [_conditionDic setObject:@0 forKey:@"minPrice"];
        [_conditionDic setObject:@10000 forKey:@"maxPrice"]; //10000需要显示为10000+
    }
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    if ([[_fullAddressTableViewCell position] isEqualToString:@""]) {
        [PopupView showMessage:lang(@"NoSubscribeAddress")];
        return;
    }
    
    if (_conditionDic) {
        if (_fullAddressTableViewCell) {
            [_conditionDic setObject:[_fullAddressTableViewCell position] forKey:@"position"];
        }
        if (_genderPickerComponentTableViewCell) {
            [_conditionDic setObject:[CommonFuncs requiredGender:[_genderPickerComponentTableViewCell selectedIndex]] forKey:@"gender"];
        }
        if (_rentTypeSwitchTableViewCell) {
            [_conditionDic setObject:[CommonFuncs rentTypeConvert:[_rentTypeSwitchTableViewCell switchIndex]] forKey:@"rentType"];
        }
        if (_roomsPickerComponentTableViewCell) {
            [_conditionDic setObject:[NSNumber numberWithInteger:[_roomsPickerComponentTableViewCell selectedIndex]] forKey:@"roomNumber"];
        }
        if (_rangeSliderTableViewCell) {
            [_conditionDic setObject:[NSNumber numberWithFloat:[_rangeSliderTableViewCell leftValue]]forKey:@"minPrice"];
            [_conditionDic setObject:[NSNumber numberWithFloat:[_rangeSliderTableViewCell rightValue]] forKey:@"maxPrice"];
        }
    }

    
    WEAK_SELF weakSelf = self;
    [self showLoadingView];
    [[SuiteAgent sharedInstance] updateSubscribeWithFilter:_conditionDic completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, SubscribeModel *subscribe) {
        [weakSelf hideLoadingView];
        
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            if (weakSelf.subscribeConditionChangeHandler) {
                weakSelf.subscribeConditionChangeHandler(subscribe);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (void)createConditionTableView {
    if (!_conditionTableView) {
        _conditionTableView = [[Room107TableView alloc] initWithFrame:[CommonFuncs tableViewFrame] style:UITableViewStylePlain];
        [_conditionTableView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
        _conditionTableView.delegate = self;
        _conditionTableView.dataSource = self;
        [self.view addSubview:_conditionTableView];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            FullAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FullAddressTableViewCell"];
            if (!cell) {
                cell = [[FullAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FullAddressTableViewCell"];
                [self setCellTitle:lang(@"FullAddress") andCell:cell andOffsetY:0];
                [cell setAddressPlaceholder:@""];
                [cell setPosition:_conditionDic[@"position"]];
                _fullAddressTableViewCell = cell;
            }
            WEAK_SELF weakSelf = self;
            [cell setAddressShouldBeginEditingHandler:^{
                SuiteSearchFromSubwayViewController *suiteSearchFromSubwayViewController = [[SuiteSearchFromSubwayViewController alloc] init];
                suiteSearchFromSubwayViewController.delegate = weakSelf;
                [weakSelf.navigationController pushViewController:suiteSearchFromSubwayViewController animated:YES];
            }];
            
            return cell;
        }
            break;
        case 1:
        {
            CustomPickerComponentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GenderPickerComponentTableViewCell"];
            if (!cell) {
                cell = [[CustomPickerComponentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GenderPickerComponentTableViewCell"];
                [self setCellTitle:lang(@"RenterType") andCell:cell andOffsetY:0];
                [cell setStringsArray:@[lang(@"AllHouse"), lang(@"Female"), lang(@"Male"), lang(@"Male&Female")] withOffsetY:0 withUnit:nil];
                [cell setSelectedIndex:[CommonFuncs indexOfGender:_conditionDic[@"gender"]]];
                _genderPickerComponentTableViewCell = cell;
            }
            
            return cell;
        }
            break;
        case 2:
        {
            CustomSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RentTypeSwitchTableViewCell"];
            if (!cell) {
                cell = [[CustomSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RentTypeSwitchTableViewCell"];
                [self setCellTitle:lang(@"RentType") andCell:cell andOffsetY:cellOffsetY];
                [cell setStringsArray:@[[@"\ue626 " stringByAppendingFormat:@"%@", lang(@"All")], [@"\ue624 " stringByAppendingFormat:@"%@", lang(@"RentHouse")], [@"\ue625 " stringByAppendingFormat:@"%@", lang(@"RentRoom")]] withOffsetY:cellOffsetY];
                [cell setSwitchIndex:[CommonFuncs indexOfRentType:_conditionDic[@"rentType"]]];
                _rentTypeSwitchTableViewCell = cell;
            }
            
            return cell;
        }
            break;
        case 3:
        {
            CustomRangeSliderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomRangeSliderTableViewCell"];
            if (!cell) {
                cell = [[CustomRangeSliderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomRangeSliderTableViewCell"];
                [self setCellTitle:lang(@"Budget") andCell:cell andOffsetY:cellOffsetY];
                [cell setMinValue:0 andMaxValue:10000 withOffsetY:cellOffsetY];
                [cell setLeftValue:[_conditionDic[@"minPrice"] floatValue] andRightValue:[_conditionDic[@"maxPrice"] floatValue]];
                _rangeSliderTableViewCell = cell;
            }
            
            return cell;
        }
            break;
        case 4:
        {
            CustomPickerComponentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomsPickerComponentTableViewCell"];
            if (!cell) {
                cell = [[CustomPickerComponentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"roomsPickerComponentTableViewCell"];
                [self setCellTitle:lang(@"SuiteType") andCell:cell andOffsetY:cellOffsetY];
                [cell setStringsArray:@[lang(@"NoLimit"), @"1", @"2", @"3", @"4+"] withOffsetY:cellOffsetY withUnit:lang(@"Room")];
                [cell setSelectedIndex:[_conditionDic[@"roomNumber"] integerValue]];
                _roomsPickerComponentTableViewCell = cell;
            }
            
            return cell;
        }
            break;
        default:
        {
            static NSString *cellIdentifier = @"UITableViewCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            return cell;
        }
            break;
    }
}

- (void)setCellTitle:(NSString *)title andCell:(Room107TableViewCell *)cell andOffsetY:(CGFloat)offsetY {
    CGRect frame = cell.titleLabel.frame;
    frame.origin.y += offsetY;
    [cell.titleLabel setFrame:frame];
    [cell setTitle:title];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return fullAddressTableViewCellMinHeight;
            break;
        case 1:
        case 4:
            return customPickerComponentTableViewCellHeight + cellOffsetY;
            break;
        case 2:
            return customSwitchTableViewCellHeight + cellOffsetY;
            break;
        case 3:
            return customRangeSliderTableViewCellHeight + cellOffsetY;
            break;
        default:
            return 0;
            break;
    }
}

#pragma mark - SuiteSearchFromSubwayViewDelegate
- (void)suiteSearchFromSubwayShouldReturnOrSearchButton:(NSString *)position {
    [_fullAddressTableViewCell setPosition:position];
}

- (void)suiteSearchFromSubwayShouldTappedOnTagPosition:(NSString *)tagPosition atIndex:(NSInteger)index {
    [_fullAddressTableViewCell setPosition:tagPosition];
}

- (void)suiteSearchFromSubwayDidSelectedWithKeyword:(NSString *)keyword {
    [_fullAddressTableViewCell setPosition:keyword];
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
