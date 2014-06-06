//
//  DismissableViewController.m
//  techefb
//
//  Created by Ron Hu on 5/5/14.
//  Copyright (c) 2014 Techpubs, Inc. All rights reserved.
//

#import "HURLModalViewController.h"

@interface HURLModalViewController ()

@end

@implementation HURLModalViewController{
    UITapGestureRecognizer *tapRecognizerOfDismissView;
}

-(void)viewDidAppear:(BOOL)animated{
    tapRecognizerOfDismissView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissViewWhenTouchOutsideView:)];
    
    tapRecognizerOfDismissView.numberOfTapsRequired = 1;
    tapRecognizerOfDismissView.cancelsTouchesInView = NO;
    
    [self.view.window addGestureRecognizer:tapRecognizerOfDismissView];
    
    [super viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.view.window removeGestureRecognizer:tapRecognizerOfDismissView];
    
    [super viewWillDisappear:animated];
}
-(void)handleDismissViewWhenTouchOutsideView:(UITapGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateEnded){
        CGPoint location = [sender locationInView:nil];
        if(![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil]){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
@end
