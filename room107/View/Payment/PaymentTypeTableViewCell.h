//
//  PaymentTypeTableViewCell.h
//  room107
//
//  Created by ningxia on 16/3/24.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat paymentTypeTableViewCellHeight = 44;

@interface PaymentTypeTableViewCell : Room107TableViewCell

- (void)setPaymentTypeImageName:(NSString *)imageName;
- (void)setPaymentTypeTitle:(NSString *)title;
- (void)setPaymentTypeSeleted:(BOOL)selected;

@end
