//
//  SuiteSearchFromSubwayViewController.m
//  room107
//
//  Created by 107间 on 16/1/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SuiteSearchFromSubwayViewController.h"
#import "Room107TableView.h"
#import "SuiteFromSubwayCell.h"
#import "TLTagsControl.h"
#import "SearchTextField.h"
#import "AppClient.h"
#import "SystemAgent.h"
#import "SubwayLineModel.h"

@interface SuiteSearchFromSubwayViewController()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, TLTagsControlDelegate>

@property (nonatomic, strong) SearchTextField *positionSearchTextField;
@property (nonatomic, strong) TLTagsControl *addressTagsControl;
@property (nonatomic, strong) NSMutableArray *tagsArray;//标签数组
@property (nonatomic, strong) Room107TableView *routeTableView; //线路
@property (nonatomic, strong) Room107TableView *stopTableView;  //站点
@property (nonatomic, strong) NSArray *subwayInfoArray;   //地铁信息数据
@property (nonatomic, assign) NSInteger num; //当前点击的线路

@end

@implementation SuiteSearchFromSubwayViewController

- (void)getInfo {
    _subwayInfoArray = [[SystemAgent sharedInstance] getSubwayLinesFromLocal];
    if (!_subwayInfoArray || _subwayInfoArray.count == 0) {
        [self showLoadingView];
        
        WEAK_SELF weakSelf = self;
        [[SystemAgent sharedInstance] getSubwayLines:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *subwayLines) {
            [weakSelf hideLoadingView];
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
                
            if (!errorCode) {
                weakSelf.subwayInfoArray = subwayLines;
                [weakSelf createTableView];
            } else {
                if ([self isLoginStateError:errorCode]) {
                    return;
                }
            }
        }];
    } else {
        [self createTableView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:_tagsArray forKey:@"historyPositions"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_positionSearchTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setRightBarButtonTitle:lang(@"Search")];
    
    self.tagsArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"historyPositions"] ];
    
    //搜索框
    [self creatSearch];
    
    CGFloat originY = 5;
    //搜索历史
    UILabel *searchHistory = [[UILabel alloc] init];
    [searchHistory setFrame:CGRectMake(0, originY, self.view.frame.size.width, 16)];
    [searchHistory setText:lang(@"SearchHistory")];
    [searchHistory setFont:[UIFont room107SystemFontOne]];
    [searchHistory setTextColor:[UIColor room107GrayColorC]];
    [searchHistory setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:searchHistory];
    
    originY = 11;
    CGFloat spaceX = 22;
    CGFloat tagsHeight = 25;
    //标签样式
    self.addressTagsControl = [[TLTagsControl alloc] initWithFrame:CGRectMake(spaceX, CGRectGetMaxY(searchHistory.frame) + originY, self.view.frame.size.width - 2 * spaceX, tagsHeight) andTags:_tagsArray andPlaceholder:@"" withTagsControlMode:TLTagsControlModeList];
    _addressTagsControl.tapDelegate = self ;
    [_addressTagsControl reloadTagSubviews];
    _addressTagsControl.showsVerticalScrollIndicator = NO;
    _addressTagsControl.showsHorizontalScrollIndicator = NO;
    _addressTagsControl.tagsTextFont = [UIFont room107SystemFontTwo];
    [self.view addSubview:_addressTagsControl];
    
    [self getInfo];
}

- (void)createTableView {
    if (!_routeTableView) {
        CGFloat routeWidth = self.view.frame.size.width * 2/5.0;
        CGFloat stopWidth = self.view.frame.size.width * 3/5.0;
        CGFloat originY = 22;
        
        //清除搜索历史
        CGFloat width = 100;
        CGFloat viewWidth = self.view.frame.size.width;
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(viewWidth/2 - width/2, CGRectGetMaxY(_addressTagsControl.frame) + originY - 5, width, 30)];
        [deleteButton.titleLabel setFont:[UIFont room107SystemFontTwo]];
        [deleteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [deleteButton setTitle:lang(@"DeleteSearchHistory") forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor room107GreenColor] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteSearchHistory) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:deleteButton];
        
        //地铁找房
        UILabel *subwayLabel = [[UILabel alloc] init];
        
        [subwayLabel setFrame:CGRectMake(0, CGRectGetMaxY(deleteButton.frame) + originY - 5, self.view.frame.size.width, 16)];
        [subwayLabel setTextColor:[UIColor room107GrayColorC]];
        [subwayLabel setText:lang(@"SubwayForHouse")];
        [subwayLabel setFont:[UIFont room107SystemFontOne]];
        [subwayLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:subwayLabel];
        
        //此时采用[[UIScreen mainScreen] bounds]计算最准确的高度
        CGFloat height = CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetMaxY(subwayLabel.frame) - 11 - statusBarHeight - navigationBarHeight;
        
        self.routeTableView = [[Room107TableView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(subwayLabel.frame) + 11, routeWidth, height)];
        _routeTableView.delegate = self;
        _routeTableView.dataSource = self;
        if (_subwayInfoArray && _subwayInfoArray.count > 0) {
            NSIndexPath *firstPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [_routeTableView selectRowAtIndexPath:firstPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
        
        self.stopTableView = [[Room107TableView alloc] initWithFrame:CGRectMake(routeWidth, CGRectGetMaxY(subwayLabel.frame) + 11, stopWidth, height)];
        [_stopTableView setBackgroundColor:[UIColor room107GrayColorA]];
        _stopTableView.delegate = self;
        _stopTableView.dataSource = self;
        
        [self.view addSubview:_routeTableView];
        [self.view addSubview:_stopTableView];
    }
}

///创建搜索框
- (void)creatSearch {
    //搜索框
    _positionSearchTextField = [[SearchTextField alloc] initWithFrame:CGRectMake(0, 8,self.view.frame.size.width, 28)];
    _positionSearchTextField.delegate = self;
    [_positionSearchTextField setPlaceholder:lang(@"SearchPlaceholder") textColor:[UIColor room107GrayColorD] textFont:[UIFont room107FontTwo]];
    _positionSearchTextField.returnKeyType = UIReturnKeySearch;
    _positionSearchTextField.enablesReturnKeyAutomatically = YES;
    self.navigationItem.titleView = _positionSearchTextField;
}

- (void)popToPreviousView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _routeTableView) {
        //线路
        return _subwayInfoArray.count;
    } else if (tableView == _stopTableView) {
        //车站
        return [[_subwayInfoArray[_num] stations] count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _routeTableView) {
        //线路
        static NSString *cellID = @"routeCellID" ;
        SuiteFromSubwayCell *routeCell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (nil == routeCell) {
            routeCell = [[SuiteFromSubwayCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }
        if (indexPath.row < _subwayInfoArray.count) {
            [routeCell setSubwayName:[_subwayInfoArray[indexPath.row] name]];
        }
        routeCell.selectedBackgroundView = [[UIView alloc] initWithFrame:routeCell.frame];
        [routeCell.selectedBackgroundView setBackgroundColor:[UIColor room107GrayColorA]];
        return routeCell;
    } else {
        //车站
        static NSString *cellID = @"stopCellID" ;
        SuiteFromSubwayCell *stopCell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (nil == stopCell) {
            stopCell = [[SuiteFromSubwayCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellID];
        }
        if (_num < _subwayInfoArray.count && indexPath.row < [[_subwayInfoArray[_num] stations] count]) {
            [stopCell setSubwayName:[_subwayInfoArray[_num] stations][indexPath.row]];
        }
        [stopCell setBackgroundColor:[UIColor room107GrayColorA]];
        stopCell.selectedBackgroundView = [[UIView alloc] initWithFrame:stopCell.frame];
        [stopCell.selectedBackgroundView setBackgroundColor:[UIColor room107GrayColorB]];
        return stopCell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return suiteFromSubwayCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _routeTableView) {
        self.num = indexPath.row ;
        [_positionSearchTextField resignFirstResponder];
        [_stopTableView reloadData];
    } else {
        if ([self.delegate respondsToSelector:@selector(suiteSearchFromSubwayDidSelectedWithKeyword:)]) {
            if (_num < _subwayInfoArray.count && indexPath.row < [[_subwayInfoArray[_num] stations] count]) {
                NSString *keyword = [_subwayInfoArray[_num] keywords][indexPath.row];
                [self.delegate suiteSearchFromSubwayDidSelectedWithKeyword:keyword];
                [self insertHistorePosition:keyword];
            }
        }
        [self popToPreviousView];
    }
}

#pragma mark - TLTagsControlDelegate
- (void)tagsControl:(TLTagsControl *)tagsControl tappedAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(suiteSearchFromSubwayShouldTappedOnTagPosition:atIndex:)]) {
        [self.delegate suiteSearchFromSubwayShouldTappedOnTagPosition:self.tagsArray[index] atIndex:index];
        NSString *temp = self.tagsArray[index];
        [self.tagsArray removeObject:self.tagsArray[index]];
        [self.tagsArray insertObject:temp atIndex:0];
    }
    [self popToPreviousView];
}

#pragma mark - UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchAndBack];
    return YES;
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    [self searchAndBack];
}

- (void)searchAndBack {
    if ([self.positionSearchTextField.text isEqualToString:@""]) {
        [PopupView showMessage:lang(@"PositionIsEmpty")];
    } else {
        if ([self.delegate respondsToSelector:@selector(suiteSearchFromSubwayShouldReturnOrSearchButton:)]) {
            [self.delegate suiteSearchFromSubwayShouldReturnOrSearchButton:_positionSearchTextField.text];
            [self insertHistorePosition:_positionSearchTextField.text];
            [self popToPreviousView];
        }
    }
}

- (void)insertHistorePosition:(NSString *)position {
    for (int i = 0 ; i < self.tagsArray.count ; i++) {
        if ([position isEqualToString:self.tagsArray[i]]) {
            [self.tagsArray removeObjectAtIndex:i];
            [self.tagsArray insertObject:position atIndex:0];
            return;
        }
    }
    [self.tagsArray insertObject:position atIndex:0];
}

- (void)deleteSearchHistory {
    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
    }];
    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:[lang(@"Confirm") substringToIndex:2] action:^{
        //清除本地搜索历史
        [_addressTagsControl clearAllTags];
        [_tagsArray removeAllObjects];
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:lang(@"WhetherDeleteSearchHistory") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
    [alert show];

}
@end
