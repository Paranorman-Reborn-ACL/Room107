//
//  AddressTagsControlTableViewCell.h
//  room107
//
//  Created by ningxia on 15/12/21.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat addressTagsControlTableViewCellHeight = 45.0f;

@interface AddressTagsControlTableViewCell : Room107TableViewCell

- (void)setAddressTags:(NSMutableArray *)tags;
- (void)setQuickSearchHandler:(void(^)(NSMutableArray *tags))handler;
- (void)addNewTag;
- (void)resignFirstResponder;

@end
