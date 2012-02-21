//
//  DConnection.h
//  Titlz
//
//  Created by David Lains on 2/17/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DConnection;

typedef void (^DConnectionProgressBlock)(DConnection* connection);
typedef void (^DConnectionCompletionBlock)(DConnection* connection, NSError* error);

@interface DConnection : NSObject

@property(nonatomic, strong) NSMutableData* downloadData;
@property(nonatomic, assign) float percentComplete;
@property(nonatomic, assign) NSUInteger progressThreshold;

+(id) connectionWithURL:(NSURL*)url progressBlock:(DConnectionProgressBlock)progress completionBlock:(DConnectionCompletionBlock)completion;
+(id) connectionWithRequest:(NSURLRequest*)request progressBlock:(DConnectionProgressBlock)progress completionBlock:(DConnectionCompletionBlock)completion;

-(id) initWithURL:(NSURL*)url progressBlock:(DConnectionProgressBlock)progress completionBlock:(DConnectionCompletionBlock)completion;
-(id) initWithRequest:(NSURLRequest*)request progressBlock:(DConnectionProgressBlock)progress completionBlock:(DConnectionCompletionBlock)completion;

-(void) start;
-(void) stop;

@end
