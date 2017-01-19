//
//  HouseInfoManageViewController.m
//  room107
//
//  Created by ningxia on 15/8/28.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HouseInfoManageViewController.h"
#import "Room107TableView.h"
#import "RoundedGreenButton.h"
#import "RequiredGenderTableViewCell.h"
#import "MonthlyRentTableViewCell.h"
#import "SuiteRegionTableViewCell.h"
#import "FullAddressTableViewCell.h"
#import "SuiteTypeTableViewCell.h"
#import "AreaTableViewCell.h"
#import "FloorTableViewCell.h"
#import "SuiteDescriptionTableViewCell.h"
#import "SuiteFacilitiesTableViewCell.h"
#import "ContactInfoTableViewCell.h"
#import "HouseManageAgent.h"
#import "NSString+Encoded.h"
#import "NSDictionary+JSONString.h"
#import "NSNumber+Additions.h"
#import "CustomTextField.h"
#import "CustomTextView.h"
#import "NXIconTextField.h"
#import <CoreText/CoreText.h>
#import "OnlineDiscountTableViewCell.h"
#import "NSString+IsPureNumer.h"
#import "RegularExpressionUtil.h"
#import "DatePickerTableViewCell.h"

@interface HouseInfoManageViewController () <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,CustomTextFieldDelegate>

@property (nonatomic, strong) NSString *imageToken;
@property (nonatomic, strong) NSString *imageKeyPattern;
@property (nonatomic, strong) NSMutableDictionary *houseJSON;//描述房子信息（不含房子信息），json格式，json对应的数据结构为LandlordSuiteItem，json整体进行urlEncode
@property (nonatomic, strong) NSMutableArray *houseItems;
@property (nonatomic, strong) NSArray *houseKeysArray;
@property (nonatomic, strong) Room107TableView *houseInfoTableView;
@property (nonatomic, strong) RequiredGenderTableViewCell *requiredGenderTableViewCell;
@property (nonatomic, strong) MonthlyRentTableViewCell *monthlyRentTableViewCell;
@property (nonatomic, strong) SuiteRegionTableViewCell *suiteRegionTableViewCell;
@property (nonatomic, strong) FullAddressTableViewCell *fullAddressTableViewCell;
@property (nonatomic, strong) SuiteTypeTableViewCell *suiteTypeTableViewCell;
@property (nonatomic, strong) AreaTableViewCell *areaTableViewCell;
@property (nonatomic, strong) FloorTableViewCell *floorTableViewCell;
@property (nonatomic, strong) SuiteDescriptionTableViewCell *suiteDescriptionTableViewCell;
@property (nonatomic, strong) SuiteFacilitiesTableViewCell *suiteFacilitiesTableViewCell;
@property (nonatomic, strong) SuiteFacilitiesTableViewCell *suiteFacilitiesRentTableViewCell;
@property (nonatomic, strong) ContactInfoTableViewCell *contactInfoTableViewCell;
@property (nonatomic, strong) OnlineDiscountTableViewCell *onlineDiscountTableViewCell;
@property (nonatomic, strong) DatePickerTableViewCell *datePickerTableViewCell;
@property (nonatomic, strong) void (^dismissHandlerBlock)();
@property (nonatomic, assign) CGSize oldContentOfSize;
@property (nonatomic, assign) CGFloat heightOfInfo;
@property (nonatomic, assign) BOOL isChanged;
@property (nonatomic, strong) UITapGestureRecognizer *tapHideKeyboard;
@end

@implementation HouseInfoManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _houseItems = [NSMutableArray arrayWithObjects:[_houseJSON[@"rentType"] isEqual:[CommonFuncs rentTypeForHouse]] ? lang(@"MonthlyRent") : lang(@"RequiredGender"), lang(@"SuiteRegion"), lang(@"FullAddress"), lang(@"SuiteType"), [NSString stringWithFormat:@"%@（m²）", lang(@"Area")], lang(@"FloorTips"), lang(@"SuiteDescription"), lang(@"SuiteFacilities"), lang(@"ContactInfo"), lang(@"EarliestCheckin"), lang(@"RentsIncludeFees"), nil];
    
    _houseKeysArray = @[[_houseJSON[@"rentType"] isEqual:@2] ? @"price" : lang(@"requiredGender"), @"district", @"position", @[@"roomNumber", @"hallNumber", @"kitchenNumber", @"toiletNumber"], @"area", @"floor", @"description", @"facilities", @[@"telephone", @"wechat", @"qq"], @"checkinTime", @"extraFees"];
    
    CGRect frame = self.view.frame;
    frame.size.height -= statusBarHeight + navigationBarHeight + [self heightOfSegmentedControl];
    _houseInfoTableView = [[Room107TableView alloc] initWithFrame:frame];
    _houseInfoTableView.delegate = self;
    _houseInfoTableView.dataSource = self;
    _houseInfoTableView.tableHeaderView = [self createTableHeaderView];
    _houseInfoTableView.tableFooterView = [self createTableFooterView];
    [self.view addSubview:_houseInfoTableView];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide)  name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow)  name:UIKeyboardWillShowNotification object:nil];
    
    self.tapHideKeyboard = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];

}

- (UIView *)createTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 20.0f}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    return headerView;
}

- (UIView *)createTableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 100.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = footerView.frame;
    frame.size.height = 100;
    SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"SaveInfo") andAssistantButtonTitle:@""];
    [footerView addSubview:mutualBottomView];
    [mutualBottomView setMainButtonDidClickHandler:^{
        [self saveInfo];
    }];
    
    return footerView;
}

- (void)setViewControllerDismissHandler:(void(^)())handler {
    _dismissHandlerBlock = handler;
    
    if (!_suiteRegionTableViewCell  || !_fullAddressTableViewCell || !_suiteTypeTableViewCell || !_areaTableViewCell || !_floorTableViewCell || !_suiteDescriptionTableViewCell || !_suiteFacilitiesTableViewCell || !_contactInfoTableViewCell) {
        if (_dismissHandlerBlock) {
            _dismissHandlerBlock();
            return;
        }
    }
    
    NSString *title = lang(@"WhetherToSave");
    NSString *message = @"";
    NSString *cancelButtonTitle = lang(@"Cancel");
    NSString *otherTitle = lang(@"Save");
    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:cancelButtonTitle action:^{
        if (_dismissHandlerBlock) {
            _dismissHandlerBlock();
        }
    }];
    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:otherTitle action:^{
        [self saveInfo];
    }];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
    [alert show];
}

- (void)saveInfo {
    if ([[_fullAddressTableViewCell position] isEmpty]) {
        [PopupView showMessage:lang(@"AddressIsEmpty")];
        return;
    }
    
    if ([[_suiteTypeTableViewCell roomNumber] integerValue] <= 0) {
        [PopupView showMessage:lang(@"BedroomNumberIsZero")];
        return;
    }
    
    if ([[_areaTableViewCell area] isEqual:@0]) {
        [PopupView showMessage:lang(@"AreaIsZero")];
        return;
    }
    
    if ([[_suiteDescriptionTableViewCell suiteDescription] isEmpty]) {
        [PopupView showMessage:lang(@"SuiteDescriptionIsEmpty")];
        return;
    }
    
    if (![_contactInfoTableViewCell isTelephoneOn] && [[_contactInfoTableViewCell wechat] isEmpty] && [[_contactInfoTableViewCell qq] isEmpty]) {
        [PopupView showMessage:lang(@"ContactInfoIsEmpty")];
        return;
    } else if (![[_contactInfoTableViewCell qq] isEmpty] && !([RegularExpressionUtil validNumber:[_contactInfoTableViewCell qq]] || [RegularExpressionUtil validEmail:[_contactInfoTableViewCell qq]])) {
        //QQ账号（纯数字或邮箱格式）
        [PopupView showMessage:lang(@"QQIsError")];
        return;
    }
    
    if ([_houseJSON[@"rentType"] isEqual:@2]) {
        if (![[_monthlyRentTableViewCell price] isPureInt] || [[_monthlyRentTableViewCell price] isEqual:@0]) {
            [PopupView showMessage:lang(@"RentMoneyIsEmpty")];
            return;
        }
    }
    
    for (NSUInteger i = 0; i < _houseKeysArray.count; i++) {
        switch (i) {
            case 0:
                if ([_houseJSON[@"rentType"] isEqual:@2]) {
                    [_houseJSON setObject:[_monthlyRentTableViewCell price] forKey:@"price"];
                } else {
                    [_houseJSON setObject:[NSNumber numberWithInteger:[_requiredGenderTableViewCell requiredGender]] forKey:_houseKeysArray[i]];
                }
                break;
            case 1:
                [_houseJSON setObject:[_suiteRegionTableViewCell district] forKey:_houseKeysArray[i]];
                break;
            case 2:
                [_houseJSON setObject:[_fullAddressTableViewCell position] forKey:_houseKeysArray[i]];
                break;
            case 3:
                [_houseJSON setObject:[_suiteTypeTableViewCell roomNumber] forKey:_houseKeysArray[i][0]];
                [_houseJSON setObject:[_suiteTypeTableViewCell hallNumber] forKey:_houseKeysArray[i][1]];
                [_houseJSON setObject:[_suiteTypeTableViewCell kitchenNumber] forKey:_houseKeysArray[i][2]];
                [_houseJSON setObject:[_suiteTypeTableViewCell toiletNumber] forKey:_houseKeysArray[i][3]];
                break;
            case 4:
                [_houseJSON setObject:[_areaTableViewCell area] forKey:_houseKeysArray[i]];
                break;
            case 5:
                [_houseJSON setObject:[_floorTableViewCell floor] forKey:_houseKeysArray[i]];
                break;
            case 6:
                [_houseJSON setObject:[_suiteDescriptionTableViewCell suiteDescription] forKey:_houseKeysArray[i]];
                break;
            case 7:
                [_houseJSON setObject:[_suiteFacilitiesTableViewCell suiteFacilities] forKey:_houseKeysArray[i]];
                break;
            case 8:
                if ([_contactInfoTableViewCell isTelephoneOn]) {
                    [_houseJSON setObject:[_contactInfoTableViewCell telephone] forKey:_houseKeysArray[i][0]];
                } else {
                    [_houseJSON removeObjectForKey:_houseKeysArray[i][0]];
                }
                
                [_houseJSON setObject:[_contactInfoTableViewCell wechat] forKey:_houseKeysArray[i][1]];
                [_houseJSON setObject:[_contactInfoTableViewCell qq] forKey:_houseKeysArray[i][2]];
                break;
            case 9:
                if (_datePickerTableViewCell) {
                    [_houseJSON setObject:_datePickerTableViewCell.dateString forKey:_houseKeysArray[i]];
                }
                break;
            case 10:
                if (_suiteFacilitiesRentTableViewCell) {
                    [_houseJSON setObject:[_suiteFacilitiesRentTableViewCell suiteFacilities] forKey:_houseKeysArray[i]];
                }
                break;
            default:
                break;
        }
    }
    
    NSString *encodedHouseJSON = [[_houseJSON JSONRepresentationWithPrettyPrint:YES] URLEncodedString];
    NSMutableDictionary *houseInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:encodedHouseJSON, @"house", nil];
    [self showLoadingView];
    [[HouseManageAgent sharedInstance] updateHouseWithHouseInfo:houseInfo completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            if (_dismissHandlerBlock) {
                _dismissHandlerBlock();
            }
            [PopupView showMessage:lang(@"InfoUpdated")];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (id)initWithImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseJSON:(NSMutableDictionary *)houseJSON {
    self = [super init];
    if (self != nil) {
        _imageToken = imageToken;
        _imageKeyPattern = imageKeyPattern;
        _houseJSON = houseJSON;
    }
    return self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _houseItems.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            if ([_houseJSON[@"rentType"] isEqual:@2]) {
                MonthlyRentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonthlyRentTableViewCell"];
                if (!cell) {
                    cell = [[MonthlyRentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MonthlyRentTableViewCell"];
                    [cell setTitle:_houseItems[indexPath.row]];
                }
                
                if (!_monthlyRentTableViewCell) {
                    _monthlyRentTableViewCell = cell;
                    [_monthlyRentTableViewCell setPrice:_houseJSON[_houseKeysArray[indexPath.row]]];
                    _monthlyRentTableViewCell.priceTextField.delegate = self;
                }
                
                return cell;
            } else {
                RequiredGenderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequiredGenderTableViewCell"];
                if (!cell) {
                    cell = [[RequiredGenderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RequiredGenderTableViewCell"];
                    [cell setTitle:_houseItems[indexPath.row]];
                }
                
                if (!_requiredGenderTableViewCell) {
                    _requiredGenderTableViewCell = cell;
                    [_requiredGenderTableViewCell setRequiredGender:[_houseJSON[_houseKeysArray[indexPath.row]] integerValue]];
                }
                
                return cell;
            }
        }
            break;
        case 1:
        {
            SuiteRegionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuiteRegionTableViewCell"];
            if (!cell) {
                cell = [[SuiteRegionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteRegionTableViewCell"];
                [cell setTitle:_houseItems[indexPath.row]];
            }
            
            if (!_suiteRegionTableViewCell) {
                _suiteRegionTableViewCell = cell;
                [_suiteRegionTableViewCell setDistrict:_houseJSON[_houseKeysArray[indexPath.row]]];
            }
            
            return cell;
        }
            break;
        case 2:
        {
            FullAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FullAddressTableViewCell"];
            if (!cell) {
                cell = [[FullAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FullAddressTableViewCell"];
                cell.cellBlock = ^(void){
                    CGFloat contentOffsetY;
                    if ([_houseJSON[@"rentType"] isEqual:@2]) {
                        contentOffsetY = monthlyRentTableViewCellHeight+onlineDiscountTableViewCellHeight+suiteRegionTableViewCellHeight;
                    } else {
                        contentOffsetY = requiredGenderTableViewCellHeight+suiteRegionTableViewCellHeight;
                    }
                    [UIView animateWithDuration:0.5 animations:^{
                        self.houseInfoTableView.contentOffset = CGPointMake(0, contentOffsetY+15);
                    }];

                };
                [cell setTitle:_houseItems[indexPath.row]];
            }
            
            if (!_fullAddressTableViewCell) {
                _fullAddressTableViewCell = cell;
                [_fullAddressTableViewCell setPosition:_houseJSON[_houseKeysArray[indexPath.row]]];
            }
            
            return cell;
        }
            break;
        case 3:
        {
            SuiteTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuiteTypeTableViewCell"];
            if (!cell) {
                cell = [[SuiteTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteTypeTableViewCell"];
                [cell setTitle:_houseItems[indexPath.row]];
            }
            if (!_suiteTypeTableViewCell) {
                _suiteTypeTableViewCell = cell;
                [_suiteTypeTableViewCell setRoomNumber:_houseJSON[_houseKeysArray[indexPath.row][0]]];
                [_suiteTypeTableViewCell setHallNumber:_houseJSON[_houseKeysArray[indexPath.row][1]]];
                [_suiteTypeTableViewCell setKitchenNumber:_houseJSON[_houseKeysArray[indexPath.row][2]]];
                [_suiteTypeTableViewCell setToiletNumber:_houseJSON[_houseKeysArray[indexPath.row][3]]];
            }
            
            return cell;
        }
            break;
        case 4:
        {
            AreaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AreaTableViewCell"];
            if (!cell) {
                cell = [[AreaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AreaTableViewCell"];
                [cell setTitle:_houseItems[indexPath.row]];
            }
            
            if (!_areaTableViewCell) {
                _areaTableViewCell = cell;
                [_areaTableViewCell setArea:_houseJSON[_houseKeysArray[indexPath.row]]];
            }
            
            return cell;
        }
            break;
        case 5:
        {
            FloorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FloorTableViewCell"];
            if (!cell) {
                cell = [[FloorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FloorTableViewCell"];
                [cell setTitle:_houseItems[indexPath.row]];
            }
            
            if (!_floorTableViewCell) {
                _floorTableViewCell = cell;
                [_floorTableViewCell setFloor:_houseJSON[_houseKeysArray[indexPath.row]]];
            }
            
            return cell;
        }
            break;
        case 6:
        {
            SuiteDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuiteDescriptionTableViewCell"];
            if (!cell) {
                cell = [[SuiteDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteDescriptionTableViewCell"];
                [cell setTitle:_houseItems[indexPath.row]];
                cell.suiteDescriptionTextView.delegate = self;
                [cell setPlaceholder:lang(@"SuiteDescriptionTips")];
            }
            
            if (!_suiteDescriptionTableViewCell) {
                _suiteDescriptionTableViewCell = cell;
                [_suiteDescriptionTableViewCell setSuiteDescription:_houseJSON[_houseKeysArray[indexPath.row]]];
            }
            
            return cell;
        }
            break;
        case 7:
        {
            SuiteFacilitiesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuiteFacilitiesTableViewCell"];
            if (!cell) {
                cell = [[SuiteFacilitiesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteFacilitiesTableViewCell"];
                [cell setTitle:_houseItems[indexPath.row]];
                  [cell setSourceFacilities:@[@{@"icon":@"\ue600", @"content":lang(@"TV")}, @{@"icon":@"\ue601", @"content":lang(@"Fridge")}, @{@"icon":@"\ue602", @"content":lang(@"Washer")}, @{@"icon":@"\ue603", @"content":lang(@"AirConditioner")}, @{@"icon":@"\ue604", @"content":lang(@"Elevator")}, @{@"icon":@"\ue605", @"content":lang(@"WaterHeater")}, @{@"icon":@"\ue606", @"content":lang(@"WIFI")}, @{@"icon":@"\ue607", @"content":lang(@"Balcony")}]];
            }
            
            if (!_suiteFacilitiesTableViewCell) {
                _suiteFacilitiesTableViewCell = cell;
                [_suiteFacilitiesTableViewCell setSuiteFacilities:_houseJSON[_houseKeysArray[indexPath.row]]];
            }
            return cell;
        }
            break;
        case 8:
        {
            ContactInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactInfoTableViewCell"];
            if (!cell) {
                cell = [[ContactInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactInfoTableViewCell"];
                cell.telephoneTextField.delegate = self;
                cell.wechatTextField.delegate = self;
                cell.qqTextField.delegate = self;
                cell.telephoneTextField.responderDelegate = self;
                cell.wechatTextField.responderDelegate = self;
                cell.qqTextField.responderDelegate = self;
                [cell setTitle:_houseItems[indexPath.row]];
            }
            
            if (!_contactInfoTableViewCell) {
                _contactInfoTableViewCell = cell;
                NSString *telephone = _houseJSON[_houseKeysArray[indexPath.row][0]];
                if (telephone && ![telephone isEqualToString:@""]) {
                    [_contactInfoTableViewCell setTelephone:telephone withOn:YES];
                } else {
                    [_contactInfoTableViewCell setTelephone:[[AppClient sharedInstance] telephone] withOn:NO];
                }
                
                [_contactInfoTableViewCell setWechat:_houseJSON[_houseKeysArray[indexPath.row][1]]];
                [_contactInfoTableViewCell setQQ:_houseJSON[_houseKeysArray[indexPath.row][2]]];
            }
            
            return cell;
        }
            break;
        case 9:
        {
            DatePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"datePickerTableViewCell"];
            if (!cell) {
                cell = [[DatePickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"datePickerTableViewCell"];
                [cell setTitle:_houseItems[indexPath.row]];
                [cell resetNoTipsFrame];
            }
            if (!_datePickerTableViewCell) {
                _datePickerTableViewCell = cell;
                [_datePickerTableViewCell setDate:_houseJSON[_houseKeysArray[indexPath.row]]];
            }
            return cell;
        }
            break;
        case 10:
        {
            SuiteFacilitiesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuiteFacilitiesRentTableViewCell"];
            if (!cell) {
                cell = [[SuiteFacilitiesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteFacilitiesRentTableViewCell"];
                [cell setTitle:_houseItems[indexPath.row]];
                [cell setSourceFacilities:@[@{@"icon":@"\ue670", @"content":lang(@"Water")}, @{@"icon":@"\ue671", @"content":lang(@"Electricity")}, @{@"icon":@"\ue672", @"content":lang(@"Gas")}, @{@"icon":@"\ue606", @"content":lang(@"Net")}, @{@"icon":@"\ue673", @"content":lang(@"Estate")}, @{@"icon":@"\ue674", @"content":lang(@"Health")}, @{@"icon":@"\ue675", @"content":lang(@"Heater")}, @{@"icon":@"\ue600", @"content":lang(@"TV")}]];
            }
            
            if (!_suiteFacilitiesRentTableViewCell) {
                _suiteFacilitiesRentTableViewCell = cell;
                [_suiteFacilitiesRentTableViewCell setSuiteFacilities:_houseJSON[_houseKeysArray[indexPath.row]]];
            }
            
            return cell;
        }
            break;

        default:
            break;
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            if ([_houseJSON[@"rentType"] isEqual:@2]) {
                return monthlyRentTableViewCellHeight;
            } else {
                return requiredGenderTableViewCellHeight;
            }
            break;
        case 1:
            return suiteRegionTableViewCellHeight;
            break;
        case 2:
            return fullAddressTableViewCellMinHeight;
            break;
        case 3:
            return suiteTypeTableViewCellHeight;
            break;
        case 4:
            return areaTableViewCellHeight;
            break;
        case 5:
            return floorTableViewCellHeight;
            break;
        case 6:
            return suiteDescriptionTableViewCellHeight;
            break;
        case 7:
            return [CommonFuncs getSuiteFacilitiesTableViewCellHeight];
            break;
        case 8:
            return contactInfoTableViewCellHeight;
            break;
        case 9:
            return noTipsDatePickerTableViewCellHeight;
            break;
        case 10:
            return [CommonFuncs getSuiteFacilitiesTableViewCellHeight]; //动态获取该类型cell高度 适应不同屏幕
            break;
        default:
            return 44;
            break;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


#pragma mark -textFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _monthlyRentTableViewCell.priceTextField) {
        //校验纯数字，兼容退格键
        return string.length > 0 ? [RegularExpressionUtil validNumber:string] : YES;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGFloat contentOffsetY;
    if (textField == _fullAddressTableViewCell.fullAddressTextField) {
        if ([_houseJSON[@"rentType"] isEqual:@2]) {
             contentOffsetY = monthlyRentTableViewCellHeight+onlineDiscountTableViewCellHeight+suiteRegionTableViewCellHeight ;
        } else {
            contentOffsetY = requiredGenderTableViewCellHeight+suiteRegionTableViewCellHeight;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.houseInfoTableView.contentOffset = CGPointMake(0, contentOffsetY+15);
        }];
    } else if (textField == _contactInfoTableViewCell.telephoneTextField || textField == _contactInfoTableViewCell.qqTextField || textField == _contactInfoTableViewCell.wechatTextField) {
        if ([_houseJSON[@"rentType"] isEqual:@2]) {
            contentOffsetY = monthlyRentTableViewCellHeight+onlineDiscountTableViewCellHeight+suiteRegionTableViewCellHeight+fullAddressTableViewCellMinHeight+suiteTypeTableViewCellHeight+areaTableViewCellHeight+floorTableViewCellHeight+suiteDescriptionTableViewCellHeight+suiteFacilitiesTableViewCellHeight;
        } else {
            contentOffsetY = requiredGenderTableViewCellHeight+suiteRegionTableViewCellHeight+fullAddressTableViewCellMinHeight+suiteTypeTableViewCellHeight+areaTableViewCellHeight+floorTableViewCellHeight+suiteDescriptionTableViewCellHeight+suiteFacilitiesTableViewCellHeight;
        }
        self.heightOfInfo = contentOffsetY;
        if (!_isChanged) {
             self.oldContentOfSize = self.houseInfoTableView.contentSize;
            _isChanged = YES;
        }
        if (self.houseInfoTableView.contentSize.height == self.oldContentOfSize.height) {
              CGFloat y = self.houseInfoTableView.contentSize.height+200;
              CGSize tempSize = CGSizeMake(self.view.frame.size.width, y);
              self.houseInfoTableView.contentSize = tempSize;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.houseInfoTableView.contentOffset = CGPointMake(0, contentOffsetY+145);
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _monthlyRentTableViewCell.priceTextField) {
        if ([textField.text isEqualToString: @""]) {
            //输入框为空
            return;
        }
        if ((![NSString isPureInt:textField.text]) || (![NSString isPureFloat:textField.text])) {
            //输入内容有特殊字符
            [PopupView showMessage:lang(@"RentMoneyIsEmpty")];
            textField.text = nil ;
        } else {
            //正常
        }
        
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [(CustomTextView *)textView showPlaceholder:textView.text.length == 0 ? YES : NO];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGFloat contentOffsetY;
    if (textView == _suiteDescriptionTableViewCell.suiteDescriptionTextView) {
        if ([_houseJSON[@"rentType"] isEqual:@2]) {
            contentOffsetY = monthlyRentTableViewCellHeight+suiteRegionTableViewCellHeight+fullAddressTableViewCellMinHeight+suiteTypeTableViewCellHeight+areaTableViewCellHeight+floorTableViewCellHeight;
        } else {
            contentOffsetY = requiredGenderTableViewCellHeight+suiteRegionTableViewCellHeight+fullAddressTableViewCellMinHeight+suiteTypeTableViewCellHeight+areaTableViewCellHeight+floorTableViewCellHeight;
        }
        [UIView animateWithDuration:.5 animations:^{
            self.houseInfoTableView.contentOffset = CGPointMake(0, contentOffsetY+15);
        }];
    }
}

#pragma mark - 键盘消失调用
- (void)keyboardDidHide {
    [self.view removeGestureRecognizer:self.tapHideKeyboard];
    [UIView animateWithDuration:0.8 animations:^{
        [self.houseInfoTableView reloadData];
    }];
}

#pragma mark - 键盘出现时候调用
- (void)keyboardWillShow {
    [self.view addGestureRecognizer:self.tapHideKeyboard];
}

- (void)hideKeyboard {

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldResignFirstResponder {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.8 animations:^{
        [self.houseInfoTableView reloadData];
    }];
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
