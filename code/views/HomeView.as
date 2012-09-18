package code.views
{
	import code.model.AppModel;
	import code.views.HomeViewConstants;
	import code.vo.AppVO;
	import code.vo.FilmConstants;
	import code.vo.TextVO;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	public class HomeView extends MovieClip
	{
		private var omniUrl:String;
		private var loader:Loader;
		private var shLogoLoader:Loader;
		private var urlRequest:URLRequest;
		
		private var objAppModel:AppModel= AppModel.getInstance();
		private var omniHolder:MovieClip = new MovieClip();
		private var omniX:uint = 545;
		private var omniY:uint = 10;
		
		private var finderX:uint = omniX-25;
		private var finderY:uint = omniY+58;
		private var smartStartX:uint = finderX;
		private var smartStartY:uint = finderY;
		private var welcomeX:uint = finderX;
		private var welcomeY:uint = smartStartY+20;
		private var homeBtnX:uint = omniX-80;
		private var homeBtnY:uint = omniY+7;
		private var showHowLogoX:int = -10;
		private var showHowLogoY:uint = omniY-5;
	
		private var finderMc:Finder_MC;
		private var smartStartMC:SmartStart_MC;
		private var welcomeMC:Welcome_MC;
		private var homeBtn:HomeBtn_MC;
		private var showHowLogo:MovieClip;
		private var checkClicked:Boolean = true;
		
		private var videoBucket:VideoBucketHolder;
		private var objVideoPlayer:VideoPlayer;
		private var tabFullMC;
		
		private var textVO:TextVO;
		
		private var requestedVideoURL:String;
		
		public function HomeView()
		{
			//trace("Home View")
			textVO = new TextVO();
			omniUrl = AppVO.BASEURL+AppVO.OMNI_SWF;
			attachShowHowLogo();
			loadOmniSwf();	
			attachWelcomeMC();
			attachSmartStartMC();
			attachFinderMC();		
			attachHomeBtn();		
			videoBucket = new VideoBucketHolder();
			objVideoPlayer = VideoPlayer.getInstance();
		}
		
		 private function loadOmniSwf():void
		 {
			 urlRequest = new URLRequest();
			 urlRequest.url = omniUrl;
			 
			 loader=new Loader();
			 loader.load(urlRequest);
			
			 loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,omniEventHandler);
			 loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,omniEventHandler);
			 loader.contentLoaderInfo.addEventListener(Event.COMPLETE,omniEventHandler);
		 }
		 
		 private function omniEventHandler(event:*):void
		 {
			 switch(event.type)
			 {
				 case 'open':
					//trace("open");					
					 break;
				 
				 case 'progress':
					// trace("Progress");
					 break;
				 
				 case 'init':
					 //trace("init");
					 break;
				 
				 case 'complete':
					// trace("Omni LoadedComplete>>"+HomeViewConstants.omniHolder);				
					 HomeViewConstants.omniHolder.addChild(loader);
					 objAppModel.stageRef.addChild(HomeViewConstants.omniHolder);
					 HomeViewConstants.omniHolder.x=omniX;
					 HomeViewConstants.omniHolder.y=omniY;
					 break;
				 
				 case 'ioError':
					 trace("IO Error or Bad File name error");
					 break;
				 
				 default:
					 trace("Desired Event Not Found");
					 break;
			 }
		 }
		 
		 private function attachFinderMC():void
		 {				
			 objAppModel.stageRef.addChild(HomeViewConstants.finderMc);
			 HomeViewConstants.finderMc.x = finderX;
			 HomeViewConstants.finderMc.y = finderY;
		 }
		 
		 private function attachSmartStartMC():void
		 {
			trace(HomeViewConstants.smartStartMC.tabSh2snap_full)
			 objAppModel.stageRef.addChild(HomeViewConstants.smartStartMC);
			 useButtonMode(true);
			 HomeViewConstants.smartStartMC.x = smartStartX;
			 HomeViewConstants.smartStartMC.y = smartStartY;
			 HomeViewConstants.smartStartMC.stop();			 
			 HomeViewConstants.smartStartMC.tabSmartstart.addEventListener(MouseEvent.ROLL_OVER,tabEvents);
			 HomeViewConstants.smartStartMC.tabPlaylist.addEventListener(MouseEvent.ROLL_OVER,tabEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap.addEventListener(MouseEvent.ROLL_OVER,tabEvents);
			 HomeViewConstants.smartStartMC.tabSh2map.addEventListener(MouseEvent.ROLL_OVER,tabEvents);
			 HomeViewConstants.smartStartMC.tabMostviewed.addEventListener(MouseEvent.ROLL_OVER,tabEvents);
			 
			 HomeViewConstants.smartStartMC.tabSmartstart.addEventListener(MouseEvent.ROLL_OUT,tabEvents);
			 HomeViewConstants.smartStartMC.tabPlaylist.addEventListener(MouseEvent.ROLL_OUT,tabEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap.addEventListener(MouseEvent.ROLL_OUT,tabEvents);
			 HomeViewConstants.smartStartMC.tabSh2map.addEventListener(MouseEvent.ROLL_OUT,tabEvents);
			 HomeViewConstants.smartStartMC.tabMostviewed.addEventListener(MouseEvent.ROLL_OUT,tabEvents);
			 
			 HomeViewConstants.smartStartMC.tabSmartstart.addEventListener(MouseEvent.CLICK,tabEvents);
			 HomeViewConstants.smartStartMC.tabPlaylist.addEventListener(MouseEvent.CLICK,tabEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap.addEventListener(MouseEvent.CLICK,tabEvents);
			 HomeViewConstants.smartStartMC.tabSh2map.addEventListener(MouseEvent.CLICK,tabEvents);
			 HomeViewConstants.smartStartMC.tabMostviewed.addEventListener(MouseEvent.CLICK,tabEvents);
			 ////////////////////////////////////////////////////////////////////
			 
			 HomeViewConstants.smartStartMC.tabSh2snap_full.back2videoBtn_mc.addEventListener(MouseEvent.CLICK,back2videoBtn_ClickHandler);
			 HomeViewConstants.smartStartMC.tabSmartstart_full.back2videoBtn_mc.addEventListener(MouseEvent.CLICK,back2videoBtn_ClickHandler);
			 HomeViewConstants.smartStartMC.tabPlaylist_full.back2videoBtn_mc.addEventListener(MouseEvent.CLICK,back2videoBtn_ClickHandler);
			 HomeViewConstants.smartStartMC.tabSh2map_full.back2videoBtn_mc.addEventListener(MouseEvent.CLICK,back2videoBtn_ClickHandler);
			 HomeViewConstants.smartStartMC.tabMostviewed_full.back2videoBtn_mc.addEventListener(MouseEvent.CLICK,back2videoBtn_ClickHandler);
			 
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn1.addEventListener(MouseEvent.CLICK,sh2SnapButtonEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn2.addEventListener(MouseEvent.CLICK,sh2SnapButtonEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn3.addEventListener(MouseEvent.CLICK,sh2SnapButtonEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn4.addEventListener(MouseEvent.CLICK,sh2SnapButtonEvents);
			 
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn1.addEventListener(MouseEvent.ROLL_OVER,sh2SnapButtonEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn2.addEventListener(MouseEvent.ROLL_OVER,sh2SnapButtonEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn3.addEventListener(MouseEvent.ROLL_OVER,sh2SnapButtonEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn4.addEventListener(MouseEvent.ROLL_OVER,sh2SnapButtonEvents);
			 
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn1.addEventListener(MouseEvent.ROLL_OUT,sh2SnapButtonEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn2.addEventListener(MouseEvent.ROLL_OUT,sh2SnapButtonEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn3.addEventListener(MouseEvent.ROLL_OUT,sh2SnapButtonEvents);
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn4.addEventListener(MouseEvent.ROLL_OUT,sh2SnapButtonEvents);
		 }		 
		 
		 private function useButtonMode(bool:Boolean):void
		 {
			 HomeViewConstants.smartStartMC.tabSmartstart.buttonMode = bool;
			 HomeViewConstants.smartStartMC.tabPlaylist.buttonMode = bool
			 HomeViewConstants.smartStartMC.tabSh2snap.buttonMode = bool
			 HomeViewConstants.smartStartMC.tabSh2map.buttonMode = bool
			 HomeViewConstants.smartStartMC.tabMostviewed.buttonMode = bool
				 
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn1.buttonMode = bool;
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn2.buttonMode = bool;
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn3.buttonMode = bool;
			 HomeViewConstants.smartStartMC.tabSh2snap_full.SH2snapFullBtn4.buttonMode = bool;
			 
			 HomeViewConstants.smartStartMC.tabSh2snap_full.back2videoBtn_mc.buttonMode = bool;
			 HomeViewConstants.smartStartMC.tabSmartstart_full.back2videoBtn_mc.buttonMode = bool;
			 HomeViewConstants.smartStartMC.tabPlaylist_full.back2videoBtn_mc.buttonMode = bool;
			 HomeViewConstants.smartStartMC.tabSh2map_full.back2videoBtn_mc.buttonMode = bool;
			 HomeViewConstants.smartStartMC.tabMostviewed_full.back2videoBtn_mc.buttonMode = bool;
		 }
		 
		 private function tabEvents(event:MouseEvent):void
		 {
			var tabMC = event.target.parent[event.currentTarget.name+"_mc"];
			tabFullMC = event.target.parent[event.currentTarget.name+"_full"];
			
			switch(event.type)
			{
				case "rollOver":
					tabMC.gotoAndPlay(1);
					break;
				
				case "rollOut":		
					tabMC.gotoAndPlay(21);
					break;
				
				case "click":	
					switch(event.currentTarget.name)
					{					
						case VideoBucketConstants.TAB_SMART_START:							
							objVideoPlayer.controlVideoPlayBack(false);		// Pausing the video
							tabFullMC.play()
							attachVideoBucket(event.currentTarget);
						break;
						
						case VideoBucketConstants.TAB_SH2_SNAP:							
							objVideoPlayer.controlVideoPlayBack(false);		// Pausing the video
							tabFullMC.play()
							//attachVideoBucket(event.currentTarget);
						break;
						
						case VideoBucketConstants.TAB_MOST_VIEWED:							
							objVideoPlayer.controlVideoPlayBack(false);		// Pausing the video
							tabFullMC.play()
							attachVideoBucket(event.currentTarget);
						break;
						
						case VideoBucketConstants.TAB_PLAYLIST:							
							/*objVideoPlayer.controlVideoPlayBack(false);		// Pausing the video
							tabFullMC.play()
							attachVideoBucket(event.currentTarget);*/
						break;
						
						case VideoBucketConstants.TAB_MAP:							
							/*objVideoPlayer.controlVideoPlayBack(false);		// Pausing the video
							tabFullMC.play()
							attachVideoBucket(event.currentTarget);*/
							break;
					}
					break;
			}			
		 }
		 
		 
		 private function sh2SnapButtonEvents(event:MouseEvent):void
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
						disableSH2snapFullBtnSates(event.currentTarget);
						event.target.gotoAndStop(2);
						attachVideoBucket(event.currentTarget); // Need to use whenever  videoBucket need to attach
					 break;
			 }			
		 }
		 
		private function disableSH2snapFullBtnSates(target:Object):void
		 {			
			 var str:String = target.name;
			 var subStr:String = str.substr(0,str.length-1);
						 
			 for(var i:uint=1;i<5;i++)
			 {
				 target.parent[subStr+i].gotoAndStop(1);				
			 }
			 target.gotoAndStop(2);
		 }
		 
		private function attachVideoBucket(tabObject:Object):void
		 {
			 // Before adding a child need to check if it's already existed or not
		
			//if(videoBucket==null)
			if(videoBucket==null)
			{
//				this.removeChild(videoBucket);
//				videoBucket = null;
				videoBucket = new VideoBucketHolder();
				VideoBucketConstants.VIDEOBUCKET_ARRAY= [];						
				videoBucket.openSH2SnapTab(tabObject);
				trace("VideoBucket  Flushed")
			}
			else{				
				videoBucket.openSH2SnapTab(tabObject);
				trace("VideoBucket Not Flushed")
			}			
			this.addChild(videoBucket);
			
			videoBucket.x = VideoBucketConstants.videoBucketX;
			videoBucket.y = VideoBucketConstants.videoBucketY;		
		 }
		 
		public function back2videoBtn_ClickHandler(event:MouseEvent=null,videoURL=null):void
		{		
			//event.currentTarget.parent.addEventListener(Event.ENTER_FRAME,frameUpdate);
			if(videoURL!=null)
				requestedVideoURL = videoURL;
			
			tabFullMC.addEventListener(Event.ENTER_FRAME,frameUpdate);		
			
			if(this.contains(videoBucket))
			{
				this.removeChild(videoBucket)
			}			
		}
				 
		 private function frameUpdate(event:Event):void
		 {		
			 event.currentTarget.prevFrame();
			 if(event.currentTarget.currentFrame==1)
			 {
				 event.currentTarget.removeEventListener(Event.ENTER_FRAME,frameUpdate);		
				 objVideoPlayer.playClicked(null,requestedVideoURL);
				 videoBucket=null;
			 }
		 }
		 
		 private function attachWelcomeMC():void
		 {			
			 objAppModel.stageRef.addChild(HomeViewConstants.welcomeMC);
			 HomeViewConstants.welcomeMC.x = welcomeX;
			 HomeViewConstants.welcomeMC.y = welcomeY;
			 attachTagCloud();
		 }
		 
		 private function attachTagCloud():void
		 {
			 var tagCloud:TagCloud = new TagCloud();
		 }
		 
		 private function attachHomeBtn():void
		 {			
			 HomeViewConstants.homeBtn.scaleX= 1.3;
			 HomeViewConstants.homeBtn.scaleY= 1.3;			 
			 objAppModel.stageRef.addChild(HomeViewConstants.homeBtn);
			 HomeViewConstants.homeBtn.x = homeBtnX;
			 HomeViewConstants.homeBtn.y = homeBtnY;
			 HomeViewConstants.homeBtn.productNameTxt.text=objAppModel.getProductName();
			 HomeViewConstants.homeBtn.buttonMode=true;
			 HomeViewConstants.homeBtn.addEventListener(MouseEvent.CLICK,showHowLogoEventHandler);
			 HomeViewConstants.homeBtn.addEventListener(MouseEvent.ROLL_OVER,showHowLogoEventHandler);
			 HomeViewConstants.homeBtn.addEventListener(MouseEvent.ROLL_OUT,showHowLogoEventHandler);
		 }
		 
		 private function attachShowHowLogo():void
		 {	
			 objAppModel.stageRef.addChild(HomeViewConstants.showHowLogo);
			 shLogoLoader = new Loader();			 
			 shLogoLoader.load(new URLRequest(AppVO.BASEURL+AppVO.SHOWHOW_LOGO));
			 shLogoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,showHowLogoEventHandler);
			 shLogoLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,showHowLogoEventHandler);
			 shLogoLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,showHowLogoEventHandler);			 
		 }
		 
		 private function showHowLogoEventHandler(event:*):void
		 {
			 switch(event.type)
			 {
				 case 'open':
					 //trace("open");					
					 break;
				 
				 case 'progress':
					 //trace("Progress");
					 break;
				 
				 case 'init':
					 //trace("init");
					 break;
				 
				 case 'complete':
					 //trace("Complete");
					 HomeViewConstants.showHowLogo.addChild(shLogoLoader);
					 HomeViewConstants.showHowLogo.x = showHowLogoX;
					 HomeViewConstants.showHowLogo.y = showHowLogoY;
					 HomeViewConstants.showHowLogo.buttonMode=true;					 
					 break;
				 
				 case 'ioError':
					 trace("IO Error or Bad File name error");
					 break;
				 
				 case 'click':					 
					 HomeViewConstants.homeBtn.gotoAndStop(5);
					 break;
				 
				 case 'rollOut':					 
					 HomeViewConstants.homeBtn.gotoAndStop(1);
					 break;
				 
				 case 'rollOver':					 
					 HomeViewConstants.homeBtn.gotoAndStop(5);
					 break;
				 
				 default:
					 trace("Desired Event Not Found");
					 break;
			 }
		 }
	} 
}