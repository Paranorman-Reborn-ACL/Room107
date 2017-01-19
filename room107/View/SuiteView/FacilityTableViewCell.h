//
//  FacilityTableViewCell.h
//  room107
//
//  Created by ningxia on 15/6/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107TableViewCell.h"

static CGFloat facilityTableViewCellHeight = 187.5f;

@interface FacilityTableViewCell : Room107TableViewCell

- (void)setCellTitle:(NSString *)title;
- (void)setSourceFacilities:(NSArray *)facilities;
- (void)setFacilities:(NSArray *)facilities;

@end
