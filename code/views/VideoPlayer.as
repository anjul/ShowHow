package code.views
{
	import code.model.AppModel;
	import code.views.HomeViewConstants;
	
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	
	
	/**
	 * ...
	 * @author anand
	 */
	public class VideoPlayer extends MovieClip
	{
		
		private static var objVideoPlayer:VideoPlayer;
		
		// time to buffer for the video in sec.
		const BUFFER_TIME:Number				= 8;
		// start volume when initializing player
		const DEFAULT_VOLUME:Number				= 0.6;
		// update delay in milliseconds.
		const DISPLAY_TIMER_UPDATE_DELAY:int	= 10;
		// smoothing for video. may slow down old computers
		const SMOOTHING:Boolean					= true;
		
		// ###############################
		// ############# VARIABLES
		// ###############################
		
		// flag for knowing if user hovers over description label
		var bolDescriptionHover:Boolean = false;
		// flag for knowing in which direction the description label is currently moving
		var bolDescriptionHoverForward:Boolean = true;
		// flag for knowing if flv has been loaded
		var bolLoaded:Boolean					= false;
		// flag for volume scrubbing
		var bolVolumeScrub:Boolean				= false;
		// flag for progress scrubbing
		var bolProgressScrub:Boolean			= false;
		// holds the number of the active video
		var intActiveVid:int;
		// holds the last used volume, but never 0
		var intLastVolume:Number				= DEFAULT_VOLUME;
		// net connection object for net stream
		var ncConnection:NetConnection;
		// net stream object
		var nsStream:NetStream;
		// object holds all meta data
		var objInfo:Object;
		// shared object holding the player settings (currently only the volume)
		var shoVideoPlayerSettings:SharedObject = SharedObject.getLocal("playerSettings");
		// url to flv file
		// timer for updating player (progress, volume...)
		var tmrDisplay:Timer;
		// loads the xml file
		var urlLoader:URLLoader;
		// holds the request for the loader
		var urlRequest:URLRequest;
		// playlist xml
		var xmlPlaylist:XML;
		
		//////
		private var checkClicked:Boolean = true;
	
		private var objAppModel:AppModel=AppModel.getInstance();
		var strSource:String = objAppModel.stageRef.loaderInfo.parameters.playlist == null ? "playlist.xml" : objAppModel.stageRef.loaderInfo.parameters.playlist;
		
		public function VideoPlayer(singletonEnf:SingletonEnforcer)
		{
			if(singletonEnf==null)
			{
				throw new  Error("To instantiate this class use getInstance(), use of new is not allowed");
			}else{
				objAppModel.stageRef.stage.scaleMode	= StageScaleMode.NO_SCALE;
				objAppModel.stageRef.stage.align		= StageAlign.TOP_LEFT;
				initVideoPlayer();
			}			
		}
		
		public static function getInstance():VideoPlayer
		{
			if(objVideoPlayer==null)
			{
				objVideoPlayer = new VideoPlayer(new SingletonEnforcer());
			}
			return objVideoPlayer;
		}
		
		// ###############################
		// ############# FUNCTIONS
		// ###############################
		
		// sets up the player
		function initVideoPlayer():void {
			// hide video controls on initialisation
			objAppModel.stageRef.mcVideoControls.visible = false;
			
			// hide buttons
			objAppModel.stageRef.mcVideoControls.btnUnmute.visible			= false;
			objAppModel.stageRef.mcVideoControls.btnPause.visible			= false;
			objAppModel.stageRef.mcVideoControls.btnFullscreenOff.visible	= false;
			
			// set the progress/preload fill width to 1
			objAppModel.stageRef.mcVideoControls.mcProgressFill.mcFillRed.width	= 1;
			objAppModel.stageRef.mcVideoControls.mcProgressFill.mcFillGrey.width= 1;
			
			// set time and duration label
			objAppModel.stageRef.mcVideoControls.lblTimeDuration.htmlText	= "<font color='#000000'>00:00</font>00:00";
			
			// add global event listener when mouse is released
			objAppModel.stageRef.stage.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			
			// add fullscreen listener [AS]Commented for the time being
			objAppModel.stageRef.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
			
			// add event listeners to all buttons
			objAppModel.stageRef.mcVideoControls.btnPause.addEventListener(MouseEvent.CLICK, pauseClicked);
			objAppModel.stageRef.mcVideoControls.btnPlay.addEventListener(MouseEvent.CLICK, playClicked);
			objAppModel.stageRef.mcVideoControls.btnStop.addEventListener(MouseEvent.CLICK, stopClicked);
			objAppModel.stageRef.mcVideoControls.btnNext.addEventListener(MouseEvent.CLICK, playNext);
			objAppModel.stageRef.mcVideoControls.btnPrevious.addEventListener(MouseEvent.CLICK, playPrevious);
			objAppModel.stageRef.mcVideoControls.btnMute.addEventListener(MouseEvent.CLICK, muteClicked);
			objAppModel.stageRef.mcVideoControls.btnUnmute.addEventListener(MouseEvent.CLICK, unmuteClicked);
			//[AS]:: Fullscreen Buttons are off as of now.
			objAppModel.stageRef.mcVideoControls.btnFullscreenOn.addEventListener(MouseEvent.CLICK, fullscreenOnClicked);
			objAppModel.stageRef.mcVideoControls.btnFullscreenOff.addEventListener(MouseEvent.CLICK, fullscreenOffClicked);
			
			objAppModel.stageRef.mcVideoControls.btnVolumeBar.addEventListener(MouseEvent.MOUSE_DOWN, volumeScrubberClicked);
			objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.btnVolumeScrubber.addEventListener(MouseEvent.MOUSE_DOWN, volumeScrubberClicked);
			objAppModel.stageRef.mcVideoControls.btnProgressBar.addEventListener(MouseEvent.MOUSE_DOWN, progressScrubberClicked);
			objAppModel.stageRef.mcVideoControls.mcProgressScrubber.btnProgressScrubber.addEventListener(MouseEvent.MOUSE_DOWN, progressScrubberClicked);
			
			objAppModel.stageRef.mcVideoControls.mcVideoDescription.btnDescription.addEventListener(MouseEvent.MOUSE_OVER, startDescriptionScroll);
			objAppModel.stageRef.mcVideoControls.mcVideoDescription.btnDescription.addEventListener(MouseEvent.MOUSE_OUT, stopDescriptionScroll);
			////////////////////////////////////////////////////////////
			
			objAppModel.stageRef.vptabControlBtn1.addEventListener(MouseEvent.CLICK, vptabControls);
			objAppModel.stageRef.vptabControlBtn1.addEventListener(MouseEvent.ROLL_OVER, vptabControls);
			objAppModel.stageRef.vptabControlBtn1.addEventListener(MouseEvent.ROLL_OUT, vptabControls);
			
			objAppModel.stageRef.vptabControlBtn2.addEventListener(MouseEvent.CLICK, vptabControls);
			objAppModel.stageRef.vptabControlBtn2.addEventListener(MouseEvent.ROLL_OVER, vptabControls);
			objAppModel.stageRef.vptabControlBtn2.addEventListener(MouseEvent.ROLL_OUT, vptabControls);
			
			objAppModel.stageRef.vptabControlBtn3.addEventListener(MouseEvent.CLICK, vptabControls);
			objAppModel.stageRef.vptabControlBtn3.addEventListener(MouseEvent.ROLL_OVER, vptabControls);
			objAppModel.stageRef.vptabControlBtn3.addEventListener(MouseEvent.ROLL_OUT, vptabControls);
			
			HomeViewConstants.smartStartMC.videoprefMain_mc.cancel_mc.addEventListener(MouseEvent.CLICK, vptabPreference);
			HomeViewConstants.smartStartMC.videoprefMain_mc.cancel_mc.addEventListener(MouseEvent.ROLL_OVER, vptabControls);
			HomeViewConstants.smartStartMC.videoprefMain_mc.cancel_mc.addEventListener(MouseEvent.ROLL_OUT, vptabControls);
		
			objAppModel.stageRef.vptabControlBtn1.buttonMode = true;
			objAppModel.stageRef.vptabControlBtn2.buttonMode = true;
			objAppModel.stageRef.vptabControlBtn3.buttonMode = true;
			
			
			//////////////////////////////////////////////////////////
			
			// create timer for updating all visual parts of player and add
			// event listener
			tmrDisplay = new Timer(DISPLAY_TIMER_UPDATE_DELAY);
			tmrDisplay.addEventListener(TimerEvent.TIMER, updateDisplay);
			
			// create a new net connection, add event listener and connect
			// to null because we don't have a media server
			ncConnection = new NetConnection();
			ncConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ncConnection.connect(null);
			
			// create a new netstream with the net connection, add event
			// listener, set client to this for handling meta data and
			// set the buffer time to the value from the constant
			
			var customClient:Object = new Object();
			customClient.onMetaData = onMetaData;
			
			
			nsStream = new NetStream(ncConnection);
			nsStream.client = customClient;
			nsStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			//nsStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			//nsStream.client = this;
			nsStream.bufferTime = BUFFER_TIME;
			
			// attach net stream to video object on the stage
			objAppModel.stageRef.vidDisplay.attachNetStream(nsStream);
			// set the smoothing value from the constant
			objAppModel.stageRef.vidDisplay.smoothing = SMOOTHING;
			
			// set default volume and get volume from shared object if available
			var tmpVolume:Number = DEFAULT_VOLUME;
			if(shoVideoPlayerSettings.data.playerVolume != undefined) {
				tmpVolume = shoVideoPlayerSettings.data.playerVolume;
				intLastVolume = tmpVolume;
			}
			// update volume bar and set volume
			objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.x = (53 * tmpVolume) + 355;
			objAppModel.stageRef.mcVideoControls.mcVolumeFill.mcFillRed.width = objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.x - 371 + 53;
			setVolume(tmpVolume);
			
			// create new request for loading the playlist xml, add an event listener
			// and load it
			trace(strSource+"AutoPlay//"+AppModel.AUTOPLAY_VIDEO_URL)
			urlRequest = new URLRequest(strSource);
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, playlistLoaded);
			urlLoader.load(urlRequest); 
			TweenLite.to(objAppModel.stageRef.videoControlMain.videoControls_mc,0,  {alpha:0});
			TweenLite.to(objAppModel.stageRef.videoControlMain.controlTransbg_mc,0, {alpha:0});
			
			TweenLite.to(HomeViewConstants.smartStartMC.videoprefMain_mc,0, {alpha:0});
			HomeViewConstants.smartStartMC.videoprefMain_mc.visible=false
			
		}
		private function vptabControls(event:MouseEvent):void
		{			
			switch(event.type)
			{				 
				case "rollOver":					
					if(checkClicked)
					{
						checkClicked = false;
						event.target.gotoAndStop(2);
					}
					else
					{
						event.target.gotoAndStop(1);
					}
					break;
				
				case "rollOut":	
					if(checkClicked)
					{
						event.target.gotoAndStop(2);
					}
					else
					{
						checkClicked = true;
						event.target.gotoAndStop(1);						
					}
					break;
				
				case "click":		
					checkClicked = true;
					trace(">>>>"+event.currentTarget.name)
					
					videotabControlplay(event.currentTarget)
					disablevptabControlsBtnStates(event.currentTarget);
					
					//event.target.gotoAndStop(2);
					break;
				
			}			
		}
		
		function videotabControlplay(target:Object):void{
			var strval:String = target.name;
			var subStr:String = strval.substr(strval.length-1,strval.length);
			//trace(strval+"--------->"+subStr)
			if(subStr=="1"){
				
				vptabPreference()
			}else if(subStr=="2"){
				
				
				vptabControlsclick()
			}else if(subStr=="3"){
				vptabSubtext()
			}
			
		}
		
		
		function disablevptabControlsBtnStates(target:Object):void
		{			
			var str:String = target.name;
			var subStr:String = str.substr(0,str.length-1);
			trace(target.name+")))))((((("+str)
			for(var i:uint=1;i<4;i++)
			{
				trace("$$"+target.parent[subStr+i])
				target.parent[subStr+i].gotoAndStop(1);		
				//target.subStr+i.gotoAndStop(1);				
			}
			target.gotoAndStop(2);
		}
				
		/////////////////////////////////////////////start----videopref btn///////////////////////////////////////
		var vptabpreferencecliked:Boolean=true
		
		function vptabPreference(event:MouseEvent=null):void{
			
			trace("iiiiiiiiiiiiiiiiii")
			if(vptabpreferencecliked==true){
				
				HomeViewConstants.smartStartMC.videoprefMain_mc.visible=true
				vptabpreferencecliked=false
				var tweentitlea:TweenLite=objAppModel.tweenManager(HomeViewConstants.smartStartMC.videoprefMain_mc,.5,{alpha:1})
				tweentitlea.play()
				
			}else{
				HomeViewConstants.smartStartMC.videoprefMain_mc.visible=false
				vptabpreferencecliked=true
				var tweentitleb=objAppModel.tweenManager(HomeViewConstants.smartStartMC.videoprefMain_mc,.5,{alpha:0})
				tweentitleb.play()
			}
		}
		
		/////////////////////////////////////////////end----videopref btn///////////////////////////////////////
		
		/////////////////////////////////////////////start----subtext btn///////////////////////////////////////
		var vptabSubtextcliked:Boolean=true
			
		function vptabSubtext():void{
			
		
			if(  vptabSubtextcliked==true){
				vptabSubtextcliked=false
		var tweentitlea=objAppModel.tweenManager(objAppModel.stageRef.subtitle_mc,.5,{y:375, alpha:1})
		tweentitlea.play()
			
		}else{
			vptabSubtextcliked=true
			var tweentitleb=objAppModel.tweenManager(objAppModel.stageRef.subtitle_mc,.5,{y:258, alpha:0})
			tweentitleb.play()
		}
	}
		
		/////////////////////////////////////////////end----subtext btn///////////////////////////////////////
		
		/////////////////////////////////////////////start----control btn///////////////////////////////////////
		var vpcontrolcliked:Boolean=true
		function vptabControlsclick():void{
							
			if(  vpcontrolcliked==true){
				vpcontrolcliked=false
				var tween1a=objAppModel.tweenManager(objAppModel.stageRef.videoControlMain.controlTransbg_mc,.5,{y:155, alpha:1, onComplete:vptabControlscomplete})
				tween1a.play()
				objAppModel.stageRef.mcVideoControls.visible = false
				
			}else{
				vpcontrolcliked=true
				var tween2b=objAppModel.tweenManager(objAppModel.stageRef.videoControlMain.videoControls_mc, .5, {alpha:0,onComplete:vptabControlsback});
				tween2b.play()
				
			}
						
		}
		
		function vptabControlscomplete(){
			
			var tween2a=objAppModel.tweenManager(objAppModel.stageRef.videoControlMain.videoControls_mc, .5, {alpha:1});
			tween2a.play()
			
		}
		function vptabControlsback(){
			objAppModel.stageRef.mcVideoControls.visible = true
			var tween1b=objAppModel.tweenManager(objAppModel.stageRef.videoControlMain.controlTransbg_mc,.5,{y:1, alpha:0})
			tween1b.play()
			
		}
		
		/////////////////////////////////////////////end----control btn///////////////////////////////////////
		
		function asyncErrorHandler(event:AsyncErrorEvent):void
		{
			trace(event.text);
		}
		
		
		function playClicked(e:MouseEvent=null):void
		{
			// check's, if the flv has already begun
			// to download. if so, resume playback, else
			// load the file
			if(!bolLoaded) {
				nsStream.play(strSource);
				bolLoaded = true;
			}
			else{
				nsStream.resume();
			}
			
			objAppModel.stageRef.vidDisplay.visible = true;
			
			// switch play/pause visibility
			objAppModel.stageRef.mcVideoControls.btnPause.visible	= true;
			objAppModel.stageRef.mcVideoControls.btnPlay.visible		= false;
		}
		
		function pauseClicked(e:MouseEvent=null):void {
			// pause video
			nsStream.pause();
			
			// switch play/pause visibility
			objAppModel.stageRef.mcVideoControls.btnPause.visible	= false;
			objAppModel.stageRef.mcVideoControls.btnPlay.visible		= true;
		}
		
		function stopClicked(e:MouseEvent):void {
			// calls stop function
			stopVideoPlayer();
		}
		
		function muteClicked(e:MouseEvent):void {
			// set volume to 0
			setVolume(0);
			
			// update scrubber and fill position/width
			objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.x				= 345;
			objAppModel.stageRef.mcVideoControls.mcVolumeFill.mcFillRed.width	= 1;
		}
		
		function unmuteClicked(e:MouseEvent):void {
			// set volume to last used value or DEFAULT_VOLUME if last volume is zero
			var tmpVolume:Number = intLastVolume == 0 ? DEFAULT_VOLUME : intLastVolume
			setVolume(tmpVolume);
			
			// update scrubber and fill position/width
			objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.x = (53 * tmpVolume) + 345;
			objAppModel.stageRef.mcVideoControls.mcVolumeFill.mcFillRed.width = objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.x - 371 + 53;
		}
		
		function volumeScrubberClicked(e:MouseEvent):void {
			// set volume scrub flag to true
			bolVolumeScrub = true;
			
			// start drag
			objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.startDrag(true, new Rectangle(345, 16, 55, 0)); // NOW TRUE
		}
		
		function progressScrubberClicked(e:MouseEvent):void {
			// set progress scrub flag to true
			bolProgressScrub = true;
			
			// start drag
			objAppModel.stageRef.mcVideoControls.mcProgressScrubber.startDrag(true, new Rectangle(0, 2, 280, 0)); // NOW TRUE
		}
		
		function mouseReleased(e:MouseEvent):void {
			// set progress/volume scrub to false
			bolVolumeScrub		= false;
			bolProgressScrub	= false;
			
			// stop all dragging actions
			objAppModel.stageRef.mcVideoControls.mcProgressScrubber.stopDrag();
			objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.stopDrag();
			
			// update progress/volume fill
			objAppModel.stageRef.mcVideoControls.mcProgressFill.mcFillRed.width	=objAppModel.stageRef.mcVideoControls.mcProgressScrubber.x + 5;
			objAppModel.stageRef.mcVideoControls.mcVolumeFill.mcFillRed.width	=objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.x - 371 + 53;
			
			// save the volume if it's greater than zero
			if((objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.x - 345) / 53 > 0)
				intLastVolume = (objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.x - 345) / 53;
		}
		
		function updateDisplay(e:TimerEvent):void {
			// checks, if user is scrubbing. if so, seek in the video
			// if not, just update the position of the scrubber according
			// to the current time
			if(bolProgressScrub)
				nsStream.seek(Math.round(objAppModel.stageRef.mcVideoControls.mcProgressScrubber.x * objInfo.duration / 280))
			else
				objAppModel.stageRef.mcVideoControls.mcProgressScrubber.x = nsStream.time * 280 / objInfo.duration; 
			
			// set time and duration label
			objAppModel.stageRef.mcVideoControls.lblTimeDuration.htmlText		= "<font color='#000000'>" + formatTime(nsStream.time) + "</font> / " + formatTime(objInfo.duration);
			
			// update the width from the progress bar. the grey one displays
			// the loading progress
			objAppModel.stageRef.mcVideoControls.mcProgressFill.mcFillRed.width	= objAppModel.stageRef.mcVideoControls.mcProgressScrubber.x + 5;
			objAppModel.stageRef.mcVideoControls.mcProgressFill.mcFillGrey.width	= nsStream.bytesLoaded * 460 / nsStream.bytesTotal;
			
			// update volume and the red fill width when user is scrubbing
			if(bolVolumeScrub) {
				setVolume((objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.x - 345) / 53);
				objAppModel.stageRef.mcVideoControls.mcVolumeFill.mcFillRed.width = objAppModel.stageRef.mcVideoControls.mcVolumeScrubber.x - 371 + 53;
			}
			
			// chech if user is currently hovering over description label
			if(bolDescriptionHover) {
				// check in which direction we're currently moving
				if(bolDescriptionHoverForward) {
					// move to the left and check if we've shown everthing
					objAppModel.stageRef.mcVideoControls.mcVideoDescription.lblDescription.x -= 0.1;
					if(objAppModel.stageRef.mcVideoControls.mcVideoDescription.lblDescription.textWidth - 133 <= Math.abs(objAppModel.stageRef.mcVideoControls.mcVideoDescription.lblDescription.x))
						bolDescriptionHoverForward = false;
				} else {
					// move to the right and check if we're back to normal
					objAppModel.stageRef.mcVideoControls.mcVideoDescription.lblDescription.x += 0.1;
					if(objAppModel.stageRef.mcVideoControls.mcVideoDescription.lblDescription.x >= 0)
						bolDescriptionHoverForward = true;
				}
			} else {
				// reset label position and direction variable
				objAppModel.stageRef.mcVideoControls.mcVideoDescription.lblDescription.x = 0;
				bolDescriptionHoverForward = true;
			}
		}
		
		function onMetaData(info:Object):void {
			// stores meta data in a object
			objInfo = info;
			
			// now we can start the timer because
			// we have all the neccesary data
			if(!tmrDisplay.running)
				tmrDisplay.start();
		}
		
		function netStatusHandler(event:NetStatusEvent):void {
			// handles net status events
			switch (event.info.code) {
				// trace a messeage when the stream is not found
				case "NetStream.Play.StreamNotFound":
					trace("Stream not found: " + strSource);
					break;
				// when the video reaches its end, we check if there are
				// more video left or stop the player
				case "NetStream.Play.Stop":
					if(intActiveVid + 1 < xmlPlaylist..vid.length())
						playNext();
					else
						stopVideoPlayer();
					break;
			}
		}
		
		function stopVideoPlayer():void {
			// pause netstream, set time position to zero
			nsStream.pause();
			nsStream.seek(0);
			
			// in order to clear the display, we need to
			// set the visibility to false since the clear
			// function has a bug
			objAppModel.stageRef.vidDisplay.visible					= false;
			
			// switch play/pause button visibility
			objAppModel.stageRef.mcVideoControls.btnPause.visible	= false;
			objAppModel.stageRef.mcVideoControls.btnPlay.visible		= true;
		}
		
		function setVolume(intVolume:Number = 0):void {
			// create soundtransform object with the volume from
			// the parameter
			var sndTransform:SoundTransform		= new SoundTransform(intVolume);
			// assign object to netstream sound transform object
			nsStream.soundTransform	= sndTransform;
			
			// hides/shows mute and unmute button according to the
			// volume
			if(intVolume > 0) {
				objAppModel.stageRef.mcVideoControls.btnMute.visible		= true;
				objAppModel.stageRef.mcVideoControls.btnUnmute.visible	= false;
			} else {
				objAppModel.stageRef.mcVideoControls.btnMute.visible		= false;
				objAppModel.stageRef.mcVideoControls.btnUnmute.visible	= true;
			}
			
			// store the volume in the flash cookie
			shoVideoPlayerSettings.data.playerVolume = intVolume;
			shoVideoPlayerSettings.flush();
		}
		
		function formatTime(t:int):String {
			// returns the minutes and seconds with leading zeros
			// for example: 70 returns 01:10
			var s:int = Math.round(t);
			var m:int = 0;
			if (s > 0) {
				while (s > 59) {
					m++; s -= 60;
				}
				return String((m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s);
			} else {
				return "00:00";
			}
		}
		
		function fullscreenOnClicked(e:MouseEvent):void {
			// go to fullscreen mode
			stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		function fullscreenOffClicked(e:MouseEvent):void {
			// go to back to normal mode
			stage.displayState = StageDisplayState.NORMAL;
		}
		
		function onFullscreen(e:FullScreenEvent):void {
			// check if we're entering or leaving fullscreen mode
			if (e.fullScreen) {
				// switch fullscreen buttons
				objAppModel.stageRef.mcVideoControls.btnFullscreenOn.visible = false;
				objAppModel.stageRef.mcVideoControls.btnFullscreenOff.visible = true;
				
				// bottom center align controls
				objAppModel.stageRef.mcVideoControls.x = (Capabilities.screenResolutionX - 460) / 2;
				objAppModel.stageRef.mcVideoControls.y = (Capabilities.screenResolutionY - 33);
				
				//Code Added by [AS]
				var point1:Point = new Point(0,0);
				var obj1:Object = objAppModel.stageRef.vidDisplay.localToGlobal(point1);
				
				objAppModel.stageRef.vidDisplay.height 	= Capabilities.screenResolutionY;
				objAppModel.stageRef.vidDisplay.width 	= Capabilities.screenResolutionX;
				
				objAppModel.stageRef.vidDisplay.x 	= objAppModel.stageRef.vidDisplay.x - obj1.x;
				objAppModel.stageRef.vidDisplay.y 	= objAppModel.stageRef.vidDisplay.y - obj1.y;
				
				//[AS]:: Mangae Depth Between VideoDisplay and McVideoControls
				//objAppModel.stageRef.mcVideoControls.swapChildren(objAppModel.stageRef.vidDisplay);
				
				
				//Code Commented by [AS]
				// size up video display
				/*objAppModel.stageRef.vidDisplay.height 	= Capabilities.screenResolutionY	//(Capabilities.screenResolutionY - 33);
				objAppModel.stageRef.vidDisplay.width 	= objAppModel.stageRef.vidDisplay.height * 4 / 3;*/
				//objAppModel.stageRef.vidDisplay.x		= (Capabilities.screenResolutionX - objAppModel.stageRef.vidDisplay.width) / 2;
				
				//objAppModel.stageRef.vidDisplay.x		= (stage.fullScreenWidth - objAppModel.stageRef.vidDisplay.width) / 2;
				//objAppModel.stageRef.vidDisplay.y		= (stage.fullScreenHeight- objAppModel.stageRef.vidDisplay.height ) / 2;
				
				// [AS:3/09/12]Visiblitity off for HomeView Static assets
				HomeViewConstants.finderMc.visible =false;
				HomeViewConstants.homeBtn.visible =false;
				HomeViewConstants.omniHolder.visible =false;
				HomeViewConstants.showHowLogo.visible =false;
				HomeViewConstants.smartStartMC.visible =false;
				HomeViewConstants.welcomeMC.visible =false;
			} else {
				// switch fullscreen buttons
				objAppModel.stageRef.mcVideoControls.btnFullscreenOn.visible = true;
				objAppModel.stageRef.mcVideoControls.btnFullscreenOff.visible = false;
				
				// reset controls position
				objAppModel.stageRef.mcVideoControls.x = 39.55;
				objAppModel.stageRef.mcVideoControls.y = 485.15;
				
				// reset video display
				objAppModel.stageRef.vidDisplay.y = 88;
				objAppModel.stageRef.vidDisplay.x = 5;
				objAppModel.stageRef.vidDisplay.width = 510.75;
				objAppModel.stageRef.vidDisplay.height = 286.3;
				
				HomeViewConstants.finderMc.visible =true;
				HomeViewConstants.homeBtn.visible =true;
				HomeViewConstants.omniHolder.visible =true;
				HomeViewConstants.showHowLogo.visible =true;
				HomeViewConstants.smartStartMC.visible =true;
				HomeViewConstants.welcomeMC.visible =true;
			}
		}
		
		function playlistLoaded(e:Event):void {
			// create new xml with loaded data from loader
			xmlPlaylist = new XML(urlLoader.data);
			
			// set source of the first video but don't play it
			playVid(0, false)
			
			// show controls
			objAppModel.stageRef.mcVideoControls.visible = true;
		}
		
		function playVid(intVid:int = 0, bolPlay = true):void {
			if(bolPlay) {
				// stop timer
				tmrDisplay.stop();
				
				// play requested video
				nsStream.play(String(xmlPlaylist..vid[intVid].@src));
				
				// switch button visibility
				objAppModel.stageRef.mcVideoControls.btnPause.visible= true;
				objAppModel.stageRef.btnPlay.visible = false;
			} else {
				strSource = xmlPlaylist..vid[intVid].@src;
			}
			playClicked();
			// show video display
			objAppModel.stageRef.vidDisplay.visible	= true;
			
			// reset description label position and assign new description
			objAppModel.stageRef.mcVideoControls.mcVideoDescription.lblDescription.x = 0;
			objAppModel.stageRef.mcVideoControls.mcVideoDescription.lblDescription.htmlText = (intVid + 1) + ". <font color='#000000'>" + String(xmlPlaylist..vid[intVid].@desc) + "</font>";
			
			// update active video number
			intActiveVid = intVid;
		}
		
		function playNext(e:MouseEvent = null):void {
			// check if there are video left to play and play them
			if(intActiveVid + 1 < xmlPlaylist..vid.length())
				playVid(intActiveVid + 1);
			
		}
		
		function playPrevious(e:MouseEvent = null):void {
			// check if we're not and the beginning of the playlist and go back
			if(intActiveVid - 1 >= 0)
				playVid(intActiveVid - 1);
		}
		
		function startDescriptionScroll(e:MouseEvent):void {
			// check if description label is too long and we need to enable scrolling
			if(objAppModel.stageRef.mcVideoControls.mcVideoDescription.lblDescription.textWidth > 138)
				bolDescriptionHover = true;
		}
		
		function stopDescriptionScroll(e:MouseEvent):void {
			// disable scrolling
			bolDescriptionHover = false;
		}
		
		//Method Added By [AS::13Sep12], to Control VideoPlayer playback functions from outside
		public function controlVideoPlayBack(bool:Boolean):void
		{
			if(bool)
			{
				playClicked();
			}
			else
			{
				pauseClicked();
			}			
		}
	}	
}class SingletonEnforcer{}