//
//  MessageSublistViewController.m
//  room107
//
//  Created by 107间 on 16/4/20.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "MessageSublistViewController.h"
#import "SystemAgent.h"
#import "TemplateViewFuncs.h"
#import "Room107TableView.h"
#import "SVPullToRefresh.h"
#import "RightMenuViewItem.h"
#import "RightMenuView.h"
#import "MessageSublistOnlyTextTableViewCell.h"
#import "NSString+JSONCategories.h"
#import "NSDictionary+JSONString.h"

static NSInteger fromIndex = 0;
static NSInteger toIndex = 20;
static NSInteger offset = 20;

@interface MessageSublistViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Room107TableView *messageSublistVTableView;
@property (nonatomic, strong) NSMutableArray *messageItemArray;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSString *barTitle;
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;//CBStore下拉刷新
@property (nonatomic, assign) BOOL isReaded;
@property (nonatomic, strong) RightMenuView *rightMenuItem;

@end

@implementation MessageSublistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatTableView];
    [self.navigationItem setTitle:_barTitle];
    [self setRightBarButtonTitle:lang(@"More")];
    [self showLoadingView];
    [self getMessageSublistIndexFrom:fromIndex to:toIndex];
    
    //监听当前页面列表删除卡片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCard:) name:DeleteCardNotification object:nil];
}

- (void)deleteCard:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        //判断当前窗口是否可视
        NSNumber *cardID = [notification object];
        [TemplateViewFuncs deleteCardByCardID:cardID andTableView:_messageSublistVTableView andData:_messageItemArray];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //防止tab切换时候导致的107间动画滞留问题 手动隐藏 下拉开始再手动放开
    [self.storeHouseRefreshControl setHidden:YES];
}

- (void)setURLParams:(NSDictionary *)URLParams {
    _type = URLParams[@"type"] ? URLParams[@"type"] : @0;
    _barTitle = URLParams[@"title"] ? URLParams[@"title"] : @"";
}

- (void)creatTableView {
    CGRect frame = [CommonFuncs tableViewFrame];
    self.messageSublistVTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    _messageSublistVTableView.delegate = self;
    _messageSublistVTableView.dataSource = self;
    [_messageSublistVTableView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
    [_messageSublistVTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //为tableView添加下拉刷新
    self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.messageSublistVTableView target:self refreshAction:@selector(refreshTriggered:) plist:@"Property" color:[UIColor room107GrayColorD] lineWidth:1.5 dropHeight:95 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
    WEAK_SELF weakSelf = self;
    [_messageSublistVTableView addInfiniteScrollingWithActionHandler:^{
        NSInteger indexFrom = weakSelf.messageItemArray.count;
        NSInteger indexTo = indexFrom + offset;
        [weakSelf getMessageSublistIndexFrom:indexFrom to:indexTo];
    }];
    [self.view addSubview:_messageSublistVTableView];
}

- (void)getMessageSublistIndexFrom:(NSInteger)indexFrom to:(NSInteger)indexTo {
    WEAK_SELF weakSelf = self;
    if (!_type) {
        _type = @0;
    }
    NSDictionary *params = @{@"type":_type, @"indexFrom":@(indexFrom), @"indexTo":@(indexTo)};
    [[SystemAgent sharedInstance] getMessageSublistWithParams:params complete:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards) {
        [weakSelf hideLoadingView];
        [weakSelf.messageSublistVTableView.infiniteScrollingView stopAnimating];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        if (!errorCode) {
            if (!cards || cards.count == 0) {
                //无消息 关闭上拉加载
                weakSelf.messageSublistVTableView.showsInfiniteScrolling = NO;
            } else {
                weakSelf.messageSublistVTableView.showsInfiniteScrolling = YES ;
            }
            
            if (weakSelf.messageItemArray) {
                //列表已经存在 1.下拉刷新 2.上拉加载更多  3.全部已读
                if (indexFrom == 0) {
                    //请求第一页数据，清空数组，重新添加对象
                    [weakSelf.messageItemArray removeAllObjects];
                    [weakSelf.messageItemArray addObjectsFromArray:[TemplateViewFuncs cardsDataConvert:cards]];
                    if (weakSelf.messageItemArray.count > 0) {
                        //滚动列表至顶部
                        [weakSelf.messageSublistVTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                    }
                } else {
                    if (weakSelf.isReaded) {
                        //全部已读
                        [weakSelf.messageItemArray removeAllObjects];
                        [weakSelf.messageItemArray addObjectsFromArray:[TemplateViewFuncs cardsDataConvert:cards]];
                    } else {
                        //上拉加载更多
                        [weakSelf.messageItemArray addObjectsFromArray:[TemplateViewFuncs cardsDataConvert:cards]];
                    }
                    weakSelf.isReaded = NO;
                }
            } else {
                //列表不存在 第一次进入页面
                weakSelf.messageItemArray = [TemplateViewFuncs cardsDataConvert:cards];
            }
            [weakSelf.messageSublistVTableView reloadData];
        } else {
            if (weakSelf.messageItemArray) {
                
            } else {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [weakSelf showNetworkFailedWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf showLoadingView];
                        [weakSelf getMessageSublistIndexFrom:fromIndex to:toIndex];
                    }];
                } else {
                    
                    [weakSelf showUnknownErrorWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf showLoadingView];
                        [weakSelf getMessageSublistIndexFrom:fromIndex to:toIndex];
                    }];
                }
            }
        }
        //返回数据后停止动画 手动保持动画0.5s
        if (!weakSelf.messageSublistVTableView.scrollEnabled) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDragAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.storeHouseRefreshControl finishingLoadingAndComplete:^{
                    weakSelf.messageSublistVTableView.scrollEnabled = YES ;
                    [self enabledPopGesture:YES];
                }];
            });
        }
    }];
}

#pragma mark - rightBarButtonDidClick
- (IBAction)rightBarButtonDidClick:(id)sender {
    if (!_rightMenuItem) {
        [self creatRightItem];
    } else {
        if (_rightMenuItem.hidden) {
            [_rightMenuItem showMenuView];
        } else {
            [_rightMenuItem dismissMenuView];
        }
    }
}

- (void)creatRightItem {
    RightMenuViewItem *allReadedItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"AllReaded") clickComplete:^{
        //全部已读
        WEAK_SELF weakSelf = self;
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
        }];
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
            [[SystemAgent sharedInstance] cleanAllMessageWithType:_type completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                if (!errorCode) {
                    NSInteger indexFrom = 0;
                    NSInteger indexTo = weakSelf.messageItemArray.count;
                    self.isReaded = YES;
                    [self getMessageSublistIndexFrom:indexFrom to:indexTo];
                }
            }];
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:lang(@"AllReadOrNot") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
        [alert show];
    }];
    
    RightMenuViewItem *allDeletedItem = [[RightMenuViewItem alloc] initWithSize:CGSizeMake(100, 44) title:lang(@"AllDeleted") clickComplete:^{
        //全部删除
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
        }];
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
            [self showLoadingView];
            [[SystemAgent sharedInstance] deleteAllMessageWithType:_type completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                [self hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                
                if (!errorCode) {
                    [_messageItemArray removeAllObjects];
                    [_messageSublistVTableView reloadData];
                    //全部删除后关闭上拉 小菊花
                    _messageSublistVTableView.showsInfiniteScrolling = NO;
                }
            }];
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:lang(@"AllDeletedOrNot") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
        [alert show];
    }];
    
    self.rightMenuItem = [[RightMenuView alloc] initWithItems:@[allReadedItem, allDeletedItem] itemHeight:40];
    [self.view addSubview:_rightMenuItem];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  _messageItemArray.count > 0 ? _messageItemArray.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_messageItemArray.count > section) {
        return [TemplateViewFuncs numberOfRowsByData:_messageItemArray[section]];
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_messageItemArray && _messageItemArray.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_messageItemArray[indexPath.section]] > indexPath.row) {
        return [TemplateViewFuncs tableViewCellByData:_messageItemArray[indexPath.section] atIndex:indexPath.row andTableView:tableView andViewController:self];
    } else {
        if (_messageItemArray) {
            MessageSublistOnlyTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageSublistOnlyTextTableViewCell"];
            if (nil == cell) {
                cell = [[MessageSublistOnlyTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageSublistOnlyTextTableViewCell" type:_type];
            }
            return cell;
        }
    }
    
    return [Room107TableViewCell new];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_messageItemArray && _messageItemArray.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_messageItemArray[indexPath.section]] > indexPath.row) {
        return [TemplateViewFuncs heightForTableViewCellByData:_messageItemArray[indexPath.section] atIndex:indexPath.row];
    } else {
        return self.view.frame.size.height;
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
    if (_messageItemArray && _messageItemArray.count > indexPath.section && [TemplateViewFuncs numberOfRowsByData:_messageItemArray[indexPath.section]] > indexPath.row) {
        NSMutableDictionary *newMutableMessageItem = [_messageItemArray[indexPath.section] mutableCopy];
        
        if (TemplateTypeTwelve == [newMutableMessageItem[@"type"] intValue] || TemplateTypeThirteen == [newMutableMessageItem[@"type"] intValue]) {
            //当数据为组合模板11 12的时候 对section下的数据做特殊处理
            NSMutableArray *cardsArray = [newMutableMessageItem[@"cards"] mutableCopy];
            if (indexPath.row < [cardsArray count]) {
                NSMutableDictionary *rowDict = [[cardsArray[indexPath.row] JSONValue] mutableCopy];
                [rowDict setObject:@0 forKey:@"reddie"];
                NSString *JSONString = [rowDict JSONString];
                [cardsArray replaceObjectAtIndex:indexPath.row withObject:JSONString];
                [newMutableMessageItem setObject:cardsArray forKey:@"cards"];
                [_messageItemArray replaceObjectAtIndex:indexPath.section withObject:newMutableMessageItem];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        } else {
            [newMutableMessageItem setObject:@0 forKey:@"reddie"];
            [_messageItemArray replaceObjectAtIndex:indexPath.section withObject:newMutableMessageItem];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        [TemplateViewFuncs goToTargetPageByData:_messageItemArray[indexPath.section] atIndex:indexPath.row andViewController:self];
    }
}

#pragma mark - Notifying refresh control of scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.storeHouseRefreshControl setHidden:NO];
    if (scrollView == self.messageSublistVTableView) {
        [self.storeHouseRefreshControl scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.messageSublistVTableView) {
        [self.storeHouseRefreshControl scrollViewDidEndDragging];
    }
}

#pragma mark - Listening for the user to trigger a refresh
//下拉动画开始执行 调接口口 请求数据 关闭tableView滑动效果
- (void)refreshTriggered:(id)sender {
    _messageSublistVTableView.scrollEnabled = NO ;
    [self enabledPopGesture:NO];//禁用返回手势
    [self getMessageSublistIndexFrom:fromIndex to:toIndex];
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
