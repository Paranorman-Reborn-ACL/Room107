//
//  ManageSubscribesTableViewCell.h
//  room107
//
//  Created by ningxia on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat manageSubscribesTableViewCellHeight = 77.0f;

@interface ManageSubscribesTableViewCell : Room107TableViewCell

- (void)setPosition:(NSString *)position;
- (void)setContent:(NSString *)content;
- (void)setViewDidLongPressHandler:(void(^)())handler;

@end
