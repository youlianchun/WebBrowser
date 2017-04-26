//
//  PanelViewController.h
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/25.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PanelCellItem.h"

@class PanelViewController,PanelItem;

@protocol PanelControllerDelegate <NSObject>

-(NSInteger)numberOfItemAtPanelViewController:(PanelViewController*)panelViewController;

-(PanelCellItem*)panelViewController:(PanelViewController*)panelViewController itemAtIndex:(NSInteger)index;

@optional
-(void)panelViewController:(PanelViewController*)panelViewController didSelectItemAtIndex:(NSInteger)index;

-(void)panelViewController:(PanelViewController*)panelViewController deleteItemAtIndex:(NSInteger)index;

@end



@interface PanelViewController : UIViewController

+(PanelViewController*)displayWithDelegate:(id<PanelControllerDelegate>)delegate;

@end
