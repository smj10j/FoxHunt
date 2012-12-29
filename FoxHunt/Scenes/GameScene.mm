//
//  GameScene.mm
//  Outlaw
//
//  Created by Stephen Johnson on 12/23/12.
//  Copyright Conquer LLC 2012. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene

+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init {

	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		
		//CGSize winSize = [CCDirector sharedDirector].winSize;
		
		_state = SETUP;
		_fixedTimestepAccumulator = 0;
		
		_numCollectiblesOnScreen = 0;
		_numObstaclesOnScreen = 0;
		_normalParallaxSpeed = [ConfigManager intForKey:CONFIG_PARALLAX_SPEED];
		_targetParallaxSpeed = _normalParallaxSpeed;

		CGSize winSize = [CCDirector sharedDirector].winSize;
		[LevelHelperLoader dontStretchArt];
		
		// init physics
		[self initPhysics];

		//create a LevelHelperLoader object that has the data of the specified level
		_levelLoader = [[LevelHelperLoader alloc] initWithContentOfFile:[NSString stringWithFormat:@"Levels/Empty"]];
		
		//create all objects from the level file and adds them to the cocos2d layer (self)
		[_levelLoader addObjectsToWorld:_world cocos2dLayer:self];
		[_levelLoader useLevelHelperCollisionHandling];

		_mainLayer = [_levelLoader layerWithUniqueName:@"MAIN_LAYER"];
		_parallaxNode = [_levelLoader parallaxNodeWithUniqueName:@"Parallax"];

		_levelSize = winSize.width < _levelLoader.gameWorldSize.size.width ? _levelLoader.gameWorldSize.size : winSize;
		DebugLog(@"Level size: %f x %f", _levelSize.width, _levelSize.height);


		//checks if the level has physics boundaries
		if([_levelLoader hasPhysicBoundaries]) {
			//if it does, it will create the physic boundaries
			[_levelLoader createPhysicBoundaries:_world];
		}	
		if(![_levelLoader isGravityZero]) {
			//create level-specified gravity
			[_levelLoader createGravity:_world];
		}

		[self setupPlayer];
		
		_state = RUNNING;
		[self scheduleUpdate];
	}
	return self;
}

-(void) setupPlayer {

	LHSprite* foxSprite = [_levelLoader createSpriteWithName:@"rocketmouse_1_run" fromSheet:@"Actors" fromSHFile:@"Spritesheet" tag:PLAYER parent:_mainLayer];
	[foxSprite transformPosition:ccp(200*SCALING_FACTOR_H, _levelSize.height/2)];
	[foxSprite prepareAnimationNamed:@"Player_run" fromSHScene:@"Spritesheet"];
	
	_player = [[Player alloc] initWithSprite:foxSprite];
	[_player run];
	
	
	[_levelLoader registerBeginOrEndCollisionCallbackBetweenTagA:PLAYER
															andTagB:GROUND
				idListener:_player
				selListener:@selector(onGroundCollision:)];
				
	[_levelLoader registerBeginOrEndCollisionCallbackBetweenTagA:PLAYER
															andTagB:OBSTACLE
				idListener:_player
				selListener:@selector(onObstacleCollision:)];
				
	[_levelLoader registerBeginOrEndCollisionCallbackBetweenTagA:PLAYER
															andTagB:COLLECTIBLE
				idListener:_player
				selListener:@selector(onCollectibleCollision:)];
				
				
	[_levelLoader registerBeginOrEndCollisionCallbackBetweenTagA:PLAYER
															andTagB:COIN
				idListener:_player
				selListener:@selector(onCoinCollision:)];
}

-(void) initPhysics {
		
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
	_world = new b2World(gravity);
	
	// Do we want to let bodies sleep?
	_world->SetAllowSleeping(true);
	
	_world->SetContinuousPhysics(true);
}


-(void) draw {
	[super draw];
}

-(void) update: (ccTime) dt {
	
	_fixedTimestepAccumulator+= dt;
	//DebugLog(@"dt = %f, _fixedTimestepAccumulator = %f", dt, _fixedTimestepAccumulator);
	
	//dynamically set this guy
	const int BASELINE_MAX_STEPS = [ConfigManager intForKey:CONFIG_SIMULATION_MAX_STEPS];
	static float maxSteps = BASELINE_MAX_STEPS;
	
	const double stepSize = [ConfigManager doubleForKey:CONFIG_SIMULATION_STEP_SIZE];
	const int steps = _fixedTimestepAccumulator / stepSize;
		
	if (steps > 0) {

		const int stepsClamped = MIN(steps, (int)maxSteps);
        _fixedTimestepAccumulator-= (stepsClamped * stepSize);
	 
		for (int i = 0; i < stepsClamped; i++) {
			[self singleUpdateStep:stepSize];
		}
		
	}else {
		//no step - we're just too dang fast!
	}
	
	if(MODIFYING_GAME_CONFIG && _lifetime - _lastConfigReload >= GAME_CONFIG_REFRESH_RATE) {
		_lastConfigReload = _lifetime;
		_normalParallaxSpeed = [ConfigManager intForKey:CONFIG_PARALLAX_SPEED];
	}
}

-(void) singleUpdateStep:(ccTime) dt {
	
	_lifetime+= dt;

	//DebugLog(@"singleUpdateStep. _fixedTimestepAccumulator = %f", _fixedTimestepAccumulator);

	if(![_player isAlive]) {
		//TODO: go to menu
		[self restart];
		return;
	}

	const static int32 velocityIterations = 8;
	const static int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_world->Step(dt, velocityIterations, positionIterations);
	
    //Iterate over the bodies in the physics world
	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext()) {
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            
            if(myActor != 0) {
                //THIS IS VERY IMPORTANT - GETTING THE POSITION FROM BOX2D TO COCOS2D
                myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
				myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            
        }
	}
	
	//tell the player to update itself
	[_player update:dt];

	
	[self updateParallaxSpeed];
	
	
	
	//generate random collectibles
	if((int)(_lifetime*10)%10 == 0 && arc4random_uniform(1000) < 200 && _numCollectiblesOnScreen < 10) {
		[self addCollectible];
	}
	//generate random obstacles
	if((int)(_lifetime*10)%10 == 0 && arc4random_uniform(1000) < 200 && _numCollectiblesOnScreen < 10) {
		[self addObstacle];
	}
		
	[self destroyOffscreenSprites];
}

//TODO: change this naming to something more inline with the game once we know what it is
-(void)addCollectible {
	CGSize winSize = [CCDirector sharedDirector].winSize;

	LHSprite* collectibleSprite = [_levelLoader createBatchSpriteWithName:@"object_sleepingcat" fromSheet:@"Obstacles" fromSHFile:@"Spritesheet" tag:COLLECTIBLE];
	[_parallaxNode addSprite:collectibleSprite parallaxRatio:ccp(1,0)];
	[collectibleSprite transformPosition:ccp(
							arc4random_uniform(winSize.width/2) + winSize.width,
							(arc4random_uniform(40)+80)*SCALING_FACTOR_V
						)
	];
			
	DebugLog(@"adding collectible sprite at %f,%f", collectibleSprite.position.x, collectibleSprite.position.y);
}

-(void)addObstacle {
	CGSize winSize = [CCDirector sharedDirector].winSize;

	LHSprite* obstacleSprite = [_levelLoader createBatchSpriteWithName:@"object_sleepingdog" fromSheet:@"Obstacles" fromSHFile:@"Spritesheet" tag:OBSTACLE];
	[_parallaxNode addSprite:obstacleSprite parallaxRatio:ccp(1,0)];
	[obstacleSprite transformPosition:ccp(
							arc4random_uniform(winSize.width/2) + winSize.width,
							arc4random_uniform(winSize.height)
						)
	];
			
	DebugLog(@"adding obstacle sprite at %f,%f", obstacleSprite.position.x, obstacleSprite.position.y);
}

-(void)destroyOffscreenSprites {
	//destroy offscreen obstacles
	NSArray* obstacles = [_levelLoader spritesWithTag:OBSTACLE];
	_numObstaclesOnScreen = [obstacles count];
	for(LHSprite* obstacle in obstacles) {
		//DebugLog(@"Checking obstacle at %f,%f", obstacle.position.x, obstacle.position.y);
		if(obstacle.position.x <= obstacle.boundingBox.size.width) {
			[obstacle runAction:[CCSequence actions:
						[CCFadeOut actionWithDuration:0.5f],
						[CCCallBlock actionWithBlock:^{
							[obstacle removeSelf];
							DebugLog(@"Removing offscreen obstacle");
						}],
						nil
			]];
		}
	}
}

-(void)updateParallaxSpeed {
	
	if(_targetParallaxSpeed != _parallaxNode.speed) {
		[_parallaxNode setSpeed:_targetParallaxSpeed];
		_targetParallaxSpeed+= (_normalParallaxSpeed - _targetParallaxSpeed)/100;
		//DebugLog(@"_targetParallaxSpeed = %f", _targetParallaxSpeed);
	}
	
	//DebugLog(@"Parallax speed: %f", _parallaxNode.speed);
}

- (void)restart {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:0.5 scene:[GameScene scene]]];
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	_numTouchesOnScreen+= [touches count];

	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
	
		_lastTouchStart = location;
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {


}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	_numTouchesOnScreen-= [touches count];
	if(_numTouchesOnScreen <= 0) {
		_numTouchesOnScreen = 0;
	}

	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
	
		if(location.x-_lastTouchStart.x == 0 && location.y-_lastTouchStart.y == 0) {
			continue;
		}

		//swipe direction
		CGPoint dashVector = ccpNormalize(ccpSub(location, _lastTouchStart));
		
		//move the player
		[_player dash:ccp(0, dashVector.y)];

		if([_player isDashing]) {
			//speed up/down parallax
			if(dashVector.x > 0) {
				_targetParallaxSpeed+= dashVector.x*[ConfigManager intForKey:CONFIG_PARALLAX_SPEED_ADJUSTMENT_FACTOR];
			}
		}
	}
}








-(void) onEnter {
	[super onEnter];
}


-(void) onExit {
	if(DEBUG_MEMORY) DebugLog(@"GameScene onExit");

	for(LHSprite* sprite in _levelLoader.allSprites) {
		[sprite stopAnimation];
	}
	
	[super onExit];
}


-(void) dealloc {
	if(DEBUG_MEMORY) DebugLog(@"GameScene dealloc");
	if(DEBUG_MEMORY) report_memory();
	
	if(_player != nil) {
		[_player release];
		_player = nil;
	}
	
	[_levelLoader removeAllPhysics];
	[_levelLoader release];
	_levelLoader = nil;

	delete _world;
	_world = NULL;
			
	[super dealloc];
	
	if(DEBUG_MEMORY) DebugLog(@"End GameScene dealloc");
	if(DEBUG_MEMORY) report_memory();
}

@end
