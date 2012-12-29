//
//  Player.h
//  Outlaw
//
//  Created by Stephen Johnson on 12/24/12.
//  Copyright (c) 2012 Conquer LLC. All rights reserved.
//

#ifndef Outlaw_Actor_h
#define Outlaw_Actor_h

#import "Common.h"
#import "LevelHelperLoader.h"
#import "CCPhysicsSprite.h"

@interface Player : NSObject {

	LHSprite* _sprite;

	double _lifetime;

	int _seed;
	int _id;
	NSString* _type;
	
	bool _isMoving;
	
	bool _canDash;
	bool _isDashing;
	float _dashImpulseUp;
	float _dashImpulseDown;
	
	bool _isOnGround;
	
	bool _isDying;
	bool _isAlive;
	bool _needsToDie;
	
	int _startX;
	double _lastConfigReload;
	
	NSMutableArray* _spritesToRemove;
}

-(id)initWithSprite:(LHSprite*)sprite;

-(void)update:(ccTime)dt;


-(LHSprite*)sprite;
-(bool)isOnGround;
-(bool)isDashing;
-(bool)isAlive;

-(void) onGroundCollision:(LHContactInfo*)contact;
-(void) onObstacleCollision:(LHContactInfo*)contact;
-(void) onCollectibleCollision:(LHContactInfo*)contact;
-(void) onCoinCollision:(LHContactInfo*)contact;

-(void)run;
-(void)stop;
-(void)dash:(CGPoint)direction;


-(void)dealloc;

@end

#endif