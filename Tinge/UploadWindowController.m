//
//  DropboxWindowController.m
//  Tinge
//
//  Created by Sergey Dolin on 8/18/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "UploadWindowController.h"
#import "Pasteboard.h"
#import "EditorWindowController.h"
#import "PresentationManager.h"

const int kStatusNone=0;
const int kStatusConnecting=-1;
const int kStatusUploadInProgress=-2;
const int kStatusUploadFail=-3;
const int kStatusUploadSuccess=-4;
const int kStatusLinkInProgress=-5;
const int kStatusLinkFail=-6;
const int kStatusLinkSuccess=-7;

@interface UploadWindowController ()

@end


NSMutableArray* getWindows(){
    static NSMutableArray* sWindows=nil;
    if (sWindows==nil){
        sWindows=[[NSMutableArray alloc] initWithCapacity:3];
    }
    return sWindows;
}

void countWindow(NSWindow* window){
    NSMutableArray *wa=getWindows();
    if ([wa indexOfObject:window]==NSNotFound){
        [wa addObject:window];
    };
}
void decountWindow(NSWindow* window){
    NSMutableArray *wa=getWindows();
    [wa removeObject:window];
}

NSRect windowFrame(NSWindow* window){
    NSRect sr=[[NSScreen mainScreen] frame];
    NSRect wr=[window frame];
    NSUInteger count=[getWindows() count];
    
    float bottom=20+(count-1)*(wr.size.height+20);
    //if (bottom==0)
    //    bottom=20;
    NSRect r=NSMakeRect(sr.size.width-wr.size.width-20,bottom,wr.size.width,wr.size.height);
    return r;
}


@implementation UploadWindowController {
    @private
    CGImageRef _imageOriginal;
    NSURL* _fileURL;
    NSMutableData *_responseData;
    int _status;
    NSURLConnection* _connection;
    NSObject<UploadStorage>* _storage;
    NSTimer* _timer;
    NSInteger _lastHTTPStatus;
}
//+(void)uploadFile:(NSURL*)fileURL withImage:(CGImageRef)image toStorage:(NSObject<UploadStorage>*)storage canceled:(BOOL *)canceled mayNeedRepeat:(BOOL*)repeat;

+(BOOL)startUploadFile:(NSURL*)fileURL withImage:(CGImageRef)image toStorage:(NSObject<UploadStorage>*)storage
{
    if (![storage isAllowed]){
        BOOL success;
        BOOL cancel;
        [storage allowSuccess:&success userCancel:&cancel];
        if (!success || cancel) return NO;
    }
    
    UploadWindowController* uwc=[[UploadWindowController alloc] initWithFileURL:fileURL  andImage:image andStorage:storage];
    [uwc showWindow:self];
    [uwc doStartUpload];

    [PresentationManager uploadDidOpen];
    return YES;
};


- (id)initWithFileURL:(NSURL*)fileURL andImage:(CGImageRef)imageOriginal  andStorage:(NSObject<UploadStorage>*)storage{
    self=[super initWithWindowNibName:@"Upload"];
    if (nil!=self){
        _imageOriginal=CGImageRetain(imageOriginal);
        _fileURL=[fileURL retain];
        _storage=[storage retain];
        [self setShouldCascadeWindows:NO];
    }
    return self;
}
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)dealloc {
    CGImageRelease(_imageOriginal);
    [_fileURL release];
    [_responseData release];
    [_storage release];
   // [_timer release]; autorelease
    [super dealloc];
}
- (void)windowDidLoad
{
    [super windowDidLoad];
    countWindow(self.window);
    self.window.opaque=NO;
    self.window.backgroundColor = [[NSColor yellowColor] colorWithAlphaComponent:0.5];
    [image setImage:[NSImage imageNamed:_storage.imageName]];
    [text setStringValue:_storage.textNone];
    [self.window setFrame:windowFrame(self.window) display:YES];
}

- (IBAction)selectCancel:(id)sender{
    if (kStatusUploadFail==_status || kStatusLinkSuccess==_status || kStatusLinkFail==_status)
        [self close];
    else
        [self.window close];
};

#pragma mark NSURLConnection  Methods

- (void)setStatus:(int) status{
    _status=status;
    switch (status) {
        case kStatusConnecting:
            [text setStringValue:_storage.textConnecting];
            break;
        case kStatusUploadInProgress:
            [text setStringValue:_storage.textUploadInProgress];
            break;
        case kStatusUploadSuccess:
            [text setStringValue:_storage.textUploadSuccess];
            break;
        case kStatusLinkInProgress:
            [text setStringValue:_storage.textLinkInProgress];
            break;
        case kStatusLinkSuccess:
            [text setStringValue:_storage.textLinkSuccess];
            break;
//        case kStatusFail:
//            [text setStringValue:_storage.textFailed];
//            break;
        default:
            [text setStringValue:_storage.textNone];
            break;
    }
}

- (BOOL)doStartUpload{
    [_connection release];
    self.status=kStatusConnecting;
    [text setStringValue:_storage.textNone];

    NSInputStream *s=[NSInputStream inputStreamWithURL:_fileURL];
    
    NSMutableURLRequest* request=[_storage requestUpload];

    [request setHTTPBodyStream:s];
    
    self.status=kStatusUploadInProgress;
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    return YES;
}

- (BOOL)doStartLink{
    [_connection release];
    self.status=kStatusConnecting;
    [text setStringValue:_storage.textNone];
    
    NSMutableURLRequest* request=[_storage requestLink];
    
//    [request setHTTPBody:nil];
    
    self.status=kStatusLinkInProgress;
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    return YES;
}



#pragma mark Timer utils

- (void)closeOnTimer:(NSTimer *)timer{
   // [_timer release];
    [_timer invalidate];
    _timer=nil;
    if (kStatusLinkSuccess==_status)
        [self close];
}

- (void)startTimer{
    _timer=[NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(closeOnTimer:) userInfo:nil repeats:NO];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer: _timer forMode: NSDefaultRunLoopMode];
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
    //NSString *response=[NSString stringWithUTF8String:[_responseData bytes]];
   // char *t=(char*)[_responseData bytes];
    NSString *response=[[NSString alloc] initWithData:_responseData
                          encoding:NSUTF8StringEncoding];
    if (_lastHTTPStatus<300){
        if (kStatusUploadInProgress==_status) {
            self.status=kStatusUploadSuccess;
            [[NSFileManager defaultManager] removeItemAtPath:[_fileURL path] error:NULL];
            [self doStartLink];
        } else {
            NSString* url=[_storage responeLinkFromResponse:_responseData];
            if ([[url substringToIndex:4] isEqualToString:@"http"]) {
                [Pasteboard pasteString:url];
                self.status=kStatusLinkSuccess;
                countWindow(self.window);
                [self.window setFrame:windowFrame(self.window) display:YES];
                [[self window] makeKeyAndOrderFront:self];
                [self  startTimer];
                [[NSSound soundNamed:@"Blow"] play];
            }else{
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:url};
                [self connection:connection
                didFailWithError:[NSError errorWithDomain:@"Link Error"
                                                     code:1
                                                 userInfo:userInfo]];
            }
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
    NSLog(@"Upload didFailWithError: %@",error);
    [[NSSound soundNamed:@"Basso"] play];
    NSString* f;
    if (kStatusUploadInProgress==_status){
        f=_storage.textUploadFailed;
        self.status=kStatusUploadFail;
    }else{
        f=_storage.textLinkFailed;
        self.status=kStatusLinkFail;
    }
    NSRange r=[[error localizedDescription] rangeOfString:@"access token is malformed"];//dropbox
    BOOL auth=NO;
    if (r.location!=NSNotFound){
        [_storage setValid:NO];
        [text setStringValue:@"Access token has some problems, try upload again to re-authenticate"];
        auth=YES;
    }else if (_lastHTTPStatus==401){
        [_storage setValid:NO];
        [text setStringValue:@"Access denied, try upload again to re-authenticate"];
        auth=YES;
    }else{
        [text setStringValue:[NSString stringWithFormat: f,[error localizedDescription]]];
    }

    [[NSFileManager defaultManager] removeItemAtPath:[_fileURL path] error:NULL];
    EditorWindowController* ewc=[EditorWindowController startEdit:_imageOriginal];
    if (auth)
        [ewc exportToDropbox];
}



#pragma mark NSWindow Delegate Methods
- (void)windowDidBecomeKey:(NSNotification *)notification {
    }

- (void)windowDidResignKey:(NSNotification *)notification {
    if (kStatusLinkSuccess==_status)
        [self close];
}

- (void)windowWillClose:(NSNotification *)notification {
    decountWindow(self.window);
    [PresentationManager uploadDidClose];
}



@end
