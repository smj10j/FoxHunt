//
//  ParallaxLayer.mm
//  FoxHunt
//
//  Created by Stephen Johnson on 12/29/12.
//  Copyright (c) 2012 Conquer LLC. All rights reserved.
//

#import "ParallaxLayer.h"
#import "LevelHelperLoader.h"

@implementation ParallaxLayer


-(id)init {
	static int ID = 1;
	if(self = [super init]) {
		
		_id = ID++;
		
		_lifetime = 0;

		_speed = 0;
		_width = 0;
	}
	return self;
}

-(void)draw {

	if(DEBUG_COLLISIONS) {
	
		ccColor4F color;
		CGSize size;
		double scalar;
	
		for(CCNode* node in self.children) {
			
			scalar = 0;
			
			if(node.tag == OBSTACLE) {
				scalar = [ConfigManager doubleForKey:CONFIG_OBSTACLE_BOUNDING_BOX_SCALAR];
				color = ccc4f(1, .3, .3, 1);
				
			}else if(node.tag == BYSTANDER) {
				scalar = [ConfigManager doubleForKey:CONFIG_BYSTANDER_BOUNDING_BOX_SCALAR];
				color = ccc4f(.3, .3, 1, 1);
			}
			
			
			if(scalar > 0) {

				size = CGSizeMake(node.boundingBox.size.width*scalar,
								node.boundingBox.size.height*scalar);

				ccDrawSolidRect(
					ccp(node.position.x - size.width/2,
						node.position.y - size.height/2),
					ccp(node.position.x  + size.width/2,
						node.position.y + size.height/2),
					color);
			}
	
		}
	}
	[super draw];
}

-(void)update:(ccTime)dt {
	_lifetime+= dt;
		
		
	if(_backgroundNodes.size() > 0) {
		CCNode* front = _backgroundNodes.front();
		//DebugLog(@"front %f,%f", self.position.x, self.position.y);
		
		if(![self isNodeVisible:front]) {
			CCNode* back = _backgroundNodes.back();

			_backgroundNodes.pop_front();

			front.position = ccp(back.position.x+back.boundingBox.size.width, front.position.y);
			//DebugLog(@"Moving background node to %f,%f, Left=%f", front.position.x, front.position.y, self.position.x);
			_backgroundNodes.push_back(front);		
		}
	}
	
	self.position = ccpSub(self.position, ccp(_speed*dt, 0));
}

-(NSArray*)collisionsWith:(CCNode*)targetNode tag:(int)tag {

	NSMutableArray* collisions = [[[NSMutableArray alloc] init] autorelease];
	
	double targetBoundingBoxScalar = [ConfigManager doubleForKey:CONFIG_PLAYER_BOUNDING_BOX_SCALAR];
	
	double nodeBoundingBoxScalar = 1.0;
	
	if(tag == OBSTACLE) {
		nodeBoundingBoxScalar = [ConfigManager doubleForKey:CONFIG_OBSTACLE_BOUNDING_BOX_SCALAR];
	}else if(tag == BYSTANDER) {
		nodeBoundingBoxScalar = [ConfigManager doubleForKey:CONFIG_BYSTANDER_BOUNDING_BOX_SCALAR];
	}

	CGSize targetSize = CGSizeMake(targetNode.boundingBox.size.width*targetBoundingBoxScalar,
									targetNode.boundingBox.size.height*targetBoundingBoxScalar);
	CGRect targetRect = CGRectMake(targetNode.position.x - self.position.x - targetSize.width/2,
									targetNode.position.y - self.position.y - targetSize.height/2,
									targetSize.width,
									targetSize.height);


	for(CCNode* node in self.children) {
		if(node.tag == tag) {
			
			CGSize size = CGSizeMake(node.boundingBox.size.width*nodeBoundingBoxScalar,
									node.boundingBox.size.height*nodeBoundingBoxScalar);
			CGRect nodeRect = CGRectMake(node.position.x - size.width/2,
											node.position.y - size.height/2,
											size.width,
											size.height);

			
			if(CGRectIntersectsRect(nodeRect, targetRect)) {
			
				[collisions addObject:node];
				//DebugLog(@"INTERSECTION with tag=%d, target.y = %f, node.y = %f!", node.tag, targetNode.position.y, node.position.y);
			}
		}
	}

	return collisions;
}

-(void)addNode:(CCNode*)node parallaxRatio:(CGPoint)ratio {
	node.position = ccp(node.position.x - self.position.x, node.position.y - self.position.y);
	[self addChild:node z:2];
}

-(void)pushBackgroundNode:(CCNode*)node parallaxRatio:(CGPoint)ratio {
	[self addChild:node z:1];
	
	[node retain];
	_backgroundNodes.push_back(node);
	
	_width+= node.boundingBox.size.width;
}

-(double)speed {
	return _speed;
}

-(void)setSpeed:(double)speed {
	_speed = speed;
}

-(bool)isNodeVisible:(CCNode*)node {
	float nodeRight = node.position.x+node.boundingBox.size.width/2 + self.position.x;
	return nodeRight > 0;
}

-(double)offset {
	return self.position.x;
}

-(void)dealloc {
	for(CCNode* node : _backgroundNodes) {
		[node release];
	}
	_backgroundNodes.clear();
	
	[super dealloc];
}

@end
