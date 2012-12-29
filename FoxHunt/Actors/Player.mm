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
		_dashImpulseUp = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE_UP];
		_dashImpulseDown = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE_DOWN];
		
		
		_startX = [ConfigManager intForKey:CONFIG_PLAYER_START_POSITION_X] * SCALING_FACTOR_H;
		
		_obstaclesToRemove = [[NSMutableArray alloc] init];

	}
	return self;
}


-(void)update:(ccTime)dt {
	_lifetime+= dt;

	b2Vec2 v = _sprite.body->GetLinearVelocity();
	if(v.x < 0.5 && v.y < 0.5) {
		_isDashing = false;
	}
	
	//lock to a fixed position
	[_sprite transformPosition:ccp(_startX, _sprite.position.y)];
	
	for(LHSprite* obstacleSprite in _obstaclesToRemove) {
		
		DebugLog(@"Destroying crushed baddie!");
		
		[obstacleSprite makeNoPhysics];
		
		[obstacleSprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:0.5 angle:360]]];

		[obstacleSprite runAction:[CCMoveBy actionWithDuration:2.0f
											position:ccp(arc4random_uniform(300*SCALING_FACTOR_H)-(150*SCALING_FACTOR_H),
													-400*SCALING_FACTOR_V)]];
		
		[obstacleSprite runAction:[CCSequence actions:
				[CCDelayTime actionWithDuration:0.5],
				[CCFadeOut actionWithDuration:1.0],
				[CCCallBlock actionWithBlock:^{
					[obstacleSprite removeSelf];
				}],
				nil
			]
		 ];
	}
	[_obstaclesToRemove removeAllObjects];
	
	
	if(MODIFYING_GAME_CONFIG && _lifetime - _lastConfigReload >= GAME_CONFIG_REFRESH_RATE) {
		_lastConfigReload = _lifetime;
		_startX = [ConfigManager intForKey:CONFIG_PLAYER_START_POSITION_X] * SCALING_FACTOR_H;
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
			_dashImpulseUp = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE_UP];
			_dashImpulseDown = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE_DOWN];
			
			[_sprite prepareAnimationNamed:[_sprite.animationName stringByReplacingOccurrencesOfString:@"_fly" withString:@"_run"]  fromSHScene:_sprite.animationSHScene];
			
			if(_isMoving) {
				[_sprite playAnimation];
			}
		}
	}
}

-(void) onObstacleCollision:(LHContactInfo*)contact {
	LHSprite* playerSprite = [contact spriteA];
	LHSprite* obstacleSprite = [contact spriteB];

	if(playerSprite != nil && obstacleSprite != nil && !obstacleSprite.userData) {
		if(contact.contactType == LH_BEGIN_CONTACT) {
		
			obstacleSprite.userData = (void*)true;
		
			//if we land on top of baddies - kill them!
			if(obstacleSprite.position.y < playerSprite.position.y) {

				//kill the baddie
				 [_obstaclesToRemove addObject:obstacleSprite];

				_canDash = true;
				_dashImpulseUp = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE_UP];
				_dashImpulseDown = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE_DOWN];
				
				_sprite.body->SetLinearVelocity(b2Vec2(_sprite.body->GetLinearVelocity().x, 0));
				_sprite.body->ApplyLinearImpulse(
						b2Vec2(0,[ConfigManager doubleForKey:CONFIG_PLAYER_OBSTACLE_BOUNCE_IMPULSE]),
					_sprite.body->GetWorldCenter()
				);				
				
				[_sprite prepareAnimationNamed:[_sprite.animationName stringByReplacingOccurrencesOfString:@"_fly" withString:@"_run"]  fromSHScene:_sprite.animationSHScene];
				
				if(_isMoving) {
					[_sprite playAnimation];
				}
				
				
			}else {
				//boooo we die
				DebugLog(@"OH NO!!!!!!");
				//[obstacleSprite removeSelf];
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
	if(true || _canDash) {
		DebugLog(@"DASH!! direction = %f,%f", direction.x, direction.y);
		_isDashing = true;
		
		double dashImpulse = _dashImpulseUp;
		if(direction.y < 0) {
			dashImpulse = _dashImpulseDown;
		}
		
		_sprite.body->ApplyLinearImpulse(
				b2Vec2(direction.x*dashImpulse,
						direction.y*dashImpulse),
			_sprite.body->GetWorldCenter()
		);

		[_sprite prepareAnimationNamed:[_sprite.animationName stringByReplacingOccurrencesOfString:@"_run" withString:@"_fly"]  fromSHScene:_sprite.animationSHScene];
		
		[_sprite playAnimation];
		
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
	
	[_obstaclesToRemove release];
	
	[super dealloc];
}

@end
