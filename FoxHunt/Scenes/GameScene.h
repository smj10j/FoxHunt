//
//  GameScene.h
//  Outlaw
//
//  Created by Stephen Johnson on 12/23/12.
//  Copyright Conquer LLC 2012. All rights reserved.
//

#import "Common.h"
#import "Box2D.h"
#import "LevelHelperLoader.h"
#import "CCPhysicsSprite.h"
#import "Player.h"
#import "Obstacle.h"
#import "Bystander.h"
#import <list>
using namespace std;

enum GAME_STATE {
	SETUP,
	PAUSE,
	RUNNING,
	GAME_OVER
};

// HelloWorldLayer
@interface GameScene : CCLayer
{	
	LevelHelperLoader* _levelLoader;
	b2World* _world;					// strong ref

	float _fixedTimestepAccumulator;
	double _lifetime;
	double _lastConfigReload;
	
	CGSize _levelSize;
	LHLayer* _mainLayer;
	LHParallaxNode* _parallaxNode;
	double _targetParallaxSpeed;
	double _normalParallaxSpeed;
	
	list<Obstacle*> _obstacles;
	list<Bystander*> _bystanders;

	CCLabelTTF* _traveDistanceLabel;
	double _traveDistanceInPixels;
	

	GAME_STATE _state;
	
	int _numTouchesOnScreen;
	CGPoint _lastTouchStart;
	
	Player* _player;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;




@end
