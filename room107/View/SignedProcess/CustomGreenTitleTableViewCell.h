//
//  CustomGreenTitleTableViewCell.h
//  room107
//
//  Created by 107间 on 16/3/16.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat customGreenTitleTableViewCellHeight = 30.0f;

@interface CustomGreenTitleTableViewCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *)title;
@end
