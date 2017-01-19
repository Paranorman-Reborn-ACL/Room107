//
//  CustomPickerComponentTableViewCell.h
//  room107
//
//  Created by ningxia on 15/12/22.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat customPickerComponentTableViewCellHeight = 120.0f;

@interface CustomPickerComponentTableViewCell : Room107TableViewCell

- (void)setStringsArray:(NSArray *)strings withOffsetY:(CGFloat)offsetY withUnit:(NSString *)unit;
- (void)setSelectedIndex:(NSInteger)index;
- (void)setSelectedIndexDidChangeHandler:(void(^)(NSInteger index))handler;
- (NSInteger)selectedIndex;

@end
