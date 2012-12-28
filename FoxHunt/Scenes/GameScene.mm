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
		
		// enable events
		
		_state = SETUP;
		
		self.isTouchEnabled = YES;
		
		//CGSize winSize = [CCDirector sharedDirector].winSize;
		
		_fixedTimestepAccumulator = 0;

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
		[_parallaxNode setSpeed:[ConfigManager intForKey:CONFIG_PARALLAX_SPEED]];

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

		[self setupTest];
		
		_state = RUNNING;
		[self scheduleUpdate];
	}
	return self;
}

-(void) setupTest {

	LHSprite* foxSprite = [_levelLoader createSpriteWithName:@"rocketmouse_1_run" fromSheet:@"Actors" fromSHFile:@"Spritesheet" tag:PLAYER parent:_mainLayer];
	[foxSprite transformPosition:ccp(200*SCALING_FACTOR_H, _levelSize.height/2)];
	[foxSprite prepareAnimationNamed:@"Player_run" fromSHScene:@"Spritesheet"];
	
	_player = [[Player alloc] initWithSprite:foxSprite];
	[_player run];
	
	[_levelLoader registerBeginOrEndCollisionCallbackBetweenTagA:PLAYER
															andTagB:GROUND
				idListener:_player
				selListener:@selector(onGroundCollision:)];
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
	
	_lifetime+= dt;
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
	
	if(_lifetime - _lastConfigReload > 5) {
		_lastConfigReload = _lifetime;
		[_parallaxNode setSpeed:[ConfigManager intForKey:CONFIG_PARALLAX_SPEED]];
	}
}

-(void) singleUpdateStep:(ccTime) dt {
	
	//DebugLog(@"singleUpdateStep. _fixedTimestepAccumulator = %f", _fixedTimestepAccumulator);



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
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	_numTouchesOnScreen+= [touches count];

	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
	
		[_player setJumping:true];
	}
	
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	_numTouchesOnScreen-= [touches count];
	if(_numTouchesOnScreen <= 0) {
		_numTouchesOnScreen = 0;
		[_player setJumping:false];
	}

	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];

		
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
