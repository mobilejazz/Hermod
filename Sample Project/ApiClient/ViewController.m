//
//  ViewController.m
//  ApiClient
//
//  Created by Joan Martin on 26/03/15.
//  Copyright (c) 2015 Mobile Jazz. All rights reserved.
//

#import "ViewController.h"
#import "HMClient.h"

#define DoInForeground(block) \
if ([NSThread isMainThread]) \
block();\
else \
dispatch_async(dispatch_get_main_queue(), ^{\
block();\
});

@interface ViewController ()

@property (nonatomic, strong, readwrite) HMClient *apiClient;

@property (weak, nonatomic) IBOutlet UITextView *responseTextView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.apiClient = [[HMClient alloc] initWithConfigurator:^(HMClientConfigurator *configurator) {
        
        HMConfigurationManager *manager = [[HMConfigurationManager alloc] initWithPlistFileName:@"API-Config"];
        HMConfiguration *configuration = [manager configurationForEnvironment:HMEnvironmentProduction];
        [configurator configureWithConfiguration:configuration];
        
        configurator.cacheManagement = HMClientCacheManagementOffline;
        configurator.completionBlockQueue = dispatch_queue_create("com.mobilejazz.background-queue", DISPATCH_QUEUE_SERIAL);
        configurator.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    }];
    
    self.apiClient.logLevel = HMClientLogLevelRequests;
}

- (IBAction)getFakeRequest:(id)sender
{    
    HMRequest *request = [HMRequest requestWithPath:@"562158b5120000714c0113ff"];
    
    //NOTE: I am using Mocky.io to create a fake request with the custom header
    //          Cache-Control : max-age=30
    
    [_apiClient performRequest:request completionBlock:^(HMResponse *response) {
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
