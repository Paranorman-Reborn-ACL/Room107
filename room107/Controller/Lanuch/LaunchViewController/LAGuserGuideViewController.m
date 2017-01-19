//
//  LAGuserGuideViewController.m
//  LanuchImageTest
//
//  Created by 刘安国 on 15/10/27.
//  Copyright (c) 2015年 刘安国. All rights reserved.
//


//获取屏幕 宽度、高度
#define SCREEN_FRAME ([UIScreen mainScreen].bounds)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#import "LAGuserGuideViewController.h"
#import "LAGfirstGuide.h"
#import "LAGsecondGuide.h"
#import "LAGthirdGuide.h"
#import "LAGforthGuide.h"
#import "LoginAndRegisterViewController.h"

@interface LAGuserGuideViewController ()<UIScrollViewDelegate>

@property (nonatomic,assign) BOOL animationisOver;

@property (nonatomic, strong) UIScrollView *backGroundView; //底层滑动view
@property (nonatomic, strong) UIPageControl *page;

@property (nonatomic, strong) LAGfirstGuide *firstGuide;     //引导页第一页
@property (nonatomic, strong) LAGsecondGuide *secondGuide;   //引导页第二页
@property (nonatomic, strong) LAGthirdGuide *thirdGuide;     //引导页第三页
@property (nonatomic, strong) LAGforthGuide *forthGuide;     //引导页第四页

@property (nonatomic, strong) UIButton *leftButton;           //登录 | 注册按钮
@property (nonatomic, strong) UIButton *rightButton;          //随便看看按钮

@property (nonatomic, copy) void (^lookButtonDidClickedHandlerBlock)();


@end

@implementation LAGuserGuideViewController

- (UIPageControl *)page {
    if (nil == _page) {
        _page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 50*SCREEN_HEIGHT/480-12,SCREEN_WIDTH, 10)];
        _page.currentPageIndicatorTintColor = [UIColor room107GrayColorD];
        _page.pageIndicatorTintColor = [UIColor room107GrayColorB];
//        _page.backgroundColor = [UIColor redColor];
        _page.numberOfPages = 4 ;
    }
    return _page;
}

- (UIButton *)leftButton {
    if (nil == _leftButton) {
        _leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
//        [_leftButton setBackgroundColor:[UIColor redColor]];
        [_leftButton setBackgroundColor:[UIColor room107PinkColor]];
        _leftButton.frame = CGRectMake(0, SCREEN_HEIGHT-50 ,SCREEN_WIDTH/2, 50);
        [_leftButton setTitle:lang(@"LoginOrRegister") forState:UIControlStateNormal];
        [_leftButton.titleLabel setFont:[UIFont room107SystemFontThree]];
        [_leftButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if(nil == _rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-50 ,SCREEN_WIDTH/2, 50);
        [_rightButton setBackgroundColor:[UIColor room107PinkColor]];
        [_rightButton setTitle:lang(@"LookAround") forState:UIControlStateNormal];
        //        [_rightButton.titleLabel setText:@"随便看看"];
        [_rightButton.titleLabel setFont:[UIFont room107SystemFontThree]];
        [_rightButton addTarget:self action:@selector(look) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UIScrollView *)backGroundView {
    if (nil == _backGroundView) {
        _backGroundView = [[UIScrollView alloc] initWithFrame:SCREEN_FRAME];
        _backGroundView.contentSize = CGSizeMake(SCREEN_WIDTH * 4 , 0);
        _backGroundView.pagingEnabled = YES ;
        _backGroundView.bounces = NO ;
        _backGroundView.showsHorizontalScrollIndicator = NO ;
        _backGroundView.delegate = self ;
        
        [_backGroundView addSubview:self.firstGuide];
        [_backGroundView addSubview:self.secondGuide];
        [_backGroundView addSubview:self.thirdGuide];
        [_backGroundView addSubview:self.forthGuide];
    }
    return _backGroundView;
}
- (LAGfirstGuide *)firstGuide {
    if (nil == _firstGuide) {
        _firstGuide = [[LAGfirstGuide alloc] initWithFrame:SCREEN_FRAME];
    }
    return _firstGuide;
}

- (LAGsecondGuide *)secondGuide {
    if (nil == _secondGuide) {
        _secondGuide = [[LAGsecondGuide alloc] initWithFrame:CGRectMake(SCREEN_WIDTH,0 , SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _secondGuide;
}

- (LAGthirdGuide *)thirdGuide {
    if (nil == _thirdGuide) {
        _thirdGuide = [[LAGthirdGuide alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _thirdGuide;
}

- (LAGforthGuide *)forthGuide {
    if (nil == _forthGuide) {
        _forthGuide = [[LAGforthGuide alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _forthGuide;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.backGroundView];
    [self.view addSubview:self.page];
    [self.view addSubview:self.leftButton];
    [self.view addSubview:self.rightButton];
    
    UIImageView * logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 33* 271/88, 33)];
    
    [self.view addSubview:logoImage];
    logoImage.image = [UIImage imageNamed:@"左上logo"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_firstGuide animationOfView];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideView) name:ClientDidLoginNotification object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
//    if (!_navigationController) {
//        _navigationController = [[UINavigationController alloc] init];
//        [_navigationController.navigationBar setBarTintColor:[UIColor room107GreenColor]];
//        _navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont room107FontFour]};//控制标题的样式
//        [_navigationController.navigationBar setTintColor:[UIColor whiteColor]];//控制返回按钮的样式
//        [_navigationController.navigationBar setTranslucent:NO];
//    }
}

#pragma mark -- ScrollView delegate方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offX = scrollView.contentOffset.x;
    _page.currentPage = offX/SCREEN_WIDTH;

    if ( !self.animationisOver) {
    switch (_page.currentPage) {
        case 1 :
            [_secondGuide animationOfView];
            break;
        case 2:
            [_thirdGuide  animationOfView];
            break;
        case 3:
            [_forthGuide animationOfView];
            self.animationisOver = YES ;
        default:
            break;
          }
    }
    switch (_page.currentPage) {
        case 0:{
            CGFloat proportion = scrollView.contentOffset.x/SCREEN_WIDTH ;
            UIColor *stepcolor = [UIColor colorWithRed:255/255. green:(128 + 60*proportion)/255. blue:(128-128*proportion)/255. alpha:1];
            [_firstGuide setStepColor:stepcolor];
            [_secondGuide setStepColor:stepcolor];
            [self setColorButton:stepcolor];
            break;
        }
        case 1 :{
            CGFloat proportion = scrollView.contentOffset.x/SCREEN_WIDTH - 1;
            UIColor *stepcolor = [UIColor colorWithRed:(255 - 200*proportion)/255. green:(188 - 33*proportion)/255. blue:(0+255*proportion)/255. alpha:1];
            [_secondGuide setStepColor:stepcolor];
            [_thirdGuide setStepColor:stepcolor];
            [self setColorButton:stepcolor];
            break;
        }
        case 2:{
            CGFloat proportion = scrollView.contentOffset.x/SCREEN_WIDTH - 2;
            UIColor *stepcolor = [UIColor colorWithRed:(25- 25*proportion)/255. green:(155 + 17*proportion)/255. blue:(255-104*proportion)/255. alpha:1];
            [self setColorButton:stepcolor];
            [_thirdGuide setStepColor:stepcolor];
            [_forthGuide setStepColor:stepcolor];
            break;
        }
        default:
        break;}

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)hideView {
    if ([[AppClient sharedInstance] isLogin]) {
        self.loginHandler();
    }
}

#pragma mark - 登录 | 注册 随便看看

- (void)login {
    LoginAndRegisterViewController *loginAndRegisterViewController = [[LoginAndRegisterViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginAndRegisterViewController];
    [navigationController.navigationBar setBarTintColor:[UIColor room107GreenColor]];
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont room107FontFour]};//控制标题的样式
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];//控制返回按钮的样式
    [navigationController.navigationBar setTranslucent:NO];
    //取消navigationBar底部阴影线
    [navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    [navigationController.navigationBar setShadowImage:[UIImage new]];
    [loginAndRegisterViewController setLoginAndRegisterViewControllerType:LoginAndRegisterViewControllerPresentType];
    [self presentViewController:navigationController animated:YES completion:^{
        
    }];
}

- (void)look {
    if (_lookButtonDidClickedHandlerBlock) {
        _lookButtonDidClickedHandlerBlock();
    }
}

- (void)setColorButton:(UIColor *)color{
    [_leftButton setBackgroundColor:color];
    [_rightButton setBackgroundColor:color];
}

- (void)setLookButtonDidClickedHandler:(void(^)())handler {
    _lookButtonDidClickedHandlerBlock = handler;
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
