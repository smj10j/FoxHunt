//
//  ParallaxLayer.h
//  FoxHunt
//
//  Created by Stephen Johnson on 12/29/12.
//  Copyright (c) 2012 Conquer LLC. All rights reserved.
//

#import "Common.h"
#import "LevelHelperLoader.h"
#import <list>
using namespace std;

@interface ParallaxLayer : CCLayer {

	double _lifetime;

	int _id;
	
	double _speed;
	
	double _width;
	list<CCNode*> _backgroundNodes;

}

-(id)init;
-(void)update:(ccTime)dt;


-(double)offset;
-(double)speed;
-(void)setSpeed:(double)speed;

-(void)addNode:(CCNode*)sprite parallaxRatio:(CGPoint)ratio;
-(void)pushBackgroundNode:(CCNode*)node parallaxRatio:(CGPoint)ratio;

-(bool)isNodeVisible:(CCNode*)node;

-(void)dealloc;

@end
