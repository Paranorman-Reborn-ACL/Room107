//
//  HouseProfileTableViewCell.h
//  room107
//
//  Created by ningxia on 15/12/28.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat houseProfileTableViewCellHeight = 170;

@interface HouseProfileTableViewCell : Room107TableViewCell

- (void)setAvatarImageViewWithURL:(NSString *)url;
- (void)setCity:(NSString *)city andName:(NSString *)name andRequiredGender:(NSString *)gender;
- (void)setPosition:(NSString *)position;
- (void)setPrice:(NSNumber *)price;
- (void)setHouseNumber:(NSString *)number;
- (void)setSubmitTime:(NSString *)time;
- (CGFloat)getCellHeightWithPosition:(NSString *)position;

@end
