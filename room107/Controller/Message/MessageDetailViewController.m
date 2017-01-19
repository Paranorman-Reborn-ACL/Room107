//
//  MessageDetailViewController.m
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "SystemAgent.h"
#import "ListOneTableViewCell.h"
#import "PriceOneTableViewCell.h"
#import "Room107TableView.h"
#import "RoundedGreenButton.h"
#import "SuiteAgent.h"
#import "TimeUtil.h"

@interface MessageDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSNumber *messageID;
@property (nonatomic, strong) MessageInfoModel *message;
@property (nonatomic, strong) Room107TableView *messageTableView;
@property (nonatomic, strong) ListOneTableViewCell *listOneTableViewCell;
@property (nonatomic, strong) NSDictionary *currentButtonInfo;

@end

@implementation MessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _listOneTableViewCell = [[ListOneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListOneTableViewCell"];
    
    [self getMessageDetail];
}

- (id)initWithMessageID:(NSNumber *)messageID {
    self = [super init];
    if (self != nil) {
        _messageID = messageID;
    }
    
    return self;
}

/*
 URLParams:{
 messageId = 10001;
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
    _messageID = URLParams[@"messageId"];
}

- (void)getMessageDetail {
    [self showLoadingView];
    [[SystemAgent sharedInstance] getMessageDetailWithMessageID:_messageID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, MessageInfoModel *message) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            _message = message;
            [self setTitle:_message.title];
            
            if (!_messageTableView) {
                _messageTableView = [[Room107TableView alloc] initWithFrame:[CommonFuncs tableViewFrame]];
                _messageTableView.delegate = self;
                _messageTableView.dataSource = self;
                _messageTableView.tableHeaderView = [self createTableHeaderView];
                _messageTableView.tableFooterView = [self createTableFooterView];
                [self.view addSubview:_messageTableView];
            }
            [_messageTableView reloadData];
        } else {
            if (!_message) {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                        [self getMessageDetail];
                    }];
                } else {
                    
                    [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                        [self getMessageDetail];
                    }];
                }
            }
        }
    }];
}

- (UIView *)createTableHeaderView {
    CGFloat originX = 22;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont room107SystemFontThree],
                                 NSParagraphStyleAttributeName:paragraphStyle};
    CGRect contentRect = [_message.content boundingRectWithSize:(CGSize){[[UIScreen mainScreen] bounds].size.width - 2 * originX, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    CGFloat labelHeight = 20;
    CGFloat originY = 0;
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, originY, self.view.bounds.size.width, contentRect.size.height + 2 * labelHeight + 22}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    originY = 6;
    SearchTipLabel *timeLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, headerView.frame.size.width - 2 * originX, labelHeight}];
    [timeLabel setFont:[UIFont room107FontTwo]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    [timeLabel setText:[TimeUtil friendlyDateTimeFromDateTime:_message.timestamp withFormat:@"%Y/%m/%d %H:%M"]];
    [headerView addSubview:timeLabel];
    
    originY += labelHeight + 5;
    SearchTipLabel *contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, headerView.frame.size.width - 2 * originX, contentRect.size.height}];
    [contentLabel setTextColor:[UIColor room107GrayColorD]];
    contentLabel.attributedText = [[NSAttributedString alloc] initWithString:_message.content ? _message.content : @"" attributes:attributes];
    [headerView addSubview:contentLabel];
    
    return headerView;
}

- (UIView *)createTableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 100.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    NSString *mainButtonTitle = @"";
    NSString *assistantButtonTitle = @"";
    for (NSDictionary *button in _message.buttons) {
        if ([button[@"style"] isEqual:@0]) {
            //账单通知类消息会有2个style为0的按钮
            mainButtonTitle = button[@"name"];
        } else {
            assistantButtonTitle = button[@"name"];
        }
    }
    
    CGFloat originY = CGRectGetHeight(footerView.bounds) - 100;
    CGRect frame = (CGRect){0, originY, CGRectGetWidth(footerView.bounds), 100};
    SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:mainButtonTitle andAssistantButtonTitle:assistantButtonTitle];
    [footerView addSubview:mutualBottomView];
    [mutualBottomView setMainButtonDidClickHandler:^{
        for (NSDictionary *button in _message.buttons) {
            if ([button[@"style"] isEqual:@0]) {
                if (button[@"alert"]) {
                    [self showAlertViewWithButtonInfo:button];
                } else {
                    [self goToTargetWithButtonInfo:button];
                }
            }
        }
    }];
    [mutualBottomView setAssistantButtonDidClickHandler:^{
        for (NSDictionary *button in _message.buttons) {
            if ([button[@"style"] isEqual:@1]) {
                if (button[@"alert"]) {
                    [self showAlertViewWithButtonInfo:button];
                } else {
                    [self goToTargetWithButtonInfo:button];
                }
            }
        }
    }];
    
    return footerView;
}

- (void)goToTargetWithButtonInfo:(NSDictionary *)button {
    if ([button[@"targetType"] isEqual:@0]) {
        //REDIRECT，根据uri跳转到相应页面
        [[NXURLHandler sharedInstance] handleOpenURL:button[@"uri"] params:button[@"params"] context:self];
    } else {
        NSString *module = [[NSURL URLWithString:button[@"uri"]] host];
        if ([module isEqualToString:@"houseCancelSubscribe"]) {
            [self showLoadingView];
            [[SuiteAgent sharedInstance] cancelSubscribeWithID:button[@"params"] ? button[@"params"][@"id"] : nil completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                [self hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                
                if (!errorCode) {
                    //BACKGRAND，根据uri启动后台任务，成功后展示successNote
                    [PopupView showMessage:button[@"successNote"]];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:CancelSubscribeSuccessNotification object:self];
                }
            }];
        }
    }
}

- (void)showAlertViewWithButtonInfo:(NSDictionary *)button {
    UIAlertView *buttonAlertView = [[UIAlertView alloc] initWithTitle:button[@"alert"]
                                                                     message:lang(@"")
                                                                    delegate:self
                                                           cancelButtonTitle:lang(@"Cancel")
                                                           otherButtonTitles:lang(@"Confirm"), nil];
    [buttonAlertView show];
    _currentButtonInfo = button;
}

#pragma mark - UIAlertViewDelegate
//根据被点击按钮的索引处理点击事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self goToTargetWithButtonInfo:_currentButtonInfo];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)_message.cards count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *card = _message.cards[indexPath.row];
    if ([card[@"template"] isEqual:@0]) {
        ListOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListOneTableViewCell"];
        if (!cell) {
            cell = [[ListOneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListOneTableViewCell"];
        }
        
        [cell setCard:card];
        
        return cell;
    } else {
        PriceOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PriceOneTableViewCell"];
        if (!cell) {
            cell = [[PriceOneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PriceOneTableViewCell"];
        }
        
        [cell setCard:card];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *card = _message.cards[indexPath.row];
    if ([card[@"template"] isEqual:@0]) {
        return [_listOneTableViewCell heightByCard:card];
    } else {
        return priceOneTableViewCellHeight;
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
