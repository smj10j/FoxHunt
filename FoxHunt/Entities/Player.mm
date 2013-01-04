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
		
		_isAlive = true;
		_needsToDie = false;
		_isDying = false;
		
		_canJump = true;
		_isJumping = false;
		_jumpImpulse = [ConfigManager doubleForKey:CONFIG_PLAYER_JUMP_IMPULSE_INITIAL];
		
		_isDashing = false;
		_isOnGround = false;
		_canDash = true;
		_dashImpulseUp = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE_UP];
		_dashImpulseDown = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE_DOWN];
		
		
		_startX = [ConfigManager intForKey:CONFIG_PLAYER_START_POSITION_X] * SCALING_FACTOR_H;
		
		_spritesToRemove = [[NSMutableArray alloc] init];

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

	b2Vec2 v = _sprite.body->GetLinearVelocity();
	if(v.x < 0.5 && v.y < 0.5) {
		_isDashing = false;
		//DebugLog(@"STOPPED DASHING!");
	}
	
	//lock to a fixed position
	[_sprite transformPosition:ccp(_startX, _sprite.position.y)];
	
	for(LHSprite* sprite in _spritesToRemove) {
		
		DebugLog(@"Plyer is destroying sprite!");
		
		[sprite makeNoPhysics];
		
		[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:0.5 angle:360]]];

		[sprite runAction:[CCMoveBy actionWithDuration:2.0f
											position:ccp(arc4random_uniform(300*SCALING_FACTOR_H)-(150*SCALING_FACTOR_H),
													-400*SCALING_FACTOR_V)]];
		
		[sprite runAction:[CCSequence actions:
				[CCDelayTime actionWithDuration:0.5],
				[CCFadeOut actionWithDuration:1.0],
				[CCCallBlock actionWithBlock:^{
					[sprite removeSelf];
				}],
				nil
			]
		 ];
	}
	[_spritesToRemove removeAllObjects];
	
	
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

-(bool)isAlive {
	return _isAlive && !_isDying && !_needsToDie;
}

-(void)die {
	DebugLog(@"Adios, amigo.");
	
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
				[_sprite removeSelf];
				_isAlive = false;
			}],
			nil
		]
	 ];
}

-(void) onGroundCollision:(LHContactInfo*)contact {
	LHSprite* playerSprite = [contact spriteA];

	if(playerSprite != nil) {
		if(contact.contactType == LH_BEGIN_CONTACT) {
			_isOnGround = true;
			_isJumping = false;
			_canJump = true;
			_jumpImpulse = [ConfigManager doubleForKey:CONFIG_PLAYER_JUMP_IMPULSE_INITIAL];
	
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

-(void) onBystanderCollision:(Bystander*)bystander {

	if(![bystander isAlive]) {
		return;
	}

	//TODO: differentiate between coins and baddies in another method
	//if we land on top of baddies - kill them!
	if(_sprite.body != NULL && _sprite.body->GetLinearVelocity().y < 0) {

		//kill the baddie
		[bystander setNeedsToDie];

		_canDash = true;
		_dashImpulseUp = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE_UP];
		_dashImpulseDown = [ConfigManager doubleForKey:CONFIG_PLAYER_DASH_IMPULSE_DOWN];
		
		_sprite.body->SetLinearVelocity(b2Vec2(_sprite.body->GetLinearVelocity().x, 0));
		_sprite.body->ApplyLinearImpulse(
				b2Vec2(0,[ConfigManager doubleForKey:CONFIG_PLAYER_OBSTACLE_BOUNCE_IMPULSE]),
			_sprite.body->GetWorldCenter()
		);				
		
	}
}

-(void) onObstacleCollision:(Obstacle*)obstacle {

	if(![obstacle isAlive]) {
		return;
	}
	
	//boooo we die
	_needsToDie = true;
}

-(void) onCoinCollision:(LHContactInfo*)contact {
	LHSprite* playerSprite = [contact spriteA];
	LHSprite* coinSprite = [contact spriteB];

	if(playerSprite != nil && coinSprite != nil && !coinSprite.userData) {
		if(contact.contactType == LH_BEGIN_CONTACT) {
		
			coinSprite.userData = (void*)true;
		
			//TODO: handle coin collection
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
	if(_isAlive && !_needsToDie && _canDash) {
		DebugLog(@"DASH!! direction = %f,%f", direction.x, direction.y);
		_isDashing = true;
		_isOnGround = false;
		
		double dashImpulse = _dashImpulseUp;
		if(direction.y < 0) {
			dashImpulse = _dashImpulseDown;
		}
		
		//we haaaave lifffttoooofff!
		_sprite.body->SetLinearVelocity(b2Vec2(0,0));
		_sprite.body->ApplyLinearImpulse(
				b2Vec2(direction.x*dashImpulse,
						direction.y*dashImpulse),
			_sprite.body->GetWorldCenter()
		);

		//fly animation
		[_sprite prepareAnimationNamed:[_sprite.animationName stringByReplacingOccurrencesOfString:@"_run" withString:@"_fly"]
			fromSHScene:_sprite.animationSHScene];
		[_sprite playAnimation];
		
	}
}

-(void)jump {
	if(_isAlive && !_needsToDie && _canJump) {
		DebugLog(@"JUMP!!");
		_isOnGround = false;
		
		if(_isJumping) {
			_jumpImpulse+= [ConfigManager doubleForKey:CONFIG_PLAYER_JUMP_IMPULSE_STEP];
		}
		_isJumping = true;

		//we haaaave lifffttoooofff!
		_sprite.body->SetLinearVelocity(b2Vec2(0,0));
		_sprite.body->ApplyLinearImpulse(
				b2Vec2(0,_jumpImpulse),
			_sprite.body->GetWorldCenter()
		);

		//fly animation
		[_sprite prepareAnimationNamed:[_sprite.animationName stringByReplacingOccurrencesOfString:@"_run" withString:@"_fly"]
			fromSHScene:_sprite.animationSHScene];
		[_sprite playAnimation];
		
	}
}

-(void)fly:(CGPoint)direction {
	_canJump = false;
}

-(void)dealloc {
	if(_sprite != nil) {
		[_sprite release];
		_sprite = nil;
	}
	
	[_spritesToRemove release];
	
	[super dealloc];
}

@end
