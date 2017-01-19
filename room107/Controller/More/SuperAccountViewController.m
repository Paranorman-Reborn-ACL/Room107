//
//  SuperAccountViewController.m
//  room107
//
//  Created by ningxia on 16/1/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SuperAccountViewController.h"
#import "CustomTextField.h"

@interface SuperAccountViewController ()

@property (nonatomic, strong) UILabel *UUIDLabel;
@property (nonatomic, strong) UILabel *serverLabel;
@property (nonatomic, strong) UIButton *myServerButton;
@property (nonatomic, strong) UIButton *changeToTestButton;
@property (nonatomic, strong) UIButton *changeToServerButton;
@property (nonatomic, strong) CustomTextField *serverTextField;

@end

@implementation SuperAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"SuperAccount")];
    
    CGFloat originX = 10.0f;
    CGFloat buttonHeight = 25.0f;
    CGFloat buttonWidth = 50.0f;
    CGFloat originY = statusBarHeight;
    UIButton *newUserButton = [[UIButton alloc] initWithFrame:(CGRect){originX, originY, 2 * buttonWidth, buttonHeight}];
    [newUserButton setTitle:@"纯净的小七" forState:UIControlStateNormal];
    [newUserButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [newUserButton addTarget:self action:@selector(newUserButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newUserButton];
    
    originY += 2 * buttonHeight;
    UIButton *deityButton = [[UIButton alloc] initWithFrame:(CGRect){originX, originY, 2 * buttonWidth, buttonHeight}];
    [deityButton setTitle:@"本尊" forState:UIControlStateNormal];
    [deityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deityButton addTarget:self action:@selector(deityButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deityButton];
    
    originY += 2 * buttonHeight;
    _UUIDLabel = [[UILabel alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth(self.view.bounds) - 2 * originX, buttonHeight}];
    [_UUIDLabel setBackgroundColor:[UIColor clearColor]];
    _UUIDLabel.font = [UIFont room107SystemFontThree];
    _UUIDLabel.textColor = [UIColor room107GrayColorD];
    _UUIDLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_UUIDLabel];
    NSString *UUIDString = [Room107UserDefaults getValueFromUserDefaultsWithKey:KEY_UUIDString];
    [_UUIDLabel setText:UUIDString ? UUIDString : [UIDevice currentDevice].identifierForVendor.UUIDString];
    
    originY += 2 * buttonHeight;
    originX = 10.0f;
    _serverTextField = [[CustomTextField alloc] initWithFrame:(CGRect){originX, originY - 5, CGRectGetWidth(self.view.bounds) - 2 * originX - buttonWidth, buttonHeight + 10}];
    [self.view addSubview:_serverTextField];
    
    UIButton *changeButton = [[UIButton alloc] initWithFrame:(CGRect){originX + CGRectGetWidth(_serverTextField.bounds), originY, buttonWidth, buttonHeight}];
    [changeButton setTitle:@"切换" forState:UIControlStateNormal];
    [changeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    
    originY += CGRectGetHeight(_serverTextField.bounds) + 10;
    _serverLabel = [[UILabel alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth(self.view.bounds) - 2 * originX, buttonHeight}];
    [_serverLabel setBackgroundColor:[UIColor clearColor]];
    _serverLabel.font = [UIFont room107SystemFontThree];
    _serverLabel.textColor = [UIColor room107GrayColorD];
    _serverLabel.textAlignment = NSTextAlignmentLeft;
    [_serverLabel setText:[[AppClient sharedInstance] baseDomain]];
    [self.view addSubview:_serverLabel];
    
    originY = CGRectGetHeight(self.view.bounds) - statusBarHeight - navigationBarHeight - 2 * buttonHeight;
    _myServerButton = [[UIButton alloc] initWithFrame:(CGRect){originX, originY, 2 * buttonWidth, buttonHeight}];
    [_myServerButton setTitle:@"我的服务器" forState:UIControlStateNormal];
    [_myServerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_myServerButton addTarget:self action:@selector(myServerButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_myServerButton];
    
    originX += 2 * buttonWidth;
    _changeToTestButton = [[UIButton alloc] initWithFrame:(CGRect){originX, originY, 2 * buttonWidth, buttonHeight}];
    [_changeToTestButton setTitle:@"线上101" forState:UIControlStateNormal];
    [_changeToTestButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_changeToTestButton addTarget:self action:@selector(changeToTestButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_changeToTestButton];
    
    originX += 2 * buttonWidth;
    _changeToServerButton = [[UIButton alloc] initWithFrame:(CGRect){originX, originY, 2 * buttonWidth, buttonHeight}];
    [_changeToServerButton setTitle:@"正式服务器" forState:UIControlStateNormal];
    [_changeToServerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_changeToServerButton addTarget:self action:@selector(changeToServerButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_changeToServerButton];
    
    originY -= buttonHeight + statusBarHeight;
    UIButton *haiXiButton = [[UIButton alloc] initWithFrame:(CGRect){originX, originY, 3 * buttonWidth, buttonHeight}];
    [haiXiButton setTitle:@"赵海曦's Server" forState:UIControlStateNormal];
    [haiXiButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [haiXiButton addTarget:self action:@selector(haiXiButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:haiXiButton];
    
    UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controlsResignFirstResponder)];
    [self.view addGestureRecognizer:tapGestureRecgnizer];
}

- (void)controlsResignFirstResponder {
    [_serverTextField resignFirstResponder];
}

- (IBAction)newUserButtonDidClick:(id)sender {
    //模拟生成一个全新的UUID
    NSString *UUIDString = [@"107107" stringByAppendingFormat:@"_%.f000%@", [NSDate date].timeIntervalSince1970, [UIDevice currentDevice].identifierForVendor.UUIDString];
    [_UUIDLabel setText:UUIDString];
    [Room107UserDefaults saveUserDefaultsWithKey:KEY_UUIDString andValue:UUIDString];
}

- (IBAction)deityButtonDidClick:(id)sender {
    NSString *UUIDString = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [_UUIDLabel setText:UUIDString];
    [Room107UserDefaults saveUserDefaultsWithKey:KEY_UUIDString andValue:UUIDString];
}

- (IBAction)changeToTestButtonDidClick:(id)sender {
    [[AppClient sharedInstance] changeBaseDomain:@"http://101.200.204.65"];
    [self resetApp];
}

- (IBAction)changeToServerButtonDidClick:(id)sender {
    [[AppClient sharedInstance] changeBaseDomain:@"http://107room.com"];
    [self resetApp];
}

- (IBAction)myServerButtonDidClick:(id)sender {
    [[AppClient sharedInstance] changeBaseDomain:@"http://192.168.88.15:8081"];
    [self resetApp];
}

- (IBAction)haiXiButtonDidClick:(id)sender {
    [[AppClient sharedInstance] changeBaseDomain:@"http://192.168.88.9:80"];
    [self resetApp];
}

- (IBAction)changeButtonDidClick:(id)sender {
    [[AppClient sharedInstance] changeBaseDomain:_serverTextField.text];
    [self resetApp];
}

- (void)resetApp {
    [_serverLabel setText:[[AppClient sharedInstance] baseDomain]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ClientDidLogoutNotification object:self];
    [App clearPersistentStore]; //清空本地数据库数据
    [self pushLoginAndRegisterViewController];
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
