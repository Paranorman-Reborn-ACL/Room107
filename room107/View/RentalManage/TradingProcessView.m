//
//  TradingProcessView.m
//  room107
//
//  Created by ningxia on 15/8/3.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "TradingProcessView.h"
#import "SearchTipLabel.h"
#import "CircleGreenLabel.h"

static NSUInteger processViewTag = 1000;
static CGFloat markLabelMaxWidth = 22.0f;
static CGFloat markLabelMinWidth = 16.0f;

@interface TradingProcessView ()

@property (nonatomic) CGRect processMarkLabelFrame;
@property (nonatomic) CGRect processLabelFrame;

@end

@implementation TradingProcessView

- (id)initWithFrame:(CGRect)frame processesArray:(NSArray *)processes {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat originX = 0.0f;
        CGFloat originY = 0.0f;
        originY += (markLabelMaxWidth - 0.5) / 2;
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, frame.size.width, 0.5}];
        [lineView setBackgroundColor:[UIColor room107GrayColorC]];
        [self addSubview:lineView];
        
        CGFloat processViewWidth = frame.size.width / processes.count;
//        CGFloat processViewWidth = 66;
        CGFloat spacingX = (frame.size.width - processes.count * processViewWidth) / (processes.count - 1);
        for (NSUInteger i = 0; i < processes.count; i++) {
            UIView *processView = [[UIView alloc] initWithFrame:(CGRect){originX + i * (processViewWidth + spacingX), 0, processViewWidth, frame.size.height}];
            [processView setBackgroundColor:[UIColor clearColor]];
            [processView setTag:(processViewTag + i)];
            [self addSubview:processView];
            
            _processMarkLabelFrame = (CGRect){CGRectGetWidth(processView.bounds) / 2 - markLabelMaxWidth / 2, 0, markLabelMaxWidth, markLabelMaxWidth};
            CircleGreenLabel *processMarkLabel = [[CircleGreenLabel alloc] initWithFrame:_processMarkLabelFrame];
            [processMarkLabel setBackgroundColor:[UIColor room107GrayColorC]];
            [processMarkLabel setText:[NSString stringWithFormat:@"%lu", i + 1]];
            [processMarkLabel setFont:[UIFont room107FontTwo]];
            [processView addSubview:processMarkLabel];
            
            CGFloat labelY = CGRectGetHeight(processMarkLabel.bounds) + 3.0f;
            _processLabelFrame = (CGRect){0, labelY, processViewWidth, CGRectGetHeight(processView.bounds) - labelY};
            SearchTipLabel *processLabel = [[SearchTipLabel alloc] initWithFrame:_processLabelFrame];
            [processLabel setText:processes[i]];
            [processLabel setTextAlignment:NSTextAlignmentCenter];
            [processView addSubview:processLabel];
        }
    }
    
    return self;
}

- (void)setCurrentStep:(NSNumber *)step {
    for (UIView *processView in [self subviews]) {
        if (processView.tag >= processViewTag) {
            if (processView.tag == (processViewTag + [step unsignedIntegerValue])) {
                for (UIView *view in [processView subviews]) {
                    if ([view isKindOfClass:[CircleGreenLabel class]]) {
                        view.layer.cornerRadius = CGRectGetHeight(_processMarkLabelFrame) / 2;
                        [view setFrame:_processMarkLabelFrame];
                        [view setBackgroundColor:[UIColor room107GreenColor]];
                    } else if ([view isKindOfClass:[SearchTipLabel class]]) {
                        [(SearchTipLabel *)view setTextColor:[UIColor room107GreenColor]];
                        [(SearchTipLabel *)view setFont:[UIFont room107FontThree]];
                    }
                }
            } else {
                for (UIView *view in [processView subviews]) {
                    if ([view isKindOfClass:[CircleGreenLabel class]]) {
                        CGRect frame = _processMarkLabelFrame;
                        frame.origin.x += (markLabelMaxWidth - markLabelMinWidth) / 2;
                        frame.origin.y = (markLabelMaxWidth - markLabelMinWidth) / 2;
                        frame.size.width = markLabelMinWidth;
                        frame.size.height = frame.size.width;
                        view.layer.cornerRadius = CGRectGetHeight(frame) / 2;
                        [view setFrame:frame];
                        [view setBackgroundColor:[UIColor room107GrayColorC]];
                    } else if ([view isKindOfClass:[SearchTipLabel class]]) {
                        [(SearchTipLabel *)view setTextColor:[UIColor room107GrayColorC]];
                        [(SearchTipLabel *)view setFont:[UIFont room107FontTwo]];
                    }
                }
            }
        }
    }
}

@end
