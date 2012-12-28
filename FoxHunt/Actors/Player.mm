//
//  Player.mm
//  Outlaw
//
//  Created by Stephen Johnson on 12/24/12.
//  Copyright (c) 2012 Conquer LLC. All rights reserved.
//

#import "Player.h"

@implementation Player


-(id)initWithSprite:(LHSprite*)sprite {
	static int ID = 1;
	if(self = [super init]) {
		_sprite = sprite;
		[_sprite retain];

		_seed = arc4random_uniform(50)+1;
		_id = ID++;
		_type = @"Player";
		
		_lifetime = 0;
		
		_isMoving = false;
		_isOnGround = false;
		_canJump = true;
		
	}
	return self;
}

-(void)update:(ccTime)dt {
	_lifetime+= dt;	

	if(_isMoving) {

		//slide the parent layer
		//CGPoint speedVector = ccpMult(ccp(1*PTM_RATIO, 0), -dt);
		//_sprite.parent.position = ccpAdd(_sprite.parent.position, speedVector);
		//DebugLog(@"parent pos: %f,%f", _sprite.parent.position.x, _sprite.parent.position.y);
	}
}

-(LHSprite*)sprite {
	return _sprite;
}

-(void) onGroundCollision:(LHContactInfo*)contact {
	LHSprite* playerSprite = [contact spriteA];

	if(playerSprite != nil) {
		if(contact.contactType == LH_BEGIN_CONTACT) {
			_isOnGround = true;
			_canJump = true;
			
			
			[_sprite prepareAnimationNamed:[_sprite.animationName stringByReplacingOccurrencesOfString:@"_fly" withString:@"_run"]  fromSHScene:_sprite.animationSHScene];
			
			if(_isMoving) {
				[_sprite playAnimation];
			}
		}
	}
}

-(void)run {
	_isMoving = true;
	[_sprite playAnimation];
}

-(void)stop {
	_isMoving = false;
	[_sprite stopAnimation];
}

-(void)jump {
	if(_canJump) {
		[_sprite prepareAnimationNamed:[_sprite.animationName stringByReplacingOccurrencesOfString:@"_run" withString:@"_fly"]  fromSHScene:_sprite.animationSHScene];
		[_sprite playAnimation];
		
		_sprite.body->ApplyLinearImpulse(b2Vec2(0,0.75), _sprite.body->GetWorldCenter());

		//enable double jump
		if(_isOnGround) {
			_isOnGround = false;
		}else {
			_canJump = false;
		}
	}
}

-(void)dealloc {
	if(_sprite != nil) {
		[_sprite release];
		_sprite = nil;
	}
	[super dealloc];
}

@end
