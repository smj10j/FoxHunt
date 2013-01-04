//
//  MainMenuLayer.mm
//  FoxHunt
//
//  Created by Stephen Johnson on 12/23/12.
//  Copyright Conquer LLC 2012. All rights reserved.
//


// Import the interfaces
#import "MainMenuLayer.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "IAPManager.h"

@implementation MainMenuLayer

-(id) init
{
	if( (self=[super init])) {
		
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
			
		CCLabelTTF* label = [[CCLabelTTF alloc] initWithString:@"I am a label" fontName:@"Helvetica" fontSize:24*SCALING_FACTOR_FONTS];
		[self addChild:label];
		[label release];
	}
	
	return self;
}


@end
