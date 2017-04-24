//
//  ViewController.h
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/23.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebView.h"

@class WKWebControlle;

@protocol WKWebControllerDelegate <UIWebViewDelegate>

@optional
- (void)webController:(WKWebControlle*)webController canGoBackChange:(BOOL)canGoBack;

- (void)webController:(WKWebControlle*)webController canGoForwardChange:(BOOL)canGoForward;

- (void)webController:(WKWebControlle*)webController estimatedProgress:(double)progress;


- (BOOL)webController:(WKWebControlle*)webController shouldContinueLoadWithResponse:(NSURLResponse*)response;

- (BOOL)webController:(WKWebControlle*)webController shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(WKNavigationType)navigationType;

- (void)webControllerDidStartLoad:(WKWebControlle *)webViewController;

- (void)webControllerDidCommitLoad:(WKWebControlle *)webViewController;

- (void)webControllerDidFinishLoad:(WKWebControlle *)webViewController;

- (void)webController:(WKWebControlle*)webController didFailLoadWithError:(NSError*)error;

- (void)webController:(WKWebControlle*)webController createWebViewWithRequest:(NSURLRequest*)request navigationType:(WKNavigationType)navigationType;

- (BOOL)webController:(WKWebControlle*)webController shouldCreateWebViewWithRequest:(NSURLRequest*)request navigationType:(WKNavigationType)navigationType;


@end

@interface WKWebControlle : UIViewController
@property (nonatomic, readonly) WebView *webView;

@property (nonatomic, assign) BOOL delegateEnabled;
@property (nonatomic, weak) id<WKWebControllerDelegate> delegate;

-(void)loadWithUrl:(id)url params:(NSDictionary*)params;

@end


