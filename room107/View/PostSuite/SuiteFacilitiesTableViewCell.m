//
//  SuiteFacilitiesTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteFacilitiesTableViewCell.h"
#import "SuiteFacilityCollectionViewCell.h"
#import "NSString+Valid.h"

static NSString *identifier = @"SuiteFacilityCollectionViewCell";

@interface SuiteFacilitiesTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *facilities;
@property (nonatomic, strong) NSArray *existFacilities;

@end

@implementation SuiteFacilitiesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        CGRect frame = [self cellFrame];
        frame.origin.y += originY;
        frame.size.height -= originY;
        
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, [self originLeftX], [self originBottomY], [self originLeftX]);
        collectionViewLayout.minimumInteritemSpacing = 11; //item之间的间隔
        collectionViewLayout.minimumLineSpacing = 11; //每一行之间的间隔
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat itemHeight = (screenWidth - 44 - 33)/4;
        collectionViewLayout.itemSize = CGSizeMake(itemHeight, itemHeight);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
        _collectionView.scrollEnabled = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[SuiteFacilityCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setCollectionViewLayout:collectionViewLayout];
        [self addSubview:_collectionView];
        
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, suiteFacilitiesTableViewCellHeight);
}
//设置全部item信息 text&&icon
- (void)setSourceFacilities:(NSArray *)sourceFacilitiesArray {
    _facilities = sourceFacilitiesArray;
}
//设置选中item数组 重绘collectionView
- (void)setSuiteFacilities:(NSString *)suiteFacilities {
    _existFacilities = [suiteFacilities getComponentsBySeparatedString:@"|"];
    [_collectionView reloadData];
}

- (NSString *)suiteFacilities {
    NSString *facilities = @"";
    
    for (NSUInteger i = 0; i < _facilities.count; i++) {
        SuiteFacilityCollectionViewCell *cell = (SuiteFacilityCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if ([cell isSelected]) {
            facilities = [facilities stringByAppendingFormat:@"|%@", _facilities[i][@"content"]];
        }
    }
    
    return facilities;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _facilities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SuiteFacilityCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell setContent:_facilities[indexPath.row]];
    
    for (NSString *facility in _existFacilities) {
        if ([facility isEqualToString:_facilities[indexPath.row][@"content"]]) {
            [cell didSelect];
            break;
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SuiteFacilityCollectionViewCell *cell = (SuiteFacilityCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    [cell didSelect];
}

@end
