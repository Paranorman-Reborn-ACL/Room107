//
//  AuditStatusForPostViewController.m
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "AuditStatusForPostViewController.h"
#import "AssetsPickerViewController.h"
#import "NYPhotoBrowser.h"
#import "RoundedGreenButton.h"
#import "Room107TableView.h"
#import "SearchTipLabel.h"
#import "SCGIFImageView.h"
#import "YellowColorTextLabel.h"
#import "IdentityInfoTableViewCell.h"
#import "ProofOfLeaseQualificationsTableViewCell.h"
#import "HouseManageAgent.h"
#import "NSString+Encoded.h"
#import "NSDictionary+JSONString.h"
#import "NSString+Valid.h"
#import "HouseManageAgent.h"
#import "QiniuFileAgent.h"
#import "SystemAgent.h"
#import "ProofOfLeaseQualificationsViewController.h"
#import "CustomTextField.h"
#import "SeparatedView.h"

@interface AuditStatusForPostViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AssetsPickerControllerDelegate, NYPhotoBrowserDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIView *detectingView;
@property (nonatomic, strong) Room107TableView *auditStatusTableView;
@property (nonatomic, strong) NSArray *landlordInfos;
@property (nonatomic, strong) IdentityInfoTableViewCell *identityInfoTableViewCell;
@property (nonatomic, strong) ProofOfLeaseQualificationsTableViewCell *currentPhotosTableViewCell;
@property (nonatomic, strong) NSMutableDictionary *houseJSON;//描述房子信息（包含房子信息），json格式，json对应的数据结构为LandlordSuiteItem，json整体进行urlEncode
@property (nonatomic, strong) UserIdentityModel *userIdentity;
@property (nonatomic, strong) NSNumber *houseID;
@property (nonatomic, strong) NSNumber *numberOfPusher;
@property (nonatomic, strong) NSString *credentialsImages;
@property (nonatomic, strong) void (^doneHandlerBlock)();

@end

@implementation AuditStatusForPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self submitSuite];
    
    _landlordInfos = @[lang(@"LandlordInfo"), lang(@"ProofOfLeaseQualifications")];
}

- (void)submitSuite {
    [self showLoadingView];
    
    NSMutableDictionary *serverHouseJSON = [[NSMutableDictionary alloc] initWithDictionary:[_houseJSON copy]];
    [serverHouseJSON setObject:serverHouseJSON[@"suiteDescription"] forKey:@"description"];
    [serverHouseJSON removeObjectForKey:@"suiteDescription"];
    
    NSString *encodedHouseJSON = [[serverHouseJSON JSONRepresentationWithPrettyPrint:YES] URLEncodedString];
    NSMutableDictionary *suiteInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:encodedHouseJSON, @"house", nil];
    WEAK_SELF weakSelf = self;
    [[HouseManageAgent sharedInstance] submitSuiteWithSuiteInfo:suiteInfo completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *houseID, NSNumber *number, UserIdentityModel *id, NSString *credentialsImages) {
        [weakSelf hideLoadingView];
        
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            [UIView animateWithDuration:3.0 animations:^{
                [weakSelf showAuditStatusTableView:NO];
            } completion:^(BOOL finished) {
                weakSelf.userIdentity = id;
                weakSelf.houseID = houseID;
                weakSelf.numberOfPusher = number;
                weakSelf.credentialsImages = credentialsImages;
                if (weakSelf.identityInfoTableViewCell) {
                    weakSelf.identityInfoTableViewCell.name = weakSelf.userIdentity.name;
                    [weakSelf.identityInfoTableViewCell setIDCard:weakSelf.userIdentity.idCard];
                }
                
                if (weakSelf.currentPhotosTableViewCell) {
                    [weakSelf.currentPhotosTableViewCell setProofPhotos:[weakSelf.credentialsImages getComponentsBySeparatedString:@"|"]];
                }                
                //发布成功删除草稿
                [[HouseManageAgent sharedInstance] deleteHouseJSON];
                [weakSelf showAuditStatusTableView:YES];
            }];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (void)showAuditStatusTableView:(BOOL)show {
    if (!_auditStatusTableView) {
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        
        _auditStatusTableView = [[Room107TableView alloc] initWithFrame:frame];
        _auditStatusTableView.delegate = self;
        _auditStatusTableView.dataSource = self;
        _auditStatusTableView.tableHeaderView = [self createHeaderView];
        _auditStatusTableView.tableFooterView = [self createFooterView];
        [self.view addSubview:_auditStatusTableView];

        _detectingView = [[UIView alloc] initWithFrame:frame];
        [_detectingView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:_detectingView];
        
        CGFloat imageViewWidth = 168;
        CGFloat imageViewHeight = 140;
        CGFloat originY = CGRectGetHeight(_detectingView.bounds) * 0.3 - imageViewWidth / 2;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"detecting.gif" ofType:nil];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        SCGIFImageView *totoroDetectingImageView = [[SCGIFImageView alloc] initWithFrame:(CGRect){(CGRectGetWidth(_detectingView.bounds) - imageViewWidth) / 2, originY, imageViewWidth, imageViewHeight}];
        [totoroDetectingImageView setData:imageData];
        [_detectingView addSubview:totoroDetectingImageView];
        
        originY += CGRectGetHeight(totoroDetectingImageView.bounds) + 22;
        YellowColorTextLabel *totoroDetectingLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(_detectingView.bounds), 40} withTitle:lang(@"TotoroDetecting")];
        [_detectingView addSubview:totoroDetectingLabel];
    }
    
    _auditStatusTableView.hidden = !show;
    _detectingView.hidden = show;
}

- (void)setHouseJSON:(NSMutableDictionary *)houseJSON {
    _houseJSON = houseJSON;
}

- (void)setDoneButtonDidClickHandler:(void(^)())handler {
    _doneHandlerBlock = handler;
}

- (UIView *)createHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 350}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 22;
    CGFloat originY = 10;
    CGFloat viewWidth = CGRectGetWidth(headerView.bounds) - 2 * originX;
    YellowColorTextLabel *postSuiteSuccessLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){originX, originY, viewWidth, 30}];
    [postSuiteSuccessLabel setFont:[UIFont room107SystemFontFive]];
    [postSuiteSuccessLabel setText:lang(@"PostSuiteSuccess")];
    [headerView addSubview:postSuiteSuccessLabel];
    
    originY += CGRectGetHeight(postSuiteSuccessLabel.bounds) + 5;
    YellowColorTextLabel *detectSuccessLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){originX + 11, originY, viewWidth - 11 * 2, 60} withTitle:lang(@"TotoroDetectSuccess") withTitleColor:[UIColor room107GrayColorC]];
    [headerView addSubview:detectSuccessLabel];
    
    CGFloat spacingY = 30;
    originY += CGRectGetHeight(detectSuccessLabel.bounds) + spacingY;
    CGFloat labelHeight = 30;
    SearchTipLabel *countOfPusherLabel = [self countOfLabel:[_numberOfPusher stringValue] andTips:lang(@"CountOfPusher") andFrame:(CGRect){originX, originY, viewWidth, labelHeight}];
    [headerView addSubview:countOfPusherLabel];
    
    originY += CGRectGetHeight(countOfPusherLabel.bounds) + 33;
    SeparatedView *separatedView = [[SeparatedView alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(headerView.bounds), 1}];
    [headerView addSubview:separatedView];
    
    originY += CGRectGetHeight(separatedView.bounds) + 33;
    originX += 11;
    viewWidth = CGRectGetWidth(headerView.bounds) - 2 * originX;
    AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@7];
    YellowColorTextLabel *titleLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){originX, originY, viewWidth, 100} withTitle:[NSString stringWithFormat:@"●%@\n%@", appText.title ? appText.title : @"", appText.text ? appText.text : @""]];
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (SearchTipLabel *)countOfLabel:(NSString *)count andTips:(NSString *)tips andFrame:(CGRect)frame{
    SearchTipLabel *countOfLabel = [[SearchTipLabel alloc] initWithFrame:frame];
    [countOfLabel setTextAlignment:NSTextAlignmentCenter];
    
    NSString *countOfSubscriber = [count ? count : @"0" stringByAppendingString:tips ? tips : @""];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:countOfSubscriber];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFive] range:NSMakeRange(0, countOfSubscriber.length - tips.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107YellowColor] range:NSMakeRange(0, countOfSubscriber.length - tips.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontThree] range:NSMakeRange(countOfSubscriber.length - tips.length, tips.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GrayColorD] range:NSMakeRange(countOfSubscriber.length - tips.length, tips.length)];
    [countOfLabel setAttributedText:attributedString];
    
    return countOfLabel;
}

- (UIView *)createFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 100.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:footerView.frame andMainButtonTitle:lang(@"Done") andAssistantButtonTitle:@""];
    [footerView addSubview:mutualBottomView];
    WEAK_SELF weakSelf = self;
    [mutualBottomView setMainButtonDidClickHandler:^{
        if (![_identityInfoTableViewCell.name isEqualToString:@""] && ![_identityInfoTableViewCell.idCard isEqualToString:@""]) {
            [weakSelf showLoadingView];
            [[HouseManageAgent sharedInstance] updateAccountInfoWithName:_identityInfoTableViewCell.name andIDCard:_identityInfoTableViewCell.idCard andDebitCard:@"" completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                [weakSelf hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                    
                if (!errorCode) {
                    [weakSelf updateCredentialsImages];
                }
            }];
        } else {
            [weakSelf updateCredentialsImages];
        }
    }];
    
    return footerView;
}

- (void)updateCredentialsImages {
    __block NSString *imagesMaxString = @"";
    
    NSMutableArray *imageDics = [[NSMutableArray alloc] init];
    NSMutableArray *imageKeys = [[NSMutableArray alloc] init];
    NSArray *images = [_currentPhotosTableViewCell photos];
    
    if (images.count <= 0) {
        [self openPostSuiteManageView];
        return;
    }
    
    [self showLoadingView];
    WEAK_SELF weakSelf = self;
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
                                
                                [[HouseManageAgent sharedInstance] updateCredentialsImagesWithHouseID:_houseID andCredentialsImages:[imagesMaxString URLEncodedString] completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                                    [weakSelf hideLoadingView];
                                    if (errorTitle || errorMsg) {
                                        [PopupView showTitle:errorTitle message:errorMsg];
                                    }
                
                                    if (!errorCode) {
                                        [weakSelf openPostSuiteManageView];
                                    } else {
                                        if ([self isLoginStateError:errorCode]) {
                                            return;
                                        }
                                    }
                                }];
                            } else {
                                [weakSelf hideLoadingView];
                                if ([self isLoginStateError:errorCode]) {
                                    return;
                                }
                            }
                        }];
                    } else {
                        [weakSelf hideLoadingView];
                    }
                }];
            } else {
                [weakSelf hideLoadingView];
                //未更改图片
                [weakSelf openPostSuiteManageView];
            }
        } else {
            [weakSelf hideLoadingView];
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (void)openPostSuiteManageView {
    if (_doneHandlerBlock) {
        _doneHandlerBlock();
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _landlordInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            IdentityInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IdentityInfoTableViewCell"];
            if (!cell) {
                cell = [[IdentityInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IdentityInfoTableViewCell"];
                [cell setTitle:_landlordInfos[indexPath.row]];
                cell.fullNameTextField.delegate = self;
                cell.IDNumberTextField.delegate = self;
                _identityInfoTableViewCell = cell;
            }
            
            return cell;
        }
            break;
        case 1:
        {
            ProofOfLeaseQualificationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProofOfLeaseQualificationsTableViewCell"];
            if (!cell) {
                cell = [[ProofOfLeaseQualificationsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProofOfLeaseQualificationsTableViewCell"];
                [cell setTitle:_landlordInfos[indexPath.row]];
                _currentPhotosTableViewCell = cell;
            }
            
            [cell setContent:lang(@"ViewSample")];
            WEAK_SELF weakSelf = self;
            [cell setViewDidClickHandler:^{
                ProofOfLeaseQualificationsViewController *proofOfLeaseQualificationsViewController = [[ProofOfLeaseQualificationsViewController alloc] init];
                [weakSelf.navigationController pushViewController:proofOfLeaseQualificationsViewController animated:YES];
            }];
            
            WEAK(cell) weakCell = cell;
            [cell setSelectPhotoHandler:^(NSInteger index) {
                if (index == -1) {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                                  initWithTitle:@""
                                                  delegate:weakSelf
                                                  cancelButtonTitle:lang(@"Cancel")
                                                  destructiveButtonTitle:lang(@"Camera")
                                                  otherButtonTitles:lang(@"Photos"), nil];
                    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
                    actionSheet.destructiveButtonIndex = -1;//销毁按钮（红色），对用户的某个动作起到警示作用，-1代表不设置
                    [actionSheet showInView:weakSelf.view];
                } else {
                    NYPhotoBrowser *photoBrowser = [[NYPhotoBrowser alloc] initWithImages:[weakCell photos]];
                    [photoBrowser setInitialPageIndex:index];
                    photoBrowser.delegate = weakSelf;
                    [weakSelf presentViewController:photoBrowser animated:YES completion:^{
                        
                    }];
                }
            }];
            
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
            return identityInfoTableViewCellHeight + 20;
            break;
        case 1:
            return proofOfLeaseQualificationsTableViewCellHeight + 40;
            break;
        default:
            return 44;
            break;
    }
    
    return 44;
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
    WEAK_SELF weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (weakSelf.currentPhotosTableViewCell) {
            [weakSelf.currentPhotosTableViewCell addPhoto:image];
            [weakSelf reloadAddPhotosTableViewCell];
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
    [_auditStatusTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    WEAK_SELF weakSelf = self;
    if (textField == _identityInfoTableViewCell.fullNameTextField ) {
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.auditStatusTableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.auditStatusTableView.tableHeaderView.frame));
        }];
    } else if (textField == _identityInfoTableViewCell.IDNumberTextField ) {
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.auditStatusTableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.auditStatusTableView.tableHeaderView.frame) + 80);
        }];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
