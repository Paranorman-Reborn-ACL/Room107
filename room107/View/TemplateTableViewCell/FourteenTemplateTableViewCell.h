//
//  FourteenTemplateTableViewCell.h
//  room107
//
//  Created by 107间 on 16/4/19.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat fourteenTemplateTableViewCellHeight = 46.0f;

@interface FourteenTemplateTableViewCell : Room107TableViewCell

- (void)setFourteenTemplateInfo:(NSDictionary *)info;
- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler;

@end
