//
//  UIViewController+BMSlideMenu.h
//  BMSlideMenu
//
//  Created by Bogdan Matveev on 24.06.15.
//  Copyright (c) 2015 BOGDAN MATVEEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMSlideMenu.h"

@interface UIViewController(BMSlideMenu)

@property (nonatomic, weak) BMSlideMenu *slideMenu;

- (IBAction)showLeftMenu:(id)sender;
- (IBAction)showRightMenu:(id)sender;

@end
