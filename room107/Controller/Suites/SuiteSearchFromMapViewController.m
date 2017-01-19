//
//  SuiteSearchFromMapViewController.m
//  room107
//
//  Created by 107间 on 16/1/6.
//  Copyright © 2016年 107room. All rights reserved.
//
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "SuiteSearchFromMapViewController.h"
#import "SuiteSearchFromMapBottomView.h"
#import "SuiteAgent.h"
#import "NSString+Encoded.h"
#import "HouseListItemModel.h"
#import "Room107TableView.h"
#import "CustomSwitchTableViewCell.h"
#import "CustomPickerComponentTableViewCell.h"
#import "CustomRangeSliderTableViewCell.h"
#import "HouseDetailViewController.h"
#import "SystemAgent.h"
#import "AppPropertiesModel.h"
#import "SearchTextField.h"
#import "SuiteSearchFromSubwayViewController.h"
#import "AuthenticationAgent.h"
#import "RoundedGreenButton.h"
#import "GreenTextButton.h"

static CGFloat moreConditionsHeight = 33.0f;
static CGFloat cellOffsetY = 33.0f;
static CGFloat buttonOffsetY = 11.0f;
static CGFloat zoomLevel = 15.0f;
static NSTimeInterval delayTime = 0.8f; //防止百度地图缩放和平移动画冲突  动画延迟时间
static NSTimeInterval kFadeInAnimation = 0.5f; //淡入动画时间
static NSTimeInterval kFadeOutAnimation = 1.0f; //淡出动画时间

@interface SuiteSearchFromMapViewController() <BMKMapViewDelegate, BMKLocationServiceDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SuiteSearchFromSubwayViewDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic) CLLocationCoordinate2D currentCoordinate; //当前坐标
@property (nonatomic, strong) BMKPointAnnotation *currentAnnotation;  //当前位置坐标
@property (nonatomic, strong) BMKLocationService *locService;   //定位服务
@property (nonatomic, strong) NSMutableArray *annotationInfoArray; //保存标记信息数组:view button
@property (nonatomic, strong) NSMutableArray *annotationArray;      //保存标记数组
@property (nonatomic, strong) SuiteSearchFromMapBottomView *bottomView; //基本情况视图
@property (nonatomic, strong) NSMutableDictionary *conditionDic;
@property (nonatomic, strong) NSArray *houseItemList;
@property (nonatomic, assign) CGFloat normalWidth; //annotationView正常价格（4位数）显示宽度
@property (nonatomic, strong) UIButton *changeConditionButton; //更多搜索条件
@property (nonatomic, strong) Room107TableView *conditionTableView; //搜索条件
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem; //当前窗口左侧的初始按钮
@property (nonatomic, strong) CustomPickerComponentTableViewCell *genderPickerComponentTableViewCell;
@property (nonatomic, strong) CustomSwitchTableViewCell *rentTypeSwitchTableViewCell;
@property (nonatomic, strong) CustomPickerComponentTableViewCell *roomsPickerComponentTableViewCell;
@property (nonatomic, strong) CustomRangeSliderTableViewCell *rangeSliderTableViewCell;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL isFirstEnter; //记录是否第一次进入地图页
@property (nonatomic, strong) UILabel *blackLabel; //黑色提示框
@property (nonatomic, strong) NSTimer *fadeOutTimer; //定时器控制黑色提示框的淡出效果
@property (nonatomic, strong) SearchTextField *positionSearchTextField;
@property (nonatomic, strong) NSString *position;
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;
@property (nonatomic, strong) NSString *screeningConditions;
@property (nonatomic, assign) BOOL hasLongClick;
@end

@implementation SuiteSearchFromMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstEnter = YES;
    
    self.currentAnnotation = [[BMKPointAnnotation alloc] init];
    self.annotationInfoArray = [[NSMutableArray alloc] init];
    self.annotationArray = [[NSMutableArray alloc] init];
    self.houseItemList = [[NSArray alloc] init];
 
    [self setTitle:@""];
    [self setRightBarButtonTitle:[lang(@"MySubscribes") substringFromIndex:2]];
    self.normalWidth = [self getWidthWithText:@"￥9999"];
    
    [self creatSearch];
    [self creatMapView];
    [self creatLocService];
    [self creatBottomInfoView];
    [self creatMoreCondition];
    [self creatGEOSearchBase];
    self.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _mapView.delegate = self;
    _locService.delegate = self;
    _geocodesearch.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _mapView.delegate = nil ;
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
    [_positionSearchTextField resignFirstResponder];
}

//地图初始化完毕时会调用此接口
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    if ((nil == _position) || [_position isEqualToString:@""] ){
        //无搜索记录
        [self checkLocServiceAndLoction];
    } else {
        [self getAnnotationsAtPosition:_position];
    }
}

//获得搜多页面地址
- (void)setSearchHistoryPosition:(NSString *)position {
    self.position = position;
}

//获得搜索页面搜索条件
- (void)setSearchConditionDic:(NSDictionary *)conditionDic {
    if (conditionDic) {
        _conditionDic = [[NSMutableDictionary alloc] initWithDictionary:conditionDic];
        [_conditionDic setObject:@"true" forKey:@"resubscribe"];
        [_conditionDic removeObjectForKey:@"indexTo"];
        [_conditionDic removeObjectForKey:@"indexFrom"];
        [_conditionDic removeObjectForKey:@"sortOrder"];
    } else {
        _conditionDic = [[NSMutableDictionary alloc] init];
        [_conditionDic setObject:[CommonFuncs requiredGender:0] forKey:@"gender"];
        [_conditionDic setObject:[CommonFuncs rentTypeConvert:0] forKey:@"rentType"];
        [_conditionDic setObject:@0 forKey:@"roomNumber"]; //0：不限，1，2，3，4+
        [_conditionDic setObject:@0 forKey:@"minPrice"];
        [_conditionDic setObject:@10000 forKey:@"maxPrice"]; //10000需要显示为10000+
    }
}

//获得当前筛选条件
- (void)setScreeningConditions:(NSString *)conditionString {
    _screeningConditions = conditionString;
}

//检测定位服务是否可以使用，可以则定位
- (void)checkLocServiceAndLoction {
    //检测定位功能是否可以使用
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
        LogDebug(@"定位服务可用,开始定位");
        [_locService startUserLocationService];
        _mapView.showsUserLocation = NO;//先关闭显示的定位图层
        _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
        _mapView.showsUserLocation = YES;//显示定位图层
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        LogDebug(@"定位服务不可用");
        WEAK_SELF weakSelf = self;
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
            if (0 == weakSelf.positionSearchTextField.text.length) {
                //采用默认坐标
                [weakSelf getAnnotationsAtCoordinate:[weakSelf getDefaulPosition]];
            }
        }];
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:[lang(@"SetUp") substringToIndex:2] action:^{
            //跳到设置页面 打开定位服务功能
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                //如果点击打开的话，需要记录当前的状态，从设置回到应用的时候会用到
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"LoctionIsClose") message:lang(@"OpenLoctionService") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
        [alert show];
    }
}

- (void)resetConditionDic {
    [_conditionDic setObject:[CommonFuncs requiredGender:0] forKey:@"gender"];
    [_conditionDic setObject:[CommonFuncs rentTypeConvert:0] forKey:@"rentType"];
    [_conditionDic setObject:@0 forKey:@"roomNumber"]; //0：不限，1，2，3，4+
    [_conditionDic setObject:@0 forKey:@"minPrice"];
    [_conditionDic setObject:@10000 forKey:@"maxPrice"]; //10000需要显示为10000+
    if (_conditionTableView) {
        //刷新筛选条件各项值
        [self refreshTableView];
    }
}

//创建搜索框
- (void)creatSearch {
    //搜索框
    _positionSearchTextField = [[SearchTextField alloc] initWithFrame:CGRectMake(0, 8, self.view.frame.size.width, 28)];
    _positionSearchTextField.delegate = self;
    [_positionSearchTextField setPlaceholder:lang(@"SearchPlaceholder") textColor:[UIColor room107GrayColorD] textFont:[UIFont room107FontTwo]];
    [_positionSearchTextField setText:_position];
    self.navigationItem.titleView = _positionSearchTextField;
}

//创建BottomView
- (void)creatBottomInfoView {
    self.bottomView = [[SuiteSearchFromMapBottomView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, self.view.frame.size.width * 4 /15)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [_bottomView addGestureRecognizer:tap];
    [self.view addSubview:_bottomView];
}

//创建地图
- (void)creatMapView {
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.frame];
    _mapView.zoomLevel = [CommonFuncs mapZoomLevel];
    _mapView.minZoomLevel = 3.0f;
    _mapView.maxZoomLevel = 19.0f;
    _mapView.zoomLevel = zoomLevel;
    [_mapView setMapType:BMKMapTypeStandard];
    [self.view addSubview:_mapView];
    
    CGFloat offsetX = 44;
    CGFloat offsetY = 44;
    CGFloat buttonWidth = 44;
    RoundedGreenButton *locateButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){CGRectGetWidth(self.view.bounds) - offsetX - buttonWidth, self.view.frame.size.height - 120 - statusBarHeight - navigationBarHeight - buttonWidth, buttonWidth, buttonWidth}];
    [locateButton setBackgroundColor:[UIColor colorFromHexString:@"#000000" alpha:0.7]];
    [locateButton.titleLabel setFont:[UIFont room107FontFour]];
    [locateButton setTitle:lang(@"Position") forState:UIControlStateNormal];
    [locateButton addTarget:self action:@selector(locateButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locateButton];
}

- (IBAction)locateButtonDidClick:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, self.view.frame.size.width * 4 /15);
    }];
    [self mapMode];
    [self checkLocServiceAndLoction];
}

//创建定位服务
- (void)creatLocService {
    self.locService = [[BMKLocationService alloc] init];
}

//创建geo搜索服务
- (void)creatGEOSearchBase {
    self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
}

//创建更多搜索条件
- (void)creatMoreCondition {
    _changeConditionButton = [[UIButton alloc] initWithFrame:(CGRect){0, 0, CGRectGetWidth(self.view.bounds), moreConditionsHeight}];
    [_changeConditionButton setBackgroundColor:[UIColor whiteColor]];
    [_changeConditionButton setTitle:_screeningConditions forState:UIControlStateNormal];
    [_changeConditionButton setTitleColor:[UIColor room107GreenColor] forState:UIControlStateNormal];
    [_changeConditionButton.titleLabel setFont:[UIFont room107SystemFontThree]];
    _changeConditionButton.alpha = 0.9;
    [self.view addSubview:_changeConditionButton];
    //获得找房页按钮title
     [_changeConditionButton addTarget:self action:@selector(changeCondition) forControlEvents:UIControlEventTouchUpInside];
  
    _blackLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 75 , CGRectGetMaxY(_changeConditionButton.frame) + 5, 150, 20)];
    [_blackLabel setBackgroundColor:[UIColor blackColor]];
    [_blackLabel setFont:[UIFont room107SystemFontOne]];
    [_blackLabel setTextColor:[UIColor whiteColor] ];
    [_blackLabel setText:lang(@"LongPressForLocation")];
    [_blackLabel setTextAlignment:NSTextAlignmentCenter];
    [_blackLabel setAlpha:0.6];
    _blackLabel.layer.cornerRadius = 10.0f;
    _blackLabel.layer.masksToBounds = YES;
    [self.view addSubview:_blackLabel];
    
    self.conditionTableView = [[Room107TableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0) style:UITableViewStyleGrouped];
    [_conditionTableView setBackgroundColor:[UIColor room107GrayColorA]];
    _conditionTableView.delegate = self;
    _conditionTableView.dataSource = self;
    
    _conditionTableView.tableFooterView = [[UIView alloc] initWithFrame:(CGRect){self.view.bounds.origin, CGRectGetWidth(self.view.bounds), buttonOffsetY + navigationBarHeight}];
    [self.view addSubview:_conditionTableView];
    [self.view addSubview:_changeConditionButton];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 75;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self creatHeaderView];
}

- (UIView *)creatHeaderView {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, 75};

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

//重置筛选条件
- (IBAction)clearAllButtonDidClick:(id)sender {
    [self resetConditionDic];
    [self refreshButtonTitle];
}

//搜索态
- (void)searchMode {
    _changeConditionButton.hidden = YES;
    //定制navigationItem
    [self setRightBarButtonTitle:lang(@"Search")];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(leftBarButtonDidClick)];
    WEAK_SELF weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        [weakSelf.conditionTableView setFrame:weakSelf.view.bounds];
    } completion:^(BOOL finished) {
    }];
}

//地图态
- (void)mapMode {
    _changeConditionButton.hidden = NO;
    [self setRightBarButtonTitle:[lang(@"MySubscribes") substringFromIndex:2]];
    WEAK_SELF weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        [weakSelf.conditionTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    }];
    self.navigationItem.leftBarButtonItem = _leftBarButtonItem;
}

#pragma mark - tableViewDelete
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
                [self setCellTitle:lang(@"RentType")  andCell:_rentTypeSwitchTableViewCell andOffsetY:cellOffsetY];
                [_rentTypeSwitchTableViewCell setStringsArray:@[[@"\ue626 " stringByAppendingFormat:@"%@", lang(@"All")], [@"\ue624 " stringByAppendingFormat:@"%@", lang(@"RentHouse")], [@"\ue625 " stringByAppendingFormat:@"%@", lang(@"RentRoom")]] withOffsetY:cellOffsetY];
                [_rentTypeSwitchTableViewCell setSwitchIndex:[CommonFuncs indexOfRentType:_conditionDic[@"rentType"]]];
            }
            
            return _rentTypeSwitchTableViewCell;
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
        default:
            return [[Room107TableViewCell alloc] init];
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 1:
            return customSwitchTableViewCellHeight + cellOffsetY;
            break;
        case 0:
        case 3:
            return customPickerComponentTableViewCellHeight + cellOffsetY;
            break;
        case 2:
            return customRangeSliderTableViewCellHeight  + cellOffsetY;
            break;
        default:
            return 0;
            break;
    }
}

- (void)setCellTitle:(NSString *)title andCell:(Room107TableViewCell *)cell andOffsetY:(CGFloat)offsetY {
    CGRect frame = cell.titleLabel.frame;
    frame.origin.y += offsetY;
    [cell.titleLabel setFrame:frame];
    [cell setTitle:title];
}

//更改搜索条件
- (void)changeConditionDic {
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
    }
}

//通过坐标获取房子 1.进来无订阅词语  2.主动定位  3.采用默认坐标
- (void)getAnnotationsAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self changeConditionDic];
    //获取当前坐标
    self.currentCoordinate = coordinate ;
    //得到定位坐标下标注点
    [self.currentAnnotation setCoordinate:_currentCoordinate];
#pragma mark - 设置地图点和设置地图缩放级别有冲突  注意执行顺序：1.先设置地图中心点 2.再设置地图缩放级别
    //设定当前位置为地图中心点
    [self.mapView setCenterCoordinate:self.currentCoordinate animated:YES];
//    [self.mapView setCenterCoordinate:_currentCoordinate];
    //设置zoomLevel
#pragma mark - 百度地图 setCenter动画和setZoomLevel冲突 延迟调用缩放比例动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _mapView.zoomLevel = zoomLevel;
    });
    //停止定位
    [_locService stopUserLocationService];
    
    NSString *location = [NSString stringWithFormat:@"%f,%f", _currentCoordinate.longitude,_currentCoordinate.latitude]; //longitude 经度, latitude 纬度
    [_conditionDic setObject:[location URLEncodedString] forKey:@"location"];
    [_conditionDic setObject:[NSNumber numberWithInt:(int)_mapView.zoomLevel] forKey:@"scaleLevel"];
    [_conditionDic removeObjectForKey:@"position"];
    WEAK_SELF weakSelf = self;
    [[SuiteAgent sharedInstance] getMapItemsWithFilter:_conditionDic completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items, NSString *position, NSString *locationX, NSString *locationY, NSNumber *alert, NSString *alertTitle, NSString *alertContent, NSString *total) {
        [weakSelf hideLoadingView];
        //清除当前标注数组
        [_mapView removeAnnotations:_annotationArray];
        [_annotationInfoArray removeAllObjects];
        [_annotationArray removeAllObjects];
        _hasLongClick = NO;
        if (errorMsg) {
            
        } else {
            //To-do：根据返回的坐标重新或取消定位 locationX：搜索地址X坐标，若没有则是无定位坐标，locationY：搜索地址Y坐标，若没有则是无定位坐标
            if (locationX && locationY) {
            }
            
            if ([alert boolValue]) {
                [weakSelf showAlertViewWithTitle:alertTitle message:alertContent];
            }
            
            if (position) {
                [weakSelf.positionSearchTextField setText:position];
                weakSelf.position = position;
                [weakSelf.conditionDic setObject:position forKey:@"position"];
            }
            
            if (0 == items.count) {
                [PopupView showMessage:lang(@"MapSearchHasNoResult")];
            }
            //获取houseItemList
            weakSelf.houseItemList = items;
            //向地图窗口添加一组标注
            [weakSelf.annotationArray addObject:weakSelf.currentAnnotation];
            [weakSelf.annotationArray addObjectsFromArray:[weakSelf getRealAnnotations]];
            [weakSelf.mapView addAnnotations:weakSelf.annotationArray];
        }
    }];
}

//获得实际坐标标注数组
- (NSArray *)getRealAnnotations {
    NSMutableArray *annotationArray = [[NSMutableArray alloc] init];
    for (HouseListItemModel *model in  _houseItemList) {
        if (!model.x || !model.y || [model.x isEqual:@0] || [model.y isEqual:@0]) {
            //坐标异常的房子
            continue;
        }
        
        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
        CLLocationCoordinate2D cooridnate = CLLocationCoordinate2DMake([model.y doubleValue], [model.x doubleValue]);
        [annotation setCoordinate:cooridnate];
        [annotationArray addObject:annotation];
    }
    
    return annotationArray;
}

//通过position获取房屋信息
- (void)getAnnotationsAtPosition:(NSString *)position {
    [self changeConditionDic];
    //清除当前标注数组
    [_mapView removeAnnotations:_annotationArray];
    [_annotationInfoArray removeAllObjects];
    [_annotationArray removeAllObjects];
    
    //停止定位
    [_locService stopUserLocationService];
    
    [_conditionDic removeObjectForKey:@"location"];
    [_conditionDic removeObjectForKey:@"scaleLevel"];
    [_conditionDic setObject:position ? [position URLDecodedString] : @"" forKey:@"position"];
    WEAK_SELF weakSelf = self;
    [[SuiteAgent sharedInstance] getMapItemsWithFilter:_conditionDic completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items, NSString *position, NSString *locationX, NSString *locationY, NSNumber *alert, NSString *alertTitle, NSString *alertContent, NSString *total) {
        [weakSelf hideLoadingView];
        if (errorMsg) {
            
        } else {
            //To-do：根据返回的坐标重新或取消定位 locationX：搜索地址X坐标，若没有则是无定位坐标，locationY：搜索地址Y坐标，若没有则是无定位坐标
            [weakSelf.currentAnnotation setCoordinate:CLLocationCoordinate2DMake(0, 0)];
            
            if ([alert boolValue]) {
                [weakSelf showAlertViewWithTitle:alertTitle message:alertContent];
            }
            
            if (position) {
                [weakSelf.positionSearchTextField setText:position];
                self.position = position;
            }
            
            if (0 == items.count) {
                [PopupView showMessage:lang(@"MapSearchHasNoResult")];
            }
            
            //获取houseItemList
            weakSelf.houseItemList = items;
            //向地图窗口添加一组标注
            [weakSelf.annotationArray addObject:weakSelf.currentAnnotation];
            [weakSelf.annotationArray addObjectsFromArray:[weakSelf getRealAnnotations]];
            [weakSelf.mapView addAnnotations:weakSelf.annotationArray];
            
            if (locationX && locationY) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([locationY floatValue], [locationX floatValue]);
                [weakSelf.currentAnnotation setCoordinate:coordinate];
                [weakSelf.mapView setCenterCoordinate:coordinate animated:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.mapView.zoomLevel = zoomLevel;
                });
            } else {
                [weakSelf.mapView showAnnotations:[weakSelf getRealAnnotations] animated:YES];
            }
        }
    }];
}

#pragma mark - BMKMapViewDelegate

//根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        if (self.currentAnnotation == annotation) {
            //中心点标注
            BMKPinAnnotationView *centerAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentAnnotationView"];
            centerAnnotationView.image = [UIImage makeImageFromText:@"\ue60e" font:[UIFont fontWithName:fontIconName size:33] color:[UIColor room107GreenColor]];
            return centerAnnotationView;
        } else {
            //获取当前annot ation坐标 来获取houseItem
            NSInteger index = [_annotationArray indexOfObject:annotation] - 1;
            HouseListItemModel *houseItem;
            if (index < _houseItemList.count) {
                houseItem = _houseItemList[index];
            }
            //house标注点价格
            NSString *priceText = [NSString stringWithFormat:@"￥%@",houseItem.price];
            //该标注点与normal比例
            CGFloat proportion = [self getWidthWithText:priceText]/_normalWidth;
            
            UIButton *priceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [priceButton setFrame:CGRectMake(3, 3, 60 * proportion, 22)];
            [priceButton setTitle:priceText forState:UIControlStateNormal];
            [priceButton setTag:_annotationInfoArray.count];
            [priceButton.titleLabel setFont:[UIFont room107SystemFontTwo]];
            [priceButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
            [priceButton addTarget:self action:@selector(priceButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [priceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
            UIImage *originImage = [UIImage imageNamed:@"greenPaopao"];
            annotationView.image = [self OriginImage:originImage scaleToSize:CGSizeMake(originImage.size.width * proportion, originImage.size.height)];
            [annotationView addSubview:priceButton];
            
            [_annotationInfoArray addObject:@{@"annotationView":annotationView , @"button" : priceButton , @"proportion" : @(proportion)}];
            return annotationView;
        }
    }
    
    return nil;
}

//长按地图时会回调此接口
- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate {
    if (!_hasLongClick) {
        _hasLongClick = YES;
        [self showLoadingView];
        WEAK_SELF weakSelf = self;
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.bottomView.frame = CGRectMake(0, weakSelf.view.frame.size.height, weakSelf.view.frame.size.width, weakSelf.view.frame.size.width * 4 /15);
        }];
        [self getAnnotationsAtCoordinate:coordinate];
    }
}

- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [UIView animateWithDuration:kFadeInAnimation animations:^{
        [_blackLabel setAlpha:0.6];
    }];
    
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [_fadeOutTimer invalidate];
    _fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(fadeoutLabelWithDuration) userInfo:nil repeats:NO];
}

#pragma mark - MKLocationServiceDelegate
//用户位置更新后，会调用此函数 (定位成功后的回调)
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [self getAnnotationsAtCoordinate:userLocation.location.coordinate];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    SuiteSearchFromSubwayViewController *subwayViewController = [[SuiteSearchFromSubwayViewController alloc] init];
    subwayViewController.delegate = self;
    [self.navigationController pushViewController:subwayViewController animated:YES];
    
    return YES;
}

#pragma mark - SuiteSearchFromSubwayViewDelegate
-(void)suiteSearchFromSubwayShouldReturnOrSearchButton:(NSString *)position {
    [self refreshButtonTitle];
    [self mapMode];
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, self.view.frame.size.width * 4 /15);
    }];
    self.position = position;
    [_positionSearchTextField setText:position];
    [self getAnnotationsAtPosition:position];
}

- (void)suiteSearchFromSubwayShouldTappedOnTagPosition:(NSString *)tagPosition atIndex:(NSInteger)index {
    [self refreshButtonTitle];
    [self mapMode];
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, self.view.frame.size.width * 4 /15);
    }];
    self.position = tagPosition;
    [_positionSearchTextField setText:tagPosition];
    [self getAnnotationsAtPosition:tagPosition];
}

- (void)suiteSearchFromSubwayDidSelectedWithKeyword:(NSString *)keyword {
    [self refreshButtonTitle];
    [self mapMode];
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, self.view.frame.size.width * 4 /15);
    }];
    self.position = keyword;
    [_positionSearchTextField setText:keyword];
    [self getAnnotationsAtPosition:keyword];
}

//右侧点击按钮
- (IBAction)rightBarButtonDidClick:(id)sender {
    if (_changeConditionButton && _changeConditionButton.hidden) {
        //搜索按钮
        if ([_positionSearchTextField.text isEmpty]) {
            [PopupView showMessage:lang(@"PositionIsEmpty")];
            return;
        }
        [self refreshButtonTitle];
        [UIView animateWithDuration:0.5 animations:^{
            self.bottomView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, self.view.frame.size.width * 4 /15);
        }];
        [self getAnnotationsAtPosition:self.position];
        [self mapMode];
    } else {
        NSMutableDictionary *filter = [[NSMutableDictionary alloc] init];;
        [filter setObject:_conditionDic[@"position"] ? _conditionDic[@"position"] : @"" forKey:@"position"];
        [filter setObject:_conditionDic[@"gender"] ? _conditionDic[@"gender"] : [CommonFuncs requiredGender:0]  forKey:@"gender"];
        [filter setObject:_conditionDic[@"rentType"] ? _conditionDic[@"rentType"] : [CommonFuncs rentTypeConvert:0]  forKey:@"rentType"];
        [filter setObject:_conditionDic[@"minPrice"] ? _conditionDic[@"minPrice"] : @0 forKey:@"minPrice"];
        [filter setObject:_conditionDic[@"maxPrice"] ? _conditionDic[@"maxPrice"] : @10000 forKey:@"maxPrice"];
        [filter setObject:_conditionDic[@"roomNumber"] ? _conditionDic[@"roomNumber"] : @0 forKey:@"roomNumber"];
        
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
}

- (void)refreshButtonTitle {
    NSString *conditionContent = lang(@"AllHouse");
    if (_genderPickerComponentTableViewCell) {
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
    }
    [_changeConditionButton setTitle:[NSString stringWithFormat:@"%@ : %@", lang(@"ChangeSearchCondition"), [conditionContent isEqualToString:lang(@"AllHouse")] ? conditionContent : [conditionContent stringByAppendingString:@"..."]] forState:UIControlStateNormal];
}

//bottomView点击方法
- (void)tapClick {
    HouseDetailViewController *houseDetailViewController = [[HouseDetailViewController alloc] init];
    if (_currentIndex < _houseItemList.count) {
        [houseDetailViewController setItem:_houseItemList[_currentIndex]];
        houseDetailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:houseDetailViewController animated:YES];
    }
}

//更改搜索条件 下拉
- (void)changeCondition {
    [self searchMode];
}

//取消搜索条件
- (void)leftBarButtonDidClick {
    [self mapMode];
    [self refreshTableView];
}

//刷新筛选条件各项值
- (void)refreshTableView {
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
}

//定位失败获取默认点坐标
- (CLLocationCoordinate2D)getDefaulPosition {
    AppPropertiesModel *property = [[SystemAgent sharedInstance] getPropertiesFromLocal];
    NSString *coordinateString = defaultMapSearchPosition;
    if (!property) {
        [[SystemAgent sharedInstance] getPopupPropertiesFromServer];
    } else {
        coordinateString = property.defaultMapSearchPosition ? property.defaultMapSearchPosition : @"";
    }
    NSArray *coordinateArray = [coordinateString componentsSeparatedByString:@","];
    CLLocationDegrees latitude = 39.99878;
    CLLocationDegrees longitude = 116.316307;
    if (coordinateArray.count > 1) {
        latitude = [coordinateArray[1] floatValue];
        longitude = [coordinateArray[0] floatValue];
    }
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    return coordinate;
}

//标注点击方法
- (IBAction)priceButtonDidClick:(id)sender {
    UIButton *senderButton = (UIButton *)sender;
    for (NSDictionary *dic in _annotationInfoArray) {
        UIButton *button = dic[@"button"];
        CGFloat proportion = [dic[@"proportion"] floatValue];
        if (senderButton == button) {
            senderButton.selected = !senderButton.selected;
            UIImage *originImage = [UIImage imageNamed:senderButton.selected ? @"yellowPaopao" : @"greenPaopao"];
            BMKPinAnnotationView *annotationView = dic[@"annotationView"];
            [annotationView setImage:[self OriginImage:originImage scaleToSize:CGSizeMake(originImage.size.width * proportion, originImage.size.height)]];
        } else {
            button.selected = NO;
            UIImage *originImage = [UIImage imageNamed:@"greenPaopao"];
            BMKPinAnnotationView *annotationView = dic[@"annotationView"];
            [annotationView setImage:[self OriginImage:originImage scaleToSize:CGSizeMake(originImage.size.width * proportion, originImage.size.height)]];
        }
    }
    //获取当前按钮下的房屋信息
    if (senderButton.tag < _houseItemList.count) {
        HouseListItemModel *houseItem = _houseItemList[senderButton.tag];
        if (senderButton.selected) {
            self.currentIndex = senderButton.tag;
            [UIView animateWithDuration:0.5 animations:^{
                [self.bottomView setItem:houseItem];
                self.bottomView.frame = CGRectMake(0, self.view.frame.size.height - self.view.frame.size.width * 4 /15, self.view.frame.size.width, self.view.frame.size.width * 4 /15);
            }];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                self.bottomView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, self.view.frame.size.width * 4 /15);
            }];
        }
    }
}

- (CGFloat)getWidthWithText:(NSString *)text {
    CGRect contentRect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 22) options:NSStringDrawingUsesLineFragmentOrigin attributes:[self getAttributes] context:nil];
    return contentRect.size.width;
}

- (NSDictionary *)getAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont room107SystemFontTwo],NSParagraphStyleAttributeName:paragraphStyle};
    return attributes;
}

- (NSAttributedString *)attributesStringWithText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text ? text : @"" attributes:[self getAttributes]];
}

- (UIImage*)OriginImage:(UIImage *)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

- (void)fadeoutLabelWithDuration {
    [UIView animateWithDuration:kFadeOutAnimation animations:^{
        [_blackLabel setAlpha:0];
    }completion:^(BOOL finished) {
        [_fadeOutTimer invalidate];
        _fadeOutTimer = nil;
    }];
}

@end


