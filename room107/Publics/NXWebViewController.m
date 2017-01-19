//
//  NXWebViewController.m
//  room107
//
//  Created by ningxia on 15/9/9.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "NXWebViewController.h"
#import "NSString+Encoded.h"

static NSString *metaNameKey = @"share-info";
static NSString *metaDataTitleKey = @"data-title";
static NSString *metaDataDesKey = @"data-des";
static NSString *metaDataImageUrlKey = @"data-image-url";
static NSString *metaDataTargetUrlKey = @"data-target-url";
static NSString *javaScriptKey = @"document.getElementsByName(\"%@\")[0].getAttribute(\"%@\")";

@interface NXWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) NSString *webTitle;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *metaDataTitle;
@property (nonatomic, strong) NSString *metaDataDes;
@property (nonatomic, strong) NSString *metaDataImageUrl;
@property (nonatomic, strong) NSString *metaDataTargetUrl;

@end

@implementation NXWebViewController

- (void)setUrl:(NSURL *)url {
    _url = url;
    if (_webView != nil) {
        [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self != nil) {
        _url = url;
    }
    return self;
}

/*
 URLParams:{
 title = "\U7b7e\U7ea6\U8bf4\U660e";
 url = "http%3A%2F%2F107room.com%2Fapp%2Fhtml%2Fexplanation%2Fcontract";
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
    if (URLParams) {
        _webTitle = URLParams[@"title"] ? [URLParams[@"title"] URLDecodedString] : @"";
        _url = [NSURL URLWithString:URLParams[@"url"] ? [URLParams[@"url"] URLDecodedString] : @""];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:[CommonFuncs tableViewFrame]];
    _webView.delegate = self;
    _webView.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
    [self.view addSubview:_webView];
//    _webView.scalesPageToFit = YES;
//    _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self setTitle:_webTitle];
    
    if (_url != nil) {
        NSMutableDictionary *parameters = [[Client sharedClient] baseParameters];
        NSArray *keys = [parameters allKeys];
        if (keys.count > 0) {
            NSString *urlString = _url.absoluteString;
            NSUInteger i = 0;
            if (!_url.query) {
                //无query参数
                urlString = [urlString stringByAppendingFormat:@"/?%@=%@", [keys objectAtIndex:0], [parameters objectForKey:[keys objectAtIndex:0]]];
                i = 1;
            }
            
            for (; i < keys.count; i++) {
                urlString = [urlString stringByAppendingFormat:@"&%@=%@", [keys objectAtIndex:i], [parameters objectForKey:[keys objectAtIndex:i]]];
            }
            // a character set containing the characters allowed in an URL's query component.
            urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            _url = [[NSURL alloc] initWithString:urlString ? urlString : @""];
        }
        [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    _metaDataTitle = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:javaScriptKey, metaNameKey, metaDataTitleKey]];
    _metaDataDes = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:javaScriptKey, metaNameKey, metaDataDesKey]];
    _metaDataImageUrl = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:javaScriptKey, metaNameKey, metaDataImageUrlKey]];
    _metaDataTargetUrl = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:javaScriptKey, metaNameKey, metaDataTargetUrlKey]];
    
    if (!_webTitle || _webTitle.length == 0) {
        [self setTitle:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
    }
    
    if (_metaDataTargetUrl && ![_metaDataTargetUrl isEqualToString:@""]) {
        //有可跳转的URL,可分享
        [self showShareButtonItem];
    } else {
        //无可跳转的URL，不可分享
        [self hideShareButtonItem];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideLoadingView];
    
    [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
        [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    }];
}

- (void)showShareButtonItem {
    [self setRightBarButtonTitle:lang(@"Share")];
}

- (void)hideShareButtonItem {
    [self setRightBarButtonTitle:nil];
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    [self shareButtonDidClicked];
}

- (void)shareButtonDidClicked {
    //避免部分特殊格式数据无法解析
    [[NXURLHandler sharedInstance] handleOpenURL:shareURI params:@{@"title":_metaDataTitle ? [_metaDataTitle URLEncodedString] : @"", @"content":_metaDataDes ? [_metaDataDes URLEncodedString] : @"", @"imageUrl":_metaDataImageUrl ? _metaDataImageUrl : @"", @"targetUrl":_metaDataTargetUrl ? _metaDataTargetUrl : @""} context:self];
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
