//
//  Obstacle.h
//  FoxHunt
//
//  Created by Stephen Johnson on 12/24/12.
//  Copyright (c) 2012 Conquer LLC. All rights reserved.
//

#ifndef FoxHunt_Obstacle_h
#define FoxHunt_Obstacle_h

#import "Common.h"
#import "LevelHelperLoader.h"
#import "CCPhysicsSprite.h"
#import "ParallaxLayer.h"

@interface Obstacle : NSObject {

	LHSprite* _sprite;

	double _lifetime;

	int _seed;
	int _id;
	NSString* _type;
	
	bool _isDying;
	bool _isAlive;
	bool _needsToDie;
}

-(id)initWithSprite:(LHSprite*)sprite;

-(void)update:(ccTime)dt;


-(LHSprite*)sprite;
-(bool)isAlive;

-(void)setNeedsToDie;
-(void)makeAliveAt:(CGPoint)pos;

-(void)dealloc;

@end

#endif