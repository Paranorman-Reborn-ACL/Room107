//
//  HouseLandlordListCardScaleFlowLayout.m
//  CollectionViewDemos
//
//  Created by huangyibiao on 16/3/27.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import "HouseLandlordListCardScaleFlowLayout.h"

@interface HouseLandlordListCardScaleFlowLayout ()

@property (nonatomic, assign) CGFloat previousOffsetX;

@end

@implementation HouseLandlordListCardScaleFlowLayout

#pragma mark - Override
- (void)prepareLayout {
    CGFloat spaceX = 22;
    CGFloat spaceY = 22;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake(spaceY, spaceX, spaceY, spaceX);
    self.minimumInteritemSpacing = spaceX / 2; //item之间的间隔
    self.minimumLineSpacing = spaceX / 2; //每一行之间的间隔
    self.itemSize = [CommonFuncs houseLandlordListCollectionViewCellSize];
    
    [super prepareLayout];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

//暂时屏蔽缩放效果
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *superAttributes = [super layoutAttributesForElementsInRect:rect];
    NSArray *attributes = [[NSArray alloc] initWithArray:superAttributes copyItems:YES];
  
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x,
                                  self.collectionView.contentOffset.y,
                                  self.collectionView.frame.size.width,
                                  self.collectionView.frame.size.height);
    CGFloat offset = CGRectGetMidX(visibleRect);
    CGFloat scaleXForCell = 1;
    CGFloat scaleZForCell = 1;
    
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat distance = offset - attribute.center.x;
        // 越往中心移动，值越小，那么缩放就越小，从而显示就越大
        // 同样，超过中心后，越往左、右走，缩放就越大，显示就越小
        CGFloat scaleForDistance = distance / self.itemSize.height;
        // 0.2可调整，值越大，显示就越大
        CGFloat scaleYForCell = 0.9 + 0.1 * (1 - fabs(scaleForDistance));
        CGFloat alpha = 0.7 + 0.3 * (1 - fabs(scaleForDistance));
        
        // only scale y-axis
        attribute.transform3D = CATransform3DMakeScale(scaleXForCell, scaleYForCell, scaleZForCell);
        attribute.alpha = alpha; //透明度
        if (alpha == 1) {
            //初始化偏移值
            self.previousOffsetX = attribute.indexPath.row * (self.collectionView.frame.size.width - self.minimumLineSpacing * 3);
        }
        attribute.zIndex = 1;
    }];
  
    return attributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    // 分页以1/3处
    if (proposedContentOffset.x > self.previousOffsetX + self.itemSize.width / 3.0) {
        self.previousOffsetX += self.collectionView.frame.size.width - self.minimumLineSpacing * 3; //计算适当的偏移值
    } else if (proposedContentOffset.x < self.previousOffsetX  - self.itemSize.width / 3.0) {
        self.previousOffsetX -= self.collectionView.frame.size.width - self.minimumLineSpacing * 3;
    }
  
    proposedContentOffset.x = self.previousOffsetX;
  
    return proposedContentOffset;
}

@end
