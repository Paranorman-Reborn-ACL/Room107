//
//  DescriptionTableViewCell.h
//  room107
//
//  Created by ningxia on 15/6/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107TableViewCell.h"

@interface DescriptionTableViewCell : Room107TableViewCell

- (void)setDescription:(NSString *)description;

- (CGFloat)getCellHeightWithDescription:(NSString *)description;

@end
