//
//  HouseInfoFillInViewController.m
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HouseInfoFillInViewController.h"
#import "Room107TableView.h"
#import "YellowColorTextLabel.h"
#import "SuiteRegionTableViewCell.h"
//#import "FullAddressTableViewCell.h"
#import "MapFullAddressTableViewCell.h"
#import "HouseManageAgent.h"
#import "SuiteTypeTableViewCell.h"
#import "AreaTableViewCell.h"
#import "FloorTableViewCell.h"
#import "SuiteDescriptionTableViewCell.h"
#import "SuiteFacilitiesTableViewCell.h"
#import "ContactInfoTableViewCell.h"
#import "RentalWayTableViewCell.h"
#import "MonthlyRentTableViewCell.h"
#import "CircleGreenMarkView.h"
#import "NSNumber+Additions.h"
#import "CustomTextField.h"
#import "CustomTextView.h"
#import "NXIconTextField.h"
#import "OnlineDiscountTableViewCell.h"
#import "NSString+IsPureNumer.h"
#import "RegularExpressionUtil.h"
#import "DatePickerTableViewCell.h"
#import "CorrectPositionViewController.h"


@interface HouseInfoFillInViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,UITextFieldDelegate,UITextViewDelegate,CustomTextFieldDelegate>

@property (nonatomic, strong) NSDictionary *district2UserCount;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *imageToken;
@property (nonatomic, strong) NSString *imageKeyPattern;
@property (nonatomic, strong) Room107TableView *houseInfoTableView;
@property (nonatomic, strong) NSMutableArray *houseItems;
@property (nonatomic, strong) SuiteRegionTableViewCell *suiteRegionTableViewCell;
//@property (nonatomic, strong) FullAddressTableViewCell *fullAddressTableViewCell;
@property (nonatomic, strong) MapFullAddressTableViewCell *mapFullAddressTableViewCell;
@property (nonatomic, strong) SuiteTypeTableViewCell *suiteTypeTableViewCell;
@property (nonatomic, strong) AreaTableViewCell *areaTableViewCell;
@property (nonatomic, strong) FloorTableViewCell *floorTableViewCell;
@property (nonatomic, strong) SuiteDescriptionTableViewCell *suiteDescriptionTableViewCell;
@property (nonatomic, strong) SuiteFacilitiesTableViewCell *suiteFacilitiesTableViewCell;
@property (nonatomic, strong) SuiteFacilitiesTableViewCell *suiteFacilitiesRentTableViewCell;
@property (nonatomic, strong) ContactInfoTableViewCell *contactInfoTableViewCell;
@property (nonatomic, strong) RentalWayTableViewCell *rentalWayTableViewCell;
@property (nonatomic, strong) DatePickerTableViewCell *datePickerTableViewCell;
@property (nonatomic, strong) void (^handlerBlock)();
@property (nonatomic, strong) NSMutableDictionary *houseJSON;//描述房子信息（包含房子信息），json格式，json对应的数据结构为LandlordSuiteItem，json整体进行urlEncode
@property (nonatomic, strong) NSArray *houseKeysArray;
@property (nonatomic, strong) UITapGestureRecognizer *tapHideKeyboard;
@end

@implementation HouseInfoFillInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //注册键盘出现的通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardShown)
     
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    self.tapHideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
}

- (void)setDistrict2UserCount:(NSDictionary *)district2UserCount andTelephone:(NSString *)telephone andImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseJSON:(NSMutableDictionary *)houseJSON andHouseKeysArray:(NSArray *)houseKeysArray {
    _district2UserCount = district2UserCount;
    _telephone = telephone;
    _imageToken = imageToken;
    _imageKeyPattern = imageKeyPattern;
    _houseJSON = houseJSON;
    _houseKeysArray = houseKeysArray;
    
    if (!_houseInfoTableView) {
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        _houseInfoTableView = [[Room107TableView alloc] initWithFrame:frame];
        _houseInfoTableView.delegate = self;
        _houseInfoTableView.dataSource = self;
        _houseInfoTableView.tableHeaderView = [self createTableHeaderView];
        _houseInfoTableView.tableFooterView = [self createTableFooterView];
        [self.view addSubview:_houseInfoTableView];
    }
    _houseItems = [NSMutableArray arrayWithObjects:lang(@"SuiteRegion"), lang(@"FullAddress"), lang(@"SuiteType"), [NSString stringWithFormat:@"%@（m²）", lang(@"Area")], lang(@"FloorTips"), lang(@"SuiteDescription"), lang(@"SuiteFacilities"), lang(@"ContactInfo"), lang(@"RentalWay"), lang(@"EarliestCheckin"), lang(@"RentsIncludeFees"), nil];
}

- (UIView *)createTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 76.0f}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = headerView.frame;
    frame.origin.x = 33;
    frame.size.width = frame.size.width - 2 * frame.origin.x;
    frame.origin.y += 5;
    frame.size.height -= (5 + 22);
    YellowColorTextLabel *houseInfoTipsLabel = [[YellowColorTextLabel alloc] initWithFrame:frame withTitle:lang(@"HouseInfoTips")];
    [headerView addSubview:houseInfoTipsLabel];
    
    return headerView;
}

- (UIView *)createTableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 130.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = footerView.frame;
    frame.size.height = 100;
    frame.origin.y = footerView.frame.size.height - frame.size.height;
    //确认按钮
    SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"VerifyInfo") andAssistantButtonTitle:@""];
    [footerView addSubview:mutualBottomView];
    [mutualBottomView setMainButtonDidClickHandler:^{
        if ([[_mapFullAddressTableViewCell position] isEmpty]) {
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
        
        if ([_rentalWayTableViewCell rentType] == 1) {
            if (![[_rentalWayTableViewCell price] isPureInt] || [[_rentalWayTableViewCell price] isEqual:@0]) {
                [PopupView showMessage:lang(@"RentMoneyIsEmpty")];
                return;
            }
        }
        
        [self completeHouseJSON];
    }];
    
    return footerView;
}

- (void)setVerifyInfoButtonDidClickHandler:(void(^)())handler {
    self.handlerBlock = handler;
}

#pragma mark - 保存草稿信息
- (void)completeHouseJSON {
    for (NSUInteger i = 0; i < _houseKeysArray.count; i++) {
        switch (i) {
            case 0:
                if (_suiteTypeTableViewCell) {
                    [_houseJSON setObject:[_suiteRegionTableViewCell district] forKey:_houseKeysArray[i]];
                }
                break;
            case 1:
                if (_mapFullAddressTableViewCell) {
                    [_houseJSON setObject:[_mapFullAddressTableViewCell position] forKey:_houseKeysArray[i]];
                }
                break;
            case 2:
                if (_suiteTypeTableViewCell) {
                    [_houseJSON setObject:[_suiteTypeTableViewCell roomNumber] forKey:_houseKeysArray[i][0]];
                    [_houseJSON setObject:[_suiteTypeTableViewCell hallNumber] forKey:_houseKeysArray[i][1]];
                    [_houseJSON setObject:[_suiteTypeTableViewCell kitchenNumber] forKey:_houseKeysArray[i][2]];
                    [_houseJSON setObject:[_suiteTypeTableViewCell toiletNumber] forKey:_houseKeysArray[i][3]];
                }
                break;
            case 3:
                if (_areaTableViewCell) {
                    [_houseJSON setObject:[_areaTableViewCell area] forKey:_houseKeysArray[i]];
                }
                break;
            case 4:
                if (_floorTableViewCell) {
                    [_houseJSON setObject:[_floorTableViewCell floor] forKey:_houseKeysArray[i]];
                }
                break;
            case 5:
                if (_suiteDescriptionTableViewCell) {
                    [_houseJSON setObject:[_suiteDescriptionTableViewCell suiteDescription] forKey:_houseKeysArray[i]];
                }
                break;
            case 6:
                if (_suiteFacilitiesTableViewCell) {
                    [_houseJSON setObject:[_suiteFacilitiesTableViewCell suiteFacilities] forKey:_houseKeysArray[i]];
                }
                break;
            case 7:
                if (_contactInfoTableViewCell) {
                    if ([_contactInfoTableViewCell isTelephoneOn]) {
                        [_houseJSON setObject:_telephone forKey:_houseKeysArray[i][0]];
                    } else {
                        [_houseJSON removeObjectForKey:_houseKeysArray[i][0]];
                    }
                    
                    [_houseJSON setObject:[_contactInfoTableViewCell wechat] forKey:_houseKeysArray[i][1]];
                    [_houseJSON setObject:[_contactInfoTableViewCell qq] forKey:_houseKeysArray[i][2]];
                }
                break;
            case 8:
                if (_rentalWayTableViewCell) {
                    [_houseJSON setObject:[CommonFuncs rentTypeConvert:[_rentalWayTableViewCell rentType]] forKey:_houseKeysArray[i][0]];
                    if ([_rentalWayTableViewCell rentType] == 1) {
                        //整租
                        if (_rentalWayTableViewCell) {
                            [_houseJSON setObject:[_rentalWayTableViewCell price] forKey:_houseKeysArray[i][1]];
                        }
                    } else {
                        //分租
                        [_houseJSON setObject:[NSNumber numberWithInteger:[_rentalWayTableViewCell requiredGender]] forKey:_houseKeysArray[i][2]];
                    }
                }
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
    
    [[HouseManageAgent sharedInstance] saveLandlordSuiteItem:_houseJSON];
    
    if (self.handlerBlock) {
        self.handlerBlock();
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _houseItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
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
            
            WEAK(cell) weakCell = cell;
            [cell setRegionIndexDidChangeHandler:^(NSInteger index) {
                [weakCell setCountOfRenter:[_district2UserCount[[[NSNumber numberWithInteger:index] stringValue]] stringValue]];
            }];
            
            return cell;
        }
            break;
        case 1:
        {
            MapFullAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FullAddressTableViewCell"];
            if (!cell) {
                cell = [[MapFullAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FullAddressTableViewCell"];
                [cell setAddressDidBeginEditingHandler:^{
                    [UIView animateWithDuration:0.5 animations:^{
                        self.houseInfoTableView.contentOffset = CGPointMake(0, suiteRegionTableViewCellHeight+76.0f);
                    }];
                }];
                [cell setTitle:_houseItems[indexPath.row]];
            }
            
            if (!_mapFullAddressTableViewCell) {
                _mapFullAddressTableViewCell = cell;
                [_mapFullAddressTableViewCell setPosition:_houseJSON[_houseKeysArray[indexPath.row]]];
            }
            
            WEAK(cell) weakCell = cell;
            [cell setTextFieldDidEndEditingHandler:^(NSString *text) {
                [[HouseManageAgent sharedInstance] getSubscribeNumberWithPosition:text completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *number, NSArray *subscribes, NSNumber *locationX, NSNumber *locationY) {
                    if (!errorCode) {
                        [weakCell setCountOfSubscriber:[number stringValue]];
                        [weakCell setImageURLwithMarkers:subscribes andLocationX:locationX andLocationY:locationY];
                    }
                }];
            }];
            
            return cell;
        }
            break;
        case 2:
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
        case 3:
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
        case 4:
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
        case 5:
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
        case 6:
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
        case 7:
        {
            ContactInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactInfoTableViewCell"];
            if (!cell) {
                cell = [[ContactInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactInfoTableViewCell"];
                cell.wechatTextField.delegate = self;
                cell.qqTextField.delegate = self;
                [cell setTitle:_houseItems[indexPath.row]];
            }

            if (!_contactInfoTableViewCell) {
                _contactInfoTableViewCell = cell;
                NSString *telephone = _houseJSON[_houseKeysArray[indexPath.row][0]];
                [_contactInfoTableViewCell setTelephone:_telephone withOn:[telephone isKindOfClass:[NSNull class]] ? NO : YES];
                [_contactInfoTableViewCell setWechat:_houseJSON[_houseKeysArray[indexPath.row][1]]];
                [_contactInfoTableViewCell setQQ:_houseJSON[_houseKeysArray[indexPath.row][2]]];
            }
            
            return cell;
        }
            break;
        case 8:
        {
            RentalWayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RentalWayTableViewCell"];
            if (!cell) {
                cell = [[RentalWayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RentalWayTableViewCell"];
                cell.priceTextField.delegate = self;
                cell.priceTextField.responderDelegate = self;
                [cell setTitle:_houseItems[indexPath.row]];
            }
            
            if (!_rentalWayTableViewCell) {
                _rentalWayTableViewCell = cell;
                [_rentalWayTableViewCell setRentType:[_houseJSON[_houseKeysArray[indexPath.row][0]] integerValue]];
                //整租类型
                if (nil == _houseJSON[_houseKeysArray[indexPath.row][0]] ) {
                } else {
                if ([_houseJSON[_houseKeysArray[indexPath.row][0]] isEqual:@2]) {
                    [_rentalWayTableViewCell setPrice:_houseJSON[_houseKeysArray[indexPath.row][1]]];
                } else {
                    //分租
                    [_rentalWayTableViewCell setRequiredGender:[_houseJSON[_houseKeysArray[indexPath.row][2]] integerValue]];
                 }
               }
            }
            [cell setSelectRentTypeHandler:^(NSInteger type) {
                if ([(NSArray *)_houseJSON[@"rooms"] count] > 0) {
                    //切换出租方式后，需要判断是否清除无效地房子草稿
                    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
                        [_rentalWayTableViewCell setRentType:[_houseJSON[_houseKeysArray[8][0]] integerValue]];
                        [_houseInfoTableView reloadData];
                    }];
                    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
                        [(NSMutableArray *)_houseJSON[@"rooms"] removeAllObjects];
                        [_houseJSON setObject:[CommonFuncs rentTypeConvert:[_rentalWayTableViewCell rentType]] forKey:_houseKeysArray[8][0]];

                    }];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"CleanRooms")
                                                                    message:@"" cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
                    [alert show];
                }
            }];

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
            return suiteRegionTableViewCellHeight;
            break;
        case 1:
            return [MapFullAddressTableViewCell getmapFullAddressTableViewCellHeight];
            break;
        case 2:
            return suiteTypeTableViewCellHeight;
            break;
        case 3:
            return areaTableViewCellHeight;
            break;
        case 4:
            return floorTableViewCellHeight;
            break;
        case 5:
            return suiteDescriptionTableViewCellHeight;
            break;
        case 6:
            return [CommonFuncs getSuiteFacilitiesTableViewCellHeight]; //动态获取该类型cell高度 适应不同屏幕
            break;
        case 7:
            return contactInfoTableViewCellHeight;
            break;
        case 8:
            return rentalWayTableViewCellHeight;
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

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _rentalWayTableViewCell.priceTextField) {
        //校验纯数字，兼容退格键
        return string.length > 0 ? [RegularExpressionUtil validNumber:string] : YES;
    }

    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _contactInfoTableViewCell.wechatTextField) {
        [UIView animateWithDuration:0.5 animations:^{
            self.houseInfoTableView.contentOffset = CGPointMake(0, suiteRegionTableViewCellHeight+[MapFullAddressTableViewCell getmapFullAddressTableViewCellHeight]+suiteTypeTableViewCellHeight+areaTableViewCellHeight+floorTableViewCellHeight+suiteDescriptionTableViewCellHeight+suiteFacilitiesTableViewCellHeight+76.0f+100);
        }];
    } else if (textField == _contactInfoTableViewCell.qqTextField) {
        [UIView animateWithDuration:0.5 animations:^{
            self.houseInfoTableView.contentOffset = CGPointMake(0, suiteRegionTableViewCellHeight+[MapFullAddressTableViewCell getmapFullAddressTableViewCellHeight]+suiteTypeTableViewCellHeight+areaTableViewCellHeight+floorTableViewCellHeight+suiteDescriptionTableViewCellHeight+suiteFacilitiesTableViewCellHeight+76.0f+180);
        }];
    } else if (textField == _rentalWayTableViewCell.priceTextField) {
        CGSize oldSize = self.houseInfoTableView.contentSize;
        [UIView animateWithDuration:3 animations:^{
            self.houseInfoTableView.contentSize = CGSizeMake(oldSize.width, oldSize.height+450);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.8 animations:^{
                self.houseInfoTableView.contentOffset = CGPointMake(0, suiteRegionTableViewCellHeight+[MapFullAddressTableViewCell getmapFullAddressTableViewCellHeight]+suiteTypeTableViewCellHeight+areaTableViewCellHeight+floorTableViewCellHeight+suiteDescriptionTableViewCellHeight+suiteFacilitiesTableViewCellHeight + contactInfoTableViewCellHeight + 200.f);
            }];
        }];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ( textField == _rentalWayTableViewCell.priceTextField) {
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (textView == _suiteDescriptionTableViewCell.suiteDescriptionTextView) {
        [UIView animateWithDuration:0.5 animations:^{
        self.houseInfoTableView.contentOffset = CGPointMake(0, suiteRegionTableViewCellHeight+[MapFullAddressTableViewCell getmapFullAddressTableViewCellHeight]+suiteTypeTableViewCellHeight+areaTableViewCellHeight+floorTableViewCellHeight+76.0f);
        }];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [(CustomTextView *)textView showPlaceholder:textView.text.length == 0 ? YES : NO];
}

#pragma mark - 监听键盘回收事件
- (void)keyboardHide {
    [self.view removeGestureRecognizer:self.tapHideKeyboard];    
    if (self.houseInfoTableView.contentOffset.y > suiteRegionTableViewCellHeight+[MapFullAddressTableViewCell getmapFullAddressTableViewCellHeight]+suiteTypeTableViewCellHeight+areaTableViewCellHeight+floorTableViewCellHeight+suiteDescriptionTableViewCellHeight+suiteFacilitiesTableViewCellHeight+contactInfoTableViewCellHeight) {
        [UIView animateWithDuration:0.8 animations:^{
            [self.houseInfoTableView reloadData];
        }];
    }
}

- (void)keyboardShown {
    [self.view addGestureRecognizer:self.tapHideKeyboard];
}

- (void)hideKeyboard {
    if ( [_rentalWayTableViewCell.priceTextField isFirstResponder] ) {
        [UIView animateWithDuration:0.8 animations:^{
            [self.houseInfoTableView reloadData];
        }];
    }
    [self.view endEditing:YES];
}

#pragma CustomTextFieldDelegate
- (void)textFieldResignFirstResponder {
    if (self.houseInfoTableView.contentOffset.y > suiteRegionTableViewCellHeight+[MapFullAddressTableViewCell getmapFullAddressTableViewCellHeight]+suiteTypeTableViewCellHeight+areaTableViewCellHeight+floorTableViewCellHeight+suiteDescriptionTableViewCellHeight+suiteFacilitiesTableViewCellHeight+contactInfoTableViewCellHeight) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.houseInfoTableView reloadData];
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
