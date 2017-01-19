//
//  FacilityTableViewCell.m
//  room107
//
//  Created by ningxia on 15/6/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "FacilityTableViewCell.h"
#import "ThirteenTemplateView.h"
#import "FacilityCollectionViewCell.h"

static CGFloat spaceY = 11;
static NSString *identifier = @"FacilityCollectionViewCell";

@interface FacilityTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ThirteenTemplateView *titleView;
@property (nonatomic, strong) NSArray *facilities;
@property (nonatomic, strong) NSArray *existFacilities;

@end

@implementation FacilityTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor room107GrayColorA]];
        CGFloat originY = 11;
        
        CGFloat viewWidth = CGRectGetWidth([self cellFrame]);
        CGFloat viewHeight = facilityTableViewCellHeight - originY;
        _containerView = [[UIView alloc] initWithFrame:(CGRect){0, spaceY, viewWidth, viewHeight}];
        [_containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_containerView];
        
        _titleView = [[ThirteenTemplateView alloc] initWithFrame:(CGRect){0, 0, viewWidth, 36} andTemplateDataDictionary:nil];
        [_containerView addSubview:_titleView];
        
        CGRect frame = _containerView.frame;
        frame.origin.y = CGRectGetHeight(_titleView.bounds);
        frame.size.height -= frame.origin.y;
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(originY, [self originLeftX], originY, [self originLeftX]);
        CGFloat itemWidth = (viewWidth - 2 * collectionViewLayout.sectionInset.left) / 4;
        CGFloat itemHeight = 48;
        collectionViewLayout.minimumInteritemSpacing = 0; //item之间的间隔，需要将NSUInteger赋值给collectionViewLayout.minimumInteritemSpacing，避免浮点数导致的间距过大（iPhone 6 Plus上显示异常）
        collectionViewLayout.minimumLineSpacing = 22; //每一行之间的间隔
        collectionViewLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
        _collectionView.scrollEnabled = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[FacilityCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setCollectionViewLayout:collectionViewLayout];
        [_containerView addSubview:_collectionView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, facilityTableViewCellHeight);
}

- (void)setCellTitle:(NSString *)title {
    [_titleView setTemplateDataDictionary:@{@"image":@"trim.png", @"text":title ? title : @""}];
}

- (void)setSourceFacilities:(NSArray *)facilities {
    _facilities = facilities;    
}

- (void)setFacilities:(NSArray *)facilities {
    self.contentView.hidden = facilities ? facilities.count > 0 ? NO : YES : YES;
    _existFacilities = facilities;
    
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _facilities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FacilityCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell setIconText:_facilities[indexPath.row][@"icon"]];
    [cell setContent:_facilities[indexPath.row][@"content"]];
    
    for (NSString *facility in _existFacilities) {
        if ([facility isEqualToString:_facilities[indexPath.row][@"content"]]) {
            [cell didSelect];
            break;
        }
    }
    
    return cell;
}

@end
