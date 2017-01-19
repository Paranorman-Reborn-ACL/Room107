//
//  HouseLandlordUpdateCoverViewController.m
//  room107
//
//  Created by ningxia on 16/4/27.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "HouseLandlordUpdateCoverViewController.h"
#import "SelectPhotosCollectionViewCell.h"
#import "HouseManageAgent.h"

static NSString *selectPhotosCollectionViewCellIdentifier = @"SelectPhotosCollectionViewCell";

@interface HouseLandlordUpdateCoverViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSNumber *houseID;
@property (nonatomic, strong) NSNumber *roomID;
@property (nonatomic, strong) NSMutableArray *houseImages;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HouseLandlordUpdateCoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"SelectPhotos")];
    [self getHouseImages];
}

- (id)initWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID {
    self = [super init];
    if (self != nil) {
        _houseID = houseID;
        _roomID = roomID;
    }
    
    return self;
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected=%@", @1]; //实现数组的快速查询
    NSArray *filteredArray = [_houseImages filteredArrayUsingPredicate:predicate];
    if (filteredArray.count > 0) {
        [self showLoadingView];
        WEAK_SELF weakSelf = self;
        [[HouseManageAgent sharedInstance] updateHouseCoverWithHouseID:_houseID andRoomID:_roomID andImageURL:filteredArray[0][@"imageUrl"] completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
            [weakSelf hideLoadingView];
            
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
            }
            
            //网络请求有数据
            if (!errorCode) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

- (void)getHouseImages {
    [self showLoadingView];
    WEAK_SELF weakSelf = self;
    [[HouseManageAgent sharedInstance] getHouseImagesWithHouseID:_houseID andRoomID:_roomID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *imageIds, NSString *cover) {
        [weakSelf hideLoadingView];
        [weakSelf createCollectionView];
        
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        
        //网络请求有数据
        if (!errorCode) {
            [weakSelf hideNetworkFailedImageView];
            
            if (imageIds.count == 0) {
                [self showAlertViewWithTitle:lang(@"NoOptionalImage") message:nil];
                return;
            }
            [weakSelf imagesDataConvert:imageIds];
            [weakSelf.collectionView reloadData];
        } else {
            //网络请求失败
            if (weakSelf.collectionView) {
                //不是第一次进入 从自页面返回  无蛙 无提示 无阻隔
            } else {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [weakSelf showNetworkFailedWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf getHouseImages];
                    }];
                } else {
                    [weakSelf showUnknownErrorWithFrame:weakSelf.view.frame andRefreshHandler:^{
                        [weakSelf getHouseImages];
                    }];
                }
            }
        }
    }];
}

- (void)imagesDataConvert:(NSArray *)imageIds {
    _houseImages = [[NSMutableArray alloc] init];
    
    for (NSString *imageId in imageIds) {
        [_houseImages addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:imageId ? imageId : @"", @"imageUrl", nil]];
    }
}

- (void)createCollectionView {
    if (!_collectionView) {
        CGFloat spaceX = 5;
        CGFloat spaceY = 5;
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(spaceY, spaceX, spaceY, spaceX);
        collectionViewLayout.minimumInteritemSpacing = 2; //item之间的间隔
        collectionViewLayout.minimumLineSpacing = 2; //每一行之间的间隔
        CGFloat itemWidth = ([[UIScreen mainScreen] bounds].size.width - spaceX * 2 - collectionViewLayout.minimumInteritemSpacing * 2) / 3;
        collectionViewLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:collectionViewLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[SelectPhotosCollectionViewCell class] forCellWithReuseIdentifier:selectPhotosCollectionViewCellIdentifier];
        [_collectionView setCollectionViewLayout:collectionViewLayout];
        [self.view addSubview:_collectionView];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _houseImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_houseImages.count > indexPath.row) {
        //避免数组越界
        SelectPhotosCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:selectPhotosCollectionViewCellIdentifier forIndexPath:indexPath];
        [cell setPhotoDataDictionary:_houseImages[indexPath.row]];
        
        return cell;
    }
    
    return [SelectPhotosCollectionViewCell new];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_houseImages.count > indexPath.row) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected=%@", @1]; //实现数组的快速查询
        NSArray *filteredArray = [_houseImages filteredArrayUsingPredicate:predicate];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        if (filteredArray.count > 0) {
            NSUInteger index = [_houseImages indexOfObject:filteredArray[0]];
            if (index == indexPath.row) {
                return;
            }
            [filteredArray[0] setObject:@0 forKey:@"selected"];
            [indexPaths addObject:[NSIndexPath indexPathForItem:index < _houseImages.count ? index : 0 inSection:0]];
        }
        
        [_houseImages[indexPath.row] setObject:@1 forKey:@"selected"];
        [indexPaths addObject:indexPath];
        [_collectionView reloadItemsAtIndexPaths:indexPaths];
        
        [self setRightBarButtonTitle:lang(@"Confirm")];
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
