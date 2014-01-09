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
    if(self.fileName){
        self.title = self.fileName;
    }
    if(self.filePath){
       /*
        NSURL *url = [NSURL fileURLWithPath:self.filePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        */
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:self.filePath];
        [self.webView loadData:data MIMEType:@"text/plain" textEncodingName:@"utf-8" baseURL:Nil];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)highlight:(NSString *)highlightText{
    
}
@end
