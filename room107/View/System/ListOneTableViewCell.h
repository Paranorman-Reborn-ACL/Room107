//
//  ListOneTableViewCell.h
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

@interface ListOneTableViewCell : Room107TableViewCell

- (CGFloat)heightByCard:(NSDictionary *)card;
- (void)setCard:(NSDictionary *)card;

@end
