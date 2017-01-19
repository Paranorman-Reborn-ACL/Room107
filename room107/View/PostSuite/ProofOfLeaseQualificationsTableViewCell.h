//
//  ProofOfLeaseQualificationsTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat proofOfLeaseQualificationsTableViewCellHeight = 150.0f;

@interface ProofOfLeaseQualificationsTableViewCell : Room107TableViewCell

- (void)setProofPhotos:(NSArray *)photos;
- (void)setSelectPhotoHandler:(void(^)(NSInteger index))handler;
- (void)addPhoto:(UIImage *)image;
- (NSArray *)photos;
- (void)deletePhotoAtIndex:(NSUInteger)index;
- (void)setContent:(NSString *)content;
- (void)setViewDidClickHandler:(void(^)())handler;

@end
