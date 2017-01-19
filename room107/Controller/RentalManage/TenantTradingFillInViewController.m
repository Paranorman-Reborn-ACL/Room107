//
//  TenantTradingFillInViewController.m
//  room107
//
//  Created by ningxia on 15/9/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "TenantTradingFillInViewController.h"
#import "Room107TableView.h"
#import "RoundedGreenButton.h"
#import "IdentityInfoTableViewCell.h"
#import "CustomShrinkMutableStringTableViewCell.h"
#import "DatePickerTableViewCell.h"
#import "SuiteDescriptionTableViewCell.h"
#import "LicenseAgreementTableViewCell.h"
#import "NSString+Encoded.h"
#import "SystemAgent.h"
#import "CustomMutableStringTableViewCell.h"
#import "CustomTextView.h"
#import "CustomGreenTitleTableViewCell.h"

@interface TenantTradingFillInViewController () <UITableViewDataSource, UITableViewDelegate,UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) Room107TableView *sectionsTableView;
@property (nonatomic, strong) ContractInfoModel *contractInfo;
@property (nonatomic, strong) void (^verifyButtonHandlerBlock)();
@property (nonatomic, strong) IdentityInfoTableViewCell *identityInfoTableViewCell;
@property (nonatomic, strong) DatePickerTableViewCell *checkinDateTableViewCell;
@property (nonatomic, strong) DatePickerTableViewCell *exitDateTableViewCell;
@property (nonatomic, strong) SuiteDescriptionTableViewCell *tenantMoreinfoTableViewCell;
@property (nonatomic, strong) LicenseAgreementTableViewCell *licenseAgreementTableViewCell;
@property (nonatomic) BOOL isOnlinePaymentSecurityHidden;
@property (nonatomic, strong) CustomShrinkMutableStringTableViewCell *paymentMethodExplanationTableViewCell;

@end

@implementation TenantTradingFillInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)createFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 100.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = footerView.frame;
    frame.size.height = 100;
    SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"Verify") andAssistantButtonTitle:@""];
    [footerView addSubview:mutualBottomView];
    [mutualBottomView setMainButtonDidClickHandler:^{
        [self mainButtonDidClick];
    }];
    
    return footerView;
}

- (void)mainButtonDidClick {
    if ([_identityInfoTableViewCell.name isEqualToString:@""] || [_identityInfoTableViewCell.idCard isEqualToString:@""]) {
        [PopupView showMessage:lang(@"TenantInfoIsEmpty")];
        [self scrollToTop];
        return;
    }
    
//最早入住时间判断
//    if ([[TimeUtil getFormatDateStringForTodayWithDateFormat:dateFormatForJSON] compare:_checkinDateTableViewCell.dateString] != NSOrderedAscending) {
//        [PopupView showMessage:lang(@"CheckInDateMustLaterThanToday")];
//        [self scrollToTop];
//        return;
//    }
    
//退组和签约日期时间判断
//    if ([_checkinDateTableViewCell.dateString compare:_exitDateTableViewCell.dateString] != NSOrderedAscending) {
//        [PopupView showMessage:lang(@"CheckInDateMustEarlierThanCheckOutDate")];
//        [self scrollToTop];
//        return;
//    }
    
    _contractInfo.tenantName = _identityInfoTableViewCell.name;
    _contractInfo.tenantIdCard = _identityInfoTableViewCell.idCard;
    _contractInfo.checkinTime = _checkinDateTableViewCell.dateString;
    _contractInfo.exitTime = _exitDateTableViewCell.dateString;
    _contractInfo.payingType = _licenseAgreementTableViewCell.status ? @0 : @1;
    _contractInfo.tenantMoreinfo = [_tenantMoreinfoTableViewCell.suiteDescription URLEncodedString];
    
    if (self.verifyButtonHandlerBlock) {
        self.verifyButtonHandlerBlock();
    }
}

- (void)scrollToTop {
    [_sectionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)setContractInfo:(ContractInfoModel *)contractInfo {
    _contractInfo = contractInfo;
    
    if (!_sections) {
        _sections = [[NSMutableArray alloc] init];
    }
    [_sections removeAllObjects];
    
    AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@2];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:appText.title ? appText.title : @"", @"key", appText.text ? appText.text : @"", @"value", nil]];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"TenantInfo"), @"key", @"", @"value", nil]];
    
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"ConfirmTheFollowingInfo"), @"key", @"", @"value", nil]];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"CheckInDate"), @"key", lang(@"CheckInDateTips"), @"value", nil]];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"CheckOutDate"), @"key", lang(@"CheckOutDateTips"), @"value", nil]];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"AdditionalInfo"), @"key", @"", @"value", nil]];
    
    appText = [[SystemAgent sharedInstance] getTextPropertyByID:@3];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:appText.title ? appText.title : @"", @"key", appText.text ? appText.text : @"", @"value", nil]];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"MonthlyPaymentAgreement"), @"key", @"", @"value", nil]];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"ChooseMonthlyPayment"), @"key", @"", @"value", nil]];
    
    if (!_sectionsTableView) {
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        _sectionsTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _sectionsTableView.delegate = self;
        _sectionsTableView.dataSource = self;
        _sectionsTableView.tableFooterView = [self createFooterView];
        [self.view addSubview:_sectionsTableView];
        
        _isOnlinePaymentSecurityHidden = NO;
        _paymentMethodExplanationTableViewCell = [[CustomShrinkMutableStringTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomShrinkMutableStringTableViewCell"];
    }
    
    if (_identityInfoTableViewCell) {
        [_identityInfoTableViewCell setName:_contractInfo.tenantName];
        [_identityInfoTableViewCell setIDCard:_contractInfo.tenantIdCard];
    }
    
    [_sectionsTableView reloadData];
    [self scrollToTop];
}

- (void)setVerifyButtonDidClickHandler:(void(^)())handler {
    self.verifyButtonHandlerBlock = handler;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            static NSString *cellID = @"cellID";
            CustomGreenTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (nil == cell) {
                cell = [[CustomGreenTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID withTitle:_sections[indexPath.row][@"key"]];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        case 1:
        {
            IdentityInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IdentityInfoTableViewCell"];
            if (!cell) {
                cell = [[IdentityInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IdentityInfoTableViewCell"];
                [cell setTitle:_sections[indexPath.row][@"key"]];
                _identityInfoTableViewCell = cell;
                _identityInfoTableViewCell.name = _contractInfo.tenantName;
                [_identityInfoTableViewCell setIDCard:_contractInfo.tenantIdCard];
            }
            
            return cell;
        }
            break;
        case 2:
        {
            CustomMutableStringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomMutableStringTableViewCell"];
            if (!cell) {
                cell = [[CustomMutableStringTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomMutableStringTableViewCell"];
            }
            [cell setContentColor:[UIColor room107YellowColor]];
            [cell setContent:_sections[indexPath.row][@"key"]];
            
            return cell;
        }
            break;
        case 3:
        {
            DatePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckinDatePickerTableViewCell"];
            if (!cell) {
                cell = [[DatePickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CheckinDatePickerTableViewCell"];
                [cell setTitle:_sections[indexPath.row][@"key"]];
                [cell setTips:@""];
                _checkinDateTableViewCell = cell;
                [_checkinDateTableViewCell setDate:_contractInfo.checkinTime];
            }
            
            return cell;
        }
            break;
        case 4:
        {
            DatePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExitDatePickerTableViewCell"];
            if (!cell) {
                cell = [[DatePickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ExitDatePickerTableViewCell"];
                [cell setTitle:_sections[indexPath.row][@"key"]];
                [cell setTips:@""];
                _exitDateTableViewCell = cell;
                [_exitDateTableViewCell setDate:_contractInfo.exitTime];
            }
            
            return cell;
        }
            break;
        case 5:
        {
            SuiteDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuiteDescriptionTableViewCell"];
            if (!cell) {
                cell = [[SuiteDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteDescriptionTableViewCell"];
                [cell setTitle:_sections[indexPath.row][@"key"]];
                _tenantMoreinfoTableViewCell = cell;
                cell.suiteDescriptionTextView.delegate = self;
                [_tenantMoreinfoTableViewCell setPlaceholder:lang(@"AdditionalExample")];
                [_tenantMoreinfoTableViewCell setSuiteDescription:_contractInfo.tenantMoreinfo ? [_contractInfo.tenantMoreinfo URLDecodedString] : @""];
            }
            return cell;
        }
            break;
        case 6:
        {
            CustomShrinkMutableStringTableViewCell *cell = [[CustomShrinkMutableStringTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomShrinkMutableStringTableViewCell"];
            [cell setContent:_sections[indexPath.row][@"value"]];
            [cell setShrinkHidden:YES];
            [cell setSubtitle:_sections[indexPath.row][@"key"]];
            
            return cell;
        }
            break;
        case 7:
        {
            CustomMutableStringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomMutableStringTableViewCell"];
            if (!cell) {
                cell = [[CustomMutableStringTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomMutableStringTableViewCell"];
            }
            [cell setContent:_sections[indexPath.row][@"key"] withAlignment:NSTextAlignmentRight];
            [cell setContentColor:[UIColor room107GreenColor]];
            [cell setViewDidClickHandler:^{
                [self viewMonthlyPaymentExplanation];
            }];
            
            return cell;
        }
            break;
        default:
        {
            LicenseAgreementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LicenseAgreementTableViewCell"];
            if (!cell) {
                cell = [[LicenseAgreementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LicenseAgreementTableViewCell"];
                [cell setContent:_sections[indexPath.row][@"key"]];
                _licenseAgreementTableViewCell = cell;
                [_licenseAgreementTableViewCell setStatus:[_contractInfo.payingType isEqual:@0]];
            }
            
            return cell;
        }
            break;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return customGreenTitleTableViewCellHeight;
            break;
        case 1:
            return identityInfoTableViewCellHeight;
            break;
        case 2:
            return 90;
            break;
        case 3:
        case 4:
            return datePickerTableViewCellHeight;
            break;
        case 5:
            return suiteDescriptionTableViewCellHeight;
            break;
        case 6:
            return [_paymentMethodExplanationTableViewCell getCellHeightWithContent:_sections[indexPath.row][@"value"]];
            break;
        case 7:
            return 40;
            break;
        default:
            return licenseAgreementTableViewCellHeight;
            break;
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
     [UIView animateWithDuration:0.5 animations:^{
         self.sectionsTableView.contentOffset = CGPointMake(0, customGreenTitleTableViewCellHeight + identityInfoTableViewCellHeight + 90 + datePickerTableViewCellHeight*2 + 35);
     }];
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    [(CustomTextView *)textView showPlaceholder:textView.text.length == 0 ? YES : NO];
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
