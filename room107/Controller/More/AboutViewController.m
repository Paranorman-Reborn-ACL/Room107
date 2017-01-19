//
//  AboutViewController.m
//  room107
//
//  Created by ningxia on 15/7/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "AboutViewController.h"
#import "CustomTextField.h"
#import "CustomTextView.h"
#import "CustomImageView.h"
#import "SuperAccountViewController.h"

@interface AboutViewController ()

@property (nonatomic, strong) CustomTextField *baseDomainTextField;
@property (nonatomic) NSUInteger tapCount; //单击数，方便调出切换服务器的彩蛋
@property (nonatomic, strong) UIScrollView *bacgGroundScroll;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"AboutUs")];
    
    self.bacgGroundScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _bacgGroundScroll.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_bacgGroundScroll];
    
    CGFloat originX = 10.0f;
    CGFloat originY = 22.0f;
    CGFloat imageViewWidth = 135;
    CGFloat imageViewHeight = 30;
    CustomImageView *logoImageView = [[CustomImageView alloc] initWithFrame:(CGRect){self.view.center.x - imageViewWidth / 2, originY, imageViewWidth, imageViewHeight}];
    [logoImageView setImageWithName:@"开机logo"];
    [_bacgGroundScroll addSubview:logoImageView];
    
    originY += imageViewHeight + 11;
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(self.view.bounds), 14}];
    [versionLabel setBackgroundColor:[UIColor clearColor]];
    versionLabel.font = [UIFont room107SystemFontTwo];
    versionLabel.textColor = [UIColor room107GrayColorC];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.text = [lang(@"Version") stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    [_bacgGroundScroll addSubview:versionLabel];
    
    originY += CGRectGetHeight(versionLabel.bounds) + 22;
    CGRect frame = self.view.frame;
    frame.origin.x += originX;
    frame.origin.y += originY;
    frame.size.width -= 2 * originX;
    frame.size.height = CGRectGetHeight(self.view.bounds) - statusBarHeight - navigationBarHeight - originY - 50;
    CustomTextView *textView = [[CustomTextView alloc] initWithFrame:frame hasDoneButton:NO];
    textView.scrollEnabled = NO;
    [textView setBackgroundColor:[UIColor clearColor]];
    textView.editable = NO;
    [_bacgGroundScroll addSubview:textView];
    
    NSString *text = lang(@"AboutInfo");
    frame = textView.frame;
    frame.size.height = [textView getContentRectWithText:text].size.height + 30;
    textView.frame = frame;
    [textView setAttributedText:[[NSAttributedString alloc] initWithString:text ? text : @"" attributes:[textView attributes]]];
    [textView setFrame:frame];
    
    CGFloat imageWidth = self.view.frame.size.width - 44;
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(22, CGRectGetMaxY(textView.frame) + 44, imageWidth, imageWidth * 193/551)];
    [topImageView setImage:[UIImage imageNamed:@"cooperation"]];
    [_bacgGroundScroll addSubview:topImageView];
    
    UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(22, CGRectGetMaxY(topImageView.frame) + 44, imageWidth, imageWidth * 120/544)];
    [downImageView setImage:[UIImage imageNamed:@"media"]];
    [_bacgGroundScroll addSubview:downImageView];
    
    UILabel *copyRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(downImageView.frame) + 44, self.view.frame.size.width, 25)];
    [copyRightLabel setBackgroundColor:[UIColor clearColor]];
    copyRightLabel.font = [UIFont room107SystemFontOne];
    copyRightLabel.textColor = [UIColor room107GrayColorC];
    copyRightLabel.textAlignment = NSTextAlignmentCenter;
    copyRightLabel.text = lang(@"CopyRight");
    [_bacgGroundScroll addSubview:copyRightLabel];
    
    UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidClick)];
    copyRightLabel.userInteractionEnabled = YES;
    [copyRightLabel addGestureRecognizer:tapGestureRecgnizer];

    _tapCount = 0;
    [_bacgGroundScroll setContentSize:CGSizeMake(0, CGRectGetMaxY(copyRightLabel.frame) + navigationBarHeight + statusBarHeight + 44)];
//    if (self.view.frame.size.height < CGRectGetMaxY(copyRightLabel.frame) + navigationBarHeight + statusBarHeight ) {
//        //内容超出屏幕
//        [_bacgGroundScroll setContentSize:CGSizeMake(0, CGRectGetMaxY(copyRightLabel.frame) + navigationBarHeight + statusBarHeight + 44)];
//    } else {
//        //内容未超出屏幕
//        [copyRightLabel setFrame:CGRectMake(frame.origin.x, self.view.frame.size.height - 44 - frame.size.height - navigationBarHeight - statusBarHeight, frame.size.width, frame.size.height)];
//    }
    
}

- (void)viewDidClick {
    _tapCount++;
    if (_tapCount > 15) {
        [self.navigationController pushViewController:[[SuperAccountViewController alloc] init] animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
