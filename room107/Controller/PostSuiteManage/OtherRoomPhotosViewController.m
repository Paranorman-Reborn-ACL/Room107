//
//  OtherRoomPhotosViewController.m
//  room107
//
//  Created by ningxia on 15/8/29.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "OtherRoomPhotosViewController.h"
#import "Room107TableView.h"
#import "AssetsPickerViewController.h"
#import "NYPhotoBrowser.h"
#import "RoomPhotosAddTableViewCell.h"
#import "QiniuFileAgent.h"
#import "HouseManageAgent.h"
#import "NSString+Valid.h"
#import "NSDictionary+JSONString.h"
#import "NSString+Encoded.h"

@interface OtherRoomPhotosViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AssetsPickerControllerDelegate, NYPhotoBrowserDelegate>

@property (nonatomic, strong) NSString *imageToken;
@property (nonatomic, strong) NSString *imageKeyPattern;
@property (nonatomic, strong) Room107TableView *otherRoomPhotosTableView;
@property (nonatomic, strong) NSMutableArray *otherRoomItems;
@property (nonatomic, strong) RoomPhotosAddTableViewCell *kitchenTableViewCell;
@property (nonatomic, strong) RoomPhotosAddTableViewCell *hallTableViewCell;
@property (nonatomic, strong) RoomPhotosAddTableViewCell *toiletTableViewCell;
@property (nonatomic, strong) RoomPhotosAddTableViewCell *otherTableViewCell;
@property (nonatomic, strong) RoomPhotosAddTableViewCell *currentPhotosTableViewCell;
@property (nonatomic, strong) void (^saveInfoHandlerBlock)();
@property (nonatomic, strong) void (^cancelHandlerBlock)();
@property (nonatomic, strong) NSMutableDictionary *houseJSON;//描述房子信息（包含房子信息），json格式，json对应的数据结构为LandlordSuiteItem，json整体进行urlEncode
@property (nonatomic, strong) NSArray *otherRoomKeysArray;
@property (nonatomic) OtherRoomPhotosViewType otherRoomPhotosViewType;
@property (nonatomic, strong) void (^dismissHandlerBlock)();
@property (nonatomic) CGFloat tableViewY;

@end

@implementation OtherRoomPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableViewY = 0;
    
    _otherRoomItems = [NSMutableArray arrayWithObjects:lang(@"Kitchen"), lang(@"LivingRoom"), lang(@"Toilet"), lang(@"Other"), nil];
    _otherRoomKeysArray = @[@"kitchenPhotos", @"hallPhotos", @"toiletPhotos", @"otherPhotos"];
}

- (void)setImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseJSON:(NSMutableDictionary *)houseJSON andType:(OtherRoomPhotosViewType)type {
    _imageToken = imageToken;
    _imageKeyPattern = imageKeyPattern;
    _houseJSON = houseJSON;
    _otherRoomPhotosViewType = type;
    
    if (!_otherRoomPhotosTableView) {
        _otherRoomPhotosTableView = [[Room107TableView alloc] initWithFrame:self.view.frame];
        _otherRoomPhotosTableView.delegate = self;
        _otherRoomPhotosTableView.dataSource = self;
        _otherRoomPhotosTableView.tableHeaderView = [self createTableHeaderView];
        _otherRoomPhotosTableView.tableFooterView = [self createFooterView];
        [self.view addSubview:_otherRoomPhotosTableView];
    }
    
    if (_kitchenTableViewCell) {
        [_kitchenTableViewCell setRoomPhotos:[_houseJSON[_otherRoomKeysArray[0]] getComponentsBySeparatedString:@"|"]];
        [_hallTableViewCell setRoomPhotos:[_houseJSON[_otherRoomKeysArray[1]] getComponentsBySeparatedString:@"|"]];
        [_toiletTableViewCell setRoomPhotos:[_houseJSON[_otherRoomKeysArray[2]] getComponentsBySeparatedString:@"|"]];
        [_otherTableViewCell setRoomPhotos:[_houseJSON[_otherRoomKeysArray[3]] getComponentsBySeparatedString:@"|"]];
    }
    
    [self scrollToTop];
}

- (void)scrollToTop {
    [_otherRoomPhotosTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)setSaveInfoButtonDidClickHandler:(void (^)())handler {
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
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 100.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = footerView.frame;
    frame.size.height = 100;
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
    /*
     kitchenPhotos，厨房照片
     hallPhotos，大厅照片
     toiletPhotos，厕所照片
     otherPhotos，其他照片
     */
    __block NSMutableArray *allPhotos = [[NSMutableArray alloc] init];
    
    [allPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:_otherRoomKeysArray[0], @"key", [_kitchenTableViewCell photos], @"images", nil]];
    [allPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:_otherRoomKeysArray[1], @"key", [_hallTableViewCell photos], @"images", nil]];
    [allPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:_otherRoomKeysArray[2], @"key", [_toiletTableViewCell photos], @"images", nil]];
    [allPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:_otherRoomKeysArray[3], @"key", [_otherTableViewCell photos], @"images", nil]];
    
    if (allPhotos.count == 0) {
        if (self.cancelHandlerBlock) {
            self.cancelHandlerBlock();
        }
        return;
    }
    
    __block NSInteger index = 0;
    for (NSMutableDictionary *photosDic in allPhotos) {
        __block NSString *imagesMaxString = @"";
        NSMutableArray *imageDics = [[NSMutableArray alloc] init];
        NSMutableArray *imageKeys = [[NSMutableArray alloc] init];
        NSArray *images = photosDic[@"images"];
        
        for (NSUInteger i = 0; i < images.count; i++) {
            if ([images[i] isKindOfClass:[UIImage class]]) {
                int random = [CommonFuncs randomNumber]; //获取随机数，避免文件名重复
                [imageDics addObject:@{@"image":images[i], @"key":[NSString stringWithFormat:_imageKeyPattern, random]}];
                [imageKeys addObject:[NSString stringWithFormat:_imageKeyPattern, random]];
            } else {
                imagesMaxString = [imagesMaxString stringByAppendingFormat:@"%@|", images[i]];
            }
        }
        
        if (!images || imageDics.count == 0) {
            [_houseJSON setObject:imagesMaxString forKey:photosDic[@"key"]];
            index++;
            if (index == allPhotos.count) {
                [self updateInfo];
            }
            continue;
        }
        
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
                        [_houseJSON setObject:imagesMaxString forKey:photosDic[@"key"]];
                        index++;
                        if (index == allPhotos.count) {
                            [self updateInfo];
                        }
                    } else {
                        if ([self isLoginStateError:errorCode]) {
                            return;
                        }
                    }
                }];
            } else {
                [PopupView showMessage:errorMsg];
                [self hideLoadingView];
            }
        }];
    }
}

- (void)updateInfo {
    if (_otherRoomPhotosViewType == OtherRoomPhotosViewTypeNew) {
        if (self.saveInfoHandlerBlock) {
            self.saveInfoHandlerBlock();
        }
    } else {
        NSString *encodedHouseJSON = [[_houseJSON JSONRepresentationWithPrettyPrint:YES] URLEncodedString];
        NSMutableDictionary *houseInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:encodedHouseJSON, @"house", nil];
        [self showLoadingView];
        [[HouseManageAgent sharedInstance] updateHouseWithHouseInfo:houseInfo completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
            [self hideLoadingView];
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
                
            if (!errorCode) {
                if (self.saveInfoHandlerBlock) {
                    self.saveInfoHandlerBlock();
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
    return _otherRoomItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomPhotosAddTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomPhotosAddTableViewCell"];
    if (!cell) {
        cell = [[RoomPhotosAddTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomPhotosAddTableViewCell"];
    }
    [cell setTitle:_otherRoomItems[indexPath.row]];
    
    switch (indexPath.row) {
        case 0:
            if (!_kitchenTableViewCell) {
                _kitchenTableViewCell = cell;
                [_kitchenTableViewCell setRoomPhotos:[_houseJSON[_otherRoomKeysArray[indexPath.row]] getComponentsBySeparatedString:@"|"]];
                [self reloadAddPhotosTableViewCell];
            }
            break;
        case 1:
            if (!_hallTableViewCell) {
                _hallTableViewCell = cell;
                [_hallTableViewCell setRoomPhotos:[_houseJSON[_otherRoomKeysArray[indexPath.row]] getComponentsBySeparatedString:@"|"]];
                [self reloadAddPhotosTableViewCell];
            }
            break;
        case 2:
            if (!_toiletTableViewCell) {
                _toiletTableViewCell = cell;
                [_toiletTableViewCell setRoomPhotos:[_houseJSON[_otherRoomKeysArray[indexPath.row]] getComponentsBySeparatedString:@"|"]];
                [self reloadAddPhotosTableViewCell];
            }
            break;
        case 3:
            if (!_otherTableViewCell) {
                _otherTableViewCell = cell;
                [_otherTableViewCell setRoomPhotos:[_houseJSON[_otherRoomKeysArray[indexPath.row]] getComponentsBySeparatedString:@"|"]];
                [self reloadAddPhotosTableViewCell];
            }
            break;
        default:
            break;
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
        
        _currentPhotosTableViewCell = weakCell;
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return roomPhotosAddTableViewCellHeight;
}

#pragma mark - NYPhotoBrowserDelegate
- (void)photoBrowser:(NYPhotoBrowser *)browser DidDeletePhotoAtIndex:(NSUInteger)index {
    [_currentPhotosTableViewCell deletePhotoAtIndex:index];
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
            assetsPicker.maximumNumberOfSelection = (maxNumberOfPhotos - _currentPhotosTableViewCell.photos.count);
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
    frame.origin.y = _tableViewY;
    frame.size.height = _otherRoomPhotosTableView.frame.size.height;
    _otherRoomPhotosTableView.frame = frame;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //拍照
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (_currentPhotosTableViewCell) {
            [_currentPhotosTableViewCell addPhoto:image];
            [self reloadAddPhotosTableViewCell];
        }
    }];
}

- (void)assetsPickerController:(AssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    //相册
    for (ALAsset *asset in assets) {
        CGImageRef ref = [[asset defaultRepresentation] fullScreenImage];
        UIImage *image = [[UIImage alloc] initWithCGImage:ref];
        if (_currentPhotosTableViewCell) {
            [_currentPhotosTableViewCell addPhoto:image];
        }
    }
    [self reloadAddPhotosTableViewCell];
}

- (void)reloadAddPhotosTableViewCell {
    [_otherRoomPhotosTableView reloadData];
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
