//
//  WebView.h
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/24.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <WebKit/WebKit.h>
@protocol WKWebNavigationDelegate <WKNavigationDelegate>

@optional

-(void)webView:(WKWebView *)webView estimatedProgress:(double)progress;

-(void)webView:(WKWebView *)webView canGoBackChange:(BOOL)canGoBack;

-(void)webView:(WKWebView *)webView canGoForwardChange:(BOOL)canGoForward;

-(void)webView:(WKWebView *)webView titleChange:(NSString*)title;

@end

@interface WebView : WKWebView
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-property-synthesis"
@property (nonatomic, weak) id <WKWebNavigationDelegate> navigationDelegate;
#pragma clang diagnostic pop
@property (nonatomic, readonly) UIImage *screenshot;

-(id)evaluateJSFunc:(NSString*)func arguments:(NSArray*)arguments;

-(NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString;

-(void)userInteractionDisableWithTime:(double)interval;

+ (void)clearCache;

@end
