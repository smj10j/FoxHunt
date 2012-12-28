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
		
		_isJumping = false;
		_isOnGround = false;
		_canJump = true;
		
	}
	return self;
}

-(void)setJumping:(bool)isJumping {
	_isJumping = isJumping;
	if(!_isJumping) {
		_canJump = false;
	}
}


-(void)update:(ccTime)dt {
	_lifetime+= dt;	

	if(_isMoving) {


	}
	
	if(_isJumping) {
		[self jump];
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
			_jumpImpulse = [ConfigManager doubleForKey:CONFIG_PLAYER_JUMP_IMPULSE];
			
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
		
		const float MAX_VELOCITY = [ConfigManager doubleForKey:CONFIG_PLAYER_JUMP_VELOCITY_MAX];
		if(_sprite.body->GetLinearVelocity().y > MAX_VELOCITY) {
			_canJump = false;
			return;
		}
		_sprite.body->ApplyLinearImpulse(b2Vec2(0,_jumpImpulse), _sprite.body->GetWorldCenter());

		_isOnGround = false;
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
