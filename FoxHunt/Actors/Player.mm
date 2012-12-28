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
		
		_isDashing = false;
		_isOnGround = false;
		_canDash = true;
		
	}
	return self;
}


-(void)update:(ccTime)dt {
	_lifetime+= dt;

	b2Vec2 v = _sprite.body->GetLinearVelocity();
	if(v.x < 0.5 && v.y < 0.5) {
		_isDashing = false;
	}
	
}

-(LHSprite*)sprite {
	return _sprite;
}

-(bool)isOnGround {
	return _isOnGround;
}

-(bool)isDashing {
	return _isDashing;
}

-(void) onGroundCollision:(LHContactInfo*)contact {
	LHSprite* playerSprite = [contact spriteA];

	if(playerSprite != nil) {
		if(contact.contactType == LH_BEGIN_CONTACT) {
			_isOnGround = true;
			_canDash = true;
			_dashImpulse = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE];
			
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


-(void)dash:(CGPoint)direction {
	if(_canDash) {
		DebugLog(@"DASH!! direction = %f,%f", direction.x, direction.y);
		_isDashing = true;
		_sprite.body->ApplyLinearImpulse(
				b2Vec2(direction.x*_dashImpulse,
						direction.y*_dashImpulse),
			_sprite.body->GetWorldCenter()
		);
		
		//dash once when in the air
		if(_isOnGround) {
			_isOnGround = false;
		}else {
			_canDash = false;
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
