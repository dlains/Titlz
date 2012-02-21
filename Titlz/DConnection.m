//
//  DConnection.m
//  Titlz
//
//  Created by David Lains on 2/17/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "DConnection.h"

@interface DConnection ()

@property(nonatomic, strong) NSURLConnection* connection;
@property(nonatomic, strong) NSURL* url;
@property(nonatomic, strong) NSURLRequest* urlRequest;
@property(nonatomic, assign) NSInteger contentLength;

@property(nonatomic, assign) float previousMilestone;

@property(nonatomic, copy) DConnectionProgressBlock progressBlock;
@property(nonatomic, copy) DConnectionCompletionBlock completionBlock;

@end

@implementation DConnection

@synthesize connection = _connection;
@synthesize url = _url;
@synthesize urlRequest = _urlRequest;
@synthesize contentLength = _contentLength;
@synthesize downloadData = _downloadData;
@synthesize percentComplete = _percentComplete;
@synthesize progressThreshold = _progressThreshold;
@synthesize previousMilestone = _previousMilestone;
@synthesize progressBlock = _progressBlock;
@synthesize completionBlock = _completionBlock;

+(id) connectionWithURL:(NSURL*)url progressBlock:(DConnectionProgressBlock)progress completionBlock:(DConnectionCompletionBlock)completion
{
    return [[self alloc] initWithURL:url progressBlock:progress completionBlock:completion];
}

+(id) connectionWithRequest:(NSURLRequest*)request progressBlock:(DConnectionProgressBlock)progress completionBlock:(DConnectionCompletionBlock)completion
{
    return [[self alloc] initWithRequest:request progressBlock:progress completionBlock:completion];
}

-(id) initWithURL:(NSURL*)url progressBlock:(DConnectionProgressBlock)progress completionBlock:(DConnectionCompletionBlock)completion
{
    return [self initWithRequest:[NSURLRequest requestWithURL:url] progressBlock:progress completionBlock:completion];
}

-(id) initWithRequest:(NSURLRequest*)request progressBlock:(DConnectionProgressBlock)progress completionBlock:(DConnectionCompletionBlock)completion
{
    if ((self = [super init]))
    {
        self.urlRequest = request;
        self.progressBlock = [progress copy];
        self.completionBlock = [completion copy];
        self.url = [request URL];
        self.progressThreshold = 1.0;
    }
    return self;
}

-(void) start
{
    self.connection = [NSURLConnection connectionWithRequest:self.urlRequest delegate:self];
}

-(void) stop
{
    [self.connection cancel];
    self.connection = nil;
    self.downloadData = nil;
    self.contentLength = 0;
    self.progressBlock = nil;
    self.completionBlock = nil;
}

-(float) percentComplete
{
    if (self.contentLength <= 0) return 0;
    return (([self.downloadData length] * 1.0f) / self.contentLength) * 100;
}

#pragma mark - NSURLConnectionDelegate

-(void) connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if ([httpResponse statusCode] == 200)
        {
            NSDictionary* header = [httpResponse allHeaderFields];
            NSString* contentLen = [header valueForKey:@"Content-Length"];
            NSInteger length = self.contentLength = [contentLen integerValue];
            self.downloadData = [NSMutableData dataWithCapacity:length];
        }
    }
}

-(void) connection:(NSURLConnection*) connection didReceiveData:(NSData*)data
{
    [self.downloadData appendData:data];
    float pctComplete = floor([self percentComplete]);
    if ((pctComplete - self.previousMilestone) >= self.progressThreshold)
    {
        self.previousMilestone = pctComplete;

        if (self.progressBlock)
            self.progressBlock(self);
    }
}

-(void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    DLog(@"Connection failed");

    if (self.completionBlock)
        self.completionBlock(self, error);
    
    self.connection = nil;
}

-(void) connectionDidFinishLoading:(NSURLConnection*)connection
{
    if (self.completionBlock)
        self.completionBlock(self, nil);

    self.connection = nil;
}

@end
