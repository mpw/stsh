//
//  MPWEchoCommand.h
//  MPWShellScriptKit
//
//  Created by Marcel Weiher on 6/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <MPWFoundation/MPWFoundation.h>


@interface MPWEchoCommand : MPWStream {
	id	toEcho;
}

-pipe:otherCommand;

@end
