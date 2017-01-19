//
//  HouseLandlordListViewController.m
//  room107
//
//  Created by ningxia on 16/4/21.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "HouseLandlordListViewController.h"
#import "SuiteAgent.h"
#import "HouseLandlordListCardScaleFlowLayout.h"
#import "HouseLandlordListCollectionViewCell.h"
#import "AddHouseCollectionViewCell.h"
#import "LandlordHouseInfoView.h"
#import "SearchTipLabel.h"
#import "HouseLandlordDetailViewController.h"
#import "NSString+Encoded.h"

static NSString *houseLandlordListCollectionViewCellIdentifier = @"HouseLandlordListCollectionViewCell";
static NSString *addHouseCollectionViewCellIdentifier = @"AddHouseCollectionViewCell";

@interface HouseLandlordListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) BOOL addHouseFlag; //是否为发房成功后的跳转
@property (nonatomic, strong) NSMutableArray *postItems;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LandlordHouseInfoView *landlordHouseInfoView;
@property (nonatomic, strong) SearchTipLabel *addHouseExplanationLabel;
@property (nonatomic) int currentIndex;

@end

@implementation HouseLandlordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"PostSuiteManage")];
    [self setRightBarButtonTitle:lang(@"LandlordExplanation")];
    _currentIndex = -1;
}

- (id)initWithAddHouseFlag:(BOOL)flag {
    self = [super init];
    if (self != nil) {
        _addHouseFlag = flag;
    }
    
    return self;
}

- (void)setAddHouseFlag:(BOOL)flag {
    _addHouseFlag = flag;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getLandlordHouseList];
}

- (void)createHouseInfoView {
    if (!_collectionView) {
        HouseLandlordListCardScaleFlowLayout *collectionViewLayout = [[HouseLandlordListCardScaleFlowLayout alloc] init];
        
        CGRect frame = (CGRect){0, 0, self.view.frame.size};
        frame.size.height = [CommonFuncs houseLandlordListCollectionViewCellSize].height + 22 * 2;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[HouseLandlordListCollectionViewCell class] forCellWithReuseIdentifier:houseLandlordListCollectionViewCellIdentifier];
        [_collectionView registerClass:[AddHouseCollectionViewCell class] forCellWithReuseIdentifier:addHouseCollectionViewCellIdentifier];
        [_collectionView setCollectionViewLayout:collectionViewLayout];
        [self.view addSubview:_collectionView];
    }
    
    CGFloat originX = 22;
    CGFloat originY = CGRectGetHeight(_collectionView.bounds);
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds) - 2 * originX;
    if (!_landlordHouseInfoView) {
        _landlordHouseInfoView = [[LandlordHouseInfoView alloc] initWithFrame:(CGRect){originX, originY, viewWidth, 87}];
        [self.view addSubview:_landlordHouseInfoView];
        _landlordHouseInfoView.hidden = YES;
    }
    
    if (!_addHouseExplanationLabel) {
        originY += 22;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 8;// 字体的行间距
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont room107SystemFontOne],
                                     NSForegroundColorAttributeName:[UIColor room107GrayColorD],
                                     NSParagraphStyleAttributeName:paragraphStyle};
        NSString *content = lang(@"PostSuiteManageExplanation");
        CGRect contentRect = [content boundingRectWithSize:(CGSize){viewWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        _addHouseExplanationLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, viewWidth, contentRect.size.height}];
        [_addHouseExplanationLabel setAttributedText:[[NSAttributedString alloc] initWithString:content attributes:attributes]];
        [self.view addSubview:_addHouseExplanationLabel];
        _addHouseExplanationLabel.hidden = YES;
    }
}

/*
 URLParams:{
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
    _addHouseFlag = NO;
}

- (void)getLandlordHouseList {
    if (!_collectionView) {
        [self showLoadingView];
    }
    
    WEAK_SELF weakSelf = self;
    [[SuiteAgent sharedInstance] getLandlordHouseList:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items) {
        [weakSelf hideLoadingView];
        [weakSelf createHouseInfoView];
        
        if ([errorCode unsignedIntegerValue]
            != unLoginCode && [errorCode unsignedIntegerValue] != unAuthenticateCode && (errorTitle || errorMsg)) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        
        //网络请求有数据
        if ([errorCode unsignedIntegerValue] == unLoginCode || [errorCode unsignedIntegerValue] == unAuthenticateCode || !errorCode) {
            [weakSelf hideNetworkFailedImageView];
            weakSelf.postItems = [NSMutableArray arrayWithArray:items];
            [weakSelf.collectionView reloadData];
            if (weakSelf.addHouseFlag && weakSelf.postItems && weakSelf.postItems.count > 0) {
                [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.postItems.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            }
        } else {
            //网络请求失败
            if (weakSelf.collectionView) {
                //不是第一次进入 从自页面返回  无蛙 无提示 无阻隔
            } else {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [weakSelf showNetworkFailedWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf getLandlordHouseList];
                    }];
                } else {
                    [weakSelf showUnknownErrorWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf getLandlordHouseList];
                    }];
                }
            }
        }
    }];
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    [self viewLandlordExplanation];
}

- (void)showHouseInfoViewWithScrollView:(UIScrollView *)scrollView {
    int itemIndex = scrollView.contentOffset.x / [CommonFuncs houseLandlordListCollectionViewCellSize].width;
    if (itemIndex > _postItems.count) {
        itemIndex -= 1;
    }
    
    if (_currentIndex == itemIndex) {
        return;
    }
    _currentIndex = itemIndex;
    if (_postItems.count > _currentIndex) {
        _landlordHouseInfoView.hidden = NO;
        _addHouseExplanationLabel.hidden = YES;
        
        NSDictionary *item = _postItems[_currentIndex];
        if (item) {
            [_landlordHouseInfoView setAlpha:0];
            [UIView animateWithDuration:0.5 animations:^{
                [_landlordHouseInfoView setAlpha:1];
            }];
            
            //houseStatus房间状态，0表示审核中，1表示审核失败，2表示对外出租，3暂不对外，4租住中
            NSArray *houseStatuses = @[lang(@"UnderReview"), lang(@"AuditFailed"), lang(@"Opening"), lang(@"CloseIn"), lang(@"BeRented")];
            [_landlordHouseInfoView setInfoDataDictionary:@{@"houseStatus":item[@"houseStatus"] ? item[@"houseStatus"] : @0, @"text":item[@"displayStatus"] ? item[@"displayStatus"] : @"", @"subtext":item[@"houseStatus"] ? houseStatuses[[item[@"houseStatus"] intValue]] : houseStatuses[0], @"pushNumber":item[@"pushNumber"] ? item[@"pushNumber"] : @0, @"viewNumber":item[@"viewNumber"] ? item[@"viewNumber"] : @0, @"interestNumber":item[@"interestNumber"] ? item[@"interestNumber"] : @0, @"requestNumber":item[@"requestNumber"] ? item[@"requestNumber"] : @0}];
        }
    } else {
        _landlordHouseInfoView.hidden = YES;
        _addHouseExplanationLabel.hidden = NO;
        [_addHouseExplanationLabel setAlpha:0];
        [UIView animateWithDuration:0.5 animations:^{
            [_addHouseExplanationLabel setAlpha:1];
        }];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [self showHouseInfoViewWithScrollView:collectionView];
    
    return _postItems.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_postItems.count > indexPath.row) {
        //避免数组越界
        HouseLandlordListCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:houseLandlordListCollectionViewCellIdentifier forIndexPath:indexPath];
        NSDictionary *item = _postItems[indexPath.row];
        NSDictionary *houseListItem = item[@"houseListItem"];
        
        NSString *imageUrl = [houseListItem[@"hasCover"] boolValue] && houseListItem[@"cover"] && houseListItem[@"cover"][@"url"] ? houseListItem[@"cover"][@"url"] : @"";
        NSString *middleText = [NSString stringWithFormat:@"￥%@", houseListItem[@"price"] ? houseListItem[@"price"] : @0];
        NSString *middleTailText = lang(@"RentHouse");
        if (![houseListItem[@"rentType"] isEqual:@2]) {
            //分租
            NSString *rentType = @""; //如果不限男女，不需要显示“不限男女”的字样
            switch ([houseListItem[@"requiredGender"] intValue]) {
                case 1:
                    rentType = lang(@"MaleLimit");
                    break;
                case 2:
                    rentType = lang(@"FemaleLimit");
                    break;
                default:
                    break;
            }
            middleTailText = [NSString stringWithFormat:@"%@ %@", houseListItem[@"name"] ? houseListItem[@"name"] : @"", rentType];
        }
        NSString *footText = [houseListItem[@"city"] stringByAppendingFormat:@" %@", houseListItem[@"position"] ? houseListItem[@"position"] : @""];
        NSString *footSubtext = [houseListItem[@"houseName"] ? houseListItem[@"houseName"] : @"" stringByAppendingFormat:@" %@ %@", houseListItem[@"area"] ? [NSString stringWithFormat:@"%@m²", houseListItem[@"area"]] : @"", houseListItem[@"floor"] ? [NSString stringWithFormat:@"%@%@", houseListItem[@"floor"], lang(@"Floor")] : @""];
        
        [cell setHouseListDataDictionary:@{@"newUpdate":item[@"newUpdate"] ? item[@"newUpdate"] : @0, @"middleText":middleText ? middleText : @"", @"middleTailText":middleTailText ? middleTailText : @"", @"footText":footText ? footText : @"", @"footSubtext":footSubtext ? footSubtext : @"", @"footSubtext":footSubtext ? footSubtext : @"", @"imageUrl":imageUrl ? imageUrl : @""}];
        
        return cell;
    } else {
        AddHouseCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:addHouseCollectionViewCellIdentifier forIndexPath:indexPath];
        
        return cell;
    }
    
    return [HouseLandlordListCollectionViewCell new];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_postItems.count > indexPath.row) {
        NSDictionary *houseListItem = _postItems[indexPath.row][@"houseListItem"];
        NSNumber *roomID = [houseListItem[@"rentType"] isEqual:@1] ? houseListItem[@"roomId"] : nil;
        HouseLandlordDetailViewController *houseLandlordDetailViewController = [[HouseLandlordDetailViewController alloc] initWithHouseID:houseListItem[@"id"] andRoomID:roomID];
        [self.navigationController pushViewController:houseLandlordDetailViewController animated:YES];
    } else {
        NSString *url = [[[AppClient sharedInstance] baseDomain] stringByAppendingString:@"/app/html/addHouse"];
        NSString *openURL = [htmlURI stringByAppendingFormat:@"?authority=login&title=%@&url=%@", [lang(@"AddHouseStep") URLEncodedString], url];
        [[NXURLHandler sharedInstance] handleOpenURL:openURL params:nil context:self];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_collectionView]) {
        [self showHouseInfoViewWithScrollView:scrollView];
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
