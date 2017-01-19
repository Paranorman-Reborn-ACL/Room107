//
//  MessageListTableViewCell.h
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "MessageListItemModel.h"
#import "Room107TableViewCell.h"

static CGFloat messageListTableViewCellHeight = 70.0f;

@interface MessageListTableViewCell : Room107TableViewCell

- (void)setMessageListItem:(MessageListItemModel *)item;
- (void)setViewDidLongPressHandler:(void(^)())handler;
- (void)setFlagHidden:(BOOL)hidden;

@end
