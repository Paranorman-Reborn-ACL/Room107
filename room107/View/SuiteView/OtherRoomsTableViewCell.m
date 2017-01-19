//
//  OtherRoomsTableViewCell.m
//  room107
//
//  Created by ningxia on 15/7/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "OtherRoomsTableViewCell.h"
#import "OtherRoomsCollectionViewCell.h"
#import "RoomModel.h"
#import "SearchTipLabel.h"
#import "Room107VisualEffectView.h"
#import "Room107GradientLayer.h"

static CGFloat spaceY = 11;
static NSString *identifier = @"OtherRoomsCollectionViewCell";
static NSUInteger numPerRow = 2;

@interface OtherRoomsTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *rooms;
@property (nonatomic) CGSize sizeForItem;
@property (nonatomic) UIEdgeInsets insetForLayout;
@property (nonatomic, strong) Room107GradientLayer *gradientLayer;

@end

@implementation OtherRoomsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11;
        CGFloat originY = 11;
        
        CGFloat viewWidth = CGRectGetWidth([self cellFrame]) - originX * 2;
        CGFloat viewHeight = CGRectGetHeight([self cellFrame]) - originY;
        SearchTipLabel *titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, viewWidth - 2 * originX, 20}];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setText:lang(@"OtherRoom")];
        
        CGRect frame = (CGRect){0, originY, viewWidth, viewHeight};
        frame.origin.y += CGRectGetHeight(titleLabel.bounds) + 10;
        frame.size.height -= frame.origin.y;
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 22, originY, 22);
        CGFloat width = CGRectGetWidth([self cellFrame]) / 3;
        _sizeForItem = CGSizeMake(width, width * 3 / 4);
        _insetForLayout = UIEdgeInsetsMake(0, width / 3, 10, width / 3);
        collectionViewLayout.minimumInteritemSpacing = viewWidth - 2 * collectionViewLayout.sectionInset.left - numPerRow * _sizeForItem.width; //item之间的间隔
        collectionViewLayout.minimumLineSpacing = 10; //每一行之间的间隔
        collectionViewLayout.itemSize = _sizeForItem;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
        _collectionView.scrollEnabled = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[OtherRoomsCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setCollectionViewLayout:collectionViewLayout];
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            _containerView = [[Room107VisualEffectView alloc] initWithFrame:(CGRect){originX, spaceY, viewWidth, viewHeight}];
            [self addSubview:_containerView];
            [[(Room107VisualEffectView *)_containerView contentView] addSubview:titleLabel];
            [[(Room107VisualEffectView *)_containerView contentView] addSubview:_collectionView];
        } else {
            _containerView = [[UIView alloc] initWithFrame:(CGRect){originX, spaceY, viewWidth, viewHeight}];
            [self addSubview:_containerView];
            [_containerView addSubview:titleLabel];
            [_containerView addSubview:_collectionView];
            CGRect frame = _containerView.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            _gradientLayer = [[Room107GradientLayer alloc] initWithFrame:frame andStartAlpha:0.3f andEndAlpha:0.3f];
            [_containerView.layer insertSublayer:_gradientLayer atIndex:0];
        }
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 100);
}

- (void)setRooms:(NSArray *)rooms {
    _rooms = rooms;
    
    CGFloat contentHeight = [self getCellHeightWithRooms:rooms];
    CGRect frame = _collectionView.frame;
    frame.size.height = contentHeight - (2 * spaceY + frame.origin.y);
    [_collectionView setFrame:frame];
    
    frame = _containerView.frame;
    frame.size.height = contentHeight - spaceY;
    [_containerView setFrame:frame];
    if (_gradientLayer) {
        frame.origin.x = 0;
        frame.origin.y = 0;
        [_gradientLayer setFrame:frame];
    }
    
    [_collectionView reloadData];
}

- (CGFloat)getCellHeightWithRooms:(NSArray *)rooms {
    return 2 * spaceY + _collectionView.frame.origin.y + (_sizeForItem.height + _insetForLayout.top + 10 +  _insetForLayout.bottom) * ((rooms.count - 1) / numPerRow + 1);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _rooms.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OtherRoomsCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherRoomsCollectionViewCell" forIndexPath:indexPath];
    RoomModel *room = _rooms[indexPath.row];
    [cell setRoomImageURL:room.imageIds[0][@"url"]];
    [cell setName:room.name];
    [cell setArea:room.area];
    [cell setOrientation:room.orientation];
    [cell setPrice:room.price];
    
    return cell;
}

@end
