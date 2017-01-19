//
//  IndividualViewController.m
//  room107
//
//  Created by ningxia on 16/4/6.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "IndividualViewController.h"
#import "SystemAgent.h"
#import "Room107TableView.h"
#import "SearchTipLabel.h"
#import "CustomImageView.h"
#import "AuthenticationAgent.h"
#import "NSString+AttributedString.h"
#import "UserAccountAgent.h"
#import "QiniuFileAgent.h"
#import "SDCycleScrollView.h"
#import "NSString+Encoded.h"
#import "TemplateViewFuncs.h"
#import "NSString+JSONCategories.h"
#import "NSDictionary+JSONString.h"

static CGFloat heightForHeaderView = 91 + statusBarHeight;

@interface IndividualViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) Room107TableView *sectionsTableView;
@property (nonatomic, strong) CustomImageView *avatarImageView;
@property (nonatomic, strong) UIButton *loginOrRegisterButton;
@property (nonatomic, strong) SearchTipLabel *telephoneLabel;
@property (nonatomic, strong) UIButton *authenticateButton;
@property (nonatomic, strong) UIButton *amountButton;
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;//CBStore下拉刷新
@property (nonatomic, strong) UIScrollView *dragScroll;
@property (nonatomic) BOOL isShowAvatarUploadedView;//头像上传的提示View是否出现过

@end

@implementation IndividualViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Build your regular UIBarButtonItem with Custom View
    [self setRightBarButtonTitle:lang(@"More")];
    [self createHeaderView];
    _isShowAvatarUploadedView = NO;
    self.fd_prefersNavigationBarHidden = YES;
    //监听当前页面列表删除卡片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCard:) name:DeleteCardNotification object:nil];
}

- (void)deleteCard:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        //判断当前窗口是否可视
        NSNumber *cardID = [notification object];
        [TemplateViewFuncs deleteCardByCardID:cardID andTableView:_sectionsTableView andData:_sections];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //防止tab切换时候导致的107间动画滞留问题 手动隐藏 下拉开始再手动放开
    [self.storeHouseRefreshControl setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self getPersonalInfoDrag:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)creatTableView {
    if (!_sectionsTableView) {
        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.origin.y = heightForHeaderView;
        frame.size.height -= frame.origin.y + tabBarHeight;
        _sectionsTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [_sectionsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _sectionsTableView.delegate = self;
        _sectionsTableView.dataSource = self;
        _sectionsTableView.tableFooterView = [[UIView alloc] initWithFrame:(CGRect){0, 0, CGRectGetWidth(_sectionsTableView.bounds), navigationBarHeight}];
        [self.view addSubview:_sectionsTableView];
        //为tableView添加下拉刷新
        self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.sectionsTableView target:self refreshAction:@selector(refreshTriggered:) plist:@"Property" color:[UIColor room107GrayColorD] lineWidth:1.5 dropHeight:95 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
    }
}

- (void)getPersonalInfoDrag:(BOOL)drag {
    WEAK_SELF weakSelf = self;
    [[SystemAgent sharedInstance] getPersonalInfo:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards) {
        if (drag) {
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
        }
        if (!errorCode) {
            [weakSelf creatTableView];
            weakSelf.sections = [TemplateViewFuncs cardsDataConvert:cards];
            [weakSelf.sectionsTableView reloadData];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
            
            if (_sectionsTableView) {
                //不是第一次进入 从子页面返回  无蛙 无提示 无阻隔
            } else {
                //第一次进入 显示🐸  无提示
                //没有网络状态下 读取本地userInfo
                [_avatarImageView setImage:[UIImage imageNamed:@"unloginlogo.png"]];
                _telephoneLabel.text = [[AppClient sharedInstance] telephone] ? [[AppClient sharedInstance] telephone] : [[AppClient sharedInstance] username];
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf showLoadingView];
                        [weakSelf getPersonalInfoDrag:NO];
                    }];
                } else {
                    [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                        [weakSelf getPersonalInfoDrag:NO];
                    }];
                }
            }
        }
        
        //返回数据后停止动画 手动保持动画0.5s
        if (drag) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDragAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.storeHouseRefreshControl finishingLoadingAndComplete:^{
                    weakSelf.sectionsTableView.scrollEnabled = YES ;
                    [self enabledPopGesture:YES];
                }];
            });
        }
        
    }];
    
    [self getUserInfo];
}

- (void)createHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, heightForHeaderView}];
    [headerView setBackgroundColor:[UIColor room107GreenColor]];
    
    CGFloat originX = 22;
    CGFloat imageViewWidth = 60;
    CGFloat originY = (heightForHeaderView - imageViewWidth - statusBarHeight) / 2  + statusBarHeight ;
    _avatarImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, imageViewWidth, imageViewWidth}];
    [_avatarImageView setBackgroundColor:[UIColor whiteColor]];
    [_avatarImageView setCornerRadius:CGRectGetWidth(_avatarImageView.bounds) / 2];
    _avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor ;
    _avatarImageView.layer.borderWidth = 1;
    _avatarImageView.layer.masksToBounds = YES;
    [headerView addSubview:_avatarImageView];
    
    originX += CGRectGetWidth(_avatarImageView.bounds) + 11;
    CGFloat viewWidth = 150;
    CGFloat viewHeight = 18;
    originY = _avatarImageView.center.y - viewHeight / 2;
    _loginOrRegisterButton = [[UIButton alloc] initWithFrame:(CGRect){originX, originY, viewWidth, viewHeight}];
    [_loginOrRegisterButton setTitle:lang(@"LoginOrRegister") forState:UIControlStateNormal];
    [_loginOrRegisterButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_loginOrRegisterButton.titleLabel setFont:[UIFont room107SystemFontFour]];
    [headerView addSubview:_loginOrRegisterButton];
    [_loginOrRegisterButton addTarget:self action:@selector(loginOrRegisterButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    originY = _avatarImageView.center.y - viewHeight;
    _telephoneLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, viewWidth - 30, viewHeight}];
    [_telephoneLabel setTextColor:[UIColor whiteColor]];
    [_telephoneLabel setFont:[UIFont room107SystemFontTwo]];
    UITapGestureRecognizer *tapClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(authenticateButtonDidClicked:)];
    [_telephoneLabel addGestureRecognizer:tapClick];
    _telephoneLabel.userInteractionEnabled = YES;
    [headerView addSubview:_telephoneLabel];
    
    originY = _avatarImageView.center.y;
    _authenticateButton = [[UIButton alloc] initWithFrame:(CGRect){originX, originY, viewWidth, viewHeight}];
    [_authenticateButton.titleLabel setFont:[UIFont room107FontTwo]];
    [_authenticateButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [headerView addSubview:_authenticateButton];
    [_authenticateButton addTarget:self action:@selector(authenticateButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:headerView];
}

- (IBAction)loginOrRegisterButtonDidClicked:(id)sender {
    [self pushLoginAndRegisterViewController];
}

- (IBAction)authenticateButtonDidClicked:(id)sender {
    [self pushAuthenticateViewController];
}

- (void)getUserInfo {
    _loginOrRegisterButton.hidden = [[AppClient sharedInstance] isLogin];
    _loginOrRegisterButton.enabled = ![[AppClient sharedInstance] isLogin];
    _telephoneLabel.hidden = ![[AppClient sharedInstance] isLogin];
    _authenticateButton.enabled = [[AppClient sharedInstance] isLogin];
    _authenticateButton.hidden = ![[AppClient sharedInstance] isLogin];
    [_avatarImageView setUserInteractionEnabled:YES];
    [_avatarImageView addGestureRecognizer:self.gestureRecognizer];
    
    if ([[AppClient sharedInstance] isLogin]) {
        [[AuthenticationAgent sharedInstance] getUserInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserInfoModel *userInfo, SubscribeModel *subscribe) {
            if (!errorCode) {
                [_telephoneLabel setText:[[AppClient sharedInstance] telephone]];
                if ((!userInfo.faviconUrl || [userInfo.faviconUrl isEqualToString:@""]) && !_isShowAvatarUploadedView) {
                    //延时调用
                    [self performSelector:@selector(showAvatarUploadedView) withObject:nil afterDelay:kAnimationDuration + kStopAnimationDuration + kAdimageStopDuration];
                    _isShowAvatarUploadedView = YES;
                }
                [_avatarImageView setImageWithURL:userInfo.faviconUrl placeholderImage:[UIImage imageNamed:@"loginlogo.png"]];
                
                NSString *authenticate = [[CommonFuncs iconCodeByHexStr:@"e685"] stringByAppendingString:lang(@"UnauthenticatedAndClick")];
                [_authenticateButton setTitle:authenticate forState:UIControlStateNormal];
                if ([[AppClient sharedInstance] isAuthenticated]) {
                    authenticate = lang(@"Authenticated");
                    NSString *anotherAuthenicate = [NSString stringWithFormat:@"%@ %@", [CommonFuncs iconCodeByHexStr:@"e686"], authenticate];
                    if ([userInfo.verifyStatus isEqual:@3] && userInfo.rapidVerifyBase && userInfo.rapidVerifyNumber) {
                        //极速认证
                        anotherAuthenicate = [anotherAuthenicate stringByAppendingFormat:@"(%@/%@)", userInfo.rapidVerifyNumber, userInfo.rapidVerifyBase];
                    }
                    if ([userInfo.verifyStatus isEqual:@1] || [userInfo.verifyStatus isEqual:@2]) {
                        //邮箱或证件认证
                        _authenticateButton.enabled = NO;
                        _telephoneLabel.userInteractionEnabled = NO;
                    } else {
                        _authenticateButton.enabled = YES;
                        _telephoneLabel.userInteractionEnabled = YES;
                    }
                    [_authenticateButton setTitle:anotherAuthenicate forState:UIControlStateNormal];
                }
            }
        }];
    } else {
        UIImage *avatarImage = [UIImage imageNamed:@"unloginlogo.png"];
        [_avatarImageView setImage:avatarImage];
    }
}

- (void)showAvatarUploadedView {
    if (self.isViewLoaded && self.view.window) {
        //判断当前窗口是否可视
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
        }];
        WEAK_SELF weakSelf = self;
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
            [weakSelf willUploadAvatar];
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"AvatarUploadedTitle")
                                                        message:lang(@"AvatarUploadedMessage") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
        [alert show];
    } else {
        _isShowAvatarUploadedView = NO;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [TemplateViewFuncs numberOfRowsByData:_sections[section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_sections && _sections.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_sections[indexPath.section]] > indexPath.row) {
        return [TemplateViewFuncs tableViewCellByData:_sections[indexPath.section] atIndex:indexPath.row andTableView:tableView andViewController:self];
    }
    
    return [Room107TableViewCell new];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_sections && _sections.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_sections[indexPath.section]] > indexPath.row) {
        return [TemplateViewFuncs heightForTableViewCellByData:_sections[indexPath.section] atIndex:indexPath.row];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.001;
    }
    return 11;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //若tableView是Group类型 返回值是0,则会返回默认值  所以保证隐藏footerInsection 给一极小值。
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]};
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [headerView setBackgroundColor:[UIColor room107GrayColorA]];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_sections && _sections.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_sections[indexPath.section]] > indexPath.row) {
        [TemplateViewFuncs goToTargetPageByData:_sections[indexPath.section] atIndex:indexPath.row andViewController:self];
    }
}


#pragma mark - Change User Avatar
- (UITapGestureRecognizer *)gestureRecognizer{
    if (!_gestureRecognizer) {
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnAvatar:)];
        _gestureRecognizer.numberOfTapsRequired = 1;
    }
    return _gestureRecognizer;
}

- (void)tapOnAvatar:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [self willUploadAvatar];
    }
}

- (void)willUploadAvatar {
    if ([[AppClient sharedInstance] isLogin]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:lang(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:lang(@"Camera"), lang(@"Photos"), nil];
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        if ([window.subviews containsObject:self.view]) {
            [actionSheet showInView:self.view];
        } else {
            [actionSheet showInView:window];
        }
    } else {
        [self loginOrRegisterButtonDidClicked:self.avatarImageView];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    switch (buttonIndex) {
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
            } else {
                [PopupView showMessage:lang(@"DeviceDoesNotSupportTakePhotos")];
            }
            break;
            
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:picker animated:YES completion:nil];
            
            break;
            
        default:
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self showLoadingView];
    
    WEAK_SELF weakSelf = self;
    UIImage *avatarImage = info[UIImagePickerControllerEditedImage];
    // 在此处将获得的avatarImage上传
    [[UserAccountAgent sharedInstance] getUploadAvatarTokenWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *faviconKey) {
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        
        if (!errorCode) {
            NSMutableArray *imageDics = [[NSMutableArray alloc] init];
            [imageDics addObject:@{@"image": avatarImage, @"key": faviconKey}];
            [[QiniuFileAgent sharedInstance] uploadWithImageDics:imageDics token:token completion:^(NSError *error, NSString *errorMsg) {
                if (!error) {
                    [[UserAccountAgent sharedInstance] uploadAvatarWithFaviconKey:faviconKey completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *faviconImage) {
                        [weakSelf hideLoadingView];
                        
                        if (errorTitle || errorMsg) {
                            [PopupView showTitle:errorTitle message:errorMsg];
                        }
                        
                        if (!errorCode) {
                            [weakSelf getUserInfo];
                        } else {
                            if ([self isLoginStateError:errorCode]) {
                                return;
                            }
                        }
                    }];
                } else {
                    [weakSelf hideLoadingView];
                    [PopupView showMessage:errorMsg];
                }
            }];
        } else {
            [weakSelf hideLoadingView];
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifying refresh control of scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.storeHouseRefreshControl setHidden:NO];
    if (scrollView == self.sectionsTableView) {
        [self.storeHouseRefreshControl scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.sectionsTableView) {
        [self.storeHouseRefreshControl scrollViewDidEndDragging];
    }
}

#pragma mark - Listening for the user to trigger a refresh

//下拉动画开始执行 调接口口 请求数据 关闭tableView滑动效果
- (void)refreshTriggered:(id)sender {
    _sectionsTableView.scrollEnabled = NO ;
    [self enabledPopGesture:NO];//禁用返回手势
    //    [self performSelector:@selector(loadDataDrag:) withObject:@1 afterDelay:0 inModes:@[NSRunLoopCommonModes]];
    [self getPersonalInfoDrag:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
