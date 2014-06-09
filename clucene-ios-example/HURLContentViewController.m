//
//  HURLContentViewController.m
//  clucene-ios-example
//
//  Created by Ron Hu on 1/9/14.
//  Copyright (c) 2014 hurongliang.com. All rights reserved.
//

#import "HURLContentViewController.h"

@interface HURLContentViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation HURLContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.searchResult.fileName){
        self.title = self.searchResult.fileName;
    }
    if(self.searchResult.filePath){
        NSData *data = [[NSData alloc] initWithContentsOfFile:self.searchResult.filePath];
        [self.webView loadData:data MIMEType:@"text/plain" textEncodingName:@"utf-8" baseURL:Nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)highlight:(NSString *)highlightText{
    
}
@end
