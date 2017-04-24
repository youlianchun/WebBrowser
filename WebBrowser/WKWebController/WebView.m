//
//  WebView.m
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/24.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "WebView.h"
#import <objc/runtime.h>

static NSString* kWebViewEstimatedProgress = @"estimatedProgress";
static NSString*  kWebViewCanGoBack = @"canGoBack";
static NSString*  kWebViewCanGoForward = @"canGoForward";

@interface WebView ()
@property (nonatomic, readwrite, weak) id navigationDelegateReceiver;
@property (nonatomic, readwrite, weak) id UIDelegateReceiver;
@property (nonatomic) BOOL didInit;
@property (nonatomic, assign) BOOL observerEnabled;
@end

@implementation WebView

+ (void)load {
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"WKContentView");
        SEL isSecureTextEntry = NSSelectorFromString(@"isSecureTextEntry");
        SEL secureTextEntry = NSSelectorFromString(@"secureTextEntry");
        BOOL addIsSecureTextEntry = class_addMethod(class, isSecureTextEntry, (IMP)secureTextEntryIMP, "B@:");
        BOOL addSecureTextEntry = class_addMethod(class, secureTextEntry, (IMP)secureTextEntryIMP, "B@:");
        if (!addIsSecureTextEntry || !addSecureTextEntry) {
            NSLog(@"WKContentView-Crash->修复失败");
        }
    });
}

BOOL secureTextEntryIMP(id sender, SEL cmd) {
    return NO;
}

+(NSArray*)infoUrlSchemes{
    static NSMutableArray *kInfoUrlSchemes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kInfoUrlSchemes = [NSMutableArray array];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSMutableDictionary *dict  = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSArray *urlTypes = dict[@"CFBundleURLTypes"];
        for (NSDictionary *urlType in urlTypes) {
            [kInfoUrlSchemes addObjectsFromArray:urlType[@"CFBundleURLSchemes"]];
        }
    });
    return kInfoUrlSchemes;
}

+(NSArray*)infoOpenURLs{
    static NSMutableArray *kInfoOpenURLs;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kInfoOpenURLs = [NSMutableArray array];
        [kInfoOpenURLs addObject:@"tel"];
        [kInfoOpenURLs addObject:@"telprompt"];
        [kInfoOpenURLs addObject:@"sms"];
        [kInfoOpenURLs addObject:@"mailto"];
    });
    return kInfoOpenURLs;
}

#pragma mark - init dalloc
-(instancetype)init {
    self = [super init];
    if (self) {
        [self customIntitialization];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self customIntitialization];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customIntitialization];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        [self customIntitialization];
    }
    return self;
}

-(void)dealloc {
    self.observerEnabled = NO;
}

- (void)customIntitialization{
    if (!self.didInit) {
        self.didInit = YES;
        self.navigationDelegate = nil;
        self.UIDelegate = nil;
        self.observerEnabled = YES;
    }
}

#pragma mark - 观察者
-(void)setObserverEnabled:(BOOL)observerEnabled {
    if (_observerEnabled == observerEnabled) {
        return;
    }
    _observerEnabled = observerEnabled;
    if (observerEnabled) {
        [self addObserver:self forKeyPath:kWebViewEstimatedProgress options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:kWebViewCanGoBack options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:kWebViewCanGoForward options:NSKeyValueObservingOptionNew context:nil];
    }else{
        [self removeObserver:self forKeyPath:kWebViewEstimatedProgress];
        [self removeObserver:self forKeyPath:kWebViewCanGoBack];
        [self removeObserver:self forKeyPath:kWebViewCanGoForward];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:kWebViewEstimatedProgress] && [self.navigationDelegate respondsToSelector:@selector(webView:estimatedProgress:)]) {
        [self.navigationDelegate webView:self estimatedProgress:self.estimatedProgress];
        return;
    }
    if ([keyPath isEqualToString:kWebViewCanGoBack] && [self.navigationDelegate respondsToSelector:@selector(webView:canGoBackChange:)]) {
        [self.navigationDelegate webView:self canGoBackChange:self.canGoBack];
        return;
    }
    if ([keyPath isEqualToString:kWebViewCanGoForward]&& [self.navigationDelegate respondsToSelector:@selector(webView:canGoForwardChange:)]) {
        [self.navigationDelegate webView:self canGoForwardChange:self.canGoForward];
        return;
    }
}

#pragma mark - evaluateJavaScript fix

-(void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    id strongSelf = self;
    [super evaluateJavaScript:javaScriptString completionHandler:^(id object, NSError *error) {
        [strongSelf title];
        if (completionHandler) {
            completionHandler(object, error);
        }
    }];
}
#pragma mark - post
-(WKNavigation *)loadRequest:(NSURLRequest *)request {
    if ([[request.HTTPMethod uppercaseString] isEqualToString:@"POST"]){
        NSString *url = request.URL.absoluteString;
        NSString *params = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        if ([params containsString:@"="]) {
            params = [params stringByReplacingOccurrencesOfString:@"=" withString:@"\":\""];
            params = [params stringByReplacingOccurrencesOfString:@"&" withString:@"\",\""];
            params = [NSString stringWithFormat:@"{\"%@\"}", params];
        }else{
            params = @"{}";
        }
        NSString *postJavaScript = [NSString stringWithFormat:@"\
                                    var url = '%@';\
                                    var params = %@;\
                                    var form = document.createElement('form');\
                                    form.setAttribute('method', 'post');\
                                    form.setAttribute('action', url);\
                                    for(var key in params) {\
                                    if(params.hasOwnProperty(key)) {\
                                    var hiddenField = document.createElement('input');\
                                    hiddenField.setAttribute('type', 'hidden');\
                                    hiddenField.setAttribute('name', key);\
                                    hiddenField.setAttribute('value', params[key]);\
                                    form.appendChild(hiddenField);\
                                    }\
                                    }\
                                    document.body.appendChild(form);\
                                    form.submit();", url, params];
        __weak typeof(self) wself = self;
        [self evaluateJavaScript:postJavaScript completionHandler:^(id object, NSError * _Nullable error) {
            if (error && [wself.navigationDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself.navigationDelegate webView:wself didFailProvisionalNavigation:nil withError:error];
                });
            }
        }];
        return nil;
    }else{
        return [super loadRequest:request];
    }
}

#pragma mark - 滚动速率
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}



#pragma mark - js调用
-(NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString {
    __block NSString* result = nil;
    if (javaScriptString.length>0) {
        __block BOOL isExecuted = NO;
        [self evaluateJavaScript:javaScriptString completionHandler:^(id obj, NSError *error) {
            result = obj;
            isExecuted = YES;
        }];
        
        while (isExecuted == NO) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return result;
}

-(id)evaluateJSFunc:(NSString*)func arguments:(NSArray*)arguments {
    NSString *paramsJSON = [self argumentsJS:arguments];
    
    NSString *jsString = [NSString stringWithFormat:@"%@('%@')", func, paramsJSON];
    
    __block id retuenValue;
    
    if ([func containsString:@"."]) {
        NSString *jsonString=[self stringByEvaluatingJavaScriptFromString:jsString];
        if (jsonString.length>0) {
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            retuenValue = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        }
    }else{
        __block BOOL isExecuted = NO;
        [self evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            retuenValue = result;
            isExecuted = YES;
        }];
        while (isExecuted == NO) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return retuenValue;
}
#pragma mark --
-(NSString*)argumentsJS:(NSArray*)arguments {
    NSMutableArray *argumentArray = [NSMutableArray arrayWithCapacity:arguments.count];
    for (int i = 0; i<arguments.count; i++) {
        if ([arguments[i] isKindOfClass:[NSDictionary class]]||[arguments[i] isKindOfClass:[NSArray class]]) {
            NSString *paramsJSON = [self convertToJSONData:arguments[i]];
            paramsJSON = [self JSONString:paramsJSON];
            argumentArray[i] = paramsJSON;
        }else{
            NSString *str = [NSString stringWithFormat:@"'%@'",arguments[i]];
            argumentArray[i] = str;
        }
    }
    NSString *paramStr = [argumentArray componentsJoinedByString:@","];
    return paramStr;
}

//-(NSString*)argumentsJSON:(NSArray*)arguments {
//    NSString *paramsJSON = [self convertToJSONData:arguments];
//    NSRange range= NSMakeRange(1,paramsJSON.length-2);
//    paramsJSON = [paramsJSON substringWithRange:range];
//    paramsJSON = [self JSONString:paramsJSON];
//    return paramsJSON;
//}

-(NSString*)JSONString:(NSString*)string{
    NSString *paramsJSON = string;
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    paramsJSON = [paramsJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    return paramsJSON;
};

- (NSString*)convertToJSONData:(id)dictOrArr {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictOrArr
                                                       options:0
                                                         error:&error];
    NSString *jsonString = @"";
    if (jsonData){
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return jsonString;
}

#pragma mark - 缓存清理
+ (void)clearCache {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        //        NSSet *websiteDataTypes = [NSSet setWithArray:@[
        ////                                                        磁盘缓存
        //                                                        WKWebsiteDataTypeDiskCache,
        //
        ////                                                        离线APP缓存
        //                                                        //WKWebsiteDataTypeOfflineWebApplicationCache,
        //
        ////                                                        内存缓存
        //                                                        WKWebsiteDataTypeMemoryCache,
        //
        ////                                                        web LocalStorage 缓存
        //                                                        //WKWebsiteDataTypeLocalStorage,
        //
        ////                                                        web Cookies缓存
        //                                                        //WKWebsiteDataTypeCookies,
        //
        ////                                                        SessionStorage 缓存
        //                                                        //WKWebsiteDataTypeSessionStorage,
        //
        ////                                                        索引DB缓存
        //                                                        //WKWebsiteDataTypeIndexedDBDatabases,
        //
        ////                                                        数据库缓存
        //                                                        //WKWebsiteDataTypeWebSQLDatabases
        //
        //                                                        ]];
        //// All kinds of data
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        
        //// Date from
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        //// Execute
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
            // Done
            
        }];
    } else {
        
        NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0];
        NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        
        NSString *cookiesFolderPath = [NSString stringWithFormat:@"%@/Cookies",libraryDir];
        NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
        NSString *webKitFolderInCaches = [NSString stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:&error];
    }
}


#pragma mark - 响应间隔禁止
-(void)userInteractionDisableWithTime:(double)interval {
    if(time<=0) {
        return;
    }
    self.userInteractionEnabled = NO;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, DISPATCH_TARGET_QUEUE_DEFAULT);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(timer);
    });
    dispatch_source_set_cancel_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userInteractionEnabled = YES;
        });
    });
    dispatch_resume(timer);
}

#pragma mark - 代理拦截

-(void)setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate {
    id<WKNavigationDelegate> delegate = (id<WKNavigationDelegate>)self;
    if (delegate != navigationDelegate) {
        self.navigationDelegateReceiver = navigationDelegate;
    }
    [super setNavigationDelegate:delegate];
}

-(void)setUIDelegate:(id<WKUIDelegate>)UIDelegate {
    id<WKUIDelegate> delegate = (id<WKUIDelegate>)self;
    if (delegate != UIDelegate) {
        self.UIDelegateReceiver = UIDelegate;
    }
    [super setUIDelegate:delegate];
}

#pragma mark --
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    UIApplication *app = [UIApplication sharedApplication];
    if([[WebView infoOpenURLs] containsObject:url.scheme]) {
        if ([app canOpenURL:url]){
            [self userInteractionDisableWithTime:0.2];
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    if([[WebView infoUrlSchemes] containsObject:url.scheme] ||
       [url.absoluteString containsString:@"itunes.apple.com"] ||
       [url.absoluteString isEqualToString:UIApplicationOpenSettingsURLString]) {
        if ([app canOpenURL:url]){
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    if ([self.navigationDelegateReceiver respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.navigationDelegateReceiver webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }else{
        decisionHandler(YES);
    }
}

#pragma mark - 代理转发
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return self;
    }
    if (self.navigationDelegateReceiver && [self.navigationDelegateReceiver respondsToSelector:aSelector]) {
        return self.navigationDelegateReceiver;
    }
    if (self.UIDelegateReceiver && [self.UIDelegateReceiver respondsToSelector:aSelector]) {
        return self.UIDelegateReceiver;
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSString*selName=NSStringFromSelector(aSelector);
    if ([selName hasPrefix:@"keyboardInput"] || [selName isEqualToString:@"customOverlayContainer"]) {//键盘输入代理过滤
        return NO;
    }
    if (self.navigationDelegateReceiver && [self.navigationDelegateReceiver respondsToSelector:aSelector]) {
        return YES;
    }
    if (self.UIDelegateReceiver && [self.UIDelegateReceiver respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

@end
