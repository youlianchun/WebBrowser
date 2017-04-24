//
//  TabBarView.h
//  TabBarController
//
//  Created by YLCHUN on 2017/4/21.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarItem.h"
@class TabBarView;
@protocol TabBarDelegate <UITabBarDelegate>

@optional
-(BOOL)tabBar:(TabBarView*)tabBar shouldSelectWithItem:(TabBarItem*) item;

@end
@interface TabBarView : UITabBar
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-property-synthesis"
@property(nonatomic, copy) NSArray<TabBarItem *> *items;
@property(nonatomic, weak) id<TabBarDelegate> delegate;     // weak reference. default is nil
#pragma clang diagnostic pop

@property (nonatomic, retain) UIImage* backgroundImage;
@property (nonatomic, retain) UIColor* shadowColor;
@property (nonatomic, retain) UIImage* lineImage;
@end
