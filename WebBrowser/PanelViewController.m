//
//  PanelViewController.m
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/25.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "PanelViewController.h"
#import "PanelTableViewCell.h"
//
@interface PanelViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<PanelControllerDelegate> delegate;
@property (nonatomic)UITableView *panelView;
@property (nonatomic)CGFloat cellHeight;
@end

@implementation PanelViewController
+(PanelViewController*)displayWithDelegate:(id<PanelControllerDelegate>)delegate {
    PanelViewController *panelViewController = [[self alloc] init];
    panelViewController.delegate = delegate;
    panelViewController.hidesBottomBarWhenPushed = YES;
    panelViewController.modalPresentationStyle = UIModalPresentationCustom;
    panelViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:panelViewController animated:YES completion:^{
        
    }];
    return panelViewController;
}

-(UITableView *)panelView {
    if (!_panelView) {
        _panelView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _panelView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _panelView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(self.view.bounds)-self.cellHeight-65)];
        self.panelView.delegate = self;
        self.panelView.dataSource = self;
        _panelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [self.view insertSubview:_panelView atIndex:0];
        _panelView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_panelView attribute:NSLayoutAttributeTop multiplier:1 constant:-25]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_panelView attribute:NSLayoutAttributeRight multiplier:1 constant:20]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_panelView attribute:NSLayoutAttributeBottom multiplier:1 constant:40]];
        [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_panelView attribute:NSLayoutAttributeLeft multiplier:1 constant:-20]];
    }
    return _panelView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.cellHeight = CGRectGetWidth([UIScreen mainScreen].bounds) / kWH_P;
    [self.panelView registerNib:[UINib nibWithNibName:kPanelTableViewCell_ID bundle:nil] forCellReuseIdentifier:kPanelTableViewCell_ID];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction:)];
//    tap.delegate = self;
//    [self.view addGestureRecognizer:tap];
    [self reloadData];
    // Do any additional setup after loading the view.
}


-(void)touchAction:(UIGestureRecognizer*)sender {
   
}
-(void)close {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfItem];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PanelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPanelTableViewCell_ID];
    if (!cell) {
        cell = [[PanelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPanelTableViewCell_ID];
    }
    __weak typeof(self) wself = self;
    PanelCellItem *item = [self itemAtIndex:indexPath.row];
    [cell updateContentWithPanelCellItem:item closeAction:^{
        [wself deleteItemAtIndex:indexPath.row];
    }];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s",__func__);
    [self didSelectItemAtIndex:indexPath.row];
    [self close];
}

-(void)reloadData {
    [self.panelView reloadData];
}

-(NSInteger)numberOfItem {
    return [self.delegate numberOfItemAtPanelViewController:self];
}

-(PanelCellItem*)itemAtIndex:(NSInteger)index {
    return [self.delegate panelViewController:self itemAtIndex:index];
}

-(void)didSelectItemAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(panelViewController:didSelectItemAtIndex:)]) {
        [self.delegate panelViewController:self didSelectItemAtIndex:index];
    }
}

-(void)deleteItemAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(panelViewController:deleteItemAtIndex:)]) {
        [self.delegate panelViewController:self deleteItemAtIndex:index];
    }
}
@end
