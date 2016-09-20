//
//  ViewController.m
//  ApiClient
//
//  Created by Joan Martin on 26/03/15.
//  Copyright (c) 2015 Mobile Jazz. All rights reserved.
//

#import "ViewController.h"
#import "MJApiClient.h"

#define DoInForeground(block) \
if ([NSThread isMainThread]) \
block();\
else \
dispatch_async(dispatch_get_main_queue(), ^{\
block();\
});

@interface ViewController ()

@property (nonatomic, strong, readwrite) MJApiClient *apiClient;

@property (weak, nonatomic) IBOutlet UITextView *responseTextView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.apiClient = [[MJApiClient alloc] initWithConfigurator:^(MJApiClientConfigurator *configurator) {
        
        MJApiConfigurationManager *manager = [[MJApiConfigurationManager alloc] initWithPlistFileName:@"API-Config"];
        MJApiConfiguration *configuration = [manager configurationForEnvironment:MJApiEnvironmentProduction];
        [configurator configureWithConfiguration:configuration];
        
        configurator.cacheManagement = MJApiClientCacheManagementOffline;
        configurator.completionBlockQueue = dispatch_queue_create("com.mobilejazz.background-queue", DISPATCH_QUEUE_SERIAL);
    }];
    
    self.apiClient.logLevel = MJApiClientLogLevelRequests;
}

- (IBAction)getFakeRequest:(id)sender
{    
    MJApiRequest *request = [MJApiRequest requestWithPath:@"562158b5120000714c0113ff"];
    
    //NOTE: I am using Mocky.io to create a fake request with the custom header
    //          Cache-Control : max-age=30
    
    [_apiClient performRequest:request completionBlock:^(MJApiResponse *response) {
        NSString *newString;
        if (response.error) {
            newString = [NSString stringWithFormat:@"Received error:\n%@\n", [response.error localizedDescription]];
        }
        else {
            newString = [NSString stringWithFormat:@"Received response:\n%@\n", response.responseObject];
        }

        DoInForeground(^{
            _responseTextView.text = [_responseTextView.text stringByAppendingString:newString];
        });
    }];
}


@end
