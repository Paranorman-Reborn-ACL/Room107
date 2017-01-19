//
//  OneTemplateView.h
//  room107
//
//  Created by 107间 on 16/4/8.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneTemplateView : UIView

- (void)clickLeftHandler:(void(^)(void))leftHandler centerHandeler:(void(^)(void))centerHandler rightHandeler:(void(^)(void))rightHandler;

@end
