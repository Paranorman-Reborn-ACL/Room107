//
//  MenuView.m
//  downTableView
//
//  Created by 107间 on 15/11/18.
//  Copyright © 2015年 107间. All rights reserved.
//

#define ITEM_WIDTH  100
#define ITEM_HEIGHT 50
#define ScreenFrame [UIScreen mainScreen].bounds
#import "MenuView.h"

@interface MenuView() <UITableViewDelegate>

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) UIScrollView *backGroundView;
@property (nonatomic, strong) UIView *alphaView;
@property (nonatomic, assign) CGRect viewFrame;
@property (nonatomic, strong) UIView *view;

@end
@implementation MenuView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, ScreenFrame.size.width, ScreenFrame.size.height)];
    if (self) {
        [self addSubview:self.view];
        self.hidden = YES;
        _lineHeight = 1;
        _itemHeight = ITEM_HEIGHT - _lineHeight;
        _itemCount  = 5;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTap)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (UIView *)alphaView {
    if (nil == _alphaView) {
        _alphaView = [[UIView alloc] init];
    }
    return _alphaView;
}

- (UIView *)view {
    if (nil == _view) {
        self.view = [[UIView alloc] init];
    }
    
    return _view;
}

- (UIScrollView *)backGroundView {
    if (nil == _backGroundView) {
        _backGroundView = [[UIScrollView alloc]init];
        _backGroundView.backgroundColor = [UIColor whiteColor];
    }
    return _backGroundView;
}

- (void)showMenuView {
    //将self置为最顶层
    [self.superview bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.count < self.itemCount) {
            self.view.frame = CGRectMake(ScreenFrame.size.width - 10 - ITEM_WIDTH, 0, ITEM_WIDTH, (_lineHeight + _itemHeight) * _count);
        } else {
            self.view.frame = CGRectMake(ScreenFrame.size.width - 10 - ITEM_WIDTH, 0, ITEM_WIDTH, (_lineHeight + _itemHeight) * _count + (_lineHeight+_itemHeight) * 2/3);
        }
        self.hidden = NO;
    } completion:^(BOOL finished) {
    }];
}

- (void)disapperView {
    [UIView animateWithDuration:0.3 animations:^{
        if (self.count < self.itemCount) {
            self.view.frame = CGRectMake(ScreenFrame.size.width - 10 - ITEM_WIDTH  , - (_lineHeight+_itemHeight)*_count , ITEM_WIDTH , (_lineHeight+_itemHeight)*_count);
        } else {
            self.view.frame = CGRectMake(ScreenFrame.size.width - 10 - ITEM_WIDTH  , - (_lineHeight+_itemHeight)*_count - (_lineHeight+_itemHeight)*2/3 , ITEM_WIDTH , (_lineHeight+_itemHeight)*_count);

        }
    }completion:^(BOOL finished) {
            self.hidden = YES;
    }];
}

- (void)addButtonTitleArray:(NSArray *)titleArray buttonColor:(UIColor *)color textFont:(UIFont *)font {
    CGFloat offsetY = 1;
    if (titleArray.count <= self.itemCount) {
        //临界点值的判断
        self.count = titleArray.count;
        self.view.frame = CGRectMake(ScreenFrame.size.width - 10 - ITEM_WIDTH, statusBarHeight + navigationBarHeight - (_lineHeight + _itemHeight) * _itemCount, ITEM_WIDTH, (_lineHeight + _itemHeight) * titleArray.count - _lineHeight);
        self.backGroundView.frame = CGRectMake(0, offsetY, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:self.backGroundView];
    } else {
        self.count = self.itemCount;
         self.view.frame = CGRectMake(ScreenFrame.size.width - 10 - ITEM_WIDTH , 64 - (_lineHeight + _itemHeight)*_itemCount, ITEM_WIDTH , (_lineHeight+_itemHeight)*_count + (_lineHeight+_itemHeight)*2/3 );
        self.backGroundView.frame = CGRectMake(0, offsetY, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:self.backGroundView];
        self.backGroundView.contentSize = CGSizeMake(0, titleArray.count *(_lineHeight + _itemHeight));
        self.backGroundView.bounces= NO;
        
        self.alphaView.frame = CGRectMake(0, (_lineHeight + _itemHeight)*_itemCount, ITEM_WIDTH, (_lineHeight+_itemHeight)*2/3);
        CAGradientLayer *gradient = [CAGradientLayer layer];
//        gradient.frame = CGRectMake(0, 0, ITEM_WIDTH, (_lineHeight+_itemHeight)*2/3);
        gradient.frame = self.alphaView.frame;
        gradient.colors = [NSArray arrayWithObjects: (id)[[[UIColor room107DeepGreenColor] colorWithAlphaComponent:0] CGColor],
                                                     (id)[[[UIColor room107DeepGreenColor] colorWithAlphaComponent:0.2] CGColor],
                                                     (id)[[[UIColor room107DeepGreenColor] colorWithAlphaComponent:0.4] CGColor],
                                                     (id)[[[UIColor room107DeepGreenColor] colorWithAlphaComponent:0.6] CGColor],
                                                     (id)[[[UIColor room107DeepGreenColor] colorWithAlphaComponent:0.8] CGColor],
                                                     (id)[[[UIColor room107DeepGreenColor] colorWithAlphaComponent:1] CGColor],
                                                      nil];
        [self.view.layer insertSublayer:gradient atIndex:2];
//        [self.view addSubview:self.alphaView];
    }
    
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0, 0);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3)
    self.view.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    self.view.layer.shadowRadius = [CommonFuncs shadowRadius];//阴影半径，默认3
    
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    float width = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    float x = self.view.bounds.origin.x;
    float y = self.view.bounds.origin.y;
    float addWH = 2;
    
    CGPoint topLeft      = self.view.bounds.origin;
    CGPoint topMiddle = CGPointMake(x+(width/2),y-addWH);
    CGPoint topRight     = CGPointMake(x+width,y);
    CGPoint rightMiddle = CGPointMake(x+width+addWH,y+(height/2));
    CGPoint bottomRight  = CGPointMake(x+width,y+height);
    CGPoint bottomMiddle = CGPointMake(x+(width/2),y+height+addWH);
    CGPoint bottomLeft   = CGPointMake(x,y+height);
    CGPoint leftMiddle = CGPointMake(x-addWH,y+(height/2));
    
    [path moveToPoint:topLeft];
    //添加四个二元曲线
    [path addQuadCurveToPoint:topRight
                 controlPoint:topMiddle];
    [path addQuadCurveToPoint:bottomRight
                 controlPoint:rightMiddle];
    [path addQuadCurveToPoint:bottomLeft
                 controlPoint:bottomMiddle];
    [path addQuadCurveToPoint:topLeft
                 controlPoint:leftMiddle];
    //设置阴影路径
    self.view.layer.shadowPath = path.CGPath;
    
    for (int i = 0 ; i < titleArray.count; i++) {
        UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonItem.tag = i ;
        buttonItem.frame = CGRectMake(0, (_lineHeight + _itemHeight) * i, ITEM_WIDTH, _itemHeight);
        [buttonItem setTitle:titleArray[i] forState:UIControlStateNormal];
        [buttonItem setBackgroundColor:color];
        buttonItem.titleLabel.font = font;
        [buttonItem addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.backGroundView addSubview:buttonItem];
    }
}

- (void)setLineColor:(UIColor *)lineColor {
    [self.backGroundView setBackgroundColor:lineColor];
}

- (void)buttonClick:(UIButton *)sender {
    [self disapperView];
    if ([self.delegate respondsToSelector:@selector(menuView:didSelectedItemAtline:) ]) {
        [self.delegate menuView:self didSelectedItemAtline:sender.tag];
    }
}

- (void)clickTap {
    [self disapperView];
}

@end
