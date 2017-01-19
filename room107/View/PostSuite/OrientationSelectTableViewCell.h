//
//  OrientationSelectTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat orientationSelectTableViewCellHeight = 155.0f;

@interface OrientationSelectTableViewCell : Room107TableViewCell

- (void)setOrientation:(NSString *)orientation;
- (NSString *)orientation;

@end
