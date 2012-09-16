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
		
		private var locationObject0:Object=new Object();
		private var locationObject1:Object=new Object();
		private var locationObject2:Object=new Object();
		private var locationObject3:Object=new Object();
		private var outOfStageLeft:Object=new Object();		
		private var outOfStageRight:Object=new Object();
		
		private var maxFrontTiles:int=4;
		private var nextTileStartingPosition:int=0;
		private var limitForNextTileSet:int=4
		
		
		public function VideoBucketHolder()
		{		
			that = this;
		}		
		
		public function openSH2SnapTab(sh2SnapTab:Object):void
		{
			objVideoPlayer=VideoPlayer.getInstance();
			trace("Tab name:="+sh2SnapTab.name)
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
				
				case VideoBucketConstants.TAB_SMART_START:
					attachVideoTiles(FilmConstants.smartStartMediaArr);
					break;
				
				case VideoBucketConstants.TAB_MOST_VIEWED:
					attachVideoTiles(FilmConstants.smartStartMediaArr);
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
			
			outOfStageLeft.sx=startX - 100;
			outOfStageLeft.sy=startY;
			
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
				urlRequest = new URLRequest();
				urlRequest.url = AppModel.BASE_URL+AppModel.player+AppModel.PID+AppModel.content+filmsArray[i].image_url;
				loader = new Loader();
				loader.load(urlRequest);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imageLoaded);				
				/////////////////////////////////////////////////////////////////////////
				this.addChild(videoBucket);
				startY = (videoBucket.height/2)+ VideoBucketConstants.VGAP+startY;
				
				if(i%2==1)
				{
					startX = (videoBucket.width/2)+VideoBucketConstants.HGAP+startX;
					startY = VideoBucketConstants.VIDEOTILE_Y;
				}				
				if(i<maxFrontTiles)	// this condition will push the x y positon of videoTile in location0-location3 objects
				{
					this["locationObject"+i].sx = videoBucket.x;
					this["locationObject"+i].sy = videoBucket.y;
				}
				VideoBucketConstants.VIDEOBUCKET_ARRAY.push(videoBucket);
			}		
				
			outOfStageRight.sx = startX;
			outOfStageRight.sy = startY;
			
			
			previousButton = new ScrollPanPrevious();
			nextButton = new ScrollPanNext();
									
			if(filmsArray.length>4)
			{
				this.addChild(previousButton);
				previousButton.x = VideoBucketConstants.previousBtnX;
				previousButton.y = VideoBucketConstants.previousBtnY;
				previousButton.visible = false;
				
				this.addChild(nextButton);
				nextButton.x = VideoBucketConstants.nextBtnX;
				nextButton.y = VideoBucketConstants.nextBtnY;	
				
				previousButton.addEventListener(MouseEvent.CLICK,scrollPaneButtonEvents);
				nextButton.addEventListener(MouseEvent.CLICK,scrollPaneButtonEvents);
				
				limitForNextTileSet = limitForNextTileSet + maxFrontTiles;
				nextTileStartingPosition = maxFrontTiles;
			}
		}
		
		private function scrollPaneButtonEvents(event:MouseEvent):void
		{
			switch(event.currentTarget)
			{
				case nextButton:
					//[AS]:: Commented as below mentioned logic needs to be rewritten
					//showNextTileSet();
//					trace("L="+VideoBucketConstants.VIDEOBUCKET_ARRAY.length+"--nextTileStartingPosition--"+nextTileStartingPosition)
					break;
				
				case previousButton:
					trace("SPP")
					break;				
			}
		}
		
		private function showNextTileSet():void
		{		
			previousButton.visible=true;
			var count:int=0;
			
			for(var i:int=nextTileStartingPosition;i<limitForNextTileSet;i++)
			{
				//VideoBucketConstants.VIDEOBUCKET_ARRAY[i-1].visible=false;
				
				VideoBucketConstants.VIDEOBUCKET_ARRAY[i].x = this["locationObject"+count].sx;
				VideoBucketConstants.VIDEOBUCKET_ARRAY[i].y = this["locationObject"+count].sy;
				
				count++;
				if(count>3){
					count=0;}
			}
			limitForNextTileSet = maxFrontTiles+i;
			
//			nextTileStartingPosition = i;		
			if(limitForNextTileSet<VideoBucketConstants.VIDEOBUCKET_ARRAY.length)
			{
				nextTileStartingPosition = i;				
			}else{
				if((limitForNextTileSet-VideoBucketConstants.VIDEOBUCKET_ARRAY.length)==1)
				{
					limitForNextTileSet=VideoBucketConstants.VIDEOBUCKET_ARRAY.length;
					nextTileStartingPosition = i;	
				}else{
					nextTileStartingPosition = maxFrontTiles;
					limitForNextTileSet = maxFrontTiles+4;
					nextButton.visible=false;
					trace("Limit Reached")}
			}
		}
				
		private function imageLoaded(event:Event)
		{
			var videoThumb = videoBucket.videoTile.videoThumb;
			videoThumb.addChild(event.currentTarget.content);			
		}
		
		//[AS]:Handling MoueEvent.CLICK callback by recieving a videoURL from clickevent

		private function playButton_Handler(videoURL:String):Function
		{
			var func:Function = function(event:MouseEvent)
			{
				//trace(">>"+videoURL);
				var videoPath:String = AppModel.BASE_URL+AppModel.player+AppModel.PID+AppModel.content+videoURL;
//				objVideoPlayer.controlVideoPlayBack(false,videoPath);		
				objAppModel.homeViewRef.back2videoBtn_ClickHandler(null,videoPath);		// Call for SH2Snap_Full animation play reverse
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

