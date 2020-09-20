//
//  ViewController.m
//  barcodeScanner
//
//  Created by Abbie on 29/02/20.
//  Copyright © 2020 Abbie. All rights reserved.
//

#import "ViewController.h"
#import "BarcodeScannerVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)startCamera:(id)sender {
    BarcodeScannerVC * controller = [[BarcodeScannerVC alloc] initWithNibName:@"BarcodeScannerVC" bundle:[NSBundle mainBundle]];
    
    //[self presentViewController:controller animated:YES completion:nil];
     UIWindow * currentwindow = [[UIApplication sharedApplication] keyWindow];
     [currentwindow.rootViewController presentViewController:controller animated:YES completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Call UI related operations
        [KonyUIContext onCurrentFormControllerPresentModalViewController:webview animated:YES];
    });
}


@end
