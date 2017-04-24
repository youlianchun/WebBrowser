//
//  ViewController.m
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/24.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadWithUrl:@"www.baidu.com" params:nil];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
