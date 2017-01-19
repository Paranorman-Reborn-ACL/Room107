//
//  RentInfoItemView.h
//  room107
//
//  Created by ningxia on 15/8/5.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RentInfoItemViewTypeCheckInDate = 0, //入住日期
    RentInfoItemViewTypeCheckOutDate, //搬出日期
    RentInfoItemViewTypePaymentMethod, //支付方式
    RentInfoItemViewTypeContractMoney, //合同租金
    RentInfoItemViewTypePayableMonthly, //应付月租
    RentInfoItemViewTypeSigningRentalGuarantee, //签约租住保障
} RentInfoItemViewType;

@interface RentInfoItemView : UIView

- (id)initWithFrame:(CGRect)frame viewType:(RentInfoItemViewType)type content:(NSString *)content;

@end
