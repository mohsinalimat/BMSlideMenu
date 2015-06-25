//
//  BMLeftViewController.m
//  BMSlideMenu
//
//  Created by Bogdan Matveev on 24.06.15.
//  Copyright (c) 2015 BOGDAN MATVEEV. All rights reserved.
//

#import "BMLeftViewController.h"
#import "UIViewController+BMSlideMenu.h"

@interface BMLeftViewController ()

@end

@implementation BMLeftViewController
- (IBAction)showVC:(id)sender {
    switch ([(UIButton*)sender tag]) {
        case 1:
            [self.slideMenu setCenterViewController:[self.storyboard
                                                     instantiateViewControllerWithIdentifier:@"rootVC"]];
            break;
        case 2:
            [self.slideMenu setCenterViewController:[self.storyboard
                                                     instantiateViewControllerWithIdentifier:@"secondVC"]];
            break;
        default:
            break;
    }
}

@end
