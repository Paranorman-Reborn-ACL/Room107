//
//  TenantTradingContractConfirmViewController.m
//  room107
//
//  Created by ningxia on 15/9/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "TenantTradingContractConfirmViewController.h"
#import "Room107TableView.h"
#import "RoundedGreenButton.h"
#import "CustomInfoItemTableViewCell.h"
#import "LicenseAgreementTableViewCell.h"
#import "YellowColorTextLabel.h"
#import "SystemAgent.h"
#import "NSString+Valid.h"
#import "CustomMutableStringTableViewCell.h"

@interface TenantTradingContractConfirmViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) Room107TableView *sectionsTableView;
@property (nonatomic, strong) void (^confirmContractButtonHandlerBlock)();
@property (nonatomic, strong) void (^changeContractButtonHandlerBlock)();
@property (nonatomic, strong) LicenseAgreementTableViewCell *licenseAgreementTableViewCell;
@property (nonatomic, strong) NSArray *diff;

@end

@implementation TenantTradingContractConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setContractInfo:(ContractInfoModel *)contractInfo andDifferent:(NSArray *)diff {
    _diff = diff;
    [self refreshDataWithContractInfo:contractInfo];
    if (_diff && _diff.count > 0) {
        [self showAlertViewWithTitle:lang(@"LandlordInfoChangedTips") message:@""];
    }
}

- (void)refreshDataWithContractInfo:(ContractInfoModel *)contractInfo {
    if (!_sections) {
        _sections = [[NSMutableArray alloc] init];
    }
    [_sections removeAllObjects];
    
    NSMutableArray *followingInfos = [[NSMutableArray alloc] init];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"RentMoney"), @"key", [@"￥" stringByAppendingString:[contractInfo.monthlyPrice stringValue] ? [contractInfo.monthlyPrice stringValue] : @""], @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"monthlyPrice"]], @"diff", nil]];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Address"), @"key", contractInfo.rentAddress, @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"rentAddress"]], @"diff", nil]];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"PaymentType"), @"key", [contractInfo.payingType isEqualToNumber:@0] ? lang(@"MonthlyPayment") : lang(@"QuarterlyPayment"), @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"payingType"]], @"diff", nil]];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"LeaseTerm"), @"key", [NSString stringWithFormat:@"%@-%@", [TimeUtil friendlyDateTimeFromDateTime:contractInfo.checkinTime withFormat:@"%Y/%m/%d"], [TimeUtil friendlyDateTimeFromDateTime:contractInfo.exitTime withFormat:@"%Y/%m/%d"]], @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"checkinTime"] || [CommonFuncs arrayHasThisContent:_diff andObject:@"exitTime"]], @"diff", nil]];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Renter"), @"key", contractInfo.tenantName, @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"tenantName"]], @"diff", nil]];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"IDNumber"), @"key", contractInfo.tenantIdCard, @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"tenantIdCard"]], @"diff", nil]];
    
    if (contractInfo.tenantMoreinfo && (contractInfo.tenantMoreinfo.length != 0)) {
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"TenantAdditionalInfo"), @"key", contractInfo.tenantMoreinfo, @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"tenantMoreinfo"]], @"diff", nil]];
    }
    
    if (contractInfo.landlordMoreinfo && (contractInfo.landlordMoreinfo.length != 0)) {
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"LandlordAdditionalInfo"), @"key", contractInfo.landlordMoreinfo, @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"landlordMoreinfo"]], @"diff", nil]];
    }

    //保障费用
    if (contractInfo.contractFee && ![contractInfo.contractFee isEqual:@0]) {
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"ContractFee"), @"key", [[CommonFuncs moneyStrByDouble:[contractInfo.contractFee doubleValue] / 100] stringByAppendingString:lang(@"PerMonth")], @"value", nil]];
    }
    
    if ([contractInfo.payingType isEqualToNumber:@0] && contractInfo.instalmentFee) {
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"InstalmentFee"), @"key", [[CommonFuncs moneyStrByDouble:[contractInfo.instalmentFee doubleValue] / 100] stringByAppendingString:lang(@"PerMonth")], @"value", nil]];
    }
    
    if ([contractInfo.payingType isEqualToNumber:@0] && contractInfo.instalmentFeeRate) {
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"InstalmentFeeRate"), @"key", [lang(@"RentMoneyMonthly") stringByAppendingFormat:@"*%@", [CommonFuncs percentString:[contractInfo.instalmentFeeRate floatValue]]], @"value", nil]];
    }
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"PricingRules"), @"key", @"", @"value", nil]];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"MoreRentalInfo"), @"key", followingInfos, @"value", nil]];
    
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"ConfirmContractTips"), @"key", [NSMutableArray arrayWithObjects:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@""), @"key", lang(@"ReadAndConfirmContractTips"), @"value", nil], nil], @"value", nil]];
    
    if (!_sectionsTableView) {
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        
        _sectionsTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _sectionsTableView.delegate = self;
        _sectionsTableView.dataSource = self;
        _sectionsTableView.tableFooterView = [self createFooterView];
        [self.view addSubview:_sectionsTableView];
    }
    [_sectionsTableView reloadData];
    [self scrollToTop];
}

- (void)scrollToTop {
    [_sectionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (UIView *)createFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 100.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = footerView.frame;
    frame.size.height = 100;
    SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"Signed") andAssistantButtonTitle:lang(@"RefillContract")];
    [footerView addSubview:mutualBottomView];
    [mutualBottomView setMainButtonDidClickHandler:^{
        [self mainButtonDidClick];
    }];
    [mutualBottomView setAssistantButtonDidClickHandler:^{
        [self assistantButtonDidClick];
    }];
    
    return footerView;
}

- (void)mainButtonDidClick {
    if (!_licenseAgreementTableViewCell.status) {
        [PopupView showMessage:lang(@"PleaseConfirmContract")];
        return;
    }
    
    if (self.confirmContractButtonHandlerBlock) {
        self.confirmContractButtonHandlerBlock();
    }
}

- (void)assistantButtonDidClick {
    if (self.changeContractButtonHandlerBlock) {
        self.changeContractButtonHandlerBlock();
    }
}

- (void)setConfirmContractButtonDidClickHandler:(void(^)())handler {
    _confirmContractButtonHandlerBlock = handler;
}

- (void)setChangeContractButtonDidClickHandler:(void(^)())handler {
    _changeContractButtonHandlerBlock = handler;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSMutableArray *)_sections[section][@"value"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            NSInteger maxRow = [(NSMutableArray *)_sections[indexPath.section][@"value"] count] - 1;
            if (indexPath.row == maxRow) {
                CustomMutableStringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomMutableStringTableViewCell"];
                if (!cell) {
                    cell = [[CustomMutableStringTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomMutableStringTableViewCell"];
                }
//                [cell setContent:_sections[indexPath.section][@"value"][indexPath.row][@"key"] withAlignment:NSTextAlignmentRight];
                [cell setContentColor:[UIColor room107GreenColor]];
                [cell setViewDidClickHandler:^{
                    [self viewPricingRules];
                }];
                [cell setBackgroundColor:[UIColor redColor]];
                return cell;
            } else {
                CustomInfoItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomInfoItemTableViewCell"];
                if (!cell) {
                    cell = [[CustomInfoItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomInfoItemTableViewCell"];
                }
                [cell setName:_sections[indexPath.section][@"value"][indexPath.row][@"key"]];
                [cell setContent:_sections[indexPath.section][@"value"][indexPath.row][@"value"]];
                if ([_sections[indexPath.section][@"value"][indexPath.row][@"diff"] boolValue]) {
                    [cell setContentColor:[UIColor room107YellowColor]];
                }
                
                return cell;
            }
        }
            break;
        default:
        {
            LicenseAgreementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LicenseAgreementTableViewCell"];
            if (!cell) {
                cell = [[LicenseAgreementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LicenseAgreementTableViewCell"];
                [cell setContent:_sections[indexPath.section][@"value"][indexPath.row][@"value"]];
                _licenseAgreementTableViewCell = cell;
            }
            
            return cell;
        }
            break;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            NSInteger maxRow = [(NSMutableArray *)_sections[indexPath.section][@"value"] count] - 1;
            if (indexPath.row == maxRow) {
                return 0;
            } else {
            return customInfoItemTableViewCellHeight;
            }
        }
            break;
        default:
            return licenseAgreementTableViewCellHeight;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]};
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    frame.origin.x = 33;
    frame.size.width -= 2 * frame.origin.x;
    YellowColorTextLabel *readAndConfirmContractTipsLabel = [[YellowColorTextLabel alloc] initWithFrame:frame withTitle:_sections[section][@"key"]];
    [headerView addSubview:readAndConfirmContractTipsLabel];
    
    return headerView;
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
