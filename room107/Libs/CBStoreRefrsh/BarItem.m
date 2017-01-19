//
//  BarItem.m
//  CBStoreHouseRefreshControl
//
//  Created by coolbeet on 10/30/14.
//  Copyright (c) 2014 Suyu Zhang. All rights reserved.
//

#import "BarItem.h"

@interface BarItem ()

@property (nonatomic) CGPoint middlePoint;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) UIColor *color;

@end

@implementation BarItem

- (instancetype)initWithFrame:(CGRect)frame startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _lineWidth = lineWidth;
        _color = color;
        
        CGPoint (^middlePoint)(CGPoint, CGPoint) = ^CGPoint(CGPoint a, CGPoint b) {
            CGFloat x = (a.x + b.x)/2.f;
            CGFloat y = (a.y + b.y)/2.f;
            return CGPointMake(x, y);
        };
        _middlePoint = middlePoint(startPoint, endPoint);
    }
    return self;
}
#pragma warning 改了barItem的frame（宽度和高度）
- (void)setupWithFrame:(CGRect)rect
{
    self.layer.anchorPoint = CGPointMake(self.middlePoint.x/self.frame.size.width, self.middlePoint.y/self.frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x + self.middlePoint.x - self.frame.size.width/2, self.frame.origin.y + self.middlePoint.y - self.frame.size.height/2, self.frame.size.width + 4, self.frame.size.height + 4);
}

- (void)setHorizontalRandomness:(int)horizontalRandomness dropHeight:(CGFloat)dropHeight
{
    int randomNumber = - horizontalRandomness + arc4random()%horizontalRandomness*2;
    self.translationX = randomNumber;
    self.transform = CGAffineTransformMakeTranslation(self.translationX, -dropHeight);
}
#pragma warning 改了绘制的点的坐标（整体下移2像素，右移2像素）
- (void)drawRect:(CGRect)rect {
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint:CGPointMake(self.startPoint.x +2, self.startPoint.y +2)];
    [bezierPath addLineToPoint:CGPointMake(self.endPoint.x +2, self.endPoint.y +2)];
    [self.color setStroke];
    bezierPath.lineWidth = self.lineWidth;
    [bezierPath stroke];
}

@end
