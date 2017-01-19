//
//  AccountCardTableViewCell.h
//  room107
//
//  Created by 107间 on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat accountCardTableViewCellHeight = 44.0f;

@interface AccountCardTableViewCell : Room107TableViewCell

- (void)setAccountCardInfo:(NSDictionary *)accountCardInfo;
- (void)setTelephone:(NSString *)telephone;
@end
