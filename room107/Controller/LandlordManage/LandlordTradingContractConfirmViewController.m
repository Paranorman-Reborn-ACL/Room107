//
//  LandlordTradingContractConfirmViewController.m
//  room107
//
//  Created by ningxia on 15/9/9.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LandlordTradingContractConfirmViewController.h"
#import "Room107TableView.h"
#import "RoundedGreenButton.h"
#import "IdentityInfoTableViewCell.h"
#import "ProofOfLeaseQualificationsTableViewCell.h"
#import "CustomInfoItemTableViewCell.h"
#import "LicenseAgreementTableViewCell.h"
#import "YellowColorTextLabel.h"
#import "NSString+Valid.h"
#import "AssetsPickerViewController.h"
#import "NYPhotoBrowser.h"
#import "QiniuFileAgent.h"
#import "HouseManageAgent.h"
#import "NSString+Encoded.h"
#import "SystemAgent.h"
#import "ProofOfLeaseQualificationsViewController.h"
#import "CustomTextField.h"
#import "SignedProcessAgent.h"

@interface LandlordTradingContractConfirmViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AssetsPickerControllerDelegate, NYPhotoBrowserDelegate,UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) Room107TableView *sectionsTableView;
@property (nonatomic, strong) ContractInfoModel *contractInfo;
@property (nonatomic, strong) void (^confirmContractButtonHandlerBlock)(UserIdentityModel *userIdentity, ContractInfoModel *contractInfo, NSNumber *contractStatus);
@property (nonatomic, strong) void (^changeContractButtonHandlerBlock)();
@property (nonatomic, strong) IdentityInfoTableViewCell *identityInfoTableViewCell;
@property (nonatomic, strong) ProofOfLeaseQualificationsTableViewCell *currentPhotosTableViewCell;
@property (nonatomic, strong) LicenseAgreementTableViewCell *licenseAgreementTableViewCell;
@property (nonatomic, strong) NSArray *diff;
@property (nonatomic, strong) UIAlertView *inputPasswordAlertView;

@end

@implementation LandlordTradingContractConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setContractInfo:(ContractInfoModel *)contractInfo andDifferent:(NSArray *)diff {
    _diff = diff;
    [self refreshDataWithContractInfo:contractInfo];
    if (_diff && _diff.count > 0) {
        [self showAlertViewWithTitle:lang(@"TenantInfoChangedTips") message:@""];
    }
}

- (void)refreshDataWithContractInfo:(ContractInfoModel *)contractInfo {
    _contractInfo = contractInfo;
    
    if (!_sections) {
        _sections = [[NSMutableArray alloc] init];
    }
    [_sections removeAllObjects];
    
    AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@0];
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[@"●" stringByAppendingString:appText.text ? appText.text : @""], @"key", [NSMutableArray arrayWithObjects:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"LandlordInfo"), @"key", nil], [NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"ProofOfLeaseQualifications"), @"key", nil], nil], @"value", nil]];
    
    NSMutableArray *followingInfos = [[NSMutableArray alloc] init];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"RentMoney"), @"key", [@"￥" stringByAppendingString:[contractInfo.monthlyPrice stringValue] ? [contractInfo.monthlyPrice stringValue] : @""], @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"monthlyPrice"]], @"diff", nil]];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Address"), @"key", contractInfo.rentAddress, @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"rentAddress"]], @"diff", nil]];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"LeaseTerm"), @"key", [NSString stringWithFormat:@"%@-%@", [TimeUtil friendlyDateTimeFromDateTime:contractInfo.checkinTime withFormat:@"%Y/%m/%d"], [TimeUtil friendlyDateTimeFromDateTime:contractInfo.exitTime withFormat:@"%Y/%m/%d"]], @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"checkinTime"] || [CommonFuncs arrayHasThisContent:_diff andObject:@"exitTime"]], @"diff", nil]];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Renter"), @"key", contractInfo.tenantName, @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"tenantName"]], @"diff", nil]];
    [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"IDNumber"), @"key", contractInfo.tenantIdCard, @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"tenantIdCard"]], @"diff", nil]];
    
    if (contractInfo.tenantMoreinfo && (contractInfo.tenantMoreinfo.length != 0)) {
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"TenantAdditionalInfo"), @"key", contractInfo.tenantMoreinfo, @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"tenantMoreinfo"]], @"diff", nil]];
    }
    
    if (contractInfo.landlordMoreinfo && (contractInfo.landlordMoreinfo.length != 0)) {
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"LandlordAdditionalInfo"), @"key", contractInfo.landlordMoreinfo, @"value", [NSNumber numberWithBool:[CommonFuncs arrayHasThisContent:_diff andObject:@"landlordMoreinfo"]], @"diff", nil]];
    }
    
    [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"MoreLeaseAndRentalInfo"), @"key", followingInfos, @"value", nil]];
    
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
    
    if (_identityInfoTableViewCell) {
        [_identityInfoTableViewCell setName:_contractInfo.landlordName];
        [_identityInfoTableViewCell setIDCard:_contractInfo.landlordIdCard];
    }
    
    if (_currentPhotosTableViewCell) {
        [_currentPhotosTableViewCell setProofPhotos:[_contractInfo.credentialsImages getComponentsBySeparatedString:@"|"]];
    }
    
    [_sectionsTableView reloadData];
    [self scrollToTop];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //保证得到正确的self.view.frame数值 
    CGRect frame = self.view.frame;
    frame.origin.y = 0 ;
    _sectionsTableView.frame = frame ;
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
    if ([_identityInfoTableViewCell.name isEqualToString:@""] || [_identityInfoTableViewCell.idCard isEqualToString:@""]) {
        [PopupView showMessage:lang(@"LandlordInfoIsEmpty")];
        [self scrollToTop];
        return;
    }
    
    if ([_currentPhotosTableViewCell photos].count <= 0) {
        [PopupView showMessage:lang(@"ProofOfLeaseQualificationsIsEmpty")];
        [self scrollToTop];
        return;
    }
    
    if (!_licenseAgreementTableViewCell.status) {
        [PopupView showMessage:lang(@"PleaseConfirmContract")];
        return;
    }
    
    _contractInfo.landlordName = _identityInfoTableViewCell.name;
    _contractInfo.landlordIdCard = _identityInfoTableViewCell.idCard;
    
    if (!_inputPasswordAlertView) {
        _inputPasswordAlertView = [[UIAlertView alloc] initWithTitle:lang(@"InputLoginPassword")
                                                                     message:lang(@"")
                                                                    delegate:self
                                                           cancelButtonTitle:lang(@"Cancel")
                                                           otherButtonTitles:lang(@"Confirm"), nil];
        
        _inputPasswordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [[_inputPasswordAlertView textFieldAtIndex:0] setTintColor:[UIColor room107GreenColor]];
        [[_inputPasswordAlertView textFieldAtIndex:0] becomeFirstResponder];
    }
    [[_inputPasswordAlertView textFieldAtIndex:0] setText:@""];
    [_inputPasswordAlertView show];
}

- (void)saveContractInfoWithPassword:(NSString *)password {
    __block NSString *imagesMaxString = @"";
    NSMutableArray *imageDics = [[NSMutableArray alloc] init];
    NSMutableArray *imageKeys = [[NSMutableArray alloc] init];
    NSArray *images = [_currentPhotosTableViewCell photos];
    
    [self showLoadingView];
    [[HouseManageAgent sharedInstance] getTokenAndImageKeyPatternWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *imageKeyPattern) {
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            for (NSUInteger i = 0; i < images.count; i++) {
                if ([images[i] isKindOfClass:[UIImage class]]) {
                    int random = [CommonFuncs randomNumber]; //获取随机数，避免文件名重复
                    [imageDics addObject:@{@"image":images[i], @"key":[NSString stringWithFormat:imageKeyPattern, random]}];
                    [imageKeys addObject:[NSString stringWithFormat:imageKeyPattern, random]];
                } else {
                    imagesMaxString = [imagesMaxString stringByAppendingFormat:@"%@|", images[i]];
                }
            }
            
            if (imageDics.count > 0) {
                [[QiniuFileAgent sharedInstance] uploadWithImageDics:imageDics token:token completion:^(NSError *error, NSString *errorMsg) {
                    if (!error) {
                        [[HouseManageAgent sharedInstance] uploadImagesWithImageKeys:imageKeys completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *imagesString) {
                            if (errorTitle || errorMsg) {
                                [PopupView showTitle:errorTitle message:errorMsg];
                            }
                
                            if (!errorCode) {
                                imagesMaxString = [imagesMaxString stringByAppendingString:imagesString ? imagesString : @""];
                                _contractInfo.credentialsImages = [imagesMaxString URLEncodedString];
                                
                                [self landlordConfirmContractWithPassword:password];
                            } else {
                                [self hideLoadingView];
                                if ([self isLoginStateError:errorCode]) {
                                    return;
                                }
                            }
                        }];
                    } else {
                        [self hideLoadingView];
                        [PopupView showMessage:errorMsg];
                    }
                }];
            } else {
                //未更改图片
                imagesMaxString = [imagesMaxString substringToIndex:imagesMaxString.length > 0 ? imagesMaxString.length - 1 : 0];
                _contractInfo.credentialsImages = [imagesMaxString URLEncodedString];
                
                [self landlordConfirmContractWithPassword:password];
            }
        } else {
            [self hideLoadingView];
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (void)landlordConfirmContractWithPassword:(NSString *)password {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:_contractInfo.landlordName forKey:@"name"];
    [info setObject:_contractInfo.landlordIdCard forKey:@"idCard"];
    [info setObject:_contractInfo.credentialsImages forKey:@"credentialsImages"];
    
    [[SignedProcessAgent sharedInstance] landlordConfirmContractWithContractID:_contractInfo.contractId andPassword:password andInfo:info completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            if (self.confirmContractButtonHandlerBlock) {
                self.confirmContractButtonHandlerBlock(userIdentity, contractInfo, contractStatus);
            }
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (void)assistantButtonDidClick {
    if (self.changeContractButtonHandlerBlock) {
        self.changeContractButtonHandlerBlock();
    }
}

- (void)setConfirmContractButtonDidClickHandler:(void(^)(UserIdentityModel *userIdentity, ContractInfoModel *contractInfo, NSNumber *contractStatus))handler {
    _confirmContractButtonHandlerBlock = handler;
}

- (void)setChangeContractButtonDidClickHandler:(void(^)())handler {
    _changeContractButtonHandlerBlock = handler;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([alertView isEqual:_inputPasswordAlertView]) {
            if ([[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
                [PopupView showMessage:lang(@"InvalidPassword")];
                return;
            }
            
            [self saveContractInfoWithPassword:[[alertView textFieldAtIndex:0] text]];
        }
    }
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
            switch (indexPath.row) {
                case 0:
                {
                    IdentityInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IdentityInfoTableViewCell"];
                    if (!cell) {
                        cell = [[IdentityInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IdentityInfoTableViewCell"];
                        [cell setTitle:_sections[indexPath.section][@"value"][indexPath.row][@"key"]];
                        _identityInfoTableViewCell = cell;
                        cell.fullNameTextField.delegate = self;
                        cell.IDNumberTextField.delegate = self;
                        [_identityInfoTableViewCell setName:_contractInfo.landlordName];
                        [_identityInfoTableViewCell setIDCard:_contractInfo.landlordIdCard];
                    }
                    return cell;
                }
                    break;
                default:
                {
                    ProofOfLeaseQualificationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProofOfLeaseQualificationsTableViewCell"];
                    if (!cell) {
                        cell = [[ProofOfLeaseQualificationsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProofOfLeaseQualificationsTableViewCell"];
                        [cell setTitle:_sections[indexPath.section][@"value"][indexPath.row][@"key"]];
                        _currentPhotosTableViewCell = cell;
                        [_currentPhotosTableViewCell setProofPhotos:[_contractInfo.credentialsImages getComponentsBySeparatedString:@"|"]];
                    }
                    
                    [cell setContent:lang(@"ViewSample")];
                    [cell setViewDidClickHandler:^{
                        ProofOfLeaseQualificationsViewController *proofOfLeaseQualificationsViewController = [[ProofOfLeaseQualificationsViewController alloc] init];
                        [self.navigationController pushViewController:proofOfLeaseQualificationsViewController animated:YES];
                    }];
                    
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
            }
            break;
        case 1:
        {
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
        case 0:
            switch (indexPath.row) {
                case 0:
                    return identityInfoTableViewCellHeight + 22;
                    break;
                default:
                    return proofOfLeaseQualificationsTableViewCellHeight;
                    break;
            }
            break;
        case 1:
            return customInfoItemTableViewCellHeight;
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
            [self presentViewController:assetsPicker animated:YES completion:^{
                
            }];
        }
    }
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
    [_sectionsTableView reloadData];
}

#pragma mark - UITextfieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.5 animations:^{
        self.sectionsTableView.contentOffset = CGPointMake(0, 200);
    }];
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
