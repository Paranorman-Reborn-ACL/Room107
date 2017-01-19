//
//  SixTemplateTableViewCell.m
//  room107
//
//  Created by ningxia on 16/4/12.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SixTemplateTableViewCell.h"
#import "SixSubTemplateCollectionViewCell.h"
#import "TemplateViewFuncs.h"

static NSString *identifier = @"SixSubTemplateCollectionViewCell";

@interface SixTemplateTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) void (^viewDidClickHandlerBlock)(NSArray *targetURLs);
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation SixTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self createCollectionView];
    }
    
    return self;
}

- (void)createCollectionView {
    if (!_collectionView) {
        CGFloat spaceX = 11;
        CGFloat spaceY = 11;
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(spaceY, spaceX, spaceY, spaceX);
        collectionViewLayout.minimumInteritemSpacing = spaceX; //item之间的间隔
        collectionViewLayout.minimumLineSpacing = spaceX; //每一行之间的间隔
        collectionViewLayout.itemSize = [TemplateViewFuncs sixSubTemplateCellSize];
        
        CGRect frame = (CGRect){0, 0, [self cellFrame].size};
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[SixSubTemplateCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setCollectionViewLayout:collectionViewLayout];
        [self.contentView addSubview:_collectionView];
    }
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, sixTemplateTableViewCellMinHeight + [TemplateViewFuncs sixSubTemplateCellSize].height);
}

- (void)setTemplateDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
}

- (void)setViewDidClickHandler:(void(^)(NSArray *targetURLs))handler {
    _viewDidClickHandlerBlock = handler;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataArray.count > indexPath.row) {
        //避免数组越界
        SixSubTemplateCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        [cell setTemplateDataDictionary:_dataArray[indexPath.row]];
        [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
            if (_viewDidClickHandlerBlock) {
                _viewDidClickHandlerBlock(holdTargetURLs);
            }
        }];
        return cell;
    }
    
    return [SixSubTemplateCollectionViewCell new];
}


- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler {
    _viewDidLongPressHandlerBlock = handler;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataArray.count > indexPath.row) {
        if (_viewDidClickHandlerBlock) {
            _viewDidClickHandlerBlock(_dataArray[indexPath.row][@"targetUrl"]);
        }
    }
}

@end
