//
//  MPWStScript.m
//  MPWShellScriptKit
//
//  Created by Marcel Weiher on 6/10/07.
//  Copyright 2007 Marcel Weiher. All rights reserved.
//

#import "MPWStScript.h"
#import <MPWTalk/MPWMethodHeader.h>
#import "MPWStsh.h"
#import "MPWShellCompiler.h"

@implementation MPWStScript

idAccessor( data, setData )
idAccessor( methodHeader , setMethodHeader )
idAccessor( script, setScript )

+scriptWithContentsOfFile:(NSString*)filename
{
	return [[[self alloc] initWithData:[NSData dataWithContentsOfFile:filename]] autorelease];
}

-initWithData:(NSData*)newData
{
	self=[super init];
	[self setData:newData];
	[self parse];
	return self;
}


-(void)parse
{
	id scanner=[[[MPWScanner alloc] initWithData:[self data]] autorelease];
	BOOL inComments=YES;
	NSString *commentPrefix=@"#";
	NSString *literalArrayPrefix=@"#(";
	NSString *exprString;
	NSMutableArray *scriptLines=[NSMutableArray array];
    while ( nil != (exprString=[scanner nextLine]) ) {

        if ( [exprString hasPrefix:commentPrefix] && ![exprString hasPrefix:literalArrayPrefix] ) {
 			if ( inComments && [exprString hasPrefix:@"#-"] ) {
				id methodHeaderString=[exprString substringFromIndex:2];
				[self setMethodHeader:[MPWMethodHeader methodHeaderWithString:methodHeaderString]];
			}
        }  else {
			[scriptLines addObject:exprString];
			inComments=NO;
		}
    }
	[self setScript:scriptLines];
}

-(BOOL)hasDeclaredReturn
{
	return [self methodHeader]!= nil && ![[methodHeader returnTypeName] isEqual:@"void"];
}

-(void)processArgsFromExecutionContext:executionContext
{
	id args=[[[[executionContext evaluator] valueOfVariableNamed:@"args"] mutableCopy] autorelease];
	
	int i;
	if ( [methodHeader numArguments] <= [args count] ) {
		for (i=0;i<[methodHeader numArguments];i++ ) {
			id arg=[args objectAtIndex:0];
			id argName=[methodHeader argumentNameAtIndex:i];
			id argType=[methodHeader argumentTypeAtIndex:i];

			//--- 'args' always takes up the 'remaining' args
			//--- but can appear at any point int the argument
			//--- list.
			
			if ( ![argName isEqual:@"args"] ) {
				if ( [argType isEqual:@"int"] ) {
					arg=[NSNumber numberWithInt:[arg intValue]];
				}
				[[executionContext evaluator] bindValue:arg toVariableNamed:argName];
				[args removeObjectAtIndex:0];
			}
		}
		[[executionContext evaluator] bindValue:[[args copy] autorelease] toVariableNamed:@"args"];
	}
}

-(void)executeInContext:executionContext
{
	id  scriptSource=[[self script] objectEnumerator];
	int line=1;
	NSString *exprString=nil;
	[self processArgsFromExecutionContext:executionContext];
	NS_DURING
    while ( nil != (exprString=[scriptSource nextObject]) ) {
		id pool=[NSAutoreleasePool new];
		id expr = [[executionContext evaluator] compile:exprString];
		id localResult = [[executionContext evaluator] executeShellExpression:expr];
		if ( [self hasDeclaredReturn] ) {
			[executionContext setRetval:localResult];
		}
		line++;
		[pool release];
	}
	if ( [self hasDeclaredReturn] ) {
		[[[MPWByteStream Stdout] do] println:[[executionContext retval] each]];
		[executionContext setRetval:nil];
	}
	NS_HANDLER
		[[MPWByteStream Stderr] println:[NSString stringWithFormat:@"Exception: %@ in line %d: '%@' ",
					localException,line,exprString]];
	NS_ENDHANDLER
}



@end
