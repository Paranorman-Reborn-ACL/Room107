//
//  ExpenseOrderTableViewCell.h
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

@interface ExpenseOrderTableViewCell : Room107TableViewCell

- (void)setNameLabelWidth:(CGFloat)width;
- (void)setName:(NSString *)name;
- (void)setAttributedName:(NSMutableAttributedString *)name;
- (void)setContentX:(CGFloat)originX;
- (void)setContent:(NSString *)content;
- (void)setAttributedContent:(NSMutableAttributedString *)content;

- (CGFloat)getCellHeightWithName:(NSString *)name;

@end
