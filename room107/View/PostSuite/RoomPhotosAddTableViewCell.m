//
//  RoomPhotosAddTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RoomPhotosAddTableViewCell.h"
#import "CustomImageView.h"

static NSString *identifier = @"UICollectionViewCell";

@interface RoomPhotosAddTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) void (^handlerBlock)(NSInteger index);

@end

@implementation RoomPhotosAddTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        CGRect frame = [self cellFrame];
        frame.origin.x = [self originLeftX];
        frame.origin.y += originY;
        frame.size.width -= 2 * [self originLeftX];
        frame.size.height -= (originY + [self originBottomY]);
        
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal; //控制滑动方向
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        CGFloat itemHeight = 50.0f;
        collectionViewLayout.minimumInteritemSpacing = collectionViewLayout.sectionInset.top; //item之间的间隔
        collectionViewLayout.minimumLineSpacing = collectionViewLayout.sectionInset.top; //每一行之间的间隔
        collectionViewLayout.itemSize = CGSizeMake(itemHeight, itemHeight);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setCollectionViewLayout:collectionViewLayout];
        [self addSubview:_collectionView];
    }
    
    return self;
}

- (IBAction)addPhotosButtonDidClick:(id)sender {
    if (self.handlerBlock) {
        self.handlerBlock(-1);
    }
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, roomPhotosAddTableViewCellHeight);
}

- (void)setRoomPhotos:(NSArray *)photos {
    _photos = [[NSMutableArray alloc] initWithArray:photos];
    [_collectionView reloadData];
}

- (void)setSelectPhotoHandler:(void(^)(NSInteger index))handler {
    self.handlerBlock = handler;
}

- (void)addPhoto:(UIImage *)image {
    [_photos addObject:image];
    [_collectionView reloadData];
}

- (NSArray *)photos {
    return _photos;
}

- (void)deletePhotoAtIndex:(NSUInteger)index {
    [_photos removeObjectAtIndex:index];
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(6, _photos.count + 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    CustomImageView *photoImageView = [[CustomImageView alloc] initWithFrame:cell.bounds];
    [photoImageView setCornerRadius:4.0f];
    [cell addSubview:photoImageView];
    
    if (indexPath.row < _photos.count) {
        [photoImageView setBackgroundColor:[UIColor clearColor]];
        id photo = _photos[indexPath.row];
        if ([photo isKindOfClass:[UIImage class]]) {
            [photoImageView setImage:photo];
        } else {
            [photoImageView setImageWithURL:photo placeholderImage:[UIImage imageNamed:@"uploadDefault.png"]];
        }
    } else {
        [photoImageView setBackgroundColor:[UIColor room107GrayColorA]];
        photoImageView.contentMode = UIViewContentModeCenter;//居中显示，不拉伸
        photoImageView.clipsToBounds = YES;
        [photoImageView setImage:[UIImage makeImageFromText:@"\ue62f" font:[UIFont room107FontThree] color:[UIColor room107GreenColor]]];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _photos.count) {
        [self addPhotosButtonDidClick:nil];
    } else {
        if (self.handlerBlock) {
            self.handlerBlock(indexPath.row);
        }
    }
}

@end
