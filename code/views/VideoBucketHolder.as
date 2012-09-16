package code.views
{
	import code.events.PlaySelectedVideoEvent;
	import code.model.AppModel;
	import code.views.HomeViewConstants;
	import code.views.VideoBucketConstants;
	import code.vo.AppVO;
	import code.vo.FilmConstants;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class VideoBucketHolder extends MovieClip
	{
		private var videoBucket:VideoBucket;
		private var objVideoPlayer:VideoPlayer;
		private var that:VideoBucketHolder;
		
		private var previousButton:ScrollPanPrevious;
		private var nextButton:ScrollPanNext;
		private var objAppModel:AppModel = AppModel.getInstance();
		
		public function VideoBucketHolder()
		{		
			that = this;
		}		
		
		public function openSH2SnapTab(sh2SnapTab:Object):void
		{
			objVideoPlayer=VideoPlayer.getInstance();
			switch(sh2SnapTab.name)
			{
				case VideoBucketConstants.SMART_START:
					//var myDuplicate:MovieClip = duplicateDisplayObject( videoBucket ) as MovieClip;
					attachVideoTiles(FilmConstants.smartStartMediaArr);
					break;
				
				case VideoBucketConstants.BEGINNER:
					attachVideoTiles(FilmConstants.beginnerMediaArr);
					break;
				
				case VideoBucketConstants.INTERMEDIATE:
					attachVideoTiles(FilmConstants.intermediateMediaArr);
					break;
				
				case VideoBucketConstants.ADVANCED:
					trace("Adv="+FilmConstants.advancedMediaArr.length);
					attachVideoTiles(FilmConstants.advancedMediaArr);
					break;
				
				default:
					trace("False Tab name::Code Error in VideoBucketHolder.as in openSH2SnapTab method,");
					break;
			}
		}
		
		private function attachVideoTiles(filmsArray:Array):void
		{
			var startX:int=VideoBucketConstants.VIDEOTILE_X;
			var startY:int=VideoBucketConstants.VIDEOTILE_Y;
			var loader:Loader;
			var urlRequest:URLRequest;
			for(var i:int=0;i<filmsArray.length;i++)
			{
				videoBucket = new VideoBucket();
				videoBucket.x = startX;
				videoBucket.y = startY;
				videoBucket.name = i.toString();
				videoBucket.videoTile.playBtn.buttonMode = true;
				videoBucket.videoTile.playBtn.addEventListener(MouseEvent.CLICK,playButton_Handler(filmsArray[i].videoURL));
				/*dispatchEvent(new PlaySelectedVideoEvent(PlaySelectedVideoEvent.CLICK,filmsArray[i].videoURL));
				videoBucket.videoTile.playBtn.addEventListener(PlaySelectedVideoEvent.CLICK,plClick);*/
				
				videoBucket.videoTile.durationText.text=filmsArray[i].duration;
				videoBucket.videoTile.videoTitleText.text=filmsArray[i].videoTitle;
				videoBucket.videoTile.summaryText.text=filmsArray[i].description;				
			
				/////////////////////////////////////////////////////////////////////////
				//Need to load image into below mentioned movie clip::But right now it's not working need to fix.
				/*urlRequest = new URLRequest();
				urlRequest.url = AppVO.IMAGE_URL+filmsArray[i].image_url;
				loader = new Loader();
				loader.load(urlRequest);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imageLoaded);		*/		
				/////////////////////////////////////////////////////////////////////////
				this.addChild(videoBucket);
				startY = (videoBucket.height/2)+ VideoBucketConstants.VGAP+startY;
				
				if(i%2==1)
				{
					startX = (videoBucket.width/2)+VideoBucketConstants.HGAP+startX;
					startY = VideoBucketConstants.VIDEOTILE_Y;
				}		
				VideoBucketConstants.VIDEOBUCKET_ARRAY.push(videoBucket);
			}		
			trace("W="+this.width+"--H="+this.height)
			previousButton = new ScrollPanPrevious();
			nextButton = new ScrollPanNext();
			
			if(filmsArray.length>4)
			{
				this.addChild(previousButton);
				previousButton.x = VideoBucketConstants.previousBtnX;
				previousButton.y = VideoBucketConstants.previousBtnY;
				//previousButton.visible = false;
				
				this.addChild(nextButton);
				nextButton.x = VideoBucketConstants.nextBtnX;
				nextButton.y = VideoBucketConstants.nextBtnY;	
				
				previousButton.addEventListener(MouseEvent.CLICK,scrollPaneButtonEvents);
				nextButton.addEventListener(MouseEvent.CLICK,scrollPaneButtonEvents);
			}
		}
		
		private function scrollPaneButtonEvents(event:MouseEvent):void
		{
			switch(event.currentTarget)
			{
				case nextButton:
					trace("Sp")
					//this.x = this.x - 900;
					break;
				
				case previousButton:
					trace("SPP")
					break;				
			}
		}
				
		private function imageLoaded(event:Event)
		{
			//videoBucket.videoTile.videoThumb.addChild(event.target.content);
			trace("Loaded")
		}
		
		//[AS]:Handling MoueEvent.CLICK callback by recieving a videoURL from clickevent

		private function playButton_Handler(videoURL:String):Function
		{
			var func:Function = function(event:MouseEvent)
			{
				//trace(">>"+videoURL);
				var videoPath:String = AppVO.IMAGE_URL+videoURL;
				objVideoPlayer.controlVideoPlayBack(false,videoPath);		
				objAppModel.homeViewRef.back2videoBtn_ClickHandler();		// Call for SH2Snap_Full animation play reverse
			}			
			/*you might want to consider adding these to a dictionary or array, 
			so can remove the listeners to allow garbage collection*/
			return func;
		}		
		
		/*private function duplicateDisplayObject( displayObject:DisplayObject ):DisplayObject 
		{
			var class_name:String = getQualifiedClassName( displayObject );
			var definition:Class = getDefinitionByName( class_name ) as Class;
			return new definition() as DisplayObject;
		}*/
	}
}

