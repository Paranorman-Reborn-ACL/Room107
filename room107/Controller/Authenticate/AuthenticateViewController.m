//
//  AuthenticateViewController.m
//  room107
//
//  Created by ningxia on 15/7/22.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "AuthenticateViewController.h"
#import "RapidAuthenticateViewController.h"
#import "EmailAuthenticateView.h"
#import "RegularExpressionUtil.h"
#import "AuthenticationAgent.h"
#import "CredentialsAuthenticateView.h"
#import "AssetsPickerViewController.h"
#import "QiniuFileAgent.h"
#import "Room107UserDefaults.h"
#import "DZNSegmentedControl.h"
#import "UIScrollView+DZNSegmentedControl.h"
#import "SuggestionViewController.h"
#import "SystemAgent.h"

@interface AuthenticateViewController () <EmailAuthenticateViewDelegate, CredentialsAuthenticateViewDelegate, DZNSegmentedControlDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AssetsPickerControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DZNSegmentedControl *segmentedControl;
@property (nonatomic, strong) RapidAuthenticateViewController *rapidAuthenticateViewController; //极速认证
@property (nonatomic, strong) EmailAuthenticateView *emailAuthenticateView; //邮箱认证
@property (nonatomic, strong) CredentialsAuthenticateView *credentialsAuthenticateView; //证件认证

@end

@implementation AuthenticateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"Authentication")];
    [self setRightBarButtonTitle:lang(@"Help")];
    [self createTopView];
}

- (void)createTopView {
    CGFloat originY = 0;
    CGRect frame = self.view.frame;
    frame.origin.y = originY;
    frame.size.height = [self heightOfSegmentedControl];
    
    self.segmentedControl = [[DZNSegmentedControl alloc] initWithFrame:frame];
    self.segmentedControl.delegate = self;
    NSArray *items = @[lang(@"EmailAuthenticate"), lang(@"CredentialsAuthenticate")];
    AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
    if (!appProperties || !appProperties.rapidVerifySwitch) {
        [[SystemAgent sharedInstance] getPropertiesFromServer];
    } else {
        if ([appProperties.rapidVerifySwitch boolValue]) {
            //极速认证有效
            items = @[lang(@"RapidAuthenticate"), lang(@"EmailAuthenticate"), lang(@"CredentialsAuthenticate")];
        }
    }
    self.segmentedControl.items = items;
    self.segmentedControl.showsCount = NO;
    self.segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
    [self.segmentedControl setTintColor:[UIColor room107GreenColor]];
    [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateNormal];
    [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateDisabled];
    [self.view addSubview:_segmentedControl];
    
    originY += CGRectGetHeight(self.segmentedControl.bounds);
    frame = self.view.frame;
    frame.origin.y = originY;
    frame.size.height -= frame.origin.y;
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES; //支持左右滑动时segmentedControl跟着一起走
    self.scrollView.segmentedControl = self.segmentedControl;
    [self.view addSubview:_scrollView];
}

- (void)endTextField {
    [self.view endEditing:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    __block CGFloat originX = 0.0;
    AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
    
    [self.segmentedControl.items enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = originX;
        frame.origin.y = 0.5;
        frame.size.height -= statusBarHeight + navigationBarHeight;
        
        switch (idx) {
            case 0:
                if (!appProperties || !appProperties.rapidVerifySwitch) {
                    //邮箱认证
                    [self showEmailAuthenticateWithFrame:frame];
                } else {
                    if ([appProperties.rapidVerifySwitch boolValue]) {
                        //极速认证
                        [self showRapidAuthenticateWithFrame:frame];
                    } else {
                        //邮箱认证
                        [self showEmailAuthenticateWithFrame:frame];
                    }
                }
                break;
            case 1:
                if (!appProperties || !appProperties.rapidVerifySwitch) {
                    //证件认证
                    [self showCredentialsAuthenticateWithFrame:frame];
                } else {
                    if ([appProperties.rapidVerifySwitch boolValue]) {
                        //邮箱认证
                        [self showEmailAuthenticateWithFrame:frame];
                    } else {
                        //证件认证
                        [self showCredentialsAuthenticateWithFrame:frame];
                    }
                }
                break;
            default:
                //证件认证
                [self showCredentialsAuthenticateWithFrame:frame];
                break;
        }
        
        originX += CGRectGetWidth(frame);
    }];
    self.scrollView.contentSize = CGSizeMake(originX, self.scrollView.frame.size.height);
    [self.segmentedControl setSelectedSegmentIndex:MIN(self.segmentedControl.items.count - 1, [[Room107UserDefaults getValueFromUserDefaultsWithKey:AuthenticateTypeKey] unsignedIntegerValue])];
    CGRect frame = _scrollView.frame;
    frame.origin.x = _segmentedControl.selectedSegmentIndex * frame.size.width;
    [self.scrollView scrollRectToVisible:frame animated:NO];
}

//极速认证
- (void)showRapidAuthenticateWithFrame:(CGRect)frame {
    if (!_rapidAuthenticateViewController) {
        _rapidAuthenticateViewController = [[RapidAuthenticateViewController alloc] init];
        [_rapidAuthenticateViewController setNavigationController:self.navigationController];
        _rapidAuthenticateViewController.view.frame = frame;
        [self.scrollView addSubview:_rapidAuthenticateViewController.view];
    }
}

//邮箱认证
- (void)showEmailAuthenticateWithFrame:(CGRect)frame {
    if (!_emailAuthenticateView) {
        _emailAuthenticateView = [[EmailAuthenticateView alloc] initWithFrame:frame];
        _emailAuthenticateView.delegate = self;
        [self.scrollView addSubview:_emailAuthenticateView];
    }
    
    if ([[Room107UserDefaults getValueFromUserDefaultsWithKey:AuthenticateEmailStepKey] unsignedIntegerValue] == AuthenticateStepTwoEmail) {
        [self showEmailAuthenticateStep:2];
    } else {
        [self showEmailAuthenticateStep:1];
    }
}

//证件认证
- (void)showCredentialsAuthenticateWithFrame:(CGRect)frame {
    if (!_credentialsAuthenticateView) {
        _credentialsAuthenticateView = [[CredentialsAuthenticateView alloc] initWithFrame:frame];
        _credentialsAuthenticateView.delegate = self;
        [self.scrollView addSubview:_credentialsAuthenticateView];
    }
    
    if ([[Room107UserDefaults getValueFromUserDefaultsWithKey:AuthenticateCredentialsStepKey] unsignedIntegerValue] == AuthenticateStepTwoCredentials) {
        [self showCredentialsAuthenticateStep:2];
    } else {
        [self showCredentialsAuthenticateStep:1];
    }
}

- (void)showEmailAuthenticateStep:(NSUInteger)step {
    if (step == 1) {
        [Room107UserDefaults saveUserDefaultsWithKey:AuthenticateEmailStepKey andValue:[NSNumber numberWithUnsignedInteger:AuthenticateStepOneEmail]];
    } else {
        [_emailAuthenticateView setAuthenticateEmail:[Room107UserDefaults getValueFromUserDefaultsWithKey:AuthenticateEmailKey]];
        [Room107UserDefaults saveUserDefaultsWithKey:AuthenticateEmailStepKey andValue:[NSNumber numberWithUnsignedInteger:AuthenticateStepTwoEmail]];
    }

    [_emailAuthenticateView showStep:step];
}

- (void)showCredentialsAuthenticateStep:(NSUInteger)step {
    if (step == 1) {
        [Room107UserDefaults saveUserDefaultsWithKey:AuthenticateCredentialsStepKey andValue:[NSNumber numberWithUnsignedInteger:AuthenticateStepOneCredentials]];
    } else {
        [_credentialsAuthenticateView setIDCareImageURL:[Room107UserDefaults getValueFromUserDefaultsWithKey:IDCardImageURLKey] andWorkCardImageURL:[Room107UserDefaults getValueFromUserDefaultsWithKey:WorkCardImageURLKey]];
        [Room107UserDefaults saveUserDefaultsWithKey:AuthenticateCredentialsStepKey andValue:[NSNumber numberWithUnsignedInteger:AuthenticateStepTwoCredentials]];
    }
    
    [_credentialsAuthenticateView showStep:step];
}

- (IBAction)backButtonDidClick:(id)sender {
    [Room107UserDefaults saveUserDefaultsWithKey:AuthenticateTypeKey andValue:[NSNumber numberWithInteger:self.segmentedControl.selectedSegmentIndex]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    WEAK_SELF weakSelf = self;
    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
    }];
    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
        [weakSelf.navigationController pushViewController:[[SuggestionViewController alloc] init] animated:YES];
    }];
    AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@14];
    if (!appText) {
        [[SystemAgent sharedInstance] getTextPropertiesFromServer];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appText.title ? appText.title : @"" message:appText.text ? appText.text : @"" cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
    [alert show];
}

#pragma mark - DZNSegmentedControlDelegate
- (void)selectedSegmentIndexChanged:(DZNSegmentedControl *)DZNSegmentedControl {
    [self.view endEditing:YES];
    
    [Room107UserDefaults saveUserDefaultsWithKey:AuthenticateTypeKey andValue:[NSNumber numberWithInteger:self.segmentedControl.selectedSegmentIndex]];
}

#pragma mark - EmailAuthenticateViewDelegate
- (void)sendAuthenticateEmailButtonDidClick:(EmailAuthenticateView *)emailAuthenticateView {
    if (![RegularExpressionUtil validEmail:[emailAuthenticateView authenticateEmail]]) {
        [PopupView showMessage:lang(@"WrongEmail")];
        return;
    }
    
    [self showLoadingView];
    [[AuthenticationAgent sharedInstance] verifyByEmail:[emailAuthenticateView authenticateEmail] completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            [Room107UserDefaults saveUserDefaultsWithKey:AuthenticateEmailKey andValue:[emailAuthenticateView authenticateEmail]];
            [self showEmailAuthenticateStep:2];
        }
    }];
}

#pragma mark - EmailAuthenticateViewResultDelegate
- (void)changeEmailButtonDidClick:(EmailAuthenticateView *)emailAuthenticateView {
    [self showEmailAuthenticateStep:1];
}

#pragma mark - CredentialsAuthenticateViewDelegate
- (void)confirmAuthenticateButtonDidClick:(CredentialsAuthenticateView *)credentialsAuthenticateView {
    [self showLoadingView];
    [[AuthenticationAgent sharedInstance] getUploadTokenAndCardKeyWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *idCardKey, NSString *workCardKey) {
        if (token) {
            NSMutableArray *imageDics = [[NSMutableArray alloc] init];
            [imageDics addObject:@{@"image":[_credentialsAuthenticateView IDPhoto], @"key":idCardKey}];
            [imageDics addObject:@{@"image":[_credentialsAuthenticateView studentcardOrWorkpermitPhoto], @"key":workCardKey}];
            [[QiniuFileAgent sharedInstance] uploadWithImageDics:imageDics token:token completion:^(NSError *error, NSString *errorMsg) {
                if (!error) {
                    [[AuthenticationAgent sharedInstance] uploadImageWithIDCardKey:idCardKey andWorkCardKey:workCardKey completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *idCardImage, NSString *workCardImage) {
                        [self hideLoadingView];
                        if (errorTitle || errorMsg) {
                            [PopupView showTitle:errorTitle message:errorMsg];
                        }
                
                        if (!errorCode) {
                            [Room107UserDefaults saveUserDefaultsWithKey:IDCardImageURLKey andValue:idCardImage];
                            [Room107UserDefaults saveUserDefaultsWithKey:WorkCardImageURLKey andValue:workCardImage];
                            [self showCredentialsAuthenticateStep:2];
                        }
                    }];
                } else {
                    [self hideLoadingView];
                    [PopupView showMessage:errorMsg];
                }
            }];
        } else {
            [self hideLoadingView];
        }
    }];
}

- (void)selectCredentialsButtonDidClick:(CredentialsAuthenticateView *)credentialsAuthenticateView {
    // 弹出图片选择
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@""
                                  delegate:self
                                  cancelButtonTitle:lang(@"Cancel")
                                  destructiveButtonTitle:lang(@"Camera")
                                  otherButtonTitles:lang(@"Photos"), nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.destructiveButtonIndex = -1;//销毁按钮（红色），对用户的某个动作起到警示作用，-1代表不设置
    [actionSheet showInView:self.view];
}

#pragma mark - CredentialsAuthenticateViewResultDelegate
- (void)reuploadButtonDidClick:(CredentialsAuthenticateView *)credentialsAuthenticateView {
    [self showCredentialsAuthenticateStep:1];
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
            assetsPicker.maximumNumberOfSelection = 1;
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
        [_credentialsAuthenticateView setCredentialsPhoto:image];
    }];
}

- (void)assetsPickerController:(AssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    //相册
    for (ALAsset *asset in assets) {
        CGImageRef ref = [[asset defaultRepresentation] fullScreenImage];
        UIImage *image = [[UIImage alloc] initWithCGImage:ref];
        [_credentialsAuthenticateView setCredentialsPhoto:image];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (_scrollView.segmentedControl) {
        //判断contentOffsetKey是否被注册
        [_scrollView removeObserver:_scrollView forKeyPath:contentOffsetKey];
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
