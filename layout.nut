////////////////////////////////////////////////////////////////
// Attract-Mode Front-End                                     //
////////////////////////////////////////////////////////////////

// Layout Options
class UserConfig {
 </ label="Background Image", help="Select background image", options="blue,green,red", order=2 /> bg_image = "red";
 </ label="Marquee Image", help="Choose game or MVS marquee", options="game,mvs", order=4 /> mq_image = "game";
 </ label="Snap Audio", help="Enable or disable snap audio (default enable)", options="enable,disable", order=6 /> enable_audio="enable";
 </ label="Select wheel style", help="Select wheel style", options="curved", order=10 /> enable_list_type="curved";
 </ label="Select spinwheel art", help="The artwork to spin", options="wheel", order=12 /> orbit_art="wheel";
 </ label="Wheel transition time", help="Time in milliseconds for wheel spin.", order=16 /> transition_ms="25";   
 </ label="Random Wheel Sounds", help="Play random sounds when navigating games wheel", options="Yes,No", order=25 /> enable_random_sound="Yes"; 
 </ label="Background Wheel Image", help="Image style when navigating games wheel", options="flyer,fanart", order=26 /> enable_random_fanart="flyer";
 }

local my_config = fe.get_config();

local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;

// modules
fe.load_module("fade");
fe.load_module( "animate" );

fe.load_module( "fade" );

local fanart = fe.add_artwork( "flyer", flx*0.5, 0, flw*0.5, flh );

// Show random fanart when transitioning to next / previous game on wheel
if (my_config["enable_random_fanart"] == "fanart")
{
	local random_num = floor(((rand() % 1000 ) / 1000.0) * (464 - (1 - 1)) + 1);
	local fanart_name = "fanart/DS"+random_num+".jpg";		
	local fanart = fe.add_image( fanart_name, flx*0.5, 0, flw*0.5, flh );
}

if (my_config["enable_random_fanart"] == "flyer")
{
	local fanart = fe.add_artwork("flyer", flx*0.55, 0, flw*0.5, flh );
}

// Background Image
if ( my_config["bg_image"] == "blue") {
 local bg = fe.add_artwork( "backblue", 0, 0, flw, flh );
}
if ( my_config["bg_image"] == "green") {
 local bg = fe.add_artwork( "backgreen", 0, 0, flw, flh );
}
if ( my_config["bg_image"] == "red") {
 local bg = fe.add_artwork( "backred", 0, 0, flw, flh );
}

// Snap Image
local snap = FadeArt( "snap", flx*0.127, fly*0.2625, flw*0.43, flh*0.5375 );
if ( my_config["enable_audio"] == "enable") {
snap.video_flags = Vid.Default;
} 
if ( my_config["enable_audio"] == "disable") {
snap.video_flags = Vid.NoAudio;
}
snap.trigger = Transition.EndNavigation;
snap.preserve_aspect_ratio=true;

local cab = fe.add_artwork( "front", 0, 0, flw, flh );
 
//vertical wheel curved
if ( my_config["enable_list_type"] == "curved" )
{
fe.load_module( "conveyor" );

local wheel_x = [ flx*0.94, flx* 0.94, flx* 0.87, flx* 0.83, flx* 0.81, flx* 0.79, flx* 0.77, flx* 0.79, flx* 0.81, flx* 0.83, flx* 0.87, flx* 0.94, ]; 
local wheel_y = [ -fly*0.22, -fly*0.105, fly*0.0, fly*0.105, fly*0.215, fly*0.325, fly*0.430, fly*0.580, fly*0.700 fly*0.795, fly*0.910, fly*0.99, ];
local wheel_w = [ flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.18, flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.13, ];
local wheel_a = [  255,  255,  255,  255,  255,  255, 255,  255,  255,  255,  255,  255, ];
local wheel_h = [  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102, flh*0.150,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102, ];
local wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];
local num_arts = 8;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
                preserve_aspect_ratio = true;
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

conveyor <- Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}

// Play random sound when transitioning to next / previous game on wheel
function sound_transitions(ttype, var, ttime) 
{
	if (my_config["enable_random_sound"] == "Yes")
	{
		local random_num = floor(((rand() % 1000 ) / 1000.0) * (124 - (1 - 1)) + 1);
		local sound_name = "sounds/GS"+random_num+".mp3";
		switch(ttype) 
		{
		case Transition.EndNavigation:		
			local Wheelclick = fe.add_sound(sound_name);
			Wheelclick.playing=true;
			break;
		}
		return false;
	}
}
fe.add_transition_callback("sound_transitions")

// Marquee Image

local mq = fe.add_image( "default.png", flx*0.105, fly*0.02, flw*0.4745, flh*0.21 );

if ( my_config["mq_image"] == "game") {
 local mq = fe.add_artwork( "marquee" flx*0.105, fly*0.02, flw*0.4745, flh*0.21 );
}

mq.preserve_aspect_ratio=true;

