//
//  ElevenTemplateView.h
//  room107
//
//  Created by 107间 on 16/4/12.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "BaseTemplateView.h"

@interface ElevenTemplateView : BaseTemplateView

- (instancetype)initWithText:(NSString *)text andImageUrl:(NSString *)imageUrl andSubText:(NSString *)subText andViewWidth:(CGFloat)viewWidth;
- (CGFloat)elevenTemplateViewHeight;

@end
