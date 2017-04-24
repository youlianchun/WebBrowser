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

@interface MainViewController ()
@property (nonatomic, retain) TabBarView *tabBar;
@property (nonatomic, retain) TabBarItem *backItem;
@property (nonatomic, retain) TabBarItem *forwardItem;
@property (nonatomic, retain) TabBarItem *panelItem;
@property (nonatomic, retain) TabBarItem *toolItem;
@property (nonatomic, retain) TabBarItem *homeItem;
@property (nonatomic, weak) WKWebControlle *wvc;
@end

@implementation MainViewController
#pragma mark -
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
        _backItem = [[TabBarItem alloc]initWithNormalTitle:@"返回" normalIcon:[UIImage imageNamed:@""] action:^(TabBarItem *item) {
            [wself backItemAction:item];
        }];
    }
    return _backItem;
}

-(TabBarItem *)forwardItem {
    if (!_forwardItem) {
        __weak typeof(self) wself = self;
        _forwardItem = [[TabBarItem alloc]initWithNormalTitle:@"前进" normalIcon:[UIImage imageNamed:@""] action:^(TabBarItem *item) {
            [wself forwardItemAction:item];
        }];
    }
    return _forwardItem;
}

-(TabBarItem *)panelItem {
    if (!_panelItem) {
        __weak typeof(self) wself = self;
        _panelItem = [[TabBarItem alloc]initWithNormalTitle:@"面板" normalIcon:[UIImage imageNamed:@""] action:^(TabBarItem *item) {
            [wself panelItemAction:item];
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
            [wself homeItemAction:item];
        }];
    }
    return _homeItem;
}

#pragma mark -

-(void)backItemAction:(TabBarItem*)item {
    NSLog(@"%s",__FUNCTION__);
//    [self.wvc goBack];
}
-(void)forwardItemAction:(TabBarItem*)item {
    NSLog(@"%s",__FUNCTION__);
//    [self.wvc goForward];
}
-(void)panelItemAction:(TabBarItem*)item {
    NSLog(@"%s",__FUNCTION__);
}
-(void)toolItemAction:(TabBarItem*)item {
    NSLog(@"%s",__FUNCTION__);
}
-(void)homeItemAction:(TabBarItem*)item {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - 

-(void)setWvc:(WKWebControlle *)wvc {
    if (_wvc != wvc) {
        _wvc = wvc;
        _wvc.delegateEnabled = NO;
        wvc.delegateEnabled = YES;
        self.backItem.enabled = wvc.webView.canGoBack;
        self.forwardItem.enabled = wvc.webView.canGoForward;
        [self.view insertSubview:wvc.view atIndex:0];
    }
}

#pragma mark -


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.items = @[
                          self.backItem,
                          self.forwardItem,
                          self.panelItem,
                          self.toolItem,
                          self.homeItem
                          ];
    WKWebControlle *webVC = [[WKWebControlle alloc] init];
    webVC.delegate = (id<WKWebControllerDelegate>) self;
    [self addChildViewController:webVC];
    self.wvc = webVC;
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
