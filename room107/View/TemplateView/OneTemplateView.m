//
//  OneTemplateView.m
//  room107
//
//  Created by 107间 on 16/4/8.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "OneTemplateView.h"
#import "OneSubTemplateView.h"

@interface OneTemplateView()

@property (nonatomic, strong) OneSubTemplateView *subOneTemplateViewLeft;
@property (nonatomic, strong) OneSubTemplateView *subOneTemplateViewCenter;
@property (nonatomic, strong) OneSubTemplateView *subOneTemplateViewRight;

@property (nonatomic, copy) void(^leftHandlerBlock)(void);
@property (nonatomic, copy) void(^centerHandlerBlock)(void);
@property (nonatomic, copy) void(^rightHandlerBlock)(void);

@end

@implementation OneTemplateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat windth = frame.size.width / 3;
        CGFloat height = frame.size.height;
        
    }
    return self;
}

- (void)clickLeftHandler:(void(^)(void))leftHandler centerHandeler:(void(^)(void))centerHandler rightHandeler:(void(^)(void))rightHandler {
    _leftHandlerBlock = leftHandler;
    _centerHandlerBlock = leftHandler;
    _rightHandlerBlock = leftHandler;
}


@end
