//
//  HouseSearchViewController.m
//  room107
//
//  Created by ningxia on 15/12/21.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "HouseSearchViewController.h"
#import "Room107TableView.h"
#import "SuiteSearchTableViewCell.h"
#import "SVPullToRefresh.h"
#import "HouseDetailViewController.h"
#import "SuiteAgent.h"
#import "HouseListItemModel.h"
#import "CustomSwitchTableViewCell.h"
#import "CustomPickerComponentTableViewCell.h"
#import "CustomRangeSliderTableViewCell.h"
#import "AuthenticationAgent.h"
#import "SuiteSearchFromMapViewController.h"
#import "SystemAgent.h"
#import "SuiteSearchFromSubwayViewController.h"
#import "SearchTextField.h"
#import "CustomImageView.h"
#import "GreenTextButton.h"
#import "YellowColorTextLabel.h"
#import "HouseSearchGuideView.h"

static CGFloat minHeightOfTableView = 0;
static CGFloat cellOffsetY = 33;
static CGFloat buttonOffsetY = 11;
static CGFloat moreConditionsHeight = 33;

@interface HouseSearchViewController () <UITableViewDataSource, UITableViewDelegate, SuiteSearchFromSubwayViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *conditionDic;
@property (nonatomic, strong) Room107TableView *conditionTableView; //筛选条件列表
@property (nonatomic, strong) Room107TableView *itemsTableView; //房间列表
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic) CGRect tableViewFrame;
@property (nonatomic) CGRect itemsTableViewFrame;
@property (nonatomic) BOOL isItemsTableViewTop; //itemsTableView是否处于最顶部
@property (nonatomic, strong) UIButton *changeConditionButton;
@property (nonatomic, strong) CustomPickerComponentTableViewCell *genderPickerComponentTableViewCell;
@property (nonatomic, strong) CustomSwitchTableViewCell *rentTypeSwitchTableViewCell;
@property (nonatomic, strong) CustomPickerComponentTableViewCell *roomsPickerComponentTableViewCell;
@property (nonatomic, strong) CustomRangeSliderTableViewCell *rangeSliderTableViewCell;
@property (nonatomic, strong) CustomSwitchTableViewCell *sortSwitchTableViewCell;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem; //当前窗口左侧的初始按钮
@property (nonatomic, strong) SearchTextField *positionSearchTextField;
@property (nonatomic, strong) CustomImageView *searchNoResultImageView;
@property (nonatomic, strong) NSString *totalItems; //搜索结果总数
@property (nonatomic, strong) HouseSearchGuideView *houseSearchGuideView; //搜索功能引导页
@property (nonatomic) BOOL isSchemaLoad; //是否是通过uri进入

@end

@implementation HouseSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableViewFrame = self.view.frame;
    _tableViewFrame.size.height = minHeightOfTableView;
    _isItemsTableViewTop = YES;
    _leftBarButtonItem = nil; //避免影响UINavigationItem的titleView位置
    self.navigationItem.leftBarButtonItem = _leftBarButtonItem;
    [self setRightBarButtonTitle:lang(@"Map")];
    
    [self createSearchView];
    [self createItemsTableView];
    [self createConditionTableView];
    [self showHouseSearchGuideView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHouseSearchGuideView) name:ClientDidLogoutNotification object:nil];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _isSchemaLoad = NO;
    }
    
    return self;
}

/*
 URLParams:{
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
    _isSchemaLoad = YES;
}

- (void)refreshItemsTableView {
    if (_itemsTableView.contentInset.top < moreConditionsHeight) {
        _itemsTableView.contentInset = UIEdgeInsetsMake(moreConditionsHeight, 0, 0, 0); //增加偏移量，实现_itemsTableView的Y值为0
    }
    [_itemsTableView reloadData];
}

- (void)createSearchView {
    _positionSearchTextField = [[SearchTextField alloc] initWithFrame:CGRectMake(0, 8, self.view.frame.size.width, 28)];
    _positionSearchTextField.delegate = self;
    [_positionSearchTextField setPlaceholder:lang(@"SearchPlaceholder") textColor:[UIColor room107GrayColorD] textFont:[UIFont room107FontTwo]];
    self.navigationItem.titleView = _positionSearchTextField;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self enterSubway];
    
    return YES;
}

- (void)enterSubway {
    SuiteSearchFromSubwayViewController *subwayVC = [[SuiteSearchFromSubwayViewController alloc] init];
    subwayVC.hidesBottomBarWhenPushed = YES;
    subwayVC.delegate = self;
    [self.navigationController pushViewController:subwayVC animated:YES];
}

- (void)controlsResignFirstResponder {
    [_positionSearchTextField resignFirstResponder];
}

- (void)initConditionDic {
    if (!_conditionDic) {
        _conditionDic = [[NSMutableDictionary alloc] init];
        [_conditionDic setObject:@"" forKey:@"position"];
    }
    [_conditionDic setObject:[CommonFuncs requiredGender:0] forKey:@"gender"];
    [_conditionDic setObject:[CommonFuncs rentTypeConvert:0] forKey:@"rentType"];
    [_conditionDic setObject:@0 forKey:@"roomNumber"]; //0：不限，1，2，3，4+
    [_conditionDic setObject:@0 forKey:@"minPrice"];
    [_conditionDic setObject:@10000 forKey:@"maxPrice"]; //10000需要显示为10000+
    [_conditionDic setObject:@0 forKey:@"sortOrder"];
    [_conditionDic setObject:@"true" forKey:@"resubscribe"]; //不更新订阅条件和搜索时间
    [_conditionDic setObject:@0 forKey:@"indexFrom"];
    [_conditionDic setObject:@20 forKey:@"indexTo"];
    if (_conditionTableView) {
        [self refreshConditionTableView];
    }
    _totalItems = nil;
    [_changeConditionButton setTitle:[NSString stringWithFormat:@"%@ : %@", lang(@"ChangeSearchCondition"), lang(@"AllHouse")] forState:UIControlStateNormal];
    [_positionSearchTextField setText:@""];
}

- (void)refreshConditionTableView {
    //刷新筛选条件各项值
    if (_genderPickerComponentTableViewCell) {
        [_genderPickerComponentTableViewCell setSelectedIndex:[CommonFuncs indexOfGender:_conditionDic[@"gender"]]];
    }
    if (_rentTypeSwitchTableViewCell) {
        [_rentTypeSwitchTableViewCell setSwitchIndex:[CommonFuncs indexOfRentType:_conditionDic[@"rentType"]]];
    }
    if (_rangeSliderTableViewCell) {
        [_rangeSliderTableViewCell setLeftValue:[_conditionDic[@"minPrice"] floatValue] andRightValue:[_conditionDic[@"maxPrice"] floatValue]];
    }
    if (_roomsPickerComponentTableViewCell) {
        [_roomsPickerComponentTableViewCell setSelectedIndex:[_conditionDic[@"roomNumber"] integerValue]];
    }
    if (_sortSwitchTableViewCell) {
        [_sortSwitchTableViewCell setSwitchIndex:[_conditionDic[@"sortOrder"] integerValue]];
    }
}

- (void)createConditionTableView {
    if (!_conditionTableView) {
        _conditionTableView = [[Room107TableView alloc] initWithFrame:_tableViewFrame style:UITableViewStyleGrouped];
        [_conditionTableView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
        _conditionTableView.delegate = self;
        _conditionTableView.dataSource = self;
        [self.view addSubview:_conditionTableView];
    }
}

- (void)createItemsTableView {
    if (!_itemsTableView) {
        _itemsTableViewFrame = [CommonFuncs tableViewFrame];
        if (!_isSchemaLoad) {
            _itemsTableViewFrame.size.height -= tabBarHeight;
        }
        _itemsTableView = [[Room107TableView alloc] initWithFrame:_itemsTableViewFrame style:UITableViewStyleGrouped];
        [_itemsTableView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
        _itemsTableView.contentInset = UIEdgeInsetsMake(moreConditionsHeight, 0, 0, 0); //增加偏移量，实现_itemsTableView的Y值为0
        _itemsTableView.delegate = self;
        _itemsTableView.dataSource = self;
        [self.view addSubview:_itemsTableView];
    }
    
    if (!_changeConditionButton) {
        _changeConditionButton = [[UIButton alloc] initWithFrame:(CGRect){0, 0, CGRectGetWidth(self.view.bounds), moreConditionsHeight}];
        [_changeConditionButton setBackgroundColor:[UIColor whiteColor]];
        [_changeConditionButton setTitleColor:[UIColor room107GreenColor] forState:UIControlStateNormal];
        [_changeConditionButton.titleLabel setFont:[UIFont room107SystemFontThree]];
        _changeConditionButton.alpha = 0.9;
        [self.view addSubview:_changeConditionButton];
        [_changeConditionButton addTarget:self action:@selector(changeCondition) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)insertRowAtBottom {
    int64_t delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (_items.count > 0) {
            NSUInteger indexFrom = _items.count;
            [_conditionDic setValue:[NSNumber numberWithUnsignedInteger:indexFrom] forKey:@"indexFrom"];
            [_conditionDic setValue:[NSNumber numberWithUnsignedInteger:indexFrom + 20] forKey:@"indexTo"];
            [_conditionDic setObject:@"false" forKey:@"resubscribe"]; //不更新订阅条件和搜索时间
        }
        [self searchHouseWithFilter:[[NSMutableDictionary alloc] init]];
    });
}

//搜索功能引导
- (void)showHouseSearchGuideView {
    [self initConditionDic];
    if (!_houseSearchGuideView) {
        _houseSearchGuideView = [[HouseSearchGuideView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_houseSearchGuideView];
    }
    _houseSearchGuideView.hidden = NO;
    _itemsTableView.hidden = YES;
    _searchNoResultImageView.hidden = YES;
}

- (void)hideHouseSearchGuideView {
    _houseSearchGuideView.hidden = YES;
    _itemsTableView.hidden = NO;
}

- (void)resetConditionsAndSearchHouse {
    if (_conditionDic) {
        if ([_positionSearchTextField.text isEmpty]) {
            [PopupView showMessage:lang(@"PositionIsEmpty")];
            return;
        }
        [_conditionDic setObject:_positionSearchTextField.text forKey:@"position"];
        [_conditionDic setObject:@"true" forKey:@"resubscribe"]; //不更新订阅条件和搜索时间
        [_conditionDic setObject:@0 forKey:@"indexFrom"];
        [_conditionDic setObject:@20 forKey:@"indexTo"];
        
        if (_genderPickerComponentTableViewCell) {
            NSString *conditionContent = lang(@"AllHouse");
            if ([_genderPickerComponentTableViewCell selectedIndex] != 0) {
                //性别限制
                conditionContent = [CommonFuncs genderPickerText:[_genderPickerComponentTableViewCell selectedIndex]];
            } else {
                if ([_rentTypeSwitchTableViewCell switchIndex] != 0) {
                    //类型
                    conditionContent = [CommonFuncs rentTypeSwitchText:[_rentTypeSwitchTableViewCell switchIndex]];
                } else {
                    if ([_rangeSliderTableViewCell leftValue] != 0 || [_rangeSliderTableViewCell rightValue] != 10000) {
                        //价格
                        conditionContent = [CommonFuncs priceRangeSliderText:[_rangeSliderTableViewCell leftValue] andRightValue:[_rangeSliderTableViewCell rightValue]];
                    } else {
                        if ([_roomsPickerComponentTableViewCell selectedIndex] != 0) {
                            //户型
                            conditionContent =  [CommonFuncs roomsPickerText:[_roomsPickerComponentTableViewCell selectedIndex]];
                        }
                    }
                }
            }
            [_changeConditionButton setTitle:[NSString stringWithFormat:@"%@ : %@", lang(@"ChangeSearchCondition"), [conditionContent isEqualToString:lang(@"AllHouse")] ? conditionContent : [conditionContent stringByAppendingString:@"..."]] forState:UIControlStateNormal];
        }
    }
    
    if (_changeConditionButton && _changeConditionButton.hidden) {
        [self unfoldConditionTableView:NO];
    }
    
    [self searchHouseWithFilter:[[NSMutableDictionary alloc] init]];
}

- (void)searchHouseWithFilter:(NSMutableDictionary *)filter {
    if (_conditionDic) {
        if (_genderPickerComponentTableViewCell) {
            [_conditionDic setObject:[CommonFuncs requiredGender:[_genderPickerComponentTableViewCell selectedIndex]] forKey:@"gender"];
        }
        if (_rentTypeSwitchTableViewCell) {
            [_conditionDic setObject:[CommonFuncs rentTypeConvert:[_rentTypeSwitchTableViewCell switchIndex]] forKey:@"rentType"];
        }
        if (_roomsPickerComponentTableViewCell) {
            [_conditionDic setObject:[NSNumber numberWithInteger:[_roomsPickerComponentTableViewCell selectedIndex]] forKey:@"roomNumber"];
        }
        if (_rangeSliderTableViewCell) {
            [_conditionDic setObject:[NSNumber numberWithFloat:[_rangeSliderTableViewCell leftValue]]forKey:@"minPrice"];
            [_conditionDic setObject:[NSNumber numberWithFloat:[_rangeSliderTableViewCell rightValue]] forKey:@"maxPrice"];
        }
        if (_sortSwitchTableViewCell) {
            [_conditionDic setObject:[NSNumber numberWithInteger:[_sortSwitchTableViewCell switchIndex]] forKey:@"sortOrder"];
        }
    }
    
    if ([_conditionDic[@"indexFrom"] isEqualToNumber:@0]) {
        [self showLoadingView];
    }
    
    if (filter) {
        filter = [NSMutableDictionary dictionaryWithDictionary:_conditionDic];
    }
    //搜索结果，需要传递_conditionDic副本，避免数据结构被更改
    WEAK_SELF weakSelf = self;
    [[SuiteAgent sharedInstance] getItemsWithFilter:filter completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items, NSString *position, NSString *total) {
        [weakSelf hideLoadingView];
        [weakSelf.itemsTableView.infiniteScrollingView stopAnimating];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            _totalItems = total;
            if (weakSelf.conditionDic) {
                if ([weakSelf.conditionDic[@"indexFrom"] isEqualToNumber:@0]) {
                    //新搜索
                    weakSelf.items = [items mutableCopy];
                    [weakSelf showSearchNoResultView:items.count == 0];
                    if (items.count == 0) {
                        [weakSelf showAlertViewWithTitle:lang(@"SearchHasNoResultTitle") message:lang(@"SearchHasNoResultMessage")];
                    } else {
                        [self hideHouseSearchGuideView];
                    }
                    
                    if (!weakSelf.isItemsTableViewTop) {
                        //不是从顶部进入的需要回到顶部
                        [weakSelf scrollToTableViewTop];
                    }
                    
                    [weakSelf.itemsTableView addInfiniteScrollingWithActionHandler:^{
                        [weakSelf insertRowAtBottom];
                    }];
                } else {
                    [weakSelf.items addObjectsFromArray:items];
                }
                
                [weakSelf refreshItemsTableView];
            }
        }
    }];
}

- (void)scrollToTableViewTop {
    if (_items.count > 0) {
        [_itemsTableView setFrame:_itemsTableViewFrame];
        [_itemsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)showSearchNoResultView:(BOOL)isShow {
    if (!_searchNoResultImageView) {
        CGFloat imageViewWidth = 100;
        _searchNoResultImageView = [[CustomImageView alloc] initWithFrame:(CGRect){0, 0, imageViewWidth, imageViewWidth}];
        CGPoint center = _itemsTableView.center;
        center.y = CGRectGetHeight(_itemsTableView.bounds) / 2;
        _searchNoResultImageView.center = center;
        [_searchNoResultImageView setImageWithName:@"searchNoResult.png"];
        [self.view addSubview:_searchNoResultImageView];
        [self.view sendSubviewToBack:_searchNoResultImageView];
    }
    _searchNoResultImageView.hidden = !isShow;
    _houseSearchGuideView.hidden = YES;
    _itemsTableView.hidden = isShow;
}

//控制UITableView的展开及收起
- (void)unfoldConditionTableView:(BOOL)unfold {
    CGRect tableViewFrame = _tableViewFrame;
    CGRect itemsTableViewFrame = _itemsTableViewFrame;
    UIBarButtonItem *leftBarButtonItem = _leftBarButtonItem;
    if (unfold) {
        //展开
        [self setRightBarButtonTitle:@"\ue61a"];
        tableViewFrame.size.height = CGRectGetHeight(self.view.bounds) - tabBarHeight;
        itemsTableViewFrame.origin.y = tableViewFrame.size.height;
        _conditionTableView.tableFooterView = [[UIView alloc] initWithFrame:(CGRect){self.view.bounds.origin, CGRectGetWidth(self.view.bounds), buttonOffsetY + navigationBarHeight}];
        [self.view bringSubviewToFront:_conditionTableView];
        
        //定制navigationItem的leftBarButtonItem
        leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(leftBarButtonDidClick:)];
    } else {
        //收起
        _conditionTableView.tableFooterView = [UIView new];
        _changeConditionButton.hidden = NO;
        [self setRightBarButtonTitle:lang(@"Map")];
        if (!_isItemsTableViewTop) {
            //不是从顶部进入的需要停留原处
            tableViewFrame.origin.y -= minHeightOfTableView;
            itemsTableViewFrame.origin.y = moreConditionsHeight;
        }
    }
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [UIView animateWithDuration:0.2 animations:^{
        [_conditionTableView setFrame:tableViewFrame];
        [_itemsTableView setFrame:itemsTableViewFrame];
        [_conditionTableView reloadData];
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)leftBarButtonDidClick:(id)sender {
    if (_changeConditionButton && _changeConditionButton.hidden) {
        [self unfoldConditionTableView:NO];
        
        if (_conditionDic) {
            [self refreshConditionTableView];
        }
    }
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    if (_changeConditionButton && _changeConditionButton.hidden) {
        [self resetConditionsAndSearchHouse];
    } else {
        SuiteSearchFromMapViewController *suiteSearchFromMapViewController = [[SuiteSearchFromMapViewController alloc] init];
        suiteSearchFromMapViewController.hidesBottomBarWhenPushed = YES; //具体到每一次push都需要设置
        [suiteSearchFromMapViewController setSearchHistoryPosition:_positionSearchTextField.text];
        [suiteSearchFromMapViewController setSearchConditionDic:_conditionDic];
        [suiteSearchFromMapViewController setScreeningConditions:_changeConditionButton.currentTitle];
        [self.navigationController pushViewController:suiteSearchFromMapViewController animated:YES];
    }
}

- (void)changeCondition {
    _changeConditionButton.hidden = YES;
    [self unfoldConditionTableView:YES];
}

- (UIView *)viewForSearchResultHeaderWithFrame:(CGRect)frame {
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat viewWidth = frame.size.width / 2 - 5;
    CGFloat viewHeight = 20;
    CGFloat originY = 5;
    SearchTipLabel *titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, viewWidth, viewHeight}];
    [titleLabel setFont:[UIFont room107SystemFontTwo]];
    [titleLabel setTextColor:[UIColor room107GrayColorE]];
    [titleLabel setTextAlignment:NSTextAlignmentRight];
    [titleLabel setText:[NSString stringWithFormat:lang(@"SearchResultNumber"), _totalItems]];
    [headerView addSubview:titleLabel];
    
    GreenTextButton *subscribeCurrentSearchButton = [[GreenTextButton alloc] initWithFrame:(CGRect){frame.size.width / 2 + 5, 5, viewWidth, viewHeight}];
    [subscribeCurrentSearchButton setTitle:lang(@"SubscribeCurrentSearch") forState:UIControlStateNormal];
    [subscribeCurrentSearchButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [subscribeCurrentSearchButton addTarget:self action:@selector(subscribeCurrentSearchButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:subscribeCurrentSearchButton];
    
    originY += viewHeight + 6;
    CGFloat maxDisplayWidth = frame.size.width;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5; //字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont room107SystemFontOne],
                                 NSParagraphStyleAttributeName:paragraphStyle};
    YellowColorTextLabel *subscribeCurrentSearchTipsLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){0, originY, maxDisplayWidth, [CommonFuncs rectWithText:lang(@"SubscribeCurrentSearchTips") andMaxDisplayWidth:maxDisplayWidth andAttributes:attributes].size.height} withTitle:lang(@"SubscribeCurrentSearchTips") withTitleColor:[UIColor room107GrayColorC]];
    [subscribeCurrentSearchTipsLabel setFont:[UIFont room107SystemFontOne]];
    [headerView addSubview:subscribeCurrentSearchTipsLabel];
    [subscribeCurrentSearchTipsLabel setHidden:[[Room107UserDefaults getValueFromUserDefaultsWithKey:SubscribeCurrentSearchTipsKey] boolValue]];
    
    originY += CGRectGetHeight(subscribeCurrentSearchTipsLabel.bounds) + 10;
    GreenTextButton *doNotPromptButton = [[GreenTextButton alloc] initWithFrame:(CGRect){0, originY, maxDisplayWidth, viewHeight}];
    [doNotPromptButton setTitle:lang(@"DoNotPrompt") forState:UIControlStateNormal];
    [doNotPromptButton addTarget:self action:@selector(doNotPromptButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:doNotPromptButton];
    [doNotPromptButton setHidden:[[Room107UserDefaults getValueFromUserDefaultsWithKey:SubscribeCurrentSearchTipsKey] boolValue]];
    
    return headerView;
}

- (UIView *)viewForConditionTableHeaderWithFrame:(CGRect)frame {
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat viewWidth = frame.size.width;
    CGFloat viewHeight = 20;
    CGFloat originY = 22;
    SearchTipLabel *titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, viewWidth, viewHeight}];
    [titleLabel setFont:[UIFont room107SystemFontTwo]];
    [titleLabel setTextColor:[UIColor room107GrayColorC]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:lang(@"AfterChangingCanResearch")];
    [headerView addSubview:titleLabel];
    
    viewWidth = frame.size.width * 3 / 5 - 5;
    originY += viewHeight;
    titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, viewWidth, viewHeight}];
    [titleLabel setFont:[UIFont room107SystemFontTwo]];
    [titleLabel setTextColor:[UIColor room107GrayColorC]];
    [titleLabel setTextAlignment:NSTextAlignmentRight];
    [titleLabel setText:lang(@"ToSeeAllHouses")];
    [headerView addSubview:titleLabel];
    
    CGFloat originX = viewWidth + 10;
    viewWidth = frame.size.width - viewWidth - 10;
    GreenTextButton *clearAllButton = [[GreenTextButton alloc] initWithFrame:(CGRect){originX, originY, viewWidth, viewHeight}];
    [clearAllButton setTitle:lang(@"ClearAll") forState:UIControlStateNormal];
    [clearAllButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [clearAllButton addTarget:self action:@selector(clearAllButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:clearAllButton];
    
    return headerView;
}

- (IBAction)subscribeCurrentSearchButtonDidClick:(id)sender {
    NSMutableDictionary *filter = [NSMutableDictionary dictionaryWithDictionary:_conditionDic];
    [filter removeObjectForKey:@"indexFrom"];
    [filter removeObjectForKey:@"indexTo"];
    [filter removeObjectForKey:@"resubscribe"];
    [filter removeObjectForKey:@"sortOrder"];
    WEAK_SELF weakSelf = self;
    [self showLoadingView];
    [[SuiteAgent sharedInstance] updateSubscribeWithFilter:filter completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, SubscribeModel *subscribe) {
        [weakSelf hideLoadingView];
        
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            [weakSelf showAlertViewWithTitle:lang(@"SubscribeCurrentSearchSuccess") message:nil];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (IBAction)doNotPromptButtonDidClick:(id)sender {
    [Room107UserDefaults saveUserDefaultsWithKey:SubscribeCurrentSearchTipsKey andValue:[NSNumber numberWithBool:YES]];
    [_itemsTableView reloadData];
}

- (IBAction)clearAllButtonDidClick:(id)sender {
    [self initConditionDic];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UITableView class]]) {
        [self controlsResignFirstResponder];
        
        if (_conditionTableView.frame.size.height == CGRectGetHeight(self.view.bounds) - tabBarHeight) {
            //避免快速滑动中搜索框异常展开
            return;
        }
        
        _isItemsTableViewTop = YES;
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY > minHeightOfTableView) {
            _isItemsTableViewTop = NO;
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_itemsTableView]) {
        return _items.count;
    } else {
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_itemsTableView]) {
        SuiteSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuiteSearchTableViewCell"];
        if (!cell) {
            cell = [[SuiteSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteSearchTableViewCell"];
        }
        
        if (_items && _items.count > indexPath.row) {
            //避免数组越界
            HouseListItemModel *houseListItem = _items[indexPath.row];
            NSDictionary *itemDic = @{@"cover":[houseListItem.hasCover boolValue] ? houseListItem.cover ? houseListItem.cover : [CommonFuncs newCoverDic] : [CommonFuncs newCoverDic], @"faviconUrl":houseListItem.faviconUrl ? houseListItem.faviconUrl : @"", @"tagIds":houseListItem.tagIds, @"isInterest":houseListItem.isInterest, @"price":houseListItem.price, @"viewCount":houseListItem.viewCount ? houseListItem.viewCount : @0, @"city":houseListItem.city, @"position":houseListItem.position, @"houseName":houseListItem.houseName, @"roomName":houseListItem.roomName, @"rentType":houseListItem.rentType, @"requiredGender":houseListItem.requiredGender, @"distance":houseListItem.distance ? houseListItem.distance : @0, @"modifiedTime":houseListItem.modifiedTime};
            [cell setItemDic:itemDic];
            WEAK_SELF weakSelf = self;
            [cell setViewHouseTagExplanationHandler:^(NSDictionary *params) {
                [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:params context:weakSelf];
            }];
            [cell setItemFavoriteHandler:^{
                if (![[AppClient sharedInstance] isLogin]) {
                    [weakSelf pushLoginAndRegisterViewController];
                    return;
                }
                
                NSNumber *houseID = houseListItem.id;
                NSNumber *roomID = [houseListItem.rentType isEqual:@1] ? houseListItem.roomId : nil;
                if ([houseListItem.isInterest boolValue]) {
                    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
                        
                    }];
                    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Delete") action:^{
                        [weakSelf showLoadingView];
                        [[SuiteAgent sharedInstance] removeInterestWithHouseID:houseID andRoomID:roomID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                            [weakSelf hideLoadingView];
                            if (errorTitle || errorMsg) {
                                [PopupView showTitle:errorTitle message:errorMsg];
                                if ([errorCode unsignedIntegerValue] == BusinessErrorCode) {
                                    //业务限制
                                    return;
                                }
                            }
                            if (!errorCode) {
                                houseListItem.isInterest = [NSNumber numberWithBool:![houseListItem.isInterest boolValue]];
                                [weakSelf.itemsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                [weakSelf showAlertViewWithTitle:lang(@"SuiteHasBeenDeleted") message:nil];
                            }
                        }];
                    }];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"WhetherDeleteTargetSuite")
                                                                    message:@"" cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
                    [alert show];
                } else {
                    [weakSelf showLoadingView];
                    [[SuiteAgent sharedInstance] addInterestWithHouseID:houseID andRoomID:roomID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                        [weakSelf hideLoadingView];
                        if (errorTitle || errorMsg) {
                            [PopupView showTitle:errorTitle message:errorMsg];
                            if ([errorCode unsignedIntegerValue] == BusinessErrorCode) {
                                //业务限制
                                return;
                            }
                        }
                        if (!errorCode) {
                            houseListItem.isInterest = [NSNumber numberWithBool:![houseListItem.isInterest boolValue]];
                            [weakSelf.itemsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf showAlertViewWithTitle:lang(@"JoinedBeSignedListTitle") message:lang(@"JoinedBeSignedListMessage")];
                        }
                    }];
                }
            }];
        }
        
        return cell;
    } else {
        switch (indexPath.row) {
            case 0:
            {
                if (!_genderPickerComponentTableViewCell) {
                    _genderPickerComponentTableViewCell = [[CustomPickerComponentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GenderPickerComponentTableViewCell"];
                    [self setCellTitle:lang(@"RenterType") andCell:_genderPickerComponentTableViewCell andOffsetY:0];
                    [_genderPickerComponentTableViewCell setStringsArray:@[lang(@"AllHouse"), lang(@"Female"), lang(@"Male"), lang(@"Male&Female")] withOffsetY:0 withUnit:nil];
                    [_genderPickerComponentTableViewCell setSelectedIndex:[CommonFuncs indexOfGender:_conditionDic[@"gender"]]];
                }
                
                return _genderPickerComponentTableViewCell;
            }
                break;
            case 1:
            {
                if (!_rentTypeSwitchTableViewCell) {
                    _rentTypeSwitchTableViewCell = [[CustomSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RentTypeSwitchTableViewCell"];
                    [self setCellTitle:lang(@"RentType") andCell:_rentTypeSwitchTableViewCell andOffsetY:cellOffsetY];
                    [_rentTypeSwitchTableViewCell setStringsArray:@[[@"\ue626 " stringByAppendingFormat:@"%@", lang(@"All")], [@"\ue624 " stringByAppendingFormat:@"%@", lang(@"RentHouse")], [@"\ue625 " stringByAppendingFormat:@"%@", lang(@"RentRoom")]] withOffsetY:cellOffsetY];
                    [_rentTypeSwitchTableViewCell setSwitchIndex:[CommonFuncs indexOfRentType:_conditionDic[@"rentType"]]];
                }
                
                return _rentTypeSwitchTableViewCell;
            }
                break;
            case 2:
            {
                if (!_rangeSliderTableViewCell) {
                    _rangeSliderTableViewCell = [[CustomRangeSliderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomRangeSliderTableViewCell"];
                    [self setCellTitle:lang(@"Budget") andCell:_rangeSliderTableViewCell andOffsetY:cellOffsetY];
                    [_rangeSliderTableViewCell setMinValue:0 andMaxValue:10000 withOffsetY:cellOffsetY];
                    [_rangeSliderTableViewCell setLeftValue:[_conditionDic[@"minPrice"] floatValue] andRightValue:[_conditionDic[@"maxPrice"] floatValue]];
                }
                
                return _rangeSliderTableViewCell;
            }
                break;
            case 3:
            {
                if (!_roomsPickerComponentTableViewCell) {
                    _roomsPickerComponentTableViewCell = [[CustomPickerComponentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomPickerComponentTableViewCell"];
                    [self setCellTitle:lang(@"SuiteType") andCell:_roomsPickerComponentTableViewCell andOffsetY:cellOffsetY];
                    [_roomsPickerComponentTableViewCell setStringsArray:@[lang(@"NoLimit"), @"1", @"2", @"3", @"4+"] withOffsetY:cellOffsetY withUnit:lang(@"Room")];
                    [_roomsPickerComponentTableViewCell setSelectedIndex:[_conditionDic[@"roomNumber"] integerValue]];
                }
                
                return _roomsPickerComponentTableViewCell;
            }
                break;
            case 4:
            {
                if (!_sortSwitchTableViewCell) {
                    _sortSwitchTableViewCell = [[CustomSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SortSwitchTableViewCell"];
                    [self setCellTitle:lang(@"Sort") andCell:_sortSwitchTableViewCell andOffsetY:cellOffsetY];
                    [_sortSwitchTableViewCell setStringsArray:@[lang(@"SmartSort"), lang(@"MonthlyPrice"), lang(@"SubmitTime")] withOffsetY:cellOffsetY];
                    [_sortSwitchTableViewCell setSwitchIndex:[_conditionDic[@"sortOrder"] integerValue]];
                }
                
                return _sortSwitchTableViewCell;
            }
                break;
            default:
            {
                static NSString *cellIdentifier = @"UITableViewCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                
                return cell;
            }
                break;
        }
    }
}

- (void)setCellTitle:(NSString *)title andCell:(Room107TableViewCell *)cell andOffsetY:(CGFloat)offsetY {
    CGRect frame = cell.titleLabel.frame;
    frame.origin.y += offsetY;
    [cell.titleLabel setFrame:frame];
    [cell setTitle:title];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_itemsTableView]) {
        return [CommonFuncs houseCardHeight] + 11;
    } else {
        switch (indexPath.row) {
            case 1:
            case 4:
                return customSwitchTableViewCellHeight + cellOffsetY;
                break;
            case 2:
                return customRangeSliderTableViewCellHeight + cellOffsetY;
                break;
            case 0:
                return customPickerComponentTableViewCellHeight;
                break;
            case 3:
                return customPickerComponentTableViewCellHeight + cellOffsetY;
                break;
            default:
                return moreConditionsHeight;
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_itemsTableView]) {
        NSNumber *hideSubscribeCurrentSearchTips = [Room107UserDefaults getValueFromUserDefaultsWithKey:SubscribeCurrentSearchTipsKey];
        return _totalItems ? [hideSubscribeCurrentSearchTips boolValue] ? 20 : 90 : 20;
    } else {
        return 75;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]};
    if ([tableView isEqual:_itemsTableView]) {
        return _totalItems ? [self viewForSearchResultHeaderWithFrame:frame] : [UIView new];
    } else {
        return [self viewForConditionTableHeaderWithFrame:frame];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_itemsTableView]) {
        if (_items && _items.count > indexPath.row) {
            //避免数组越界
            HouseDetailViewController *houseDetailViewController = [[HouseDetailViewController alloc] init];
            HouseListItemModel *houseListItem = _items[indexPath.row];
            [houseDetailViewController setItem:houseListItem];
            [houseDetailViewController setHouseInterestHandler:^(NSNumber *isInterest) {
                houseListItem.isInterest = isInterest;
                [_itemsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
            houseDetailViewController.hidesBottomBarWhenPushed = YES; //具体到每一次push都需要设置
            [self.navigationController pushViewController:houseDetailViewController animated:YES];
        }
        [self controlsResignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SuiteSearchFromSubwayViewDelegate
- (void)suiteSearchFromSubwayShouldReturnOrSearchButton:(NSString *)position {
    [_positionSearchTextField setText:position];
    [self resetConditionsAndSearchHouse];
}

- (void)suiteSearchFromSubwayShouldTappedOnTagPosition:(NSString *)tagPosition atIndex:(NSInteger)index {
    [_positionSearchTextField setText:tagPosition];
    [self resetConditionsAndSearchHouse];
}

- (void)suiteSearchFromSubwayDidSelectedWithKeyword:(NSString *)keyword {
    [_positionSearchTextField setText:keyword];
    [self resetConditionsAndSearchHouse];
}

@end
