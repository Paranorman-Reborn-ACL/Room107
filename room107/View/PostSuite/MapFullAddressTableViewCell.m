//
//  MapFullAddressTableViewCell.m
//  room107
//
//  Created by 107间 on 16/4/26.
//  Copyright © 2016年 107room. All rights reserved.
//
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "MapFullAddressTableViewCell.h"
#import "CustomTextField.h"   //地址输入框
#import "CustomImageView.h"   //头像地图
#import "CommonFuncs.h"
#import "UIImage+Room107.h"
#import "UIImageView+WebCache.h"

static CGFloat zoomLevel = 13.0f;  //保证头像显示完全所定的缩放级别

@interface MapFullAddressTableViewCell()<UITextFieldDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) CustomTextField *fullAddressTextField;
@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) CustomImageView *annotationImage;
@property (nonatomic, strong) NSMutableArray *annotationArray;
@property (nonatomic, strong) NSMutableArray *imageURLArray;
@property (nonatomic, strong) UILabel *countOfSubscriberLabel;
@property (nonatomic, strong) void (^addressDidBeginEditingHandlerBlock)();
@property (nonatomic, strong) void (^addressDidEndEditingHandlerBlock)(NSString *text);
@property (nonatomic, strong) BMKGeoCodeSearch *searcher;

@end

@implementation MapFullAddressTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        self.fullAddressTextField = [[CustomTextField alloc] initWithFrame:CGRectMake([self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], 60)];
        [_fullAddressTextField setPlaceholder:lang(@"InputRegion")];
        _fullAddressTextField.delegate = self;
        [_fullAddressTextField setLeftViewWidth:22];
        [self.contentView addSubview:_fullAddressTextField];
        
        originY = CGRectGetMaxY(_fullAddressTextField.frame) + 22;
        CGFloat mapViewWidth = CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX];
        CGFloat mapViewHeight = mapViewWidth * 9/16;
        
        self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake([self originLeftX], originY, mapViewWidth, mapViewHeight)];
        _mapView.zoomLevel = zoomLevel;
        _mapView.minZoomLevel = 3.0f;
        _mapView.maxZoomLevel = 19.0f;
        _mapView.delegate = self;
        [_mapView setMapType:BMKMapTypeStandard];
        _mapView.gesturesEnabled = NO;
        [self.contentView addSubview:_mapView];
        
        self.annotationImage = [[CustomImageView alloc] initWithFrame:CGRectMake([self originLeftX] + mapViewWidth/2 - 11, originY + mapViewHeight/2 - 11, 22, 22)];
        [_annotationImage setImage:[UIImage makeImageFromText:@"\ue60e" font:[UIFont room107FontTwo] color:[UIColor room107GreenColor]]];
        [_annotationImage setHidden:YES];
        [self.contentView addSubview:_annotationImage];
        
        originY = CGRectGetMaxY(_mapView.frame) + 15;
        self.countOfSubscriberLabel = [[UILabel alloc] initWithFrame:CGRectMake([self originLeftX], originY, mapViewWidth, 30)];
        [self.contentView addSubview:_countOfSubscriberLabel];
        
        self.annotationArray = [NSMutableArray array];
        self.imageURLArray = [NSMutableArray array];
        
        //初始化检索对象
        self.searcher = [[BMKGeoCodeSearch alloc] init];
        _searcher.delegate = self;
        
    };
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 300);
}

- (void)setPosition:(NSString *)position {
    [_fullAddressTextField setText:position];
}

- (NSString *)position {
    return _fullAddressTextField.text;
}

- (void)setAddressDidBeginEditingHandler:(void(^)())handler {
    _addressDidBeginEditingHandlerBlock = handler;
}

- (void)setTextFieldDidEndEditingHandler:(void (^)(NSString *text))handler {
    self.addressDidEndEditingHandlerBlock = handler;
    [self setCountOfSubscriber:@"0"];
}

- (void)setCountOfSubscriber:(NSString *)count {
    NSString *countOfSubscriber = [count ? count : @"0" stringByAppendingString:lang(@"CountOfSubscriberPush")];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:countOfSubscriber];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFive] range:NSMakeRange(0, countOfSubscriber.length - lang(@"CountOfSubscriberPush").length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107YellowColor] range:NSMakeRange(0, countOfSubscriber.length - lang(@"CountOfSubscriberPush").length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontThree] range:NSMakeRange(countOfSubscriber.length - lang(@"CountOfSubscriberPush").length, lang(@"CountOfSubscriberPush").length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GrayColorD] range:NSMakeRange(countOfSubscriber.length - lang(@"CountOfSubscriberPush").length, lang(@"CountOfSubscriberPush").length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    [_countOfSubscriberLabel setAttributedText:attributedString];
}

- (void)setImageURLwithMarkers:(NSArray *)markers andLocationX:(NSNumber *)locationX andLocationY:(NSNumber *)locationY{
    [_mapView removeAnnotations:_annotationArray];
    [_imageURLArray removeAllObjects];
    [_annotationArray removeAllObjects];
    if (markers && markers.count >0) {
        for (NSDictionary *dic in markers) {
            NSNumber *locationX = dic[@"locationX"];
            NSNumber *locationY = dic[@"locationY"];
            NSString *url = dic[@"favicon"];
            
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
            CLLocationCoordinate2D cooridnate = CLLocationCoordinate2DMake([locationY floatValue], [locationX floatValue]);
            [annotation setCoordinate:cooridnate];
            
            [_annotationArray addObject:annotation];
            [_imageURLArray addObject:url];
        }
    }
    [_mapView addAnnotations:_annotationArray];
    CLLocationCoordinate2D cooridnate = CLLocationCoordinate2DMake([locationY floatValue], [locationX floatValue]);
    [_mapView setCenterCoordinate:cooridnate animated:YES];
    [_annotationImage setHidden:NO];
}

#pragma mark - BMKMapViewDelegate
//根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        NSInteger index = [_annotationArray indexOfObject:annotation];
        NSString *urlString;
        if (index < _imageURLArray.count) {
            urlString = _imageURLArray[index];
        }
        CustomImageView *faviconImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [faviconImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"unloginlogo"]];
        [faviconImageView setCornerRadius:22];
        [faviconImageView setBorderWidth:1 borderColor:[UIColor whiteColor]];
        
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        [annotationView addSubview:faviconImageView];
        return annotationView;
    }
    return nil;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (_addressDidBeginEditingHandlerBlock) {
        _addressDidBeginEditingHandlerBlock();
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_addressDidEndEditingHandlerBlock) {
        _addressDidEndEditingHandlerBlock(textField.text);
    }
}

- (void)dealloc {
    _mapView.delegate = nil;
    _searcher.delegate = nil;
}

+ (CGFloat)getmapFullAddressTableViewCellHeight {
    CGFloat originY = 30;
    originY += 60 + 22;
    CGFloat mapViewWidth = [[UIScreen mainScreen] bounds].size.width- 2 * 22;
    CGFloat mapViewHeight = mapViewWidth * 9/16;
    originY += mapViewHeight + 15;
    originY += 55;
    return originY;
}

@end
