//
//  LandlordTradingFillInViewController.m
//  room107
//
//  Created by ningxia on 15/9/9.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LandlordTradingFillInViewController.h"
#import "Room107TableView.h"
#import "RoundedGreenButton.h"
#import "MonthlyRentTableViewCell.h"
#import "FullAddressTableViewCell.h"
#import "SuiteDescriptionTableViewCell.h"
#import "NSNumber+Additions.h"
#import "NSString+Encoded.h"
#import "SystemAgent.h"
#import "YellowColorTextLabel.h"
#import "CustomTextView.h"
#import "NXIconTextField.h"
#import "RegularExpressionUtil.h"

@interface LandlordTradingFillInViewController () <UITableViewDataSource, UITableViewDelegate,UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) Room107TableView *sectionsTableView;
@property (nonatomic, strong) ContractInfoModel *contractInfo;
@property (nonatomic, strong) void (^verifyButtonHandlerBlock)();
@property (nonatomic, strong) MonthlyRentTableViewCell *monthlyRentTableViewCell;
@property (nonatomic, strong) FullAddressTableViewCell *fullAddressTableViewCell;
@property (nonatomic, strong) SuiteDescriptionTableViewCell *landlordMoreinfoTableViewCell;
@property (nonatomic, assign) CGSize oldSize;
@end

@implementation LandlordTradingFillInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIView *)createHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 100.0f}];
    
    CGRect frame = headerView.frame;
    frame.origin.x = 33;
    frame.size.width -= 2 * frame.origin.x;
    AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@0];
    YellowColorTextLabel *additionalLandlordSignInfoLabel = [[YellowColorTextLabel alloc] initWithFrame:frame withTitle:[@"●" stringByAppendingString:appText.text ? appText.text : @""]];
    [headerView addSubview:additionalLandlordSignInfoLabel];
    
    return headerView;
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
    if (![[_monthlyRentTableViewCell price] isPureInt] || [[_monthlyRentTableViewCell price] isEqual:@0]) {
        [PopupView showMessage:lang(@"RentMoneyIsEmpty")];
        [self scrollToTop];
        return;
    }
    
    if ([[_fullAddressTableViewCell position] isEmpty]) {
        [PopupView showMessage:lang(@"AddressIsEmpty")];
        [self scrollToTop];
        return;
    }
    
    _contractInfo.monthlyPrice = _monthlyRentTableViewCell.price;
    _contractInfo.rentAddress = [_fullAddressTableViewCell.position URLEncodedString];
    _contractInfo.landlordMoreinfo = [_landlordMoreinfoTableViewCell.suiteDescription URLEncodedString];
    
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
    
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"ContractMoney"), @"key", [_contractInfo.monthlyPrice stringValue], @"value", nil]];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"FullAddress"), @"key", _contractInfo.rentAddress, @"value", nil]];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[lang(@"ObjectInfo") stringByAppendingFormat:@"（%@）", lang(@"Optional")], @"key", _contractInfo.landlordMoreinfo, @"value", nil]];
    
    if (!_sectionsTableView) {
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        
        _sectionsTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _sectionsTableView.delegate = self;
        _sectionsTableView.dataSource = self;
        _sectionsTableView.tableHeaderView = [self createHeaderView];
        _sectionsTableView.tableFooterView = [self createFooterView];
        [self.view addSubview:_sectionsTableView];
        self.oldSize = self.sectionsTableView.contentSize;
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
            MonthlyRentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonthlyRentTableViewCell"];
            if (!cell) {
                cell = [[MonthlyRentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MonthlyRentTableViewCell"];
                cell.priceTextField.delegate = self;
                [cell setTitle:_sections[indexPath.row][@"key"]];
                _monthlyRentTableViewCell = cell;
                [_monthlyRentTableViewCell setPrice:_contractInfo.monthlyPrice];
            }
            
            return cell;
        }
            break;
        case 1:
        {
            FullAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FullAddressTableViewCell"];
            if (!cell) {
                cell = [[FullAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FullAddressTableViewCell"];
                [cell setTitle:_sections[indexPath.row][@"key"]];
                cell.cellBlock = ^(void){
                  [UIView animateWithDuration:0.5 animations:^{
                      self.sectionsTableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.sectionsTableView.tableHeaderView.frame) + monthlyRentTableViewCellHeight);
                  }];
                };
                _fullAddressTableViewCell = cell;
                [_fullAddressTableViewCell setPosition:_contractInfo.rentAddress];
            }
            
            return cell;
        }
            break;
        default:
        {
            SuiteDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuiteDescriptionTableViewCell"];
            if (!cell) {
                cell = [[SuiteDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteDescriptionTableViewCell"];
                [cell setTitle:_sections[indexPath.row][@"key"]];
                _landlordMoreinfoTableViewCell = cell;
                _landlordMoreinfoTableViewCell.suiteDescriptionTextView.delegate = self;
                [_landlordMoreinfoTableViewCell setPlaceholder:lang(@"LandlordMoreInfo")];
                [_landlordMoreinfoTableViewCell setSuiteDescription:_contractInfo.landlordMoreinfo ?  [_contractInfo.landlordMoreinfo URLDecodedString] : @""];
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
            return monthlyRentTableViewCellHeight;
            break;
        case 1:
            return fullAddressTableViewCellMinHeight;
            break;
        default:
            return suiteDescriptionTableViewCellHeight;
            break;
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    CGSize newSize = CGSizeMake(self.oldSize.width, self.oldSize.height+2000);
       self.sectionsTableView.contentSize = newSize;
    [UIView animateWithDuration:0.5 animations:^{
        self.sectionsTableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.sectionsTableView.tableHeaderView.frame) + monthlyRentTableViewCellHeight + fullAddressTableViewCellMinHeight);
    }];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
        [(CustomTextView *)textView showPlaceholder:textView.text.length == 0 ? YES : NO];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.5 animations:^{
        self.sectionsTableView.contentSize = self.oldSize;
    }];
    
    return YES;
}
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _monthlyRentTableViewCell.priceTextField) {
        //校验纯数字，兼容退格键
        return string.length > 0 ? [RegularExpressionUtil validNumber:string] : YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _monthlyRentTableViewCell.priceTextField) {
            [UIView animateWithDuration:0.5 animations:^{
            self.sectionsTableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.sectionsTableView.tableHeaderView.frame));
        }];
    }
    
    return YES;
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
