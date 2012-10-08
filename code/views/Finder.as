package code.views
{
	import code.events.AppEvents;
	import code.model.AppModel;
	import code.model.FinderModel;
	import code.services.ServiceConstants;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	public class Finder extends MovieClip
	{
		private var requestedVideoURL:String;
		private var finderRef:MovieClip;
		private var objAppModel:AppModel = AppModel.getInstance();
		private var objVideoPlayer:VideoPlayer=VideoPlayer.getInstance();
		private var objFinderModel:FinderModel=FinderModel.getInstance();
		
		public function Finder(ref:MovieClip)
		{
			finderRef = ref;
			attachEvents();
		}
		
		private function attachEvents():void
		{
			objFinderModel.addEventListener(AppEvents.INIT_XML_DATA_LOADED,xmlDataLoaded);
			objFinderModel.addEventListener(AppEvents.XML_DATA_LOAD_FAILURE,xmlDataLoadFailure);
			
			finderRef.searchTxt.addEventListener(MouseEvent.CLICK,finderEvents);			
			finderRef.finderBtn.addEventListener(MouseEvent.MOUSE_OVER,finderEvents);
			finderRef.finderBtn.addEventListener(MouseEvent.MOUSE_OUT,finderEvents);
			finderRef.finderBtn.addEventListener(MouseEvent.CLICK,finderEvents);
			finderRef.finderBtn.buttonMode = true;
		}
		
		private function finderEvents(event:MouseEvent):void
		{
			switch(event.type)
			{
				case "rollOver":
					finderRef.finderBtn.gotoAndStop(1);
					break;
				
				case "rollOut":		
					finderRef.finderBtn.gotoAndStop(2);
					break;
				
				case "click":	
					switch(event.currentTarget.name)
					{
						case 'searchTxt':
							finderRef.searchTxt.text='';
							break;
						case 'finderBtn':
							//trace(finderRef.searchTxt.text);
							objFinderModel.loadXML(ServiceConstants.FULL_PATH+ServiceConstants.FINDER_XML_PATH+finderRef.searchTxt.text)
							break;
					}					
				break;
			}
		}
		
		private function xmlDataLoaded(event:AppEvents):void
		{
			var obj:Object = new Object();
			obj.name = "finder";
			obj.tag_full = HomeViewConstants.smartStartMC.tag_full;
			objAppModel.homeViewRef.attachVideoBucket(obj);
			
			objVideoPlayer.controlVideoPlayBack(false);	// Pausing Video Player
			HomeViewConstants.smartStartMC.tag_full.gotoAndPlay(2);
			HomeViewConstants.smartStartMC.tag_full.mouseChildren=true;
		}
		
		private function xmlDataLoadFailure(event:AppEvents):void
		{
			trace("Requested search data load faliure");
		}
		
		private function backButtonHandler(event:MouseEvent):void
		{			
			HomeViewConstants.smartStartMC.tag_full.addEventListener(Event.ENTER_FRAME,frameUpdate)
			if(objAppModel.homeViewRef.contains(HomeViewConstants.refVideoBucket))
			{
				objAppModel.homeViewRef.removeChild(HomeViewConstants.refVideoBucket)
			}
			HomeViewConstants.refVideoBucket=null;			
		}
		
		private function frameUpdate(event:Event):void
		{		
			event.currentTarget.prevFrame();
			if(event.currentTarget.currentFrame==1)
			{
				event.currentTarget.removeEventListener(Event.ENTER_FRAME,frameUpdate);		
				objVideoPlayer.playClicked(null,requestedVideoURL);
				
			}
		}
	}
}