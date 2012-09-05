package code.views
{
	import code.model.AppModel;
	import code.views.HomeViewConstants;
	import code.vo.AppVO;
	
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
		private var omniX:int = 545;
		private var omniY:int = 10;
		
		private var finderX:int = omniX-25;
		private var finderY:int = omniY+58;
		private var smartStartX:int = finderX;
		private var smartStartY:int = finderY;
		private var welcomeX:int = finderX;
		private var welcomeY:int = smartStartY+20;
		private var homeBtnX:int = omniX-58;
		private var homeBtnY:int = omniY+7;
		private var showHowLogoX:int = -10;
		private var showHowLogoY:int = omniY-5;
		
		private var finderMc:Finder_MC;
		private var smartStartMC:SmartStart_MC;
		private var welcomeMC:Welcome_MC;
		private var homeBtn:HomeBtn_MC;
		private var showHowLogo:MovieClip;
		
		
		public function HomeView()
		{
			trace("Home View")
			omniUrl = AppVO.BASEURL+AppVO.OMNI_SWF;
			loadOmniSwf();	
			attachWelcomeMC();
			attachSmartStartMC();
			attachFinderMC();		
			attachHomeBtn();
			attachShowHowLogo();
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
					 trace("Omni LoadedComplete>>"+HomeViewConstants.omniHolder);				
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
			 objAppModel.stageRef.addChild(HomeViewConstants.smartStartMC);
			 HomeViewConstants.smartStartMC.x = smartStartX;
			 HomeViewConstants.smartStartMC.y = smartStartY;
			 HomeViewConstants.smartStartMC.stop();
			 
			 HomeViewConstants.smartStartMC.btn_1.addEventListener(MouseEvent.ROLL_OVER,onClick);
			 HomeViewConstants.smartStartMC.btn_2.addEventListener(MouseEvent.ROLL_OVER,onClick);
			 HomeViewConstants.smartStartMC.btn_3.addEventListener(MouseEvent.ROLL_OVER,onClick);
			 HomeViewConstants.smartStartMC.btn_4.addEventListener(MouseEvent.ROLL_OVER,onClick);
			 HomeViewConstants.smartStartMC.btn_5.addEventListener(MouseEvent.ROLL_OVER,onClick);
			 
			 HomeViewConstants.smartStartMC.btn_1.addEventListener(MouseEvent.ROLL_OUT,onClick);
			 HomeViewConstants.smartStartMC.btn_2.addEventListener(MouseEvent.ROLL_OUT,onClick);
			 HomeViewConstants.smartStartMC.btn_3.addEventListener(MouseEvent.ROLL_OUT,onClick);
			 HomeViewConstants.smartStartMC.btn_4.addEventListener(MouseEvent.ROLL_OUT,onClick);
			 HomeViewConstants.smartStartMC.btn_5.addEventListener(MouseEvent.ROLL_OUT,onClick);
		 }
		 
		 private function onClick(event:MouseEvent):void
		 {
			switch(event.type)
			{
				case "rollOver":
					HomeViewConstants.smartStartMC.play();
					event.currentTarget.gotoAndPlay(2);
					break;
				case "rollOut":		
					HomeViewConstants.smartStartMC.play();
					event.currentTarget.gotoAndPlay(16);
					break;
			}			
		 }
		 
		 private function attachWelcomeMC():void
		 {			
			 objAppModel.stageRef.addChild(HomeViewConstants.welcomeMC);
			 HomeViewConstants.welcomeMC.x = welcomeX;
			 HomeViewConstants.welcomeMC.y = welcomeY;
		 }
		 
		 private function attachHomeBtn():void
		 {			
			 HomeViewConstants.homeBtn.scaleX= 1.3;
			 HomeViewConstants.homeBtn.scaleY= 1.3;			 
			 objAppModel.stageRef.addChild(HomeViewConstants.homeBtn);
			 HomeViewConstants.homeBtn.x = homeBtnX;
			 HomeViewConstants.homeBtn.y = homeBtnY;
			 HomeViewConstants.homeBtn.buttonMode=true;
			 HomeViewConstants.homeBtn.addEventListener(MouseEvent.CLICK,showHowLogoEventHandler);
			 HomeViewConstants.homeBtn.addEventListener(MouseEvent.ROLL_OVER,showHowLogoEventHandler);
			 HomeViewConstants.homeBtn.addEventListener(MouseEvent.ROLL_OUT,showHowLogoEventHandler);
		 }
		 
		 private function attachShowHowLogo():void
		 {	
			 urlRequest.url = AppVO.BASEURL+AppVO.SHOWHOW_LOGO;
			 shLogoLoader = new Loader();
			 
			 shLogoLoader.load(urlRequest);
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
					 trace("Complete");
					 HomeViewConstants.showHowLogo.addChild(shLogoLoader);
					 objAppModel.stageRef.addChild(HomeViewConstants.showHowLogo);
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