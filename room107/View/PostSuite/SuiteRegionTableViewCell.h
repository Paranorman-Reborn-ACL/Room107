//
//  SuiteRegionTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat suiteRegionTableViewCellHeight = 200.0f;

@interface SuiteRegionTableViewCell : Room107TableViewCell

- (void)setRegionIndexDidChangeHandler:(void(^)(NSInteger index))handler;
- (void)setCountOfRenter:(NSString *)count;
- (void)setDistrict:(NSNumber *)district;
- (NSNumber *)district;

@end
