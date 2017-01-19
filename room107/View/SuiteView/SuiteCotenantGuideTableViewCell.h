//
//  SuiteCotenantGuideTableViewCell.h
//  room107
//
//  Created by ningxia on 16/3/2.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat suiteCotenantGuideTableViewCellMinHeight = 11 * 3 + 36.5 + 22;

@interface SuiteCotenantGuideTableViewCell : Room107TableViewCell

- (void)setContent:(NSString *)content andCotenants:(NSMutableArray *)cotenants;
- (CGFloat)getCellHeightWithContent:(NSString *)content andCotenants:(NSMutableArray *)cotenants;
- (void)refreshCotenantGuideButtonStatusByIsCotenant:(BOOL)isCotenant;
- (void)setCotenantGuideButtonDidClickHandler:(void(^)())handler;
- (void)setCotenantAvatarDidClickHandler:(void(^)(NSUInteger index))handler;

@end
