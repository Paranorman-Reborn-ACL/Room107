//
//  CMBNetPayViewController.m
//  room107
//
//  Created by 107间 on 16/1/28.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "CMBNetPayViewController.h"
#import "NSString+Encoded.h"

@interface CMBNetPayViewController () <UIWebViewDelegate>

@property (nonatomic, strong) NSURL *CMBURL;
@property (nonatomic, strong) UIWebView *CMBNetPayWebView;
@property (nonatomic) BOOL isFirstLoadSuccess; //初次加载html成功

@end

@implementation CMBNetPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:lang(@"CMBPayViaPhone")];
    
    _CMBNetPayWebView = [[UIWebView alloc] initWithFrame:[CommonFuncs tableViewFrame]];
    _CMBNetPayWebView.delegate = self;
    [self.view addSubview:_CMBNetPayWebView];
    NSURLRequest *request = [NSURLRequest requestWithURL:_CMBURL];
    [_CMBNetPayWebView loadRequest:request];
}

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        NSString *urlString = [NSString stringWithFormat:@"%@?%@", params[@"url"], params[@"params"]];
        _CMBURL = [NSURL URLWithString:urlString];
        _isFirstLoadSuccess = NO;
    }
    return self;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [[NXURLHandler sharedInstance] handleOpenURL:[request.URL absoluteString] params:nil context:self];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self showLoadingView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideLoadingView];
    _isFirstLoadSuccess = YES;
    //隐藏跳转至App的TipBar
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"CallMBankClientTipBar\").style.display=\"none\""];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideLoadingView];
    if (!_isFirstLoadSuccess) {
        [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
            [_CMBNetPayWebView loadRequest:[NSURLRequest requestWithURL:_CMBURL]];
        }];
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
