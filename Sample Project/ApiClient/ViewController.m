//
//  ViewController.m
//  ApiClient
//
//  Created by Joan Martin on 26/03/15.
//  Copyright (c) 2015 Mobile Jazz. All rights reserved.
//

#import "ViewController.h"
#import "MJApiClient.h"

@interface ViewController ()

@property (nonatomic, strong, readwrite) MJApiClient *apiClient;

@property (weak, nonatomic) IBOutlet UITextView *responseTextView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.apiClient = [[MJApiClient alloc] initWithConfigurator:^(MJAPiClientConfigurator *configurator) {
        configurator.apiPath = @"/v2";
        configurator.host = @"http://www.mocky.io";//Testing using Mocki services
        configurator.cacheManagement = MJApiClientCacheManagementOffline;
    }];
    
    self.apiClient.logLevel = MJApiClientLogLevelRequests;
}

- (IBAction)getFakeRequest:(id)sender {
    
    MJApiRequest *request = [MJApiRequest requestWithPath:@"562158b5120000714c0113ff"];
    
    //NOTE: I am using Mocky.io to create a fake request with the custom header
    //          Cache-Control : max-age=30
    
    [_apiClient performRequest:request completionBlock:^(MJApiResponse *response, NSInteger key) {
        NSString *newString;
        if (response.error) {
            newString = [NSString stringWithFormat:@"Received error:\n%@\n", [response.error localizedDescription]];
        }
        else {
            newString = [NSString stringWithFormat:@"Received response:\n%@\n", response.responseObject];
        }
        _responseTextView.text = [_responseTextView.text stringByAppendingString:newString];
    }];
}


@end
