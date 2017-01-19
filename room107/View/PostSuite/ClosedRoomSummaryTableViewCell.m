//
//  ClosedRoomSummaryTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ClosedRoomSummaryTableViewCell.h"
#import "SearchTipLabel.h"
#import "CustomImageView.h"

static NSString *identifier = @"UICollectionViewCell";

@interface ClosedRoomSummaryTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) CustomImageView *coverImageView;
@property (nonatomic, strong) SearchTipLabel *roomTypeLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *photos;

@end

@implementation ClosedRoomSummaryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11;
        CGFloat originY = 5;
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth([self cellFrame]) - 2 * originX, CGRectGetHeight([self cellFrame]) - originY}];
        [containerView setBackgroundColor:[UIColor room107GrayColorB]];
        containerView.layer.cornerRadius = 4;
        containerView.layer.masksToBounds = YES;
        [self addSubview:containerView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
        [containerView addGestureRecognizer:tap];

        originY += 5;
        CGFloat lineViewX = (CGRectGetWidth(containerView.bounds) - 0.5) / 2;
        CGFloat lineViewHeight = 20;
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){lineViewX, originY, 0.5, lineViewHeight}];
        [lineView setBackgroundColor:[UIColor whiteColor]];
        [containerView addSubview:lineView];
        
        CGFloat labelWidth = 50;
        _roomTypeLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){lineViewX - labelWidth - 5, originY, labelWidth, lineViewHeight}];
        [_roomTypeLabel setFont:[UIFont room107FontThree]];
        [_roomTypeLabel setTextColor:[UIColor room107GrayColorD]];
        [_roomTypeLabel setTextAlignment:NSTextAlignmentRight];
        [containerView addSubview:_roomTypeLabel];
        
        SearchTipLabel *statusLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){lineViewX + 5, originY, labelWidth, lineViewHeight}];
        [statusLabel setText:lang(@"Closed")];
        [statusLabel setFont:[UIFont room107FontThree]];
        [statusLabel setTextColor:[UIColor room107GrayColorD]];
        [containerView addSubview:statusLabel];
        
        originY += lineViewHeight + 5;
        CGFloat imageViewRight = 15;
        CGRect frame = [self cellFrame];
        frame.origin.x = imageViewRight;
        frame.origin.y += originY;
        frame.size.width -= 2 * [self originLeftX];
        frame.size.height -= (originY + 10);
        
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal; //控制滑动方向
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        CGFloat itemHeight = 50.0f;
        collectionViewLayout.minimumInteritemSpacing = collectionViewLayout.sectionInset.top; //item之间的间隔
        collectionViewLayout.minimumLineSpacing =collectionViewLayout.sectionInset.top; //每一行之间的间隔
        collectionViewLayout.itemSize = CGSizeMake(itemHeight, itemHeight);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setCollectionViewLayout:collectionViewLayout];
        [containerView addSubview:_collectionView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, closedRoomSummaryTableViewCellHeight);
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [_collectionView reloadData];
}

- (void)setRoomType:(NSNumber *)type; {
    [_roomTypeLabel setText:[type isEqual:@1] ? lang(@"MasterBedroom") : lang(@"SecondaryBedroom")];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(6, _photos.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    CustomImageView *photoImageView = [[CustomImageView alloc] initWithFrame:cell.bounds];
    [photoImageView setCornerRadius:4.0f];
    [cell addSubview:photoImageView];
    
    [photoImageView setBackgroundColor:[UIColor clearColor]];
    id photo = _photos[indexPath.row];
    if ([photo isKindOfClass:[UIImage class]]) {
        [photoImageView setImage:photo];
    } else {
        [photoImageView setImageWithURL:photo placeholderImage:[UIImage imageNamed:@"uploadDefault.png"]];
    }
    
    return cell;
}

- (void)tapClick {
    if (self.closedRoomSummarydidClick) {
        self.closedRoomSummarydidClick();
    }
}

@end
