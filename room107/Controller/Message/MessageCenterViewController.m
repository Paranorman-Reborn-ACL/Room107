//
//  MessageCenterViewController.m
//  room107
//
//  Created by 107间 on 16/4/13.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "MessageCenterViewController.h"
#import "SystemAgent.h"
#import "TemplateViewFuncs.h"
#import "Room107TableView.h"
#import "NSString+JSONCategories.h"
#import "NSDictionary+JSONString.h"

@interface MessageCenterViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Room107TableView *messageCenterTableView;
@property (nonatomic, strong) NSMutableArray *messageItemArray;
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;//CBStore下拉刷新

@end

@implementation MessageCenterViewController
/*
 NSString *imageUrl = info[@"imageUrl"];
 NSString *text = info[@"text"];
 NSString *subText = info[@"subtext"];
 NSString *tailText = info[@"tailText"];
 NSNumber *reddie = info[@"reddie"];
*/
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatTableView];
    [self.navigationItem setTitle:lang(@"MessageCenter")];
    
    //监听当前页面列表删除卡片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCard:) name:DeleteCardNotification object:nil];
}

- (void)deleteCard:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        //判断当前窗口是否可视
        NSNumber *cardID = [notification object];
        [TemplateViewFuncs deleteCardByCardID:cardID andTableView:_messageCenterTableView andData:_messageItemArray];
    }
}

- (void)creatTableView {
    CGRect frame = [CommonFuncs tableViewFrame];
    frame.size.height -= tabBarHeight;
    self.messageCenterTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _messageCenterTableView.delegate = self;
    _messageCenterTableView.dataSource = self;
    [_messageCenterTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_messageCenterTableView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
    //为tableView添加下拉刷新
    self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.messageCenterTableView target:self refreshAction:@selector(refreshTriggered:) plist:@"Property" color:[UIColor room107GrayColorD] lineWidth:1.5 dropHeight:95 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
    [self.view addSubview:_messageCenterTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getMessageCenterInfoDrag:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //防止tab切换时候导致的107间动画滞留问题 手动隐藏 下拉开始再手动放开
    [self.storeHouseRefreshControl setHidden:YES];
}

- (void)getMessageCenterInfoDrag:(BOOL)drag {
    WEAK_SELF weakSelf = self;
    [[SystemAgent sharedInstance] getMessageCenter:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards) {
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        if (!errorCode) {
            weakSelf.messageItemArray = [TemplateViewFuncs cardsDataConvert:cards];
            [weakSelf.messageCenterTableView reloadData];
        } else {
            if (weakSelf.messageItemArray) {
                
            } else {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [weakSelf showNetworkFailedWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf showLoadingView];
                        [weakSelf getMessageCenterInfoDrag:NO];
                    }];
                } else {
                    
                    [weakSelf showUnknownErrorWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf showLoadingView];
                        [weakSelf getMessageCenterInfoDrag:NO];
                    }];
                }
            }
        }
        
        //返回数据后停止动画 手动保持动画0.5s
        if (drag) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDragAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.storeHouseRefreshControl finishingLoadingAndComplete:^{
                    weakSelf.messageCenterTableView.scrollEnabled = YES ;
                    [self enabledPopGesture:YES];
                }];
            });
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _messageItemArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [TemplateViewFuncs numberOfRowsByData:_messageItemArray[section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_messageItemArray && _messageItemArray.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_messageItemArray[indexPath.section]] > indexPath.row) {
        return [TemplateViewFuncs tableViewCellByData:_messageItemArray[indexPath.section] atIndex:indexPath.row andTableView:tableView andViewController:self];
    }
    return [Room107TableViewCell new];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_messageItemArray && _messageItemArray.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_messageItemArray[indexPath.section]] > indexPath.row) {
        return [TemplateViewFuncs heightForTableViewCellByData:_messageItemArray[indexPath.section] atIndex:indexPath.row];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //若tableView是Group类型 返回值是0,则会返回默认值  所以保证隐藏footerInsection 给一极小值。
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [TemplateViewFuncs goToTargetPageByData:_messageItemArray[indexPath.section] atIndex:indexPath.row andViewController:self];
}

#pragma mark - Notifying refresh control of scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.storeHouseRefreshControl setHidden:NO];
    if (scrollView == self.messageCenterTableView) {
        [self.storeHouseRefreshControl scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.messageCenterTableView) {
        [self.storeHouseRefreshControl scrollViewDidEndDragging];
    }
}

#pragma mark - Listening for the user to trigger a refresh

//下拉动画开始执行 调接口口 请求数据 关闭tableView滑动效果
- (void)refreshTriggered:(id)sender {
    _messageCenterTableView.scrollEnabled = NO ;
    [self enabledPopGesture:NO];//禁用返回手势
    [self getMessageCenterInfoDrag:YES];
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
