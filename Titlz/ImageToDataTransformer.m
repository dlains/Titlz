//
//  ImageToDataTransformer.m
//  Titlz
//
//  Created by David Lains on 1/24/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#import "ImageToDataTransformer.h"

@implementation ImageToDataTransformer

+(BOOL) allowsReverseTransformation
{
	return YES;
}

+(Class) transformedValueClass
{
	return [NSData class];
}

-(id) transformedValue:(id)value
{
	return UIImagePNGRepresentation(value);
}

-(id) reverseTransformedValue:(id)value
{
	return [[UIImage alloc] initWithData:value];
}

@end
