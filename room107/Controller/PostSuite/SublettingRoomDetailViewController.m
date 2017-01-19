//
//  SublettingRoomDetailViewController.m
//  room107
//
//  Created by ningxia on 15/9/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SublettingRoomDetailViewController.h"
#import "AssetsPickerViewController.h"
#import "NYPhotoBrowser.h"
#import "Room107TableView.h"
#import "RentStatusTableViewCell.h"
#import "RoomPhotosAddTableViewCell.h"
#import "RoomTypeTableViewCell.h"
#import "MonthlyRentTableViewCell.h"
#import "AreaTableViewCell.h"
#import "OrientationSelectTableViewCell.h"
#import "QiniuFileAgent.h"
#import "HouseManageAgent.h"
#import "NSNumber+Additions.h"
#import "NXIconTextField.h"
#import "OnlineDiscountTableViewCell.h"
#import "NSString+IsPureNumer.h"
#import "RegularExpressionUtil.h"

@interface SublettingRoomDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AssetsPickerControllerDelegate, NYPhotoBrowserDelegate,UITextFieldDelegate>

@property (nonatomic, strong) NSString *imageToken;
@property (nonatomic, strong) NSString *imageKeyPattern;
@property (nonatomic, strong) NSNumber *houseID;
@property (nonatomic, strong) NSMutableDictionary *roomJSON;
@property (nonatomic, strong) void (^saveInfoHandlerBlock)();
@property (nonatomic, strong) void (^cancelHandlerBlock)();
@property (nonatomic, strong) NSArray *roomItems;
@property (nonatomic, strong) Room107TableView *roomItemsTableView;
@property (nonatomic, strong) RentStatusTableViewCell *rentStatusTableViewCell;
@property (nonatomic, strong) RoomPhotosAddTableViewCell *roomPhotosAddTableViewCell;
@property (nonatomic, strong) RoomTypeTableViewCell *roomTypeTableViewCell;
@property (nonatomic, strong) MonthlyRentTableViewCell *monthlyRentTableViewCell;
@property (nonatomic, strong) AreaTableViewCell *areaTableViewCell;
@property (nonatomic, strong) OrientationSelectTableViewCell *orientationSelectTableViewCell;
@property (nonatomic, strong) OnlineDiscountTableViewCell *onlineDiscountTableViewCell;
@property (nonatomic) SublettingRoomDetailViewType sublettingRoomDetailViewType;
@property (nonatomic, strong) void (^dismissHandlerBlock)();
@property (nonatomic) CGFloat tableViewY;
@property (nonatomic) CGRect originFrame;

@end

@implementation SublettingRoomDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableViewY = 0;
}

- (void)setImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseID:(NSNumber *)houseID andRoom:(NSMutableDictionary *)room andType:(SublettingRoomDetailViewType)type {
    _imageToken = imageToken;
    _imageKeyPattern = imageKeyPattern;
    _houseID = houseID;
    _roomJSON = [room mutableCopy];
    _sublettingRoomDetailViewType = type;
    
    if (!_roomJSON[@"status"] || [_roomJSON[@"status"] isEqual:@0]) {
        _roomItems = @[lang(@"RentStatus"), lang(@"Photo"), lang(@"RoomType"), lang(@"MonthlyRent"), [NSString stringWithFormat:@"%@（m²）", lang(@"Area")], lang(@"Orientation")];
    } else {
        _roomItems = @[lang(@"RentStatus"), lang(@"Photo"), lang(@"RoomType")];
    }
    
    if (!_roomItemsTableView) {
        _originFrame = self.view.frame;
        _roomItemsTableView = [[Room107TableView alloc] initWithFrame:_originFrame];
        _roomItemsTableView.delegate = self;
        _roomItemsTableView.dataSource = self;
        _roomItemsTableView.tableHeaderView = [self createTableHeaderView];
        _roomItemsTableView.tableFooterView = [self createFooterView];
        [self.view addSubview:_roomItemsTableView];
    }
    
    if (_roomPhotosAddTableViewCell) {
        [_rentStatusTableViewCell setRentStatus:[room[@"status"] integerValue]];
        [_roomPhotosAddTableViewCell setRoomPhotos:[room[@"photos"] getComponentsBySeparatedString:@"|"]];
        [_roomTypeTableViewCell setRoomType:[room[@"type"] integerValue]];
        [_monthlyRentTableViewCell setPrice:room[@"price"]];
        [_areaTableViewCell setArea:room[@"area"]];
        [_orientationSelectTableViewCell setOrientation:room[@"orientation"]];
    }
    
    [self scrollToTop];
}

- (void)scrollToTop {
    [_roomItemsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)setSaveInfoButtonDidClickHandler:(void (^)(NSMutableDictionary *room))handler {
    self.saveInfoHandlerBlock = handler;
}

- (void)setCancelButtonDidClickHandler:(void (^)())handler {
    self.cancelHandlerBlock = handler;
}

- (void)setViewControllerDismissHandler:(void(^)())handler {
    _dismissHandlerBlock = handler;
    
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

- (UIView *)createTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 20.0f}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    return headerView;
}

- (UIView *)createFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 135.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = footerView.frame;
    frame.origin.y = 35;
    frame.size.height = CGRectGetHeight(frame) - frame.origin.y;
    SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"SaveInfo") andAssistantButtonTitle:lang(@"Cancel")];
    [footerView addSubview:mutualBottomView];
    [mutualBottomView setMainButtonDidClickHandler:^{
        [self saveInfo];
    }];
    [mutualBottomView setAssistantButtonDidClickHandler:^{
        if (self.cancelHandlerBlock) {
            self.cancelHandlerBlock();
        }
    }];
    
    return footerView;
}

- (void)saveInfo {
    __block NSString *imagesMaxString = @"";
    
    NSMutableArray *imageDics = [[NSMutableArray alloc] init];
    NSMutableArray *imageKeys = [[NSMutableArray alloc] init];
    NSArray *images = [_roomPhotosAddTableViewCell photos];
    if (images.count < 1) {
        [PopupView showMessage:lang(@"PhotosIsEmpty")];
        [self scrollToTop];
        return;
    }
    
    if ([_rentStatusTableViewCell rentStatus] == 0) {
        if (![[_monthlyRentTableViewCell price] isPureInt] || [[_monthlyRentTableViewCell price] isEqual:@0]) {
            [PopupView showMessage:lang(@"RentMoneyIsEmpty")];
            return;
        }
        
        if ([[_areaTableViewCell area] isEqual:@0]) {
            [PopupView showMessage:lang(@"AreaIsZero")];
            return;
        }
    }
    
    for (NSUInteger i = 0; i < images.count; i++) {
        if ([images[i] isKindOfClass:[UIImage class]]) {
            int random = [CommonFuncs randomNumber]; //获取随机数，避免文件名重复
            [imageDics addObject:@{@"image":images[i], @"key":[NSString stringWithFormat:_imageKeyPattern, random]}];
            [imageKeys addObject:[NSString stringWithFormat:_imageKeyPattern, random]];
        } else {
            imagesMaxString = [imagesMaxString stringByAppendingFormat:@"%@|", images[i]];
        }
    }
    
    if (imageDics.count > 0) {
        [self showLoadingView];
        [[QiniuFileAgent sharedInstance] uploadWithImageDics:imageDics token:_imageToken completion:^(NSError *error, NSString *errorMsg) {
            if (!error) {
                [[HouseManageAgent sharedInstance] uploadImagesWithImageKeys:imageKeys completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *imagesString) {
                    [self hideLoadingView];
                    if (errorTitle || errorMsg) {
                        [PopupView showTitle:errorTitle message:errorMsg];
                    }
                
                    if (!errorCode) {
                        imagesMaxString = [imagesMaxString stringByAppendingString:imagesString ? imagesString : @""];
                        
                        [self reloadRoomsTableViewWithImagesString:imagesMaxString];
                    } else {
                        if ([self isLoginStateError:errorCode]) {
                            return;
                        }
                    }
                }];
            } else {
                [self hideLoadingView];
                
            }
        }];
    } else {
        //未更改图片
        imagesMaxString = [imagesMaxString substringToIndex:imagesMaxString.length > 0 ? imagesMaxString.length - 1 : 0];
        [self reloadRoomsTableViewWithImagesString:imagesMaxString];
    }
}

- (void)reloadRoomsTableViewWithImagesString:(NSString *)imagesString {
    NSNumber *roomID = _roomJSON[@"id"];
    [_roomJSON removeAllObjects]; //修改房子、房间信息时，需要核对字段数目
    if (roomID) {
        [_roomJSON setObject:roomID forKey:@"id"];
    }
    [_roomJSON setObject:[NSNumber numberWithInteger:_rentStatusTableViewCell.rentStatus] forKey:@"status"];
    [_roomJSON setObject:imagesString forKey:@"photos"];
    [_roomJSON setObject:[NSNumber numberWithInteger:_roomTypeTableViewCell.roomType] forKey:@"type"];
    
    if (_monthlyRentTableViewCell.price) {
        [_roomJSON setObject:_monthlyRentTableViewCell.price forKey:@"price"]; //保存"每月租金"
    }
    //注意cell为nil 返回为YES 导致CRASH
    if (_areaTableViewCell && ![_areaTableViewCell.area isEqual:@0] ) {
        [_roomJSON setObject:_areaTableViewCell.area forKey:@"area"];
    }
    if (_orientationSelectTableViewCell.orientation) {
        [_roomJSON setObject:_orientationSelectTableViewCell.orientation forKey:@"orientation"];
    }
    //暂时取消95折扣价格    
    if (_sublettingRoomDetailViewType == SublettingRoomDetailViewTypeNew) {
        //若发布房子 将rooInfo保存到本地
        if (self.saveInfoHandlerBlock) {
            self.saveInfoHandlerBlock(_roomJSON);
        }
    } else {
        //若是房子管理页，则将数据传到服务器。
        WEAK_SELF weakSelf = self;
        [self showLoadingView];
        [[HouseManageAgent sharedInstance] updateRoomWithHouseID:_houseID andRoomJSON:_roomJSON completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *roomID) {
            [weakSelf hideLoadingView];
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
                
            if (!errorCode) {
                [weakSelf.roomJSON setObject:roomID forKey:@"id"];
                if (self.saveInfoHandlerBlock) {
                    self.saveInfoHandlerBlock(weakSelf.roomJSON);
                }
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
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _roomItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        //状态
        case 0:
        {
            RentStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RentStatusTableViewCell"];
            if (!cell) {
                cell = [[RentStatusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RentStatusTableViewCell"];
                [cell setTitle:_roomItems[indexPath.row]];
                _rentStatusTableViewCell = cell;
                [_rentStatusTableViewCell setRentStatus:[_roomJSON[@"status"] integerValue]];
            }
            
            WEAK_SELF weakSelf = self;
            [cell setSelectRentStatusHandler:^(NSInteger status) {
                if (status == 0) {
                    weakSelf.roomItems = @[lang(@"RentStatus"), lang(@"Photo"), lang(@"RoomType"), lang(@"MonthlyRent"), [NSString stringWithFormat:@"%@（m²）", lang(@"Area")], lang(@"Orientation")];
                } else {
                    weakSelf.roomItems = @[lang(@"RentStatus"), lang(@"Photo"), lang(@"RoomType")];
                }
                [weakSelf.roomItemsTableView reloadData];
            }];
            
            return cell;
        }
            break;
        //照片
        case 1:
        {
            RoomPhotosAddTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomPhotosAddTableViewCell"];
            if (!cell) {
                cell = [[RoomPhotosAddTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomPhotosAddTableViewCell"];
                [cell setTitle:_roomItems[indexPath.row]];
                _roomPhotosAddTableViewCell = cell;
                [_roomPhotosAddTableViewCell setRoomPhotos:[_roomJSON[@"photos"] getComponentsBySeparatedString:@"|"]];
            }
            
            WEAK(cell) weakCell = cell;
            [cell setSelectPhotoHandler:^(NSInteger index) {
                if (index == -1) {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                                  initWithTitle:@""
                                                  delegate:self
                                                  cancelButtonTitle:lang(@"Cancel")
                                                  destructiveButtonTitle:lang(@"Camera")
                                                  otherButtonTitles:lang(@"Photos"), nil];
                    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
                    actionSheet.destructiveButtonIndex = -1;//销毁按钮（红色），对用户的某个动作起到警示作用，-1代表不设置
                    [actionSheet showInView:self.view];
                } else {
                    NYPhotoBrowser *photoBrowser = [[NYPhotoBrowser alloc] initWithImages:[weakCell photos]];
                    [photoBrowser setInitialPageIndex:index];
                    photoBrowser.delegate = self;
                    [self presentViewController:photoBrowser animated:YES completion:^{
                        
                    }];
                }
            }];
            
            return cell;
        }
            break;
        //类型
        case 2:
        {
            RoomTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomTypeTableViewCell"];
            if (!cell) {
                cell = [[RoomTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomTypeTableViewCell"];
                [cell setTitle:_roomItems[indexPath.row]];
                _roomTypeTableViewCell = cell;
                [_roomTypeTableViewCell setRoomType:[_roomJSON[@"type"] integerValue]];
            }
            
            return cell;
        }
            break;
        //每月租金
        case 3:
        {
            MonthlyRentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonthlyRentTableViewCell"];
            if (!cell) {
                cell = [[MonthlyRentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MonthlyRentTableViewCell"];
                [cell setTitle:_roomItems[indexPath.row]];
                cell.priceTextField.delegate = self;
                _monthlyRentTableViewCell = cell;
                [_monthlyRentTableViewCell setPrice:_roomJSON[@"price"]];
            }
            
            return cell;
        }
            break;
        case 4:
        {
            AreaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AreaTableViewCell"];
            if (!cell) {
                cell = [[AreaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AreaTableViewCell"];
                [cell setTitle:_roomItems[indexPath.row]];
                [cell setminValue:0 andMaxValue:60];
                _areaTableViewCell = cell;
                [_areaTableViewCell setArea:_roomJSON[@"area"]];
            }
            
            return cell;
        }
            break;
        case 5:
        {
            OrientationSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrientationSelectTableViewCell"];
            if (!cell) {
                cell = [[OrientationSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OrientationSelectTableViewCell"];
                [cell setTitle:_roomItems[indexPath.row]];
                _orientationSelectTableViewCell = cell;
                [_orientationSelectTableViewCell setOrientation:_roomJSON[@"orientation"]];
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
            return rentStatusTableViewCellHeight;
            break;
        case 1:
            return roomPhotosAddTableViewCellHeight;
            break;
        case 2:
            return roomTypeTableViewCellHeight;
            break;
        case 3:
            return monthlyRentTableViewCellHeight;
            break;
        case 4:
            return areaTableViewCellHeight;
            break;
        case 5:
            return orientationSelectTableViewCellHeight;
            break;
        default:
            return 44;
            break;
    }
    
    return 44;
}

#pragma mark - NYPhotoBrowserDelegate
- (void)photoBrowser:(NYPhotoBrowser *)browser DidDeletePhotoAtIndex:(NSUInteger)index {
    [_roomPhotosAddTableViewCell deletePhotoAtIndex:index];
    [self reloadAddPhotosTableViewCell];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex <= 1) {
        if (buttonIndex == 0) {
            //拍照
            if ([App isCameraAvailable] && [App doesCameraSupportTakingPhotos]){
                UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.delegate = self;
                imagePicker.allowsEditing = NO; // allowsEditing in 3.1
                [self presentViewController:imagePicker animated:YES completion:^{
                    [self resetTableViewFrame];
                }];
            } else {
                [PopupView showMessage:lang(@"DeviceDoesNotSupportTakePhotos")];
            }
        } else if (buttonIndex == 1) {
            //相册
            AssetsPickerController * assetsPicker = [[AssetsPickerController alloc] init];
            assetsPicker.maximumNumberOfSelection = (maxNumberOfPhotos - _roomPhotosAddTableViewCell.photos.count);
            assetsPicker.assetsFilter = [ALAssetsFilter allAssets];
            assetsPicker.delegate = self;
            //采用navigationController弹出窗口，避免添加房间照片时，房子信息下方的黑线消失
            [self.navigationController presentViewController:assetsPicker animated:YES completion:^{
                [self resetTableViewFrame];
            }];
        }
    }
}

- (void)resetTableViewFrame {
    CGRect frame = self.view.frame;
    _tableViewY = MAX(frame.origin.y, _tableViewY);
    _originFrame.origin.y = _tableViewY;
    _roomItemsTableView.frame = _originFrame;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //拍照
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (_roomPhotosAddTableViewCell) {
            [_roomPhotosAddTableViewCell addPhoto:image];
            [self reloadAddPhotosTableViewCell];
        }
    }];
}

- (void)assetsPickerController:(AssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    //相册
    for (ALAsset *asset in assets) {
        CGImageRef ref = [[asset defaultRepresentation] fullScreenImage];
        UIImage *image = [[UIImage alloc] initWithCGImage:ref];
        if (_roomPhotosAddTableViewCell) {
            [_roomPhotosAddTableViewCell addPhoto:image];
        }
    }
    
    [self reloadAddPhotosTableViewCell];
}

- (void)reloadAddPhotosTableViewCell {
    [_roomItemsTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (textField == _monthlyRentTableViewCell.priceTextField ) {
        [UIView animateWithDuration:0.5f animations:^{
            self.roomItemsTableView.contentOffset = CGPointMake(0, rentStatusTableViewCellHeight+roomPhotosAddTableViewCellHeight+roomTypeTableViewCellHeight);
        }];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ( textField == _monthlyRentTableViewCell.priceTextField) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
