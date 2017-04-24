//
//  TabBarItem.h
//  TabBarController
//
//  Created by YLCHUN on 2017/4/21.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TabBarView;

@interface TabBarItem : UITabBarItem
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-property-synthesis"
@property(nonatomic, strong) UIImage *selectedImage NS_UNAVAILABLE;
@property (nonatomic, strong) UIImage *image NS_UNAVAILABLE;
@property (nonatomic, copy) NSString *title NS_UNAVAILABLE;

@property (nonatomic, readonly, weak)TabBarView *tabBar;

@property (nonatomic, assign) BOOL nilStatus;

@property (nonatomic, retain) UIImage *normalIcon;
@property (nonatomic, retain) UIImage *selectedIcon;

@property (nonatomic, copy) NSString *normalTitle;
@property (nonatomic, copy) NSString *selectedTitle;

@property (nonatomic, retain) UIColor *normalTextColor;
@property (nonatomic, retain) UIColor *selectedTextColor;

@property (nonatomic, assign)BOOL selected;
@property (nonatomic, weak) id object;
#pragma clang diagnostic pop

-(instancetype)initWithNormalTitle:(NSString *)normalTitle selectedTitle:(NSString*)selectedTitle normalIcon:(UIImage *)normalIcon selectedIcon:(UIImage*)selectedIcon normalTextColor:(UIColor*)normalTextColor selectedTextColor:(UIColor*)selectedTextColor action:(void(^)(TabBarItem *item))action;

-(instancetype)initWithNormalTitle:(NSString *)normalTitle normalIcon:(UIImage *)normalIcon normalTextColor:(UIColor*)normalTextColor action:(void(^)(TabBarItem *item))action;

-(instancetype)initWithNormalTitle:(NSString *)normalTitle normalIcon:(UIImage *)normalIcon action:(void(^)(TabBarItem *item))action;

-(instancetype)initWithAction:(void(^)(TabBarItem *item))action;


-(void)doAction;
-(void)removeFromTabBar;


- (instancetype)initWithTitle:( NSString *)title image:( UIImage *)image tag:(NSInteger)tag NS_UNAVAILABLE;
- (instancetype)initWithTitle:( NSString *)title image:( UIImage *)image selectedIcon:( UIImage *)selectedIcon NS_UNAVAILABLE;
- (instancetype)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem tag:(NSInteger)tag NS_UNAVAILABLE;

@end
