//
//  OtherRoomsCollectionViewCell.h
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherRoomsCollectionViewCell : UICollectionViewCell

- (void)setRoomImageURL:(NSString *)url;
- (void)setName:(NSString *)name;
- (void)setArea:(NSNumber *)area;
- (void)setPrice:(NSNumber *)price;
- (void)setOrientation:(NSString *)orientation;

@end
