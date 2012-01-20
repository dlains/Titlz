//
//  ContextSaver.m
//  Titlz
//
//  Created by David Lains on 1/20/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "ContextSaver.h"


@interface ContextSaver ()
+(void) displayValidationError:(NSError*)error;
@end

@implementation ContextSaver

+(void) saveContext:(NSManagedObjectContext*)context
{
    NSError* error = nil;
    if (context != nil)
    {
        if ([context hasChanges] && ![context save:&error])
        {
            // TODO: Instead of showing a detailed alert to the user perhaps show a general error
            //       message and send a notification to an email address or some other online
            //       method of getting the crash notification. Researd methods for getting crash
            //       notifications with iOS.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [ContextSaver displayValidationError:error];
        } 
    }
}

+(void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
#ifdef DEBUG
    abort();
#else
    exit(1);
#endif
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
            NSString* messages = @"Reason(s):\n";
            
            for (NSError* error in errors)
            {
                NSString* entityName = [[[[error userInfo] objectForKey:@"NSValidationErrorObject"] entity] name];
                NSString* attributeName = [[error userInfo] objectForKey:@"NSValidationErrorKey"];
                NSString* msg;
                switch ([error code])
                {
                    case NSManagedObjectValidationError:
                        msg = @"Generic validation error.";
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        msg = [NSString stringWithFormat:@"The attribute '%@' must not be empty.", attributeName];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError:
                        msg = [NSString stringWithFormat:@"The relationship '%@' doesn't have enough entries.", attributeName];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        msg = [NSString stringWithFormat:@"The relationship '%@' has too many entries.", attributeName];
                        break;
                    case NSValidationRelationshipDeniedDeleteError:
                        msg = [NSString stringWithFormat:@"To delete, the relationship '%@' must be empty.", attributeName];
                        break;
                    case NSValidationNumberTooLargeError:
                        msg = [NSString stringWithFormat:@"The number of the attribute '%@' is too large.", attributeName];
                        break;
                    case NSValidationNumberTooSmallError:
                        msg = [NSString stringWithFormat:@"The number of the attribute '%@' is too small.", attributeName];
                        break;
                    case NSValidationDateTooLateError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is too late.", attributeName];
                        break;
                    case NSValidationDateTooSoonError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is too soon.", attributeName];
                        break;
                    case NSValidationInvalidDateError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is invalid.", attributeName];
                        break;
                    case NSValidationStringTooLongError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' is too long.", attributeName];
                        break;
                    case NSValidationStringTooShortError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' is too short.", attributeName];
                        break;
                    case NSValidationStringPatternMatchingError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' doesn't match the required pattern.", attributeName];
                        break;
                    default:
                        msg = [NSString stringWithFormat:@"Unknown error (code %i).", [error code]];
                        break;
                }
                
                messages = [messages stringByAppendingFormat:@"%@%@%@\n", (entityName ? : @""), (entityName ? @": " : @""), msg];
            }
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Validation Error" message:messages delegate:[ContextSaver class] cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
}

@end
