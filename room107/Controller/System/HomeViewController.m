//
//  HomeViewController.m
//  room107
//
//  Created by ningxia on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HomeViewController.h"
#import "SystemAgent.h"
#import "Room107TableView.h"
#import "AuthenticationAgent.h"
#import "NSString+AttributedString.h"
#import "UserAccountAgent.h"
#import "SDCycleScrollView.h"
#import "NSString+Encoded.h"
#import "TemplateViewFuncs.h"
#import "NSString+JSONCategories.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) Room107TableView *sectionsTableView;
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;//CBStore下拉刷新
@property (nonatomic, strong) NSArray *loginItemsArray;
@property (nonatomic, strong) NSArray *logoutItemsArray;
@property (nonatomic, strong) UIView *statusBarView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Build your regular UIBarButtonItem with Custom View
    [self getHomeInfoDrag:NO];
    self.fd_prefersNavigationBarHidden = YES;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage makeImageFromText:@"\ue650" font:[UIFont fontWithName:fontIconName size:60.0f] color:[UIColor room107GreenColor]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeInfoDrag:) name:ClientDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeInfoDrag:) name:ClientDidLogoutNotification object:nil];
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

- (void)getHomeInfoDrag:(BOOL)drag {
    WEAK_SELF weakSelf = self;
    [[SystemAgent sharedInstance] getHomeV3Info:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards) {
        [weakSelf hideLoadingView];
        if (drag) {
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
        }
        
        if (!errorCode) {
            [weakSelf createTableView];
            weakSelf.sections = [TemplateViewFuncs cardsDataConvert:cards];
            [weakSelf.sectionsTableView reloadData];
        } else {
            if ([weakSelf isLoginStateError:errorCode]) {
                return;
            }
        
            if (weakSelf.sectionsTableView) {
                //不是第一次进入 从子页面返回  无蛙 无提示 无阻隔
            } else {
                //第一次进入 显示🐸  无提示
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [weakSelf showNetworkFailedWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf showLoadingView];
                        [weakSelf getHomeInfoDrag:NO];
                    }];
                } else {
                    [weakSelf showUnknownErrorWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf showLoadingView];
                        [weakSelf getHomeInfoDrag:NO];
                    }];
                }
            }
        }
        
        //返回数据后停止动画 手动保持动画0.5s
        if (drag) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDragAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.storeHouseRefreshControl finishingLoadingAndComplete:^{
                    weakSelf.sectionsTableView.scrollEnabled = YES ;
                    [weakSelf enabledPopGesture:YES];
                }];
            });
        }
    }];
}

- (void)createTableView {
    if (!_sectionsTableView) {
        CGRect frame = [CommonFuncs tableViewFrame];
        frame.size.height -= tabBarHeight;
        _sectionsTableView = [[Room107TableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
        _sectionsTableView.delegate = self;
        self.automaticallyAdjustsScrollViewInsets = NO;
        _sectionsTableView.dataSource = self;
        _sectionsTableView.tableFooterView = [[UIView alloc] initWithFrame:(CGRect){0, 0, CGRectGetWidth(_sectionsTableView.bounds), navigationBarHeight}];
        [self.view addSubview:_sectionsTableView];
        //为tableView添加下拉刷新
        self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.sectionsTableView target:self refreshAction:@selector(refreshTriggered:) plist:@"Property" color:[UIColor room107GrayColorD] lineWidth:1.5 dropHeight:95 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_sections.count > section) {
        return [TemplateViewFuncs numberOfRowsByData:_sections[section]];
    }
    
    return 1;
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
    switch (section) {
        case 0:
            return 0.001;
            break;
        default:
            return 11;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //若tableView是Group类型 返回值是0,则会返回默认值  所以保证隐藏footerInSection 给一极小值。
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]};
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [headerView setBackgroundColor:[UIColor room107GrayColorA]];

    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_sections && _sections.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_sections[indexPath.section]] > indexPath.row) {
        [TemplateViewFuncs goToTargetPageByData:_sections[indexPath.section] atIndex:indexPath.row andViewController:self];
    }
}

#pragma mark - Notifying refresh control of scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.storeHouseRefreshControl setHidden:NO];
    if (scrollView == self.sectionsTableView) {
        [self.storeHouseRefreshControl scrollViewDidScroll];
    }
    if (!_statusBarView) {
        _statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        [_statusBarView setBackgroundColor:[UIColor whiteColor]];
        [_statusBarView setHidden:YES];
        [self.view addSubview:_statusBarView];
    }
    NSIndexPath *path=[NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [_sectionsTableView cellForRowAtIndexPath:path];
    if (scrollView.contentOffset.y > cell.frame.size.height) {
        [_statusBarView setHidden:NO];
    } else {
        [_statusBarView setHidden:YES];
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
    [self getHomeInfoDrag:YES];
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
