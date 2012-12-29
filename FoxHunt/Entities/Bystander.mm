//
//  Bystander.mm
//  FoxHunt
//
//  Created by Stephen Johnson on 12/24/12.
//  Copyright (c) 2012 Conquer LLC. All rights reserved.
//

#import "Bystander.h"

@implementation Bystander


-(id)initWithSprite:(LHSprite*)sprite {
	static int ID = 1;
	if(self = [super init]) {
		_sprite = sprite;
		[_sprite retain];
		[sprite setVisible:false];

		_seed = arc4random_uniform(50)+1;
		_id = ID++;
		_type = @"Bystander";
		
		_lifetime = 0;
		
		
		_isAlive = false;
		_needsToDie = false;
		_isDying = false;
	}
	return self;
}


-(void)update:(ccTime)dt {
	_lifetime+= dt;

	if(!_isAlive) return;
	
	if(_needsToDie) {
		if(!_isDying) {
			[self die];
		}
		return;
	}
	
	ParallaxLayer* parallaxLayer = (ParallaxLayer*)_sprite.parent;
	
	if(![parallaxLayer isNodeVisible:_sprite]) {
		[_sprite runAction:[CCSequence actions:
					[CCDelayTime actionWithDuration:0.50f],
					[CCCallBlock actionWithBlock:^{
						_sprite.visible = false;
						_isAlive = false;
					}],
					nil
		]];
	}
}

-(LHSprite*)sprite {
	return _sprite;
}

-(bool)isAlive {
	return _isAlive && !_isDying && !_needsToDie;
}

-(void)die {
	DebugLog(@"Adios, bystander.");
	
	_isDying = true;
	
	[_sprite makeNoPhysics];
		
	[_sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:0.5 angle:360]]];

	[_sprite runAction:[CCMoveBy actionWithDuration:2.0f
										position:ccp(arc4random_uniform(300*SCALING_FACTOR_H)-(150*SCALING_FACTOR_H),
												-400*SCALING_FACTOR_V)]];
	
	[_sprite runAction:[CCSequence actions:
			[CCDelayTime actionWithDuration:0.5],
			[CCFadeOut actionWithDuration:1.0],
			[CCCallBlock actionWithBlock:^{
				_sprite.visible = false;
				_isAlive = false;
			}],
			nil
		]
	 ];
}

-(void)setNeedsToDie {
	_needsToDie = true;
}

-(void)makeAliveAt:(CGPoint)pos {
	[_sprite transformPosition:ccp(pos.x - ((ParallaxLayer*)_sprite.parent).offset, pos.y)];
	_sprite.visible = true;
	_needsToDie = false;
	_isDying = false;
	_isAlive = true;
}

-(void)dealloc {
	if(_sprite != nil) {
		[_sprite release];
		_sprite = nil;
	}
		
	[super dealloc];
}

@end
