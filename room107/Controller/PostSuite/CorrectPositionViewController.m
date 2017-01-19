//
//  CorrectPositionViewController.m
//  room107
//
//  Created by 107间 on 16/4/19.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "CorrectPositionViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "CorrectPositionTableViewCell.h"
#import "AppPropertiesModel.h"
#import "SystemAgent.h"

static CGFloat zoomLevel = 15.0f;

@interface CorrectPositionViewController ()<UITableViewDataSource, UITableViewDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate>

@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) UITableView *positionTableView;
@property (nonatomic, strong) BMKGeoCodeSearch *searcher;
@property (nonatomic, strong) NSArray *poiListArray;
@property (nonatomic, strong) UIImageView *annotationImageView;
@property (nonatomic, strong) UILabel *blackLabel;
@property (nonatomic, strong) BMKLocationService *locService;   //定位服务


@end

@implementation CorrectPositionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"修正位置"];
    [self creatMapView];
    [self crearGeoCodeSearcher];
    [self creatPositionTableView];
    self.locService = [[BMKLocationService alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _locService.delegate = self;
    _searcher.delegate = self;
}

//不使用时将delegate设置为 nil
-(void)viewWillDisappear:(BOOL)animated {
    _searcher.delegate = nil;
    _locService.delegate = nil;
}

//创建地图
- (void)creatMapView {
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - statusBarHeight - navigationBarHeight) / 2)];
    _mapView.zoomLevel = [CommonFuncs mapZoomLevel];
    _mapView.minZoomLevel = 3.0f;
    _mapView.maxZoomLevel = 19.0f;
    _mapView.zoomLevel = zoomLevel;
    _mapView.delegate = self;
    [_mapView setMapType:BMKMapTypeStandard];
    [self.view addSubview:_mapView];
    
    self.annotationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [_annotationImageView setCenter:_mapView.center];
    [_annotationImageView setImage:[UIImage makeImageFromText:@"\ue60e" font:[UIFont room107FontOne] color:[UIColor room107GreenColor]]];
    [self.view addSubview:_annotationImageView];
}

//创建信息显示
- (void)creatPositionTableView {
    self.positionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.frame), self.view.frame.size.width, (self.view.frame.size.height - statusBarHeight - navigationBarHeight) / 2)];
    _positionTableView.delegate = self;
    _positionTableView.dataSource = self;
    [_positionTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_positionTableView];
}

//创建地理编码
- (void)crearGeoCodeSearcher {
    _searcher =[[BMKGeoCodeSearch alloc]init];
}

//发起反地理编码
- (void)beginReverseGeoCode:(CLLocationCoordinate2D)coordinate2D {
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = coordinate2D;
    BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag) {
        LogDebug(@"反geo检索发送成功");
    } else {
        LogDebug(@"反geo检索发送失败");
    }
}

//定位点动画
- (void)imageAnimate {
    [UIView animateWithDuration:0.3 animations:^{
        [_annotationImageView setCenter:CGPointMake(_annotationImageView.center.x, _annotationImageView.center.y - 10)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [_annotationImageView setCenter:CGPointMake(_annotationImageView.center.x, _annotationImageView.center.y + 10)];
        }];
    }];
}

//设置blackTitle
- (void)setBlackLabelWithText:(NSString *)text {
    NSString *labelText = [lang(@"CurrentPosition") stringByAppendingString:text];
    
    if (!_blackLabel) {
        self.blackLabel = [[UILabel alloc] init];
        [_blackLabel setTextColor:[UIColor whiteColor]];
        [_blackLabel setBackgroundColor:[UIColor blackColor]];
        _blackLabel.layer.cornerRadius = 13;
        _blackLabel.layer.masksToBounds = YES;
        [_blackLabel setFont:[UIFont room107SystemFontTwo]];
        [_blackLabel setTextAlignment:NSTextAlignmentCenter];
        [_blackLabel setAlpha:0.7];
        [self.view addSubview:_blackLabel];
    }
    CGRect contentRect = [labelText boundingRectWithSize:(CGSize){MAXFLOAT, 26} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_blackLabel.font} context:nil];
    CGFloat labelWidth = contentRect.size.width + 22;
    CGFloat originX =([UIScreen mainScreen].bounds.size.width - labelWidth) / 2;
    [_blackLabel setFrame:CGRectMake(originX, 5, labelWidth, 26)];
    [_blackLabel setText:labelText];
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
                [weakSelf beginReverseGeoCode:[weakSelf getDefaulPosition]];
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

#pragma mark - BMKMapViewDelegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    if (_text) {
        //若前一页有地址则采用地址坐标
        [self beginReverseGeoCode:mapView.centerCoordinate];
    } else {
        //否则采用定位功能
        [self checkLocServiceAndLoction];
    }
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){mapView.centerCoordinate.latitude,  mapView.centerCoordinate.longitude};
    [self beginReverseGeoCode:pt];
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        self.poiListArray = result.poiList;
        [self imageAnimate];
        [self setBlackLabelWithText:result.address];
        [_positionTableView reloadData];
    } else {
        LogDebug(@"抱歉，未找到结果");
    }
}

#pragma mark - MKLocationServiceDelegate
//用户位置更新后，会调用此函数 (定位成功后的回调)
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [_locService stopUserLocationService];
    [_mapView setCenterCoordinate:userLocation.location.coordinate];
    [self beginReverseGeoCode:userLocation.location.coordinate];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _poiListArray.count;
};

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CorrectPositionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CorrectPositionTableViewCell"];
    if (nil == cell) {
        cell = [[CorrectPositionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CorrectPositionTableViewCell"];
    }
    [cell setName:[_poiListArray[indexPath.row] name] andAddress:[_poiListArray[indexPath.row] address]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return correctPositionTableViewCellHeight;
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
