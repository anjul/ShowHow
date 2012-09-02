package code.views
{
	import code.model.AppModel;
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
		private var urlRequest:URLRequest;
		
		private var objAppModel:AppModel= AppModel.getInstance();
		private var omniHolder:MovieClip = new MovieClip();
		private var omniX:int=545;
		private var omniY:int=10;
		private var finderX:int=omniX-25;
		private var finderY:int=omniY+58;
		private var smartStartX:int=finderX;
		private var smartStartY:int=finderY;
		private var welcomeX:int=finderX;
		private var welcomeY:int=smartStartY+20;
		private var homeBtnX:int=omniX-58
		private var homeBtnY:int=omniY+7
		
		private var finderMc:Finder_MC;
		private var smartStartMC:SmartStart_MC;
		private var welcomeMC:Welcome_MC;
		private var homeBtn:HomeBtn_MC;
		
		
		public function HomeView()
		{
			trace("Home View")
			omniUrl = AppVO.BASEURL+AppVO.OMNI_SWF;
			loadOmniSwf();	
			attachWelcomeMC();
			attachSmartStartMC();
			attachFinderMC();		
			attachHomeBtn();
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
					trace("open");					
					 break;
				 
				 case 'progress':
					 trace("Progress");
					 break;
				 
				 case 'init':
					 //trace("init");
					 break;
				 
				 case 'complete':
					 trace("Complete");
					 omniHolder.addChild(loader);
					 objAppModel.stageRef.addChild(omniHolder);
					 omniHolder.x=omniX;
					 omniHolder.y=omniY;
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
			 
			 finderMc = new Finder_MC();
			 objAppModel.stageRef.addChild(finderMc);
			 finderMc.x = finderX;
			 finderMc.y = finderY;
		 }
		 
		 private function attachSmartStartMC():void
		 {
			 smartStartMC = new SmartStart_MC();
			 objAppModel.stageRef.addChild(smartStartMC);
			 smartStartMC.x = smartStartX;
			 smartStartMC.y = smartStartY;
			 smartStartMC.stop();
			 smartStartMC.btn_1.addEventListener(MouseEvent.ROLL_OVER,onClick);
			 smartStartMC.btn_2.addEventListener(MouseEvent.ROLL_OVER,onClick);
			 smartStartMC.btn_3.addEventListener(MouseEvent.ROLL_OVER,onClick);
			 smartStartMC.btn_4.addEventListener(MouseEvent.ROLL_OVER,onClick);
			 smartStartMC.btn_5.addEventListener(MouseEvent.ROLL_OVER,onClick);
			 
			 smartStartMC.btn_1.addEventListener(MouseEvent.ROLL_OUT,onClick);
			 smartStartMC.btn_2.addEventListener(MouseEvent.ROLL_OUT,onClick);
			 smartStartMC.btn_3.addEventListener(MouseEvent.ROLL_OUT,onClick);
			 smartStartMC.btn_4.addEventListener(MouseEvent.ROLL_OUT,onClick);
			 smartStartMC.btn_5.addEventListener(MouseEvent.ROLL_OUT,onClick);
		 }
		 
		 private function onClick(event:MouseEvent):void
		 {
			 trace("Click="+event.target.name+">>"+event.type)
			 
			switch(event.type)
			{
				case "rollOver":
					smartStartMC.play();
					break;
				case "rollOut":
					
					smartStartMC.play();
					break;
			}			
		 }
		 
		 private function attachWelcomeMC():void
		 {
			 welcomeMC = new Welcome_MC();
			 objAppModel.stageRef.addChild(welcomeMC);
			 welcomeMC.x = welcomeX;
			 welcomeMC.y = welcomeY;
		 }
		 
		 private function attachHomeBtn():void
		 {
			 homeBtn = new HomeBtn_MC();
			 homeBtn.scaleX= 1.3;
			 homeBtn.scaleY= 1.3;			 
			 objAppModel.stageRef.addChild(homeBtn);
			 homeBtn.x = homeBtnX;
			 homeBtn.y = homeBtnY;
		 }
	} 
}