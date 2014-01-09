//
//  HURLContentViewController.h
//  clucene-ios-example
//
//  Created by Ron Hu on 1/9/14.
//  Copyright (c) 2014 hurongliang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HURLContentViewController : UIViewController<UIWebViewDelegate>
@property(strong,nonatomic)NSString *filePath;
@property(strong,nonatomic)NSString *searchText;
@end
