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
	import flash.display.Shape;
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
		
		private var previousButton:ScrollPanPrevious;
		private var nextButton:ScrollPanNext;
		private var objAppModel:AppModel = AppModel.getInstance();
		
		private var maxFrontTiles:int=4;
//		private var totalXmlLength:int=0
		
//		private var nxt:int=0
		private var tabRef:Object;
		
		
		public function VideoBucketHolder()
		{		
			var rect:Shape = new Shape()
			rect.graphics.beginFill(0xFFFFFF,1);
			rect.graphics.drawRect(VideoBucketConstants.videoBucketX,VideoBucketConstants.videoBucketY,959,530);
			rect.graphics.endFill();
			this.addChild(rect);
		}		
		
		public function openSH2SnapTab(tab:Object):void
		{
			objVideoPlayer=VideoPlayer.getInstance();
			/*if(VideoBucketConstants.scrollBtnRef[0]!=null&&VideoBucketConstants.scrollBtnRef[1]!=null)
			{
				VideoBucketConstants.scrollBtnRef[0].parent.removeChild(VideoBucketConstants.scrollBtnRef[0]);
				VideoBucketConstants.scrollBtnRef[1].parent.removeChild(VideoBucketConstants.scrollBtnRef[1])
			}*/
			trace("Tab name:="+tab.name)
//			nxt=0
			switch(tab.name)
			{
				case VideoBucketConstants.SMART_START:
					//var myDuplicate:MovieClip = duplicateDisplayObject( videoBucket ) as MovieClip;
					attachVideoTiles(FilmConstants.smartStartMediaArr);	
//					totalXmlLength=FilmConstants.smartStartMediaArr.length
					break;
				
				case VideoBucketConstants.BEGINNER:
					attachVideoTiles(FilmConstants.beginnerMediaArr);
//					totalXmlLength=FilmConstants.beginnerMediaArr.length
					break;
				
				case VideoBucketConstants.INTERMEDIATE:
					attachVideoTiles(FilmConstants.intermediateMediaArr);
//					totalXmlLength=FilmConstants.intermediateMediaArr.length
					break;
				
				case VideoBucketConstants.ADVANCED:					
					attachVideoTiles(FilmConstants.advancedMediaArr);
//					totalXmlLength=FilmConstants.advancedMediaArr.length
					break;
				
				case VideoBucketConstants.TAB_SMART_START:
					attachVideoTiles(FilmConstants.smartStartMediaArr);
//					totalXmlLength=FilmConstants.smartStartMediaArr.length
					break;
				
				case VideoBucketConstants.TAB_MOST_VIEWED:
					attachVideoTiles(FilmConstants.smartStartMediaArr);
//					totalXmlLength=FilmConstants.smartStartMediaArr.length
					break;
				
				case VideoBucketConstants.TAB_TAG_CLOUD:
					tabRef = tab;
					attachVideoTiles(FilmConstants.tagMediaArray);
//					totalXmlLength=FilmConstants.tagMediaArray.length
					break;
				
				case VideoBucketConstants.FINDER:
					tabRef = tab;
					attachVideoTiles(FilmConstants.finderMediaArray);
					//totalXmlLength=FilmConstants.tagMediaArray.length
					break;
				
			
				default:
					trace("False Tab name::Code Error in VideoBucketHolder.as in openSH2SnapTab method,");
					break;
			}
//			totalXmlLength=totalXmlLength/4
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
				
				videoBucket.videoTile.durationText.text=filmsArray[i].duration;
				videoBucket.videoTile.videoTitleText.text=filmsArray[i].videoTitle;
				videoBucket.videoTile.summaryText.text=filmsArray[i].description;				
			
				urlRequest = new URLRequest();
				urlRequest.url = AppModel.BASE_URL+AppModel.player+AppModel.PID+AppModel.content+filmsArray[i].image_url;
				loader = new Loader();
				loader.load(urlRequest);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imageLoaded(videoBucket.videoTile.videoThumb));				
				
				this.addChild(videoBucket);
//				startY = (videoBucket.videoTile.height+13)+ VideoBucketConstants.VGAP+startY;
				startY = (videoBucket.height/2)+ VideoBucketConstants.VGAP+startY;
				
				if(i%2==1)
				{
//					startX = (videoBucket.videoTile.width+94)+VideoBucketConstants.HGAP+startX;
					startX = (videoBucket.width/2)+VideoBucketConstants.HGAP+startX;
					startY = VideoBucketConstants.VIDEOTILE_Y;
				}	
				VideoBucketConstants.VIDEOBUCKET_ARRAY.push(videoBucket);
			}					
			
			previousButton = new ScrollPanPrevious();
			nextButton = new ScrollPanNext();
			
			/*VideoBucketConstants.scrollBtnRef[0]=previousButton;
			VideoBucketConstants.scrollBtnRef[1]=nextButton;*/
	
			
			if(filmsArray.length>4)
			{
				this.addChild(previousButton);
				previousButton.x = VideoBucketConstants.previousBtnX;
				previousButton.y = VideoBucketConstants.previousBtnY;
				previousButton.visible=false		
				
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
					/*nxt++
					trace("totalXmlLength+"+totalXmlLength+"nxt----"+nxt)
					if(nxt<=totalXmlLength){
						previousButton.visible=true		
						this.x = this.x - 940
						if(nxt==totalXmlLength){
							nextButton.visible=false
							previousButton.visible=true		
						}
						
						
					}else{
						nextButton.visible=false
						
					}*/
					trace("Sp")
					break;
				
				case previousButton:
					trace("SPP")
					/*nxt--
					if(nxt>=0){
						this.x = this.x + 940;
						nextButton.visible=true
						if(nxt==0){
							previousButton.visible=false
							nextButton.visible=true
						}
						
						
					}else{
						previousButton.visible=false
						
					}*/
					trace("Sp")
					break;		
				//this.x = this.x + 912;
				//break;				
			}
		}
				
		private function imageLoaded(imageHolder:MovieClip):Function
		{
			var fun:Function = function(event:Event)
			{
				imageHolder.addChild(event.currentTarget.content);				
			}		
			return fun;
		}
		
		//[AS]:Handling MoueEvent.CLICK callback by recieving a videoURL from clickevent

		private function playButton_Handler(videoURL:String):Function
		{
			var func:Function = function(event:MouseEvent)
			{
				//trace(">>"+videoURL);
				var videoPath:String = AppModel.BASE_URL+AppModel.player+AppModel.PID+AppModel.content+videoURL;	
				objAppModel.homeViewRef.back2videoBtn_ClickHandler(null,videoPath,tabRef);		// Call for SH2Snap_Full animation play reverse
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

