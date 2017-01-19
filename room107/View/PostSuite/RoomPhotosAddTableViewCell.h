//
//  RoomPhotosAddTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat roomPhotosAddTableViewCellHeight = 120.0f;

@interface RoomPhotosAddTableViewCell : Room107TableViewCell

- (void)setRoomPhotos:(NSArray *)photos;
- (void)setSelectPhotoHandler:(void(^)(NSInteger index))handler;
- (void)addPhoto:(UIImage *)image;
- (NSArray *)photos;
- (void)deletePhotoAtIndex:(NSUInteger)index;

@end
