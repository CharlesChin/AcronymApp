//
//  ViewController.m
//  AcronymApp
//
//  Created by Charles Chin on 11/24/15.
//  Copyright © 2015 Charles Chin. All rights reserved.
//

#import "ViewController.h"
#import <MBProgressHUD.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userInput;
@property (weak, nonatomic) IBOutlet UITextView *resultTextview;

- (IBAction)lookupPress:(id)sender;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // dismiss the keyboard when tapping outside of the keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self setBackgroundImg];
    self.resultTextview.text = @"\n\n\nWelcome! \n\nStart by inputing an acronym in the input box above";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - User-friendly methods

- (void)setBackgroundImg{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpg"]];
}

- (void)dismissKeyboard {
    [self.userInput resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self lookupPress:nil];
    return YES;
}

#pragma mark - IBActions

- (IBAction)lookupPress:(id)sender {
    [self.userInput resignFirstResponder];
    self.resultTextview.text = @"";
    
    NSString *baseURL = @"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=";
    NSString *acronymInput = self.userInput.text;
    NSString *fullURL = [baseURL stringByAppendingString:acronymInput];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES]; // spin while loading
    hud.labelText = @"looking :)";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Fetch data from server using AFNetworking
        [manager GET:fullURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
            jsonArray = [jsonData valueForKeyPath:@"lfs"];
        
            if ([jsonArray count] == 0) {
                self.resultTextview.text = @"\n\n\nSorry, no result found :(";
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
            }else{
                NSArray *resultArray = [jsonArray[0] valueForKey:@"lf"];
          
                // displaying the result in the textview in separate lines
                NSString *str1 = [NSString string];
                NSString *str2 = [NSString string];
          
                for (int i=0; i < [resultArray count]; i++) {
                    str1 = [str1 stringByAppendingString:resultArray[i]];
                    str2 = [str1 stringByAppendingString:@"\n\n"];
            
                    if (i < [resultArray count] - 1) {
                        str1 = str2;
                    }
                }

                dispatch_async(dispatch_get_main_queue(), ^{    // update UI with main queue
                    self.resultTextview.text = str1;
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    });
}

@end
