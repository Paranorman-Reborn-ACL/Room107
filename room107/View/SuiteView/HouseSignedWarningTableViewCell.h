//
//  HouseSignedWarningTableViewCell.h
//  room107
//
//  Created by ningxia on 16/3/1.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat houseSignedWarningTableViewCellMinHeight = 11 * 2 + 33;

@interface HouseSignedWarningTableViewCell : Room107TableViewCell

- (void)setContent:(NSString *)content;
- (CGFloat)getCellHeightWithContent:(NSString *)content;

@end
