//
//  AddPhotosTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/19.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat addPhotosTableViewCellMinHeight = 40.0f;
static CGFloat addPhotosTableViewCellHeight = 120.0f;

@interface AddPhotosTableViewCell : Room107TableViewCell

- (void)setHousePhotos:(NSArray *)photos;
- (void)setSelectPhotoHandler:(void(^)(NSInteger index))handler;
- (void)addPhoto:(UIImage *)image;
- (NSArray *)photos;
- (void)deletePhotoAtIndex:(NSUInteger)index;

@end
