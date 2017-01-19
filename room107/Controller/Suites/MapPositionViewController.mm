//
//  MapPositionViewController.m
//  room107
//
//  Created by ningxia on 15/7/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "MapPositionViewController.h"
#import "CustomRoundButton.h"
#import "BottomSurroundingCollectionViewCell.h"

static NSTimeInterval delayTime = 0.8f;

@interface MapPositionViewController () <BMKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, BMKPoiSearchDelegate>

@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *position;
@property (nonatomic, strong) BMKPointAnnotation *currentAnnotation;
@property (nonatomic, strong) BMKPoiSearch *searcher;
@property (nonatomic, strong) UICollectionView *bottomSurroundingCollectionView;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, strong) NSMutableArray *surroundingArray;
@property (nonatomic, strong) NSArray *iconArray;
@property (nonatomic, strong) NSArray *textArray;

@end

@implementation MapPositionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createMapView];
    [self creatBottomSurrounding];
    self.surroundingArray = [[NSMutableArray alloc] init];
    self.iconArray = @[@"\ue660", @"\ue661", @"\ue662", @"\ue663", @"\ue664", @"\ue665", @"\ue666", @"\ue65f"];
    self.textArray = @[lang(@"Bus"), lang(@"Subway"), lang(@"Restaurant"), lang(@"Shop"), lang(@"Movie"), lang(@"SuperMarket"), lang(@"Bank"), lang(@"Hospital")];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _searcher.delegate = nil;
}

//设置当前点经纬度
- (void)setCoordinate:(CLLocationCoordinate2D)coor position:(NSString *)pos {
    _coordinate = coor;
    _position = pos;
}
//创建地图
- (void)createMapView {
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.frame];
    _mapView.minZoomLevel = 3.0f;
    _mapView.maxZoomLevel = 19.0f;
    [_mapView setMapType:BMKMapTypeStandard];
    [self.view addSubview:_mapView];
    
    self.searcher = [[BMKPoiSearch alloc] init];
    _searcher.delegate = self;
}

- (void)creatBottomSurrounding {
    CGFloat height = 65;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.itemSize = CGSizeMake(22, 65);
    flowLayout.minimumInteritemSpacing = 33.0f;
    flowLayout.minimumLineSpacing = 33.0f;
    self.bottomSurroundingCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height) collectionViewLayout:flowLayout];
    _bottomSurroundingCollectionView.delegate = self ;
    _bottomSurroundingCollectionView.dataSource = self ;
    _bottomSurroundingCollectionView.showsHorizontalScrollIndicator = NO;
    _bottomSurroundingCollectionView.bouncesZoom = NO;
    _bottomSurroundingCollectionView.contentInset = UIEdgeInsetsMake(0, 11, 0, 11);
    _bottomSurroundingCollectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [_bottomSurroundingCollectionView registerClass:[BottomSurroundingCollectionViewCell class] forCellWithReuseIdentifier:@"myCell"];
    [self.view addSubview:_bottomSurroundingCollectionView];
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"myCell";
    BottomSurroundingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    [cell setIcon:_iconArray[indexPath.row] text:_textArray[indexPath.row]];
    if (indexPath == _lastIndexPath ) {
        [cell setCellSelected];
    } else {
        [cell setCellDeSelected];
    }
    return cell;
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.mapView setCenterCoordinate:_coordinate animated:YES];
    if (indexPath != _lastIndexPath) {
        BottomSurroundingCollectionViewCell *lastCell = (BottomSurroundingCollectionViewCell *)[collectionView cellForItemAtIndexPath:_lastIndexPath];
        [lastCell setCellDeSelected];
        BottomSurroundingCollectionViewCell *cell = (BottomSurroundingCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell setCellSelected];
        _lastIndexPath = indexPath;
        [self cheakSurroundingPlaceWithText:self.textArray[indexPath.row]];
    }
}

/**
 *地图初始化完毕时会调用此接口
 *@param mapview 地图View
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    [self.mapView setCenterCoordinate:_coordinate];
#pragma mark - 设置地图点和设置地图缩放级别有冲突  注意执行顺序：1.先设置地图中心点 2.再设置地图缩放级别 3.设置标注点
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView setZoomLevel:[CommonFuncs mapZoomLevel]];
    });
    
    self.currentAnnotation = [[BMKPointAnnotation alloc] init];
    _currentAnnotation.coordinate = _coordinate;
    _currentAnnotation.title = _position;
    [self.mapView addAnnotation:_currentAnnotation];
    [self setHeaderType:HeaderTypeGreenBack];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        //当前的地点标注位置
        if (annotation == _currentAnnotation) {
            UILabel *positionLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 100, 40}];
            [positionLabel setNumberOfLines:0];
            [positionLabel setBackgroundColor:[UIColor blackColor]];
            [positionLabel setTextColor:[UIColor whiteColor]];
            [positionLabel setTextAlignment:NSTextAlignmentCenter];
            positionLabel.alpha = 0.5;
            positionLabel.layer.cornerRadius = 5.0f;
            positionLabel.layer.masksToBounds = YES;
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:annotation.title ? annotation.title : @""];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontThree] range:NSMakeRange(0, attributedString.length)];
            [positionLabel setAttributedText:attributedString];
            CGFloat originX = 22;
            [positionLabel setFrame:(CGRect){positionLabel.frame.origin, MIN(attributedString.size.width + 20, CGRectGetWidth(self.view.bounds) - 2 * originX), attributedString.size.width > (CGRectGetWidth(self.view.bounds) - 2 * originX) ? 2 * (attributedString.size.height + 20) : attributedString.size.height + 20}];
            
            BMKActionPaopaoView *newPaopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:positionLabel];
            BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
            annotationView.image = [UIImage makeImageFromText:@"\ue60e" font:[UIFont fontWithName:fontIconName size:33] color:[UIColor room107GreenColor]];
            [annotationView setSelected:YES];
            annotationView.paopaoView = newPaopaoView;
            
            return annotationView;
        } else {
            //附近场所标注点
            BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
            annotationView.image = [UIImage makeImageFromText:@"\ue667" font:[UIFont fontWithName:fontIconName size:33] color:[UIColor room107YellowColor]];
            annotationView.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[self getPatchImageViewWithName:annotation.title andAddress:annotation.subtitle]];
            return annotationView;
        }
    }
    
    return nil;
}

- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error {
    // 清楚屏幕中所有的annotation
    [_mapView removeAnnotations:_surroundingArray];
    [_surroundingArray removeAllObjects];
    if (error == BMK_SEARCH_NO_ERROR) {
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            item.subtitle = poi.address;
            [_surroundingArray addObject:item];
        }
        [_mapView addAnnotations:_surroundingArray];
        [_mapView showAnnotations:_surroundingArray animated:YES];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
//        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }
}

//检索周边场所
- (void)cheakSurroundingPlaceWithText:(NSString *)keyWord {
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex = 0;
    option.pageCapacity = 20;
    option.radius = 2000;
    option.location = _coordinate;
    option.keyword = keyWord;
    BOOL flag = [_searcher poiSearchNearBy:option];
    if (flag) {
//        NSLog(@"周边检索发送成功");
    } else {
//        NSLog(@"周边检索发送失败");
    }
}

//获得拉伸后的paopao图片
- (UIView *)getPatchImageViewWithName:(NSString *)name andAddress:(NSString *)address {
    UILabel *nameLabel = [[UILabel alloc] init];
    [nameLabel setText:name];
    [nameLabel setTextColor:[UIColor room107GrayColorE]];
    [nameLabel setFont:[UIFont room107SystemFontThree]];
    [nameLabel sizeToFit];
    [nameLabel setFrame:CGRectMake(11, 11, nameLabel.frame.size.width > 200 ? 200 : nameLabel.frame.size.width, nameLabel.frame.size.height)];

    UILabel *addressLabel = [[UILabel alloc] init];
    [addressLabel setText:address];
    [addressLabel setTextColor:[UIColor room107GrayColorD]];
    [addressLabel setFont:[UIFont room107SystemFontOne]];
    [addressLabel sizeToFit];
    [addressLabel setFrame:CGRectMake(11, CGRectGetMaxY(nameLabel.frame) + 2 , addressLabel.frame.size.width > 250 ? 250 : addressLabel.frame.size.width, addressLabel.frame.size.height)];
    
    CGFloat maxWidth = addressLabel.frame.size.width > nameLabel.frame.size.width ? addressLabel.frame.size.width : nameLabel.frame.size.width ;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth + 22 , CGRectGetMaxY(addressLabel.frame) + 22)];
    UIImage *image = [UIImage imageNamed:@"9patch"];
    UIEdgeInsets insets = UIEdgeInsetsMake(62, 167, 62, 167);
    imageView.image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];    
    [imageView addSubview:nameLabel];
    [imageView addSubview:addressLabel];
    return imageView;
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
