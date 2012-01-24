//
//  ContextUtil.m
//  Titlz
//
//  Created by David Lains on 1/20/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "ContextUtil.h"

@implementation ContextUtil

+(BOOL) saveContext:(NSManagedObjectContext*)context
{
    BOOL saved = YES;
    
    NSError* error = nil;
    if (context != nil)
    {
        if ([context hasChanges] && ![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [ContextUtil displayValidationError:error];
            saved = NO;
        } 
    }
    
    return saved;
}

+(void) displayValidationError:(NSError*)error
{
    if(error && [[error domain] isEqualToString:@"NSCocoaErrorDomain"])
    {
        NSArray* errors = nil;
        
        // Multiple errors?
        if([error code] == NSValidationMultipleErrorsError)
        {
            errors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        }
        else
        {
            errors = [NSArray arrayWithObject:error];
        }
        
        if(errors && [errors count] > 0)
        {
            NSMutableString* message = [NSMutableString stringWithCapacity:50];
            for (NSError* error in errors)
            {
                // The missing mandatory propery error is redundant.
                if ([error code] == NSValidationMissingMandatoryPropertyError)
                    continue;

                NSString* description = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
                if (description.length > 0)
                {
                    [message appendString:description];
                    [message appendString:@"\n"];
                }
            }
            
            [DAlertView showAlertWithTitle:NSLocalizedString(@"Validation Error", @"ContextUtil:displayValidationError title") message:message buttonTitle:NSLocalizedString(@"OK", @"OK")];
        }
    }
}

@end
