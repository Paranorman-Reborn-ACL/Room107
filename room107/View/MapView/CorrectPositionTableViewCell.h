//
//  CorrectPositionTableViewCell.h
//  room107
//
//  Created by 107间 on 16/4/19.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat correctPositionTableViewCellHeight = 49.0f;

@interface CorrectPositionTableViewCell : Room107TableViewCell

-(void)setName:(NSString *)name andAddress:(NSString *)address;

@end
