//
//  AppDelegate.m
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "AppDelegate.h"
#import "SystemAgent.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APService.h"
#import "AuthenticationAgent.h"
#import <Bugtags/Bugtags.h>
#import "NSString+JSONCategories.h"
#import "LAGuserGuideViewController.h"
#import "LAGlanuchView.h"
#import "CustomImageView.h"
#import "MobClick.h"
#import "UITabBar+Badge.h"
#import "HJTabBarController.h"
#import "UncaughtExceptionHandler.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "SDWebImageManager.h"
#import "NSString+JSONCategories.h"
#import "NSString+Encoded.h"

@interface AppDelegate () <WXApiDelegate, UIAlertViewDelegate, UITabBarControllerDelegate>

@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;
@property (nonatomic, strong) BMKMapManager *mapManager;
@property (nonatomic, strong) NSDictionary *messageInfo;
@property (nonatomic, strong) Room107ViewController *currentViewController; //当前控制器，便于弹出消息详情
@property (nonatomic, strong) NSArray *viewControllerConfigs;
@property (nonatomic, strong) HJTabBarController *tabBarController;

@end

@implementation AppDelegate

//友盟统计
- (void)umengTrack {
    /**
     *  1.appkey
        2.发送策略 BATCH（启动时发送）和SEND_INTERVAL（按间隔发送）
        3.推广渠道 channelId为nil或@""时，默认会被当作@"App Store"渠道。
     */
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:BATCH channelId:@""];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    //设置是否对日志信息进行加密, 默认NO(不加密)
    [MobClick setEncryptEnabled:YES];
    if ([[AppClient sharedInstance] isLogin]) {
        [MobClick profileSignInWithPUID:[[AppClient sharedInstance] telephone] ? [[AppClient sharedInstance] telephone] : [[AppClient sharedInstance] username]];
    }
    
}

//弹出评分
- (void)markForApp {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(90 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self jumpAlertView];
    });
}

- (void)hideKeyBoard {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        for (UIView *view in window.subviews) {
            [self dismissAllKeyBoardInView:view];
        }
    }
}

- (BOOL)dismissAllKeyBoardInView:(UIView *)view {
    if ([view isFirstResponder]) {
        [view resignFirstResponder];
        return YES;
    }
    
    for(UIView *subView in view.subviews) {
        if([self dismissAllKeyBoardInView:subView]) {
            return YES;
        }
    }
    return NO;
}

- (void)jumpAlertView {
    if (!_currentViewController || HeaderTypeGreenBack == _currentViewController.headerType || HeaderTypeWhiteBack == _currentViewController.headerType || [_currentViewController isKindOfClass:[LAGuserGuideViewController class]]) {
        //无navigationController的窗口类
        return;
    }
    //iosAppUrl字段为空
    if ([[[[SystemAgent sharedInstance] getPropertiesFromLocal] iosAppUrl] isEqualToString:@""]) {
        return;
    }

    UIAlertView *showAlert = [[UIAlertView alloc]initWithTitle:lang(@"BeSatisfied")message:lang(@"Goodreviews") delegate:self cancelButtonTitle:lang(@"NextTime") otherButtonTitles:lang(@"GiveGood"),lang(@"Debunk") ,nil];
    showAlert.delegate = self;
    [showAlert show];
    NSString *lastVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:lastVersion forKey:@"lastVersionForMark"];
}


- (void)isMarkToUser {
    //判断是否相对于上次提示框 版本有升级
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (![currentVersion isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastVersionForMark"]]) {
        //当前版本高于老版本，版本有升级，重新走评分流程（即：第一次进入应用）
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasLaunch"];
    }
    //第一次进入应用
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunch"]) {
        [self markForApp];
    } else {
        //第二次进入
        NSDate *currentDate = [NSDate date]; // 获取当前时间
        NSDictionary *dictForB = [[NSUserDefaults standardUserDefaults] objectForKey:@"openAdviceBox"];
        NSDictionary *dictForC = [[NSUserDefaults standardUserDefaults] objectForKey:@"closeAlert"];
        NSDate *lastDateForB = dictForB[@"time"];
        NSDate *lastDateForC = dictForC[@"time"];
        NSNumber *countForC  = dictForC[@"count"];
        switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"number"]) {
            case 0:{//  上一次点的 “下次吧” 判断时间和点击次数
                NSTimeInterval time = [currentDate timeIntervalSinceDate:lastDateForC];
                if (time >= 7*24*3600 && [countForC isEqual:@1]) { //7天之后 且仅点过一次
                    [self markForApp];
                } else {//直接返回
                    return;
                }
            }
                break;
            case 1://  上一次点的 “给好评”  直接返回 不弹出
                return;
                break;
            case 2:{//  上一次点的 “去吐槽” 判断间隔时间
                NSTimeInterval time = [currentDate timeIntervalSinceDate:lastDateForB];
                if (time >= 14*24*3600 ) { // 14天之后
                    [self markForApp];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunch"]; //已经出现过
    NSDate *currentDate = [NSDate date];//获取当前时间
    
    switch (buttonIndex) {
        case 0:
        {
            //下次吧C
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"number"];
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"closeAlert"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@{@"time":currentDate,@"count":@1} forKey:@"closeAlert"]; //第一次点击取消
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@{@"time":currentDate,@"count":@2} forKey:@"closeAlert"]; //第二次点击取消
            }
        }
            break;
        case 1:
        {
            //给好评A
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"number"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[[SystemAgent sharedInstance] getPropertiesFromLocal] iosAppUrl]]];
        }
            break;
        case 2:
        {
            //去吐槽B
            [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"number"];
            [[NSUserDefaults standardUserDefaults] setObject:@{@"time":currentDate} forKey:@"openAdviceBox"];
            //手动延迟0.25s 避免alertView对键盘的input操作
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NXURLHandler sharedInstance] handleOpenURL:feedbackURI params:nil context:_currentViewController];
            });
        }
            break;
        default:
            break;
    }
}

//启动页加载动画
- (void)launchImage {
    LAGlanuchView *lanuchView = [[LAGlanuchView alloc]initWithFrame:self.window.frame];
    [lanuchView setBackgroundColor:[UIColor room107GreenColor]];
    [self.window addSubview:lanuchView];
    [lanuchView changeFrameAndAlpha];
}

- (UITabBarController *)mainViewController {
    if (!_tabBarController) {
        _tabBarController = [[HJTabBarController alloc] init];
        WEAK_SELF weakSelf = self;
        [_tabBarController setCenterButtonDidClickHandler:^{
            if (weakSelf.currentViewController) {
                NSString *url = [[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/addHouse"];
                NSString *openURL = [htmlURI stringByAppendingFormat:@"?authority=login&title=%@&url=%@", [lang(@"AddHouseStep") URLEncodedString], url];
                //传递正确的控制器对象
                [[NXURLHandler sharedInstance] handleOpenURL:openURL params:nil context:weakSelf.currentViewController];
            }
        }];
        _tabBarController.delegate = self;
        _tabBarController.tabBar.barTintColor = [UIColor whiteColor]; //背景色
        _tabBarController.tabBar.tintColor = [UIColor room107GreenColor]; //选中色
        
        _viewControllerConfigs = @[@{@"identifier":@"HomeViewController", @"title":lang(@"Home"), @"image":@"homeUnselected.png", @"selectedImage":@"homeSelected.png"}, @{@"identifier":@"HouseSearchViewController", @"title":lang(@"MySearch"), @"image":@"searchUnselected.png", @"selectedImage":@"searchSelected.png"}, @{@"identifier":@"MessageCenterViewController", @"title":lang(@"Message"), @"image":@"messageUnselected.png", @"selectedImage":@"messageSelected.png"}, @{@"identifier":@"IndividualViewController", @"title":[lang(@"UserAccount") substringToIndex:2], @"image":@"individualUnselected.png", @"selectedImage":@"individualSelected.png"}];
        NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        NSMutableArray *imageNames = [[NSMutableArray alloc] init];
        NSMutableArray *selectedImageNames = [[NSMutableArray alloc] init];
        for (NSDictionary *config in _viewControllerConfigs) {
            UIViewController *viewController = [[NSClassFromString(config[@"identifier"]) alloc] init];
            [titles addObject:config[@"title"]];
            [imageNames addObject:config[@"image"]];
            [selectedImageNames addObject:config[@"selectedImage"]];
            
            //每个ChildViewController增加一个UINavigationController
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
            navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor room107GrayColorE], NSFontAttributeName:[UIFont room107FontFour]};//控制标题的样式
            [navigationController.navigationBar setTintColor:[UIColor room107GreenColor]];//控制返回按钮的样式
            [navigationController.navigationBar setTranslucent:NO];
            UIView *blackLineView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, [UIScreen mainScreen].bounds.size.width, 1)];
            [blackLineView setBackgroundColor:[UIColor room107GrayColorB]];
            
            [navigationController.navigationBar addSubview:blackLineView];
            //取消navigationBar底部阴影线
            [navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
            [navigationController.navigationBar setShadowImage:[UIImage new]];
            
            [viewControllers addObject:navigationController];
        }
        [_tabBarController addChildViewControllers:viewControllers titles:titles titleColor:[UIColor room107GrayColorD] selectedTitleColor:[UIColor room107GreenColor] imageNames:imageNames selectedImageNames:selectedImageNames haveNavigationBar:NO];
        //设置tabBarCController的中间按钮
        [_tabBarController tabBarPlusButtonImageName:@"postSuite.png" selectedImageName:@"postSuite.png"];
        [_tabBarController tabBarPlusLabelText:lang(@"AddSuite") andTextColor:[UIColor room107GrayColorD]];
    }
    
    return _tabBarController;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex > 0) {
        [[SystemAgent sharedInstance] getHomeReddieV3];
        UIViewController *visibleViewController = [(UINavigationController *)viewController visibleViewController];
        if (visibleViewController) {
            [(Room107ViewController *)visibleViewController refreshData];
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    LogDebug(@"HomeDirectory:%@", NSHomeDirectory());
    
    SDWebImageManager *webImageManager = [SDWebImageManager sharedManager];
    webImageManager.imageCache.maxCacheSize = imageMaxCacheSize;
    
    //注册Bugtags(静默模式，收集Crash信息)
    [Bugtags startWithAppKey:BugtagsAppKey invocationEvent:BTGInvocationEventNone];
    
    //注册微信
    BOOL success = [WXApi registerApp:WechatAppID withDescription:@"107room"];
    if (!success) {
        LogDebug(@"注册微信失败");
    }
    
    // 要使用百度地图，请先启动BaiduMapManager
    self.mapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:BaiduMapKey generalDelegate:nil];
    if (!ret) {
        LogDebug(@"manager start failed!");
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([[AppClient sharedInstance] isLogin]) {
        self.window.rootViewController = [self mainViewController];
    } else {
        LAGuserGuideViewController *userGuideViewController = [[LAGuserGuideViewController alloc] init];
        [userGuideViewController setLookButtonDidClickedHandler:^{
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            self.window.rootViewController = [self mainViewController];
        }];
        userGuideViewController.loginHandler = ^(void) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            self.window.rootViewController = [self mainViewController];
        };
        self.window.rootViewController = userGuideViewController;
    }
    
    [self.window makeKeyAndVisible];
    [self launchImage];
//    [self isMarkToUser];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetJPush) name:ClientDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetJPush) name:ClientDidLogoutNotification object:nil];
    
    //可见的ViewController变更
    _currentViewController = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentViewControllerDidChange:) name:CurrentViewControllerDidChangeNotification object:nil];
    
    //监听底部小红点更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeReddieDidChange:) name:HomeReddieDidChangeNotification object:nil];
    
    //监听Tab的切换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarControllerSelectedIndexDidChange:) name:TabBarControllerSelectedIndexDidChangeNotification object:nil];
    
    // 极光推送，Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
//        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
//                                                       UIUserNotificationTypeSound |
//                                                       UIUserNotificationTypeAlert)
//                                           categories:nil];
    } else {
        //categories 必须为nil
//        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
//                                                       UIRemoteNotificationTypeSound |
//                                                       UIRemoteNotificationTypeAlert)
//                                           categories:nil];
    }
    // Required
//    [APService setupWithOption:launchOptions];
//    [self resetJPush];
    
    // 注册友盟统计
    [self umengTrack];
    
    if (launchOptions) {
        //应用未启动时，通过推送启动App进入消息详情页
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo) {
            _messageInfo = userInfo;
            if (application.applicationIconBadgeNumber > 0) {
                application.applicationIconBadgeNumber -= 1;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showMessageDetailViewController];
            });
        }
    }
    
    return YES;
}

- (void)currentViewControllerDidChange:(NSNotification *)notification {
    _currentViewController = (Room107ViewController *)[notification object];
}

- (void)homeReddieDidChange:(NSNotification *)notification {
    UITabBarController *tabBarController = [self mainViewController];
    NSDictionary *homeReddie = [notification object];
    NSArray *tabKeys = @[@"home", @"houseList", @"", @"message", @"personal"];//有CenterButton，所以对应于一个@""
    
    if (tabKeys.count > 0) {
        for (NSUInteger i = 0; i < tabKeys.count; i++) {
            if ([homeReddie[tabKeys[i]] boolValue]) {
                //显示
                [tabBarController.tabBar showBadgeOnItemIndex:i withTabbarItemNums:[tabBarController viewControllers].count + 1]; //有CenterButton，所以数目+1
            } else {
                //隐藏
                [tabBarController.tabBar hideBadgeOnItemIndex:i];
            }
        }
    }
}

- (void)tabBarControllerSelectedIndexDidChange:(NSNotification *)notification {
    UITabBarController *tabBarController = [self mainViewController];
    NSNumber *selectedIndex = [notification object];
    if ([tabBarController childViewControllers].count > [selectedIndex unsignedIntegerValue]) {
        [tabBarController setSelectedIndex:[selectedIndex unsignedIntegerValue]];
    }
}

- (void)resetJPush {
    if ([[AppClient sharedInstance] isLogin]) {
        [[AuthenticationAgent sharedInstance] getUserInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserInfoModel *userInfo, SubscribeModel *subscribe) {
            if (!errorCode) {
                //设置别名与标签
                NSSet *tags = [[NSSet alloc] initWithObjects:platformKey, nil];
                [APService setTags:tags alias:userInfo.username callbackSelector:@selector(tagsAliasCallback:tags:alias:) target:self];
            }
        }];
    } else {
        //设置别名与标签
        NSSet *tags = [[NSSet alloc] initWithObjects:platformKey, nil];
        UIDevice *device = [UIDevice currentDevice];
        [APService setTags:tags alias:[platformKey stringByAppendingFormat:@"_%@", [Room107UserDefaults UUIDString] ? [Room107UserDefaults UUIDString] : device.identifierForVendor.UUIDString] callbackSelector:@selector(tagsAliasCallback:tags:alias:) target:self];
    }
    
    // 本地通知内容获取：
    //    NSDictionary *localNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
    //
    //    //如果 App 状态为未运行，此函数将被调用，如果launchOptions包含UIApplicationLaunchOptionsRemoteNotificationKey表示用户点击apn 通知导致app被启动运行；如果不含有对应键值则表示 App 不是因点击apn而被启动，可能为直接点击icon被启动或其他
    //    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
}

- (void)tagsAliasCallback:(int)iResCode
                    tags:(NSSet*)tags
                   alias:(NSString*)alias {
    LogDebug(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}

- (void)InitializeTencentOAuth {
    if (!_tencentOAuth) {
        //注册QQ的SDK，分享不用用户授权（使用手机QQ当前的登录态）
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:TencentOAuthAppID andDelegate:self];
        _tencentOAuth.redirectURI = @"";
//        NSArray *permissions = [NSArray arrayWithObjects:@"add_share", @"get_user_info", @"get_simple_userinfo", @"add_t", nil];
//        BOOL result = [_tencentOAuth authorize:permissions inSafari:NO];
//        if (!result) {
//            LogDebug(@"注册QQ失败");
//        }
    }
}

// 获取当前处于activity状态的view controller
- (UIViewController *)activityViewController {
    UIViewController *activityViewController = nil;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if(window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows) {
            if(tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    NSArray *viewsArray = [window subviews];
    if([viewsArray count] > 0) {
        UIView *frontView = [viewsArray objectAtIndex:0];
        
        id nextResponder = [frontView nextResponder];
        
        if([nextResponder isKindOfClass:[UIViewController class]]) {
            activityViewController = nextResponder;
        } else {
            activityViewController = window.rootViewController;
        }
    }
    
    return activityViewController;
}

- (void)showMessageDetailViewController {
    if (_currentViewController && _messageInfo && _messageInfo[@"messageId"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_messageInfo[@"targetUrl"] && [_messageInfo[@"targetUrl"] isKindOfClass:[NSString class]]) {
                NSArray *targetURLs = [_messageInfo[@"targetUrl"] JSONValue];
                if (targetURLs && [targetURLs isKindOfClass:[NSArray class]]) {
                    for (NSString *targetURL in targetURLs) {
                        [[NXURLHandler sharedInstance] handleOpenURL:targetURL params:nil context:_currentViewController];
                    }
                }
            }
        });
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
//    LogDebug(@"deviceToken:%@", [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]);
//    [APService registerDeviceToken:deviceToken];
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
//        //your application must register for user notifications using -[UIApplication registerUserNotificationSettings:] before being able to set the icon badge
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    }
}

//iOS8中新增了通知授权后的回调
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    application.applicationIconBadgeNumber = 0; //应用启动时将通知数置0
}

// Remote Notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    application.applicationIconBadgeNumber += 1;
    
    if (!_currentViewController || HeaderTypeGreenBack == _currentViewController.headerType || HeaderTypeWhiteBack == _currentViewController.headerType) {
        //无navigationController的窗口类
        return;
    }
    
    _messageInfo = userInfo;
//    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    if (application.applicationState == UIApplicationStateActive) {
        //程序当前正处于前台
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
        }];
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:[lang(@"ViewSample") substringToIndex:2] action:^{
            [self showMessageDetailViewController];
            
            if (application.applicationIconBadgeNumber > 0) {
                application.applicationIconBadgeNumber -= 1;
            }
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_messageInfo[@"title"] message:_messageInfo[@"content"] cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
        [alert show];
    } else if(application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        //程序处于后台
        [self showMessageDetailViewController];
        
        if (application.applicationIconBadgeNumber > 0) {
            application.applicationIconBadgeNumber -= 1;
        }
    }
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    LogDebug(@"handleActionWithIdentifier");
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler  {
    LogDebug(@"handleActionWithIdentifier");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [self beingBackgroundUpdateTask];
//    // 在这里加上需要长久运行的代码
//    [self endBackgroundUpdateTask];
}

- (void)beingBackgroundUpdateTask {
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask {
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
//    [_mapManager stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[SystemAgent sharedInstance] getPropertiesFromServer:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, AppPropertiesModel *model) {
        if (!errorCode) {
//            [self onCheckVersion:model];
        }
    }];
    [[SystemAgent sharedInstance] getTextPropertiesFromServer];
    [[SystemAgent sharedInstance] getPopupPropertiesFromServer];
}
/**
 *  版本检测
 */
- (void)onCheckVersion:(AppPropertiesModel *)model {
//    LogDebug(@"最新版本号%@------推荐版本号%@------支持版本号%@",model.newestIosAppVersion,model.recommendedIosAppVersion,model.supportedIosAppVersion);
//    LogDebug(@"当前版本号:%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //当前版本号低于支持版本号，强制升级
    if (-1 == [currentVersion compare:model.supportedIosAppVersion] ) {
            RIButtonItem *updateButtonItem = [RIButtonItem itemWithLabel:[lang(@"Update") substringToIndex:2] action:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.iosAppUrl]];
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:model.supportedIosAppUpdateTitle message:model.supportedIosAppUpdateContent cancelButtonItem:nil otherButtonItems:updateButtonItem, nil];
        [alert show];
    } else {
        
        CGFloat iosRecommendedInterval = [model.iosRecommendedInterval floatValue];
        NSDate *currentDate = [NSDate date];
        NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"];
        NSTimeInterval time = [currentDate timeIntervalSinceDate:lastDate] *1000;
        BOOL isRecommended = time > iosRecommendedInterval ? YES: NO;

        //当前版本低于推荐版本号且未出现过提示框   或者   本体存储的推荐版本号与服务器返回的推荐版本号不相等且用户不是第一次登录   或者   低于推荐版本且再次出现的时间间隔大于系统推荐时间
        if   ( (-1 == [currentVersion compare:model.recommendedIosAppVersion] && isRecommended) ||
               (-1 == [currentVersion compare:model.recommendedIosAppVersion] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isCheakVersion"]) ||
               (![model.recommendedIosAppVersion isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"oldVersion"]] && [[NSUserDefaults standardUserDefaults] boolForKey:@"isCheakVersion"])
              
            ){
            
            RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCheakVersion"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"currentDate"];
            }];
            
            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:[lang(@"Update") substringToIndex:2] action:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.iosAppUrl]];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCheakVersion"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"currentDate"];
            }];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:model.recommendedIosAppUpdateTitle message:model.recommendedIosAppUpdateContent cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
            [alert show];
        }
        
      [[NSUserDefaults standardUserDefaults] setObject:model.recommendedIosAppVersion forKey:@"oldVersion"];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[url scheme] isEqualToString:@"room107"]) {
        if (_currentViewController) {
            return [[NXURLHandler sharedInstance] handleOpenURL:[url absoluteString] params:nil context:_currentViewController];
        } else {
            return NO;
        }
    } else if ([[url scheme] isEqualToString:[@"tencent" stringByAppendingString:TencentOAuthAppID]]) {
        return [TencentOAuth HandleOpenURL:url];
    } else {
        return [WXApi handleOpenURL:url delegate:self];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开 发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中,商户 app 在后台很可能被系统 kill 了,所以 pay 接口的 callback 就会失效,请商户对 standbyCallback 返回的回调结果进行处理,就是在这个方￼法里面处理跟 callback 一样的逻辑】
            LogDebug(@"result = %@", resultDic);
        }];
        
        return YES;
    }
    
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中,商户 app 在后台很可能被系统 kill 了, 所以 pay 接口的 callback 就会失效,请商户对 standbyCallback 返回的回调结果进行处理,就 是在这个方法里面处理跟 callback 一样的逻辑】
            LogDebug(@"result = %@", resultDic);
        }];
        
        return YES;
    }
    
    if ([[url scheme] isEqualToString:[@"tencent" stringByAppendingString:TencentOAuthAppID]]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)onResp:(BaseResp*)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        
        NSString *strTitle = [NSString stringWithFormat:lang(@"PaymentResult")];
        NSString *strMsg = response.errCode == WXSuccess ? lang(@"PaySuccess") : lang(@"PayFailed");

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                        message:strMsg
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:lang(@"OK"), nil];
        [alert show];
        
        switch (response.errCode) {
            case WXSuccess: {
                NSNotification *notification = [NSNotification notificationWithName:WechatPayNotification object:@"success"];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                break;
            }
            
            default: {
                NSNotification *notification = [NSNotification notificationWithName:WechatPayNotification object:@"fail"];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                break;
            }
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        //微信登录回调 SendAuthResp:微信处理完第三方程序的认证和权限申请后向第三方程序回送的处理结果
        SendAuthResp *response = (SendAuthResp *)resp;
        switch (response.errCode) {
            case 0:{
            //ERR_OK = 0(用户同意)
            NSNotification *notification = [NSNotification notificationWithName:WechatGrantNotification object:response.code];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
                break;
            case 1:
            //ERR_AUTH_DENIED = -4（用户拒绝授权）
                break;
            case 2:
            //ERR_USER_CANCEL = -2（用户取消）
                break;
            default:
                break;
        }
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    SDWebImageManager *webImageManager = [SDWebImageManager sharedManager];
    //1.取消下载操作
    [webImageManager cancelAll];
    //2.清除内存缓存
    [webImageManager.imageCache clearMemory];
}

#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin {
    LogDebug(@"登录完成");
    
//    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]) {
//        //  记录登录用户的OpenID、Token以及过期时间
//        LogDebug(@"_tencentOAuth.accessToken");
//        [PopupView showMessage:_tencentOAuth.accessToken];
//        [PopupView showMessage:_tencentOAuth.openId];
////        [PopupView showMessage:_tencentOAuth.expirationDate];
//    } else {
//        LogDebug(@"登录不成功 没有获取accesstoken");
//    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        LogDebug(@"用户取消登录");
    } else {
        LogDebug(@"登录失败");
    }
}

- (void)tencentDidNotNetWork {
    [PopupView showMessage:@"无网络连接，请设置网络"];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "room107.room107" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"room107" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"room107.sqlite"];
    
    //数据库迁移，更新数据库
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             [NSNumber numberWithBool:YES],
                             
                             NSMigratePersistentStoresAutomaticallyOption,
                             
                             [NSNumber numberWithBool:YES],
                             
                             NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        LogDebug(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            LogDebug(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (void)clearPersistentStore {
    for (NSPersistentStore *store in self.persistentStoreCoordinator.persistentStores)
    {
        NSError *error;
        NSURL *storeURL = store.URL;
        NSPersistentStoreCoordinator *storeCoordinator = self.persistentStoreCoordinator;
        [storeCoordinator removePersistentStore:store error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    }
    
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
    _managedObjectModel = nil;
}

// 判断设备是否有摄像头
- (BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 检查摄像头是否支持拍照
- (BOOL)doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

// 判断是否支持某种多媒体类型：拍照，视频
- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType {
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }

    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        NSString * mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}

@end
