//
//  MainViewController.m
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/23.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "MainViewController.h"
#import "WKWebControlle.h"
#import "TabBarView.h"
#import "PanelViewController.h"

@interface MainViewController ()<WKWebControllerDelegate, PanelControllerDelegate>
@property (nonatomic, retain) TabBarView *tabBar;
@property (nonatomic, retain) TabBarItem *backItem;
@property (nonatomic, retain) TabBarItem *forwardItem;
@property (nonatomic, retain) TabBarItem *panelItem;
@property (nonatomic, retain) TabBarItem *toolItem;
@property (nonatomic, retain) TabBarItem *homeItem;
@property (nonatomic, weak) WKWebControlle *wvc;
@property (nonatomic) NSMutableArray<__kindof WKWebControlle*> *wvcArray;
@property (nonatomic, retain) UIView *pView;
@end

@implementation MainViewController
#pragma mark -
-(UIView *)pView {
    if (!_pView) {
        _pView = [[UIView alloc] initWithFrame:CGRectZero];
        _pView.clipsToBounds = YES;
        [self.view addSubview:_pView];
    }
    return _pView;
}
-(NSMutableArray<WKWebControlle*> *)wvcArray {
    if (!_wvcArray) {
        _wvcArray = [NSMutableArray<WKWebControlle*> array];
    }
    return _wvcArray;
}
-(TabBarView *)tabBar {
    if (!_tabBar) {
        _tabBar = [[TabBarView alloc] init];
        [self.view insertSubview:_tabBar atIndex:0];
        _tabBar.translatesAutoresizingMaskIntoConstraints = NO;
        [_tabBar addConstraint: [NSLayoutConstraint constraintWithItem:_tabBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_tabBar attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_tabBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_tabBar attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    }
    return _tabBar;
}

-(TabBarItem *)backItem {
    if (!_backItem) {
        __weak typeof(self) wself = self;
        _backItem = [[TabBarItem alloc]initWithNormalTitle:@"后退" normalIcon:[UIImage imageNamed:@""] action:^(TabBarItem *item) {
            [wself.wvc.webView goBack];
        }];
    }
    return _backItem;
}

-(TabBarItem *)forwardItem {
    if (!_forwardItem) {
        __weak typeof(self) wself = self;
        _forwardItem = [[TabBarItem alloc]initWithNormalTitle:@"前进" normalIcon:[UIImage imageNamed:@""] action:^(TabBarItem *item) {
            [wself.wvc.webView goForward];
        }];
    }
    return _forwardItem;
}

-(TabBarItem *)panelItem {
    if (!_panelItem) {
        __weak typeof(self) wself = self;
        _panelItem = [[TabBarItem alloc]initWithNormalTitle:@"面板" normalIcon:[UIImage imageNamed:@""] action:^(TabBarItem *item) {
            [PanelViewController displayWithDelegate:wself];
        }];
    }
    return _panelItem;
}

-(TabBarItem *)toolItem {
    if (!_toolItem) {
        __weak typeof(self) wself = self;
        _toolItem = [[TabBarItem alloc]initWithNormalTitle:@"工具" normalIcon:[UIImage imageNamed:@""] action:^(TabBarItem *item) {
            [wself toolItemAction:item];
        }];
    }
    return _toolItem;
}

-(TabBarItem *)homeItem {
    if (!_homeItem) {
        __weak typeof(self) wself = self;
        _homeItem = [[TabBarItem alloc]initWithNormalTitle:@"主页" normalIcon:[UIImage imageNamed:@""] action:^(TabBarItem *item) {
            [wself.wvc loadWithUrl:@"www.baidu.com" params:nil];
        }];
    }
    return _homeItem;
}

#pragma mark -

-(void)backItemAction:(TabBarItem*)item {
    NSLog(@"%s",__FUNCTION__);
    [self.wvc.webView goBack];
}
-(void)forwardItemAction:(TabBarItem*)item {
    NSLog(@"%s",__FUNCTION__);
    [self.wvc.webView goForward];
}
-(void)panelItemAction:(TabBarItem*)item {
    NSLog(@"%s",__FUNCTION__);
}
-(void)toolItemAction:(TabBarItem*)item {
    NSLog(@"%s",__FUNCTION__);
}
-(void)homeItemAction:(TabBarItem*)item {
    [self.wvc loadWithUrl:@"www.baidu.com" params:nil];
}

#pragma mark - 

-(void)setWvc:(WKWebControlle *)wvc {
    if (_wvc != wvc) {
        [_wvc.view removeFromSuperview];
        if (_wvc) {
            [self.pView addSubview:_wvc.view];
        }
        if (wvc) {
            _wvc.delegateEnabled = NO;
            wvc.delegateEnabled = YES;
            self.backItem.enabled = wvc.webView.canGoBack;
            self.forwardItem.enabled = wvc.webView.canGoForward;
            [wvc.view removeFromSuperview];
            [self.view insertSubview:wvc.view atIndex:0];
        }
        _wvc = wvc;
    }
}

#pragma mark -
- (void)webController:(WKWebControlle*)webController canGoBackChange:(BOOL)canGoBack {
    self.backItem.enabled = canGoBack;
}

- (void)webController:(WKWebControlle*)webController canGoForwardChange:(BOOL)canGoForward {
    self.forwardItem.enabled = canGoForward;
}

- (void)webController:(WKWebControlle*)webController estimatedProgress:(double)progress {

}

#pragma mark -
-(NSInteger)numberOfItemAtPanelViewController:(PanelViewController*)panelViewController {
    return self.wvcArray.count;
}

-(PanelCellItem*)panelViewController:(PanelViewController*)panelViewController itemAtIndex:(NSInteger)index {
    WebView *webView = self.wvcArray[index].webView;
    PanelCellItem *item = [[PanelCellItem alloc] init];
    item.title = webView.title.length>0?webView.title:webView.URL.absoluteString;
    item.image = webView.screenshot;
    return item;
}

-(void)panelViewController:(PanelViewController*)panelViewController didSelectItemAtIndex:(NSInteger)index {
    [self changeWVCToIndex:index];
}

-(void)panelViewController:(PanelViewController*)panelViewController deleteItemAtIndex:(NSInteger)index {
    [self deleteWebVCWithIndex:index];
}

#pragma mark -

-(void)addWebVCWithUrl:(NSString*)url toCurrent:(BOOL)toCurrent {
    WKWebControlle *webVC = [[WKWebControlle alloc] init];
    webVC.delegate = (id<WKWebControllerDelegate>) self;
    webVC.delegateEnabled = toCurrent;
    [self.wvcArray addObject:webVC];
    [webVC loadWithUrl:url params:nil];
    [self.pView addSubview:webVC.view];
    if (toCurrent) {
        [self changeWVCToIndex:self.wvcArray.count-1];
    }
}

-(void)deleteWebVCWithIndex:(NSUInteger)index {
    if (index<self.wvcArray.count) {
        WKWebControlle *wvc = self.wvcArray[index];
        if (wvc == self.wvc) {
            if (index>0) {//前面有页面
                [self changeWVCToIndex:index-1];
            }else if (self.wvcArray.count-1>index){//后面有页面
                [self changeWVCToIndex:index+1];
            }
        }else {
            [wvc.view removeFromSuperview];
        }
        [wvc removeFromParentViewController];
    }
    if (self.wvcArray.count == 0) {
        [self addWebVCWithUrl:@"www.baidu.com" toCurrent:YES];
    }
}

-(void)changeWVCToIndex:(NSInteger)index {
    WKWebControlle *wvc = self.wvcArray[index];
    self.wvc = wvc;
}

#pragma mark -


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.tabBar.items = @[
                          self.backItem,
                          self.forwardItem,
                          self.panelItem,
                          self.toolItem,
                          self.homeItem
                          ];
    
    [self addWebVCWithUrl:@"www.baidu.com" toCurrent:YES];
    
    [self addWebVCWithUrl:@"http://www.cocoachina.com/bbs/index.php" toCurrent:NO];
    
    // Do any additional setup after loading the view.
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
