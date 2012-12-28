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
	
	bool _isJumping;
	float _jumpImpulse;
	bool _canJump;
	bool _isOnGround;
}

-(id)initWithSprite:(LHSprite*)sprite;

-(void)update:(ccTime)dt;


-(LHSprite*)sprite;

-(void) onGroundCollision:(LHContactInfo*)contact;

-(void)run;
-(void)stop;
-(void)setJumping:(bool)isJumping;

-(void)dealloc;

@end

#endif