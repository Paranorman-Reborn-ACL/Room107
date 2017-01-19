//
//  ProofOfLeaseQualificationsViewController.m
//  room107
//
//  Created by ningxia on 15/10/21.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "ProofOfLeaseQualificationsViewController.h"
#import "DZNSegmentedControl.h"
#import "UIScrollView+DZNSegmentedControl.h"
#import "ProofOfLeaseQualificationsView.h"

@interface ProofOfLeaseQualificationsViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DZNSegmentedControl *segmentedControl;
@property (nonatomic, strong) ProofOfLeaseQualificationsView *housePermitView;
@property (nonatomic, strong) ProofOfLeaseQualificationsView *houseContractView;

@end

@implementation ProofOfLeaseQualificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:[lang(@"ProofOfLeaseQualifications") stringByAppendingString:lang(@"Sample")]];
    [self createTopView];
}

- (void)createTopView {
    CGFloat originY = 0;
    CGRect frame = self.view.frame;
    frame.origin.y = originY;
    frame.size.height = [self heightOfSegmentedControl];
    
    self.segmentedControl = [[DZNSegmentedControl alloc] initWithFrame:frame];
    self.segmentedControl.items = @[lang(@"HousePermit"), lang(@"HouseContract")];
    self.segmentedControl.showsCount = NO;
    self.segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
    [self.segmentedControl setTintColor:[UIColor room107GreenColor]];
    [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateNormal];
    [self.segmentedControl setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateDisabled];
    [self.view addSubview:_segmentedControl];
    
    originY += CGRectGetHeight(_segmentedControl.bounds);
    frame = self.view.frame;
    frame.origin.y = originY;
    frame.size.height -= statusBarHeight + navigationBarHeight + frame.origin.y;
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
            if (!_housePermitView) {
                _housePermitView = [[ProofOfLeaseQualificationsView alloc] initWithFrame:frame andTitle:lang(@"HousePermitTips") andImageName:@"housePermit.jpg"];
                [self.scrollView addSubview:_housePermitView];
            }
        } else {
            if (!_houseContractView) {
                _houseContractView = [[ProofOfLeaseQualificationsView alloc] initWithFrame:frame andTitle:lang(@"HouseContractTips") andImageName:@"houseContract.jpg"];
                [self.scrollView addSubview:_houseContractView];
            }
        }
        
        originX += CGRectGetWidth(frame);
    }];
    
    self.scrollView.contentSize = CGSizeMake(originX, self.scrollView.frame.size.height);
}

- (void)dealloc {
    if (_scrollView.segmentedControl) {
        //判断contentOffsetKey是否被注册
        [_scrollView removeObserver:_scrollView forKeyPath:contentOffsetKey];
    }
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
