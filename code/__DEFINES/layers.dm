//Defines for atom layers and planes
//KEEP THESE IN A NICE ACSCENDING ORDER, PLEASE

//#define FLOAT_PLANE -32767 //For easy recordkeeping; this is a byond define.

//NEVER HAVE ANYTHING BELOW THIS PLANE ADJUST IF YOU NEED MORE SPACE
#define LOWEST_EVER_PLANE -200

#define CLICKCATCHER_PLANE -99

#define PLANE_SPACE -95
#define PLANE_SPACE_PARALLAX -90

/*
Z-Mimic uses planes -70 through -80, defined elsewhere.
Specifically: ZMIMIC_MAX_PLANE to (ZMIMIC_MAX_PLANE - ZMIMIC_MAX_DEPTH)
*/

#define HEAT_PLANE -12
#define HEAT_RENDER_TARGET "*HEAT_RENDER_TARGET"
#define HEAT_COMPOSITE_RENDER_TARGET "*HEAT_RENDER_TARGET_C"

#define GRAVITY_PULSE_PLANE -11
#define GRAVITY_PULSE_RENDER_TARGET "*GRAVPULSE_RENDER_TARGET"


#define FLOOR_PLANE -7

#define GAME_PLANE -6

///Slightly above the game plane but does not catch mouse clicks. Useful for certain visuals that should be clicked through, like seethrough trees
#define SEETHROUGH_PLANE -5

// PLANE_SPACE layer(s)
#define SPACE_LAYER 1.8

//#define TURF_LAYER 2 //For easy recordkeeping; this is a byond define. Most floors (FLOOR_PLANE) and walls (GAME_PLANE) use this.

// GAME_PLANE layers
#define CULT_OVERLAY_LAYER 2.01
#define MID_TURF_LAYER 2.02
#define HIGH_TURF_LAYER 2.03
#define TURF_PLATING_DECAL_LAYER 2.031
#define TURF_DECAL_LAYER 2.032 //Makes turf decals appear in DM how they will look inworld.
#define TURF_DECAL_HIGH_LAYER 2.033
#define ABOVE_OPEN_TURF_LAYER 2.04
#define AO_LAYER 2.045
#define CLOSED_TURF_LAYER 2.05
#define BULLET_HOLE_LAYER 2.06
#define ABOVE_NORMAL_TURF_LAYER 2.08
#define LATTICE_LAYER 2.2
#define DISPOSAL_PIPE_LAYER 2.3
#define GAS_PIPE_HIDDEN_LAYER 2.35 //layer = initial(layer) + piping_layer / 1000 in atmospherics/update_icon() to determine order of pipe overlap
#define WIRE_LAYER 2.4
#define WIRE_KNOT_LAYER 2.44
#define WIRE_TERMINAL_LAYER 2.45
#define GAS_SCRUBBER_LAYER 2.46
#define GAS_PIPE_VISIBLE_LAYER 2.47 //layer = initial(layer) + piping_layer / 1000 in atmospherics/update_icon() to determine order of pipe overlap
#define GAS_FILTER_LAYER 2.48
#define GAS_PUMP_LAYER 2.49
#define BOT_PATH_LAYER 2.491
#define LOW_OBJ_LAYER 2.5
/// The lattice of /obj/structure/overfloor_catwalk
#define CATWALK_LATTICE_LAYER 2.505
/// The rim of /obj/structure/overfloor_catwalk
#define CATWALK_LAYER 2.51
#define LOW_SIGIL_LAYER 2.52
#define SIGIL_LAYER 2.53
#define HIGH_PIPE_LAYER 2.54
// Anything aboe this layer is not "on" a turf for the purposes of washing
// I hate this life of ours
#define FLOOR_CLEAN_LAYER 2.55
#define BELOW_OPEN_DOOR_LAYER 2.6
#define BLASTDOOR_LAYER 2.65
#define SHUTTER_LAYER 2.67
#define OPEN_DOOR_LAYER 2.7
#define DOOR_HELPER_LAYER 2.71 //keep this above OPEN_DOOR_LAYER
#define PROJECTILE_HIT_THRESHHOLD_LAYER 2.75 //projectiles won't hit objects at or below this layer if possible
#define TABLE_LAYER 2.8
#define GATEWAY_UNDERLAY_LAYER 2.85
#define LOW_WALL_LAYER 2.86
#define BELOW_OBJ_LAYER 2.9
#define LOW_ITEM_LAYER 2.95

//#define OBJ_LAYER 3 //For easy recordkeeping; this is a byond define
#define CLOSED_DOOR_LAYER 3.1
#define CLOSED_FIREDOOR_LAYER 3.11
#define ABOVE_OBJ_LAYER 3.2
#define SHUTTER_LAYER_CLOSED 3.21
#define CLOSED_BLASTDOOR_LAYER 3.22
#define LOW_WALL_STRIPE_LAYER 3.25
#define ABOVE_WINDOW_LAYER 3.3
#define WINDOW_HELPER_LAYER 3.31 // Keep this above ABOVE_WINDOW_LAYER
#define SIGN_LAYER 3.4
#define CORGI_ASS_PIN_LAYER 3.41
#define NOT_HIGH_OBJ_LAYER 3.5
#define HIGH_OBJ_LAYER 3.6
#define BELOW_MOB_LAYER 3.7
#define LOW_MOB_LAYER 3.75
#define LYING_MOB_LAYER 3.8
#define VEHICLE_LAYER 3.9
#define VEHICLE_RIDING_LAYER 3.92
#define MOB_BELOW_PIGGYBACK_LAYER 3.94

//#define MOB_LAYER 4 //For easy recordkeeping; this is a byond define
#define MOB_SHIELD_LAYER 4.01
#define MOB_ABOVE_PIGGYBACK_LAYER 4.06
#define MOB_UPPER_LAYER 4.07
#define HITSCAN_PROJECTILE_LAYER 4.09
#define ABOVE_MOB_LAYER 4.1
#define TROLLEY_BARS_LAYER 4.2
#define WALL_OBJ_LAYER 4.25
#define EDGED_TURF_LAYER 4.3
#define ON_EDGED_TURF_LAYER 4.35
#define SPACEVINE_LAYER 4.4
#define LARGE_MOB_LAYER 4.5
#define SPACEVINE_MOB_LAYER 4.6
#define ABOVE_ALL_MOB_LAYER 4.7

//#define FLY_LAYER 5 //For easy recordkeeping; this is a byond define
#define GAS_LAYER 5
#define GASFIRE_LAYER 5.05
#define MIMICKED_LIGHTING_LAYER 5.06
#define RIPPLE_LAYER 5.1


#define BLACKNESS_PLANE 0 //To keep from conflicts with SEE_BLACKNESS internals

#define AREA_PLANE 60
#define MASSIVE_OBJ_PLANE 70
#define GHOST_PLANE 80
#define POINT_PLANE 90

#define RAD_TEXT_PLANE 90

//---------- LIGHTING -------------
///Normal 1 per turf dynamic lighting underlays
#define LIGHTING_PLANE 100
#define LIGHTING_PLANE_ADDITIVE 101

///Lighting objects that are "free floating"
#define O_LIGHTING_VISUAL_PLANE 110
#define O_LIGHTING_VISUAL_RENDER_TARGET "O_LIGHT_VISUAL_PLANE"

///Things that should render ignoring lighting
#define ABOVE_LIGHTING_PLANE 120

#define LIGHTING_PRIMARY_LAYER 15	//The layer for the main lights of the station
#define LIGHTING_PRIMARY_DIMMER_LAYER 15.1	//The layer that dims the main lights of the station
#define LIGHTING_SECONDARY_LAYER 16	//The colourful, usually small lights that go on top


///visibility + hiding of things outside of light source range
#define BYOND_LIGHTING_PLANE 130


//---------- EMISSIVES -------------
//Layering order of these is not particularly meaningful.
//Important part is the seperation of the planes for control via plane_master

/// This plane masks out lighting to create an "emissive" effect, ie for glowing lights in otherwise dark areas.
#define EMISSIVE_PLANE 150
/// The render target used by the emissive layer.
#define EMISSIVE_RENDER_TARGET "*EMISSIVE_PLANE"
/// The layer you should use if you _really_ don't want an emissive overlay to be blocked.
#define EMISSIVE_LAYER_UNBLOCKABLE 9999

///---------------- MISC -----------------------

///Pipecrawling images
#define PIPECRAWL_IMAGES_PLANE 180

///AI Camera Static
#define CAMERA_STATIC_PLANE 200

///--------------- FULLSCREEN IMAGES ------------

#define FULLSCREEN_PLANE 500
#define FLASH_LAYER 1
#define FULLSCREEN_LAYER 2
#define DITHER_LAYER 3
#define UI_DAMAGE_LAYER 4
#define BLIND_LAYER 5
#define CRIT_LAYER 6
#define CURSE_LAYER 7
#define FOV_EFFECTS_LAYER 10000 //Blindness effects are not layer 4, they lie to you

///--------------- FULLSCREEN RUNECHAT BUBBLES ------------

///Popup Chat Messages
#define RUNECHAT_PLANE 501
/// Plane for balloon text (text that fades up)
#define BALLOON_CHAT_PLANE 502

//-------------------- Rendering ---------------------
#define RENDER_PLANE_GAME 990
#define RENDER_PLANE_NON_GAME 995
#define RENDER_PLANE_MASTER 999

//-------------------- HUD ---------------------
//HUD layer defines
#define HUD_PLANE 1000
#define ABOVE_HUD_PLANE 1100

#define RADIAL_BACKGROUND_LAYER 0
///1000 is an unimportant number, it's just to normalize copied layers
#define RADIAL_CONTENT_LAYER 1000

#define ADMIN_POPUP_LAYER 1

///Layer for screentips
#define SCREENTIP_LAYER 4

///Plane of the "splash" icon used that shows on the lobby screen. Nothing should ever be above this.
#define SPLASHSCREEN_PLANE 9999

#define LOBBY_BACKGROUND_LAYER 3
#define LOBBY_BUTTON_LAYER 4

///cinematics are "below" the splash screen
#define CINEMATIC_LAYER -1

///Plane master controller keys
#define PLANE_MASTERS_GAME "plane_masters_game"
#define PLANE_MASTERS_COLORBLIND "plane_masters_colorblind"
