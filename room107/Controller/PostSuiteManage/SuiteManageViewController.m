//
//  SuiteManageViewController.m
//  room107
//
//  Created by ningxia on 15/8/28.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteManageViewController.h"
#import "DZNSegmentedControl.h"
#import "UIScrollView+DZNSegmentedControl.h"
#import "HouseInfoManageViewController.h"
#import "RoomInfoManageViewController.h"
#import "HouseManageAgent.h"

@interface SuiteManageViewController ()<DZNSegmentedControlDelegate>

@property (nonatomic, strong) NSNumber *houseID;
@property (nonatomic, strong) NSNumber *roomID;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DZNSegmentedControl *segmentedControl;
@property (nonatomic, strong) NSString *imageToken;
@property (nonatomic, strong) NSString *imageKeyPattern;
@property (nonatomic, strong) NSMutableDictionary *houseJSON;//描述房子信息（不含房子信息），json格式，json对应的数据结构为LandlordSuiteItem，json整体进行urlEncode
@property (nonatomic, strong) HouseInfoManageViewController *houseInfoManageViewController;
@property (nonatomic, strong) RoomInfoManageViewController *roomInfoManageViewController;

@end

@implementation SuiteManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"ModifyInfo")];
    [self getSuiteInfo];
}

- (id)initWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID {
    self = [super init];
    if (self != nil) {
        _houseID = houseID;
        _roomID = roomID;
    }
    
    return self;
}

/*
 URLParams:{
 houseId = 15515;
 roomId = 6515;
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
    _houseID = URLParams[@"houseId"];
    _roomID = URLParams[@"roomId"];
}

- (void)getSuiteInfo {
    [self showLoadingView];
    [[HouseManageAgent sharedInstance] manageHouseStatusWithHouseID:_houseID andRoomID:_roomID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *imageToken, NSString *imageKeyPattern, NSMutableDictionary *houseJSON) {
        [self hideLoadingView];
        //删除从服务器请求回来的 offlinePrice && onlinePrice 字段数据
        [houseJSON removeObjectForKey:@"offlinePrice"];
        [houseJSON removeObjectForKey:@"onlinePrice"];
        
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            _imageToken = imageToken;
            _imageKeyPattern = imageKeyPattern;
            _houseJSON = houseJSON;
            
            [self createTopView];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
            
            if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                    [self getSuiteInfo];
                }];
            } else {
                
                [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                    [self getSuiteInfo];
                }];
            }
        }
    }];
}

- (void)createTopView {
    CGFloat originY = 0;
    CGRect frame = self.view.frame;
    frame.origin.y = originY;
    frame.size.height = [self heightOfSegmentedControl];
    
    self.segmentedControl = [[DZNSegmentedControl alloc] initWithFrame:frame];
    self.segmentedControl.items = @[lang(@"HouseInfo"), lang(@"RoomInfo")];
    self.segmentedControl.showsCount = NO;
    self.segmentedControl.delegate = self;
    self.segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
    [self.segmentedControl setTintColor:[UIColor room107GreenColor]];
    [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateNormal];
    [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateDisabled];
    [self.view addSubview:_segmentedControl];
    
    originY += CGRectGetHeight(_segmentedControl.bounds);
    
    frame = self.view.frame;
    frame.origin.y = originY;
    frame.size.height -= frame.origin.y;
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES; //支持左右滑动时segmentedControl跟着一起走
    self.scrollView.segmentedControl = self.segmentedControl;
    [self.view addSubview:_scrollView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    __block CGFloat originX = 0.0;
    
    [self.segmentedControl.items enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = originX;
        frame.origin.y = 0.5;
        
        if (idx == 0) {
            if (!_houseInfoManageViewController) {
                _houseInfoManageViewController = [[HouseInfoManageViewController alloc] initWithImageToken:_imageToken andImageKeyPattern:_imageKeyPattern andHouseJSON:_houseJSON];
                [_houseInfoManageViewController setNavigationController:self.navigationController];
                _houseInfoManageViewController.view.frame = frame;
                [self.scrollView addSubview:_houseInfoManageViewController.view];
            }
        } else {
            if (!_roomInfoManageViewController) {
                _roomInfoManageViewController = [[RoomInfoManageViewController alloc] initWithImageToken:_imageToken andImageKeyPattern:_imageKeyPattern andHouseJSON:_houseJSON];
                [_roomInfoManageViewController setNavigationController:self.navigationController];
                _roomInfoManageViewController.view.frame = frame;
                [self.scrollView addSubview:_roomInfoManageViewController.view];
            }
        }
        
        originX += CGRectGetWidth(frame);
    }];
    
    self.scrollView.contentSize = CGSizeMake(originX, self.scrollView.frame.size.height);
    [self.segmentedControl setSelectedSegmentIndex:_roomID ? 1 : 0];
    CGRect frame = _scrollView.frame;
    frame.origin.x = (_roomID ? 1 : 0) * frame.size.width;
    [self.scrollView scrollRectToVisible:frame animated:NO];
}

- (IBAction)leftButtonDidClick:(id)sender {
    WEAK_SELF weakSelf = self;
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [_houseInfoManageViewController setViewControllerDismissHandler:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [_roomInfoManageViewController setViewControllerDismissHandler:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (_scrollView.segmentedControl) {
        //判断contentOffsetKey是否被注册
        [_scrollView removeObserver:_scrollView forKeyPath:contentOffsetKey];
    }
}

- (void)selectedSegmentIndexChanged:(DZNSegmentedControl *)DZNSegmentedControl {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [self.view endEditing:YES];    });
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
