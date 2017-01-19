//
//  LeadUserView.h
//  room107
//
//  Created by 107间 on 15/11/16.
//  Copyright © 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeadUserView : UIView
@property (nonatomic, copy) void(^sliderBlock)(void);
@property (nonatomic, copy) void(^sliderBackBlock)(void);
@end
