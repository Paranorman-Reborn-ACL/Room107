//
//  CustomShrinkMutableStringTableViewCell.h
//  room107
//
//  Created by ningxia on 15/10/15.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat customShrinkMutableStringTableViewCellMinHeight = 40.0f;

@interface CustomShrinkMutableStringTableViewCell : Room107TableViewCell

- (void)setSubtitle:(NSString *)subtitle;
- (void)setContentHidden:(BOOL)hidden;
- (void)setShrinkHidden:(BOOL)hidden;
- (void)setContentColor:(UIColor *)color;
- (void)setContent:(NSString *)content;
- (void)setShrinkHandler:(void(^)(BOOL hidden))handler;
- (CGFloat)getCellHeightWithContent:(NSString *)content;

@end
