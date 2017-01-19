//
//  SuiteDescriptionTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"
@class CustomTextView;

static CGFloat suiteDescriptionTableViewCellHeight = 170.0f;

@interface SuiteDescriptionTableViewCell : Room107TableViewCell

@property (nonatomic, strong) CustomTextView *suiteDescriptionTextView;
- (void)setPlaceholder:(NSString *)suiteDescription;
- (void)setSuiteDescription:(NSString *)suiteDescription;
- (NSString *)suiteDescription;

@end
