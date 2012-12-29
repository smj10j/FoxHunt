//
//  ConfigManager.h
//  Outlaw
//
//  Created by Stephen Johnson on 12/23/12.
//  Copyright (c) 2012 Conquer LLC. All rights reserved.
//


#ifndef Outlaw_ConfigManager_h
#define Outlaw_ConfigManager_h

@interface ConfigManager : NSObject

+(void)init;

+(bool)boolForKey:(NSString*)key;
+(NSString*)stringForKey:(NSString*)key;
+(int)intForKey:(NSString*)key;
+(double)doubleForKey:(NSString*)key;


@end



#define CONFIG_SIMULATION_STEP_SIZE @"SIMULATION_STEP_SIZE"
#define CONFIG_SIMULATION_MAX_STEPS @"SIMULATION_MAX_STEPS"

#define CONFIG_PLAYER_DASH_IMPULSE_UP @"PLAYER_DASH_IMPULSE_UP"
#define CONFIG_PLAYER_DASH_IMPULSE_DOWN @"PLAYER_DASH_IMPULSE_DOWN"
#define CONFIG_PLAYER_START_POSITION_X @"PLAYER_START_POSITION_X"
#define CONFIG_PLAYER_START_POSITION_Y @"PLAYER_START_POSITION_Y"
#define CONFIG_PLAYER_OBSTACLE_BOUNCE_IMPULSE @"PLAYER_OBSTACLE_BOUNCE_IMPULSE"

#define CONFIG_PARALLAX_SPEED @"PARALLAX_SPEED"
#define CONFIG_PARALLAX_SPEED_ADJUSTMENT_FACTOR @"PARALLAX_SPEED_ADJUSTMENT_FACTOR"
#endif