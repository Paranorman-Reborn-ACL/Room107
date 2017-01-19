//
//  SuiteFromSubwayCell.h
//  room107
//
//  Created by 107间 on 16/1/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat suiteFromSubwayCellHeight = 33.0f;

@interface SuiteFromSubwayCell : UITableViewCell

@property (nonatomic, strong) UILabel *subwayLabel;
- (void)setSubwayName:(NSString *)title;
@end
