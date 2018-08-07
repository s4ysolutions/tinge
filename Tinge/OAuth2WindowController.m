//
//  OAuth2WindowController.m
//  Tinge
//
//  Created by Sergey Dolin on 8/20/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "OAuth2WindowController.h"
#import "OAuthStorage.h"

@interface OAuth2WindowController ()

@end

@implementation OAuth2WindowController {
    @private
//    NSString* _provider;
//    NSString* _image;
//    NSURL* _url;
    
    NSURLConnection* _connection;
    NSObject<UploadStorage>* _storage;
    NSInteger _lastHTTPStatus;
    NSMutableData *_responseData;
    NSTimer* _timer;
}

volatile BOOL gAuth;
volatile BOOL gCancel;

+(void)authWithUploadStorage:(NSObject<UploadStorage>*)storage success:(BOOL*)success userCancel:(BOOL*)cancel{
    gAuth=NO;
    gCancel=NO;
    OAuth2WindowController *oc=[[OAuth2WindowController alloc] initWithUploadStorage:storage];
    [oc showWindow:self];
    [oc startTimer];
    [[NSApplication sharedApplication] runModalForWindow:oc.window];
    *success=gAuth;
    *cancel=gCancel;
};

-(id)initWithUploadStorage:(NSObject<UploadStorage>*)storage{
    self = [self initWithWindowNibName:@"OAuth2"];
    if (nil!=self){
        _storage=[storage retain];
    }
    return self;
}

-(void)dealloc{
    [_storage release];
    [_responseData release];
    [_connection release];
    [logo release];
    [textError release];
    [code release];
    [progress release];

    [super dealloc];
}
#pragma mark Timer utils

- (void)stopTimer{
    [_timer invalidate];
    _timer=nil;
}

- (void)checkCode:(NSTimer *)timer{
    NSString* scode=[[code stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![scode isEqualToString:@""]) {
        [self doStartRequestCode:scode];
    }
}

- (void)startTimer{
    _timer=[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(checkCode:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer
                                 forMode:NSModalPanelRunLoopMode];
    /*
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer: _timer forMode: NSDefaultRunLoopMode];*/
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [logo setImage:[NSImage imageNamed:[_storage imageName]]];
//    [message setStringValue:[NSString stringWithFormat:@"In order to let Tinge to store screenshots on your account please  click the button \"Open browser\", login to your Dropbox account, click \"Allow\" and copy-paste the code to the text field in this window. ",[_url absoluteString ]]];
    //[message setStringValue:@"In order to let Tinge to store screenshots on your account please  click the button \"Open browser\" beneath this texh, login to your Dropbox account, click \"Allow\" and copy-paste the code to the text field in this window. Next click \"I'm done\". "];
    [self.window setTitle:[_storage provider]];
}

- (IBAction)selectOpenBrowser:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[_storage urlOAuth2Code]];
};
/*
- (IBAction)selectDone:(id)sender{
    [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString* scode=[[code stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![scode isEqualToString:@""]) {
        [self doStartRequestCode:scode];
        //[OAuthStorage storeToken:token forProvider:[_storage provider]];
    }else{
        [self close];        
    }
};*/

- (IBAction)selectCancel:(id)sender{
    if (_connection) {
        [_connection cancel];
        [_connection release];
        _connection=nil;
        [code setStringValue:@""]; //just in case
        [textError setStringValue:@"Authorization aborted"]; //just in case
        [progress stopAnimation:self];
        [self startTimer];
    }else{
        gCancel=YES;
        [self close];
    }
};

- (void)doStartRequestCode:(NSString*)scode{
    [self stopTimer];
    [_connection release];
    [progress startAnimation:self];
    [textError setStringValue:@"Cheking the code..."];
    NSMutableURLRequest* request=[_storage requestOAuth2TokenForCode:scode];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSModalPanelRunLoopMode];
    [_connection start];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_responseData release];
    _responseData = [[NSMutableData alloc] init];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    _lastHTTPStatus = [httpResponse statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [progress startAnimation:self];
//    NSString *response=[NSString stringWithUTF8String:[_responseData bytes]];
    NSString *response=[[NSString alloc] initWithData:_responseData
                                             encoding:NSUTF8StringEncoding];
    if (_lastHTTPStatus<300){
        NSString* access_token=[_storage accessTokenFromResponse:_responseData];
        if (![[access_token substringToIndex: 1] isEqualToString:@" "]) {
            [OAuthStorage storeAccessToken:access_token forProvider:[_storage provider]];
            [textError setStringValue:@""]; //just in case
            [progress stopAnimation:self];
            gAuth=YES;
            [_connection release];
            _connection=nil;
            [self close];
        }else{
            NSDictionary *userInfo=nil;
            [self connection:connection
            didFailWithError:[NSError errorWithDomain:@"OAuth Error"
                                                 code:1
                                             userInfo:userInfo]];
        }
    }else{
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"(%ld) %@",(long)_lastHTTPStatus,response]};
        [self connection:connection
        didFailWithError:[NSError errorWithDomain:@"HTTP Error"
                                             code:_lastHTTPStatus
                                         userInfo:userInfo]];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [progress stopAnimation:self];
    NSLog(@"OAuth2 connectionDidFinishLoadin didFailWithError: %@",error);
    [textError setStringValue:[error localizedDescription]];
    code.stringValue=@"";
    [_connection release];
    _connection=nil;
    [self startTimer];
}

#pragma mark NSWindow Delegate Methods
- (void)windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] stopModal];
}
@end
