//
//  SuiteTypeTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat suiteTypeTableViewCellHeight = 150.0f;

@interface SuiteTypeTableViewCell : Room107TableViewCell

- (void)setHallNumber:(NSNumber *)number;
- (void)setRoomNumber:(NSNumber *)number;
- (void)setKitchenNumber:(NSNumber *)number;
- (void)setToiletNumber:(NSNumber *)number;
- (NSNumber *)hallNumber;
- (NSNumber *)roomNumber;
- (NSNumber *)kitchenNumber;
- (NSNumber *)toiletNumber;

@end
