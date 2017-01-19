//
//  RequiredGenderTableViewCell.h
//  room107
//
//  Created by ningxia on 15/9/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat requiredGenderTableViewCellHeight = 120.0f;

@interface RequiredGenderTableViewCell : Room107TableViewCell

- (void)setRequiredGender:(NSInteger)requiredGender;
- (NSInteger)requiredGender;

@end
