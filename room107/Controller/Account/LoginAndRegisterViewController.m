//
//  LoginAndRegisterViewController.m
//  room107
//
//  Created by 107间 on 16/3/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "LoginAndRegisterViewController.h"
#import "DZNSegmentedControl.h"
#import "UIScrollView+DZNSegmentedControl.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "CustomButton.h"
#import "AuthenticationAgent.h"
#import "BindingTelephoneViewController.h"

@interface LoginAndRegisterViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DZNSegmentedControl *segmentedControl;
@property (nonatomic, strong) LoginViewController *loginViewController;  //登录页
@property (nonatomic, strong) RegisterViewController *registerViewController;  //注册页

@end

@implementation LoginAndRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"LoginOrRegister")];
    [self createTopView];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWechatGrantResult:) name:WechatGrantNotification object:nil];//监听微信授权登录回调通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSelf) name:BindingTelephoneDismissNotification object:nil];
}

//创建顶部滑动视图
- (void)createTopView {
    
    CGFloat originY = 0;
    CGRect frame = self.view.frame;
    
    if (_loginAndRegisterViewControllerType == LoginAndRegisterViewControllerPresentType) {
        CGFloat originX = 11;
        CGFloat originY = statusBarHeight;
        CGFloat buttonWidth = 22.0f;
        originY += (navigationBarHeight - buttonWidth) / 2;
        CustomButton *leftButton = [[CustomButton alloc] initWithFrame:(CGRect){originX, originY, buttonWidth, buttonWidth}];
        [leftButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [leftButton.titleLabel setFont:[UIFont room107FontFour]];
        [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [leftButton setTitle:@"\ue60c" forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(leftButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    }
    
    frame.origin.y = originY;
    frame.size.height = 40.0f;
    
    self.segmentedControl = [[DZNSegmentedControl alloc] initWithFrame:frame];
    self.segmentedControl.items = @[lang(@"Login"), lang(@"Register")];
    self.segmentedControl.showsCount = NO;
    self.segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
    [self.segmentedControl setTintColor:[UIColor room107GreenColor]];
    [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateNormal];
    [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateDisabled];
    [self.view addSubview:_segmentedControl];
    
    originY += CGRectGetHeight(_segmentedControl.bounds);
    
    frame = self.view.frame;
    frame.origin.y = originY;
    frame.size.height -= frame.origin.y;
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES; //支持左右滑动时segmentedControl跟着一起走
    self.scrollView.segmentedControl = self.segmentedControl;
    [self.view addSubview:_scrollView];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

    __block CGFloat originX = 0.0;
    WEAK_SELF weakSelf = self;
    [self.segmentedControl.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = weakSelf.scrollView.frame;
        frame.origin.x = originX;
        frame.origin.y = 0.5;
        
        switch (idx) {
            case 0:
                if (!weakSelf.loginViewController) {
                    weakSelf.loginViewController = [[LoginViewController alloc] init];
                    weakSelf.loginViewController.view.frame = frame;
                    weakSelf.loginViewController.navigationController = weakSelf.navigationController;  //登录界面属于单独控制器 没有进入控制器栈内管理 所以原生navigationController为nil 且为只读  需要选取同名属性（navigationController）对其进行覆盖和修改 以便获得push等操作
                    weakSelf.loginViewController.loginSuccessful = ^(void) {
                        [weakSelf dismissSelf];
                    };
                    [weakSelf.scrollView addSubview:weakSelf.loginViewController.view];
                }
                break;
            case 1:
                if (!weakSelf.registerViewController) {
                    weakSelf.registerViewController = [[RegisterViewController alloc] init];
                    weakSelf.registerViewController.view.frame = frame;
                    weakSelf.registerViewController.navigationController = weakSelf.navigationController;
                    weakSelf.registerViewController.agreeProtocalExplanation = ^(void) {
                        [weakSelf viewProtocalExplanation];
                    };
                    weakSelf.registerViewController.registerSuccessful = ^(void) {
                        [weakSelf dismissSelf];
                    };
                    [weakSelf.scrollView addSubview:weakSelf.registerViewController.view];
                }
                break;
            default:
                break;
        }
        originX += CGRectGetWidth(frame);
    }];
    
    self.scrollView.contentSize = CGSizeMake(originX, self.scrollView.frame.size.height);
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
    
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
    [[NSNotificationCenter defaultCenter]removeObserver:self name:WechatGrantNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BindingTelephoneDismissNotification object:nil];

}

- (void)leftButtonDidClick:(id)sender {
    [self  dismissViewControllerAnimated:YES completion:^{
        
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
#warning 若为外层present带进来 则应该取消对navigationC的强引用 保证dealloc正常调用
    self.loginViewController = nil;
    self.registerViewController = nil;
}

- (void)getWechatGrantResult:(NSNotification *)notification {
    if (notification.object) {
        WEAK_SELF weakSelf = self;
        [[AuthenticationAgent sharedInstance] grantLoginWithOauthPlatform:@3 andCode:notification.object comlpetion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSNumber *hasTelephone, NSString *username) {
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
            if (!errorCode) {
                if ([hasTelephone isEqualToNumber:@0]) {
                    //没有绑定过手机号
                    BindingTelephoneViewController *bindingTelephoneViewController = [[BindingTelephoneViewController alloc] initWithToken:token andUsername:username];
                    [weakSelf.navigationController pushViewController:bindingTelephoneViewController animated:YES];
                    
                } else {
                     if (_loginAndRegisterViewControllerType == LoginAndRegisterViewControllerPresentType) {
                         [weakSelf dismissViewControllerAnimated:YES completion:^{
                             
                         }];
#warning 若为外层present带进来 则应该取消对navigationC的强引用 保证dealloc正常调用
                         weakSelf.loginViewController = nil;
                         weakSelf.registerViewController = nil;
                     } else {
                         [weakSelf.navigationController popViewControllerAnimated:YES];
                     }
                }
            }
            
        }];
    }
}

- (void)dismissSelf {
    if (_loginAndRegisterViewControllerType == LoginAndRegisterViewControllerPresentType) {
        [self  dismissViewControllerAnimated:YES completion:^{
            
        }];
        self.loginViewController = nil;
        self.registerViewController = nil;
    }
}
//- (void)popViewController {
//    [self.navigationController popViewControllerAnimated:YES];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
