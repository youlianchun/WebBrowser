//
//  ViewController.m
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/23.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "WKWebControlle.h"
#import "UIViewController+FullScreen.h"

@interface WKWebControlle () <WKWebNavigationDelegate, WKUIDelegate>
@property (nonatomic, retain) WebView *webView;
@property (nonatomic, retain) UIProgressView * progressView;
@property (nonatomic, assign) BOOL isVisible;
@end

@implementation WKWebControlle

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.tintColor = [UIColor greenColor];
        [self.view addSubview:_progressView];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    }
    return _progressView;
}

-(WebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        // 允许在线播放
        configuration.allowsInlineMediaPlayback = YES;
        // 允许可以与网页交互，选择视图
        configuration.selectionGranularity = YES;
        // web内容处理池
        configuration.processPool = [[WKProcessPool alloc] init];
        // 是否支持记忆读取
        configuration.suppressesIncrementalRendering = YES;
        // 设置是否允许自动播放
        configuration.mediaPlaybackRequiresUserAction = YES;//一定要在 WKWebView 初始化之前设置，在 WKWebView 初始化之后设置无效。
        // 偏好设置
        WKPreferences *preferences = [[WKPreferences alloc] init];
        preferences.javaScriptCanOpenWindowsAutomatically = NO;
        configuration.preferences = preferences;
        //        preferences.minimumFontSize = 40.0;
//        ScriptMessageManager *jsmm = [self scriptMessageManagerWhenWebViewInit];
//        if (jsmm) {
//            configuration.userContentController = jsmm;
//        }
        _webView = [[WebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        //开启手势返回
        _webView.allowsBackForwardNavigationGestures = true;
        _webView.UIDelegate = self;
        if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 9.0)) {
            //3D Touch 9.0之后
            _webView.allowsLinkPreview = NO;
        }
        _webView.navigationDelegate = self;
        [self.view insertSubview:_webView atIndex:0];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    }
    return _webView;
}

-(NSURL*)urlWithString:(NSString*)url {
    NSString *tmpStr = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (tmpStr.length == 0) {
        return nil;
    }
    NSString *str = [tmpStr lowercaseString];
    if ([str hasPrefix:@"/"] ) {
        tmpStr = [NSString stringWithFormat:@"file://%@", tmpStr];
    }else if([str hasPrefix:@"file://"]){
    }else {
        if (![str hasPrefix:@"http"]) {
            tmpStr = [NSString stringWithFormat:@"http://%@", url];
        }
    }
    NSURL *anUrl = [NSURL URLWithString:tmpStr];
    return anUrl;
}


-(void)loadWithUrl:(id)url params:(NSDictionary*)params {
    NSURL *anUrl;
    if ([url isKindOfClass:[NSString class]]) {
        anUrl = [self urlWithString:url];
    }
    if ([url isKindOfClass:[NSURL class]]) {
        anUrl = url;
    }
    if (anUrl) {
        [self.webView stopLoading];
        NSString *str = [anUrl.absoluteString lowercaseString];
        BOOL loactionUrl = [str hasPrefix:@"/"] || [str hasPrefix:@"file://"];
        if (loactionUrl) {
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
                [self.webView loadFileURL:url allowingReadAccessToURL:url];
            }else{
                NSURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                [self.webView loadRequest:request];
            }
        }else{
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:anUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
            if (params) {
                request.HTTPMethod = @"POST";
                NSString* param;
                NSArray *allKeys = params.allKeys;
                if(allKeys.count==0){
                    param = @"";
                }else{
                    NSMutableArray *keyValue = [NSMutableArray array];
                    for (NSString* key in allKeys) {
                        [keyValue addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
                    }
                    param = [keyValue componentsJoinedByString:@"&"];
                }
                [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [self.webView loadRequest:request];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //到在一个高内存消耗的H5页面上 present 系统相机，拍照完毕后返回原来页面的时候出现白屏现象（拍照过程消耗了大量内存，导致内存紧张，WebContent Process 被系统挂起），但上面的回调函数并没有被调用。在WKWebView白屏的时候，另一种现象是 webView.titile 会被置空, 因此，可以在 viewWillAppear 的时候检测 webView.title 是否为空来 reload 页面
    if (!self.webView.title && self.webView.URL.absoluteString.length>0) {
        [self.webView reload];
    }
    self.isVisible = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isVisible = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

#pragma mark -
#pragma mark - WKNavigationDelegate
@implementation WKWebControlle(WKNavigationDelegate)

- (void)webView:(WebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.progressView.hidden = NO;
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(webControllerDidStartLoad:)]) {
        [self.delegate webControllerDidStartLoad:self];
    }
}

- (void)webView:(WebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(webControllerDidCommitLoad:)]) {
        [self.delegate webControllerDidCommitLoad:self];
    }
}

- (void)webView:(WebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (webView.title.length > 0) {
        self.title = webView.title;
    }
    self.backPanEnabled = !self.webView.canGoBack;
    self.progressView.hidden = YES;
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(webControllerDidFinishLoad:)]) {
        [self.delegate webControllerDidFinishLoad:self];
    }
}

- (void)webView:(WebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.progressView.hidden = YES;
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(webController:didFailLoadWithError:)]) {
        [self.delegate webController:self didFailLoadWithError:error];
    }
}

- (void)webView:(WebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    //当客户端收到服务器的响应头，根据response相关信息，可以决定这次跳转是否可以继续进行。
    BOOL b = YES;
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(webController:shouldContinueLoadWithResponse:)]) {
        b = [self.delegate webController:self shouldContinueLoadWithResponse:navigationResponse.response];
    }
    if (b) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }else{
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}

-(void)webView:(WebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    BOOL b = YES;//[self decidePolicyForNavigationAction:navigationAction];
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(webController:shouldStartLoadWithRequest:navigationType:)]) {
        b = [self.delegate webController:self shouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    }
    decisionHandler(b);
}

-(WKWebView *)webView:(WebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    BOOL b = NO;
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(webController:shouldCreateWebViewWithRequest:navigationType:)]) {
       b = [self.delegate webController:self shouldCreateWebViewWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    }
    if (b && self.delegateEnabled && [self.delegate respondsToSelector:@selector(webController:createWebViewWithRequest:navigationType:)]) {
        [self.delegate webController:self createWebViewWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
        return nil;
    }
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}


-(void)webView:(WebView *)webView estimatedProgress:(double)progress {
    [self.progressView setProgress:progress animated:YES];
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(webController:estimatedProgress:)]) {
        [self.delegate webController:self estimatedProgress:progress];
    }
}

-(void)webView:(WebView *)webView canGoBackChange:(BOOL)canGoBack {
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(webController:canGoBackChange:)]) {
        [self.delegate webController:self canGoBackChange:canGoBack];
    }
}

-(void)webView:(WebView *)webView canGoForwardChange:(BOOL)canGoForward {
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(webController:canGoForwardChange:)]) {
        [self.delegate webController:self canGoForwardChange:canGoForward];
    }
}

// https 支持
- (void)webView:(WebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSLog(@"https证书");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

- (void)webViewWebContentProcessDidTerminate:(WebView *)webView {
    //    当 WKWebView 总体内存占用过大，页面即将白屏的时候，系统会调用上面的回调函数，我们在该函数里执行[webView reload](这个时候 webView.URL 取值尚不为 nil）解决白屏问题。在一些高内存消耗的页面可能会频繁刷新当前页面，H5侧也要做相应的适配操作。
    [webView reload];
}

@end


#pragma mark -
#pragma mark - WKUIDelegate
@implementation WKWebControlle(WKUIDelegate)

- (void)webView:(WebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // js 里面的alert实现，如果不实现，网页的alert函数无效
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    
    if (self.isVisible){//控制器不在显示时候不进行弹出操作
        [self presentViewController:alertController animated:YES completion:^{}];
    }else {
        completionHandler();
    }
}


- (void)webView:(WebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    //  js 里面的alert实现，如果不实现，网页的alert函数无效  ,
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          completionHandler(NO);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    
    if (self.isVisible){//控制器不在显示时候不进行弹出操作
        [self presentViewController:alertController animated:YES completion:^{}];
    }else {
        completionHandler(NO);
    }
    
}

- (void)webView:(WebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
        textField.placeholder = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                            completionHandler([[alertController.textFields lastObject] text]);
                                                        }]];
    
    if (self.isVisible){//控制器不在显示时候不进行弹出操作
        [self presentViewController:alertController animated:YES completion:^{}];
    }else {
        completionHandler(nil);
    }
}

@end

