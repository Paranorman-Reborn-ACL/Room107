//
//  SimilarHouseTableViewCell.m
//  room107
//
//  Created by ningxia on 15/12/29.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "SimilarHouseTableViewCell.h"
#import "ThirteenTemplateView.h"
#import "SixSubTemplateCollectionViewCell.h"
#import "HouseListItemModel.h"
#import "TemplateViewFuncs.h"

static CGFloat spaceX = 11;
static CGFloat titleViewHeight = 36;
static NSString *identifier = @"SixSubTemplateCollectionViewCell";

@interface SimilarHouseTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *recommendHouses;
@property (nonatomic, strong) void (^selectHouseHandlerBlock)(NSArray *houses, NSInteger index);
@property (nonatomic, strong) void (^viewHouseTagExplanationHandlerBlock)(NSDictionary *params);

@end

@implementation SimilarHouseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGRect frame = (CGRect){0, spaceY, [self cellFrame].size};
        frame.size.height -= spaceY;
        _containerView = [[UIView alloc] initWithFrame:frame];
        [_containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_containerView];
        
        ThirteenTemplateView *titleView = [[ThirteenTemplateView alloc] initWithFrame:(CGRect){0, 0, frame.size.width, titleViewHeight} andTemplateDataDictionary:@{@"image":@"trim.png", @"text":lang(@"SimilarHouse")}];
        [_containerView addSubview:titleView];
        
        [self createCollectionView];
    }
    
    return self;
}

- (void)createCollectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(spaceY, spaceX, spaceY, spaceX);
        collectionViewLayout.minimumInteritemSpacing = spaceX; //item之间的间隔
        collectionViewLayout.minimumLineSpacing = spaceX; //每一行之间的间隔
        collectionViewLayout.itemSize = [TemplateViewFuncs sixSubTemplateCellSize];
        
        CGRect frame = (CGRect){0, titleViewHeight, [self cellFrame].size};
        frame.size.height -= spaceY + titleViewHeight;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[SixSubTemplateCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setCollectionViewLayout:collectionViewLayout];
        [_containerView addSubview:_collectionView];
    }
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, spaceY + [TemplateViewFuncs sixSubTemplateCellSize].height + similarHouseTableViewCellMinHeight);
}

- (void)setRecommendHouses:(NSArray *)houses {
    _containerView.hidden = YES;
    if (houses.count > 0) {
        _recommendHouses = houses;
        _containerView.hidden = NO;
    }
}

- (void)setViewHouseTagExplanationHandler:(void(^)(NSDictionary *params))handler {
    _viewHouseTagExplanationHandlerBlock = handler;
}

- (void)setSelectHouseHandler:(void(^)(NSArray *houses, NSInteger index))handler {
    _selectHouseHandlerBlock = handler;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _recommendHouses.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_recommendHouses.count > indexPath.row) {
        //避免数组越界
        SixSubTemplateCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        HouseListItemModel *item = _recommendHouses[indexPath.row];
        
        NSString *imageUrl = [item.hasCover boolValue] && item.cover && item.cover[@"url"] ? item.cover[@"url"] : @"";
        NSString *headImageUrl = item.faviconUrl ? item.faviconUrl : @"";
        NSString *headImageName = item.faviconUrl ? @"" : @"loginlogo.png";
        NSString *middleText = [NSString stringWithFormat:@"￥%@", item.price];
        NSString *middleTailText = [NSString stringWithFormat:lang(@"IntentionNumber"), item.viewCount];
        NSString *footText = [item.city stringByAppendingFormat:@" %@", item.position];
        NSString *footSubtext = [item.houseName stringByAppendingFormat:@" %@ %@", item.roomName, [CommonFuncs requiredGenderText:item.requiredGender]];
        if ([item.rentType isEqual:@2]) {
            //整租
            footSubtext = [item.houseName stringByAppendingFormat:@" %@", item.roomName];
        }
        NSString *footTailText = [TimeUtil timeStringFromTimestamp:[item.modifiedTime doubleValue] / 1000 withDateFormat:@"YYYY/MM/dd"];
        
        [cell setTemplateDataDictionary:@{@"headImageUrl":headImageUrl ? headImageUrl : @"", @"headImageName":headImageName ? headImageName : @"", @"headImageType":@1, @"middleText":middleText ? middleText : @"", @"middleBackgroundColor":@"494949", @"middleTailText":middleTailText ? middleTailText : @"", @"middleTailBackgroundColor":@"494949", @"footText":footText ? footText : @"", @"footSubtext":footSubtext ? footSubtext : @"", @"footTailText":footTailText ? footTailText : @"", @"imageUrl":imageUrl ? imageUrl : @""}];
        
        return cell;
    }
    
    return [SixSubTemplateCollectionViewCell new];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_recommendHouses.count > indexPath.row && _selectHouseHandlerBlock) {
        _selectHouseHandlerBlock(_recommendHouses, indexPath.row);
    }
}

@end
