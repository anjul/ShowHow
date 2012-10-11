package code.views
{
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
		private var totalXmlLength:int=0
		
		private var nxt:int=0;
		private var resultCount:int = 0;
		private var fullTabRef:Object;		
		
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
			trace("Tab name:="+tab.name)
			switch(tab.name)
			{
				case VideoBucketConstants.SMART_START:
					//var myDuplicate:MovieClip = duplicateDisplayObject( videoBucket ) as MovieClip;
						
					fullTabRef = tab.parent;
					attachVideoTiles(FilmConstants.smartStartMediaArr);	
					totalXmlLength=FilmConstants.smartStartMediaArr.length
					break;
				
				case VideoBucketConstants.BEGINNER:
					fullTabRef = tab.parent;					
					attachVideoTiles(FilmConstants.beginnerMediaArr);
					totalXmlLength=FilmConstants.beginnerMediaArr.length
					break;
				
				case VideoBucketConstants.INTERMEDIATE:
					fullTabRef = tab.parent;
					attachVideoTiles(FilmConstants.intermediateMediaArr);
					totalXmlLength=FilmConstants.intermediateMediaArr.length
					break;
				
				case VideoBucketConstants.ADVANCED:	
					fullTabRef = tab.parent;
					attachVideoTiles(FilmConstants.advancedMediaArr);
					totalXmlLength=FilmConstants.advancedMediaArr.length
					break;
				
				case VideoBucketConstants.TAB_SMART_START:
					fullTabRef = tab.parent[tab.name+"_full"];
					attachVideoTiles(FilmConstants.smartStartMediaArr);
					totalXmlLength=FilmConstants.smartStartMediaArr.length
					break;
				
				case VideoBucketConstants.TAB_MOST_VIEWED:
					fullTabRef = tab.parent[tab.name+"_full"];
					attachVideoTiles(FilmConstants.smartStartMediaArr);
					totalXmlLength=FilmConstants.smartStartMediaArr.length
					break;
				
				case VideoBucketConstants.TAB_TAG_CLOUD:
					fullTabRef = tab.tag_full
					attachVideoTiles(FilmConstants.tagMediaArray);
					totalXmlLength=FilmConstants.tagMediaArray.length;					
					break;
				
				case VideoBucketConstants.FINDER:
					fullTabRef = tab.tag_full;
					attachVideoTiles(FilmConstants.finderMediaArray);
					totalXmlLength=FilmConstants.finderMediaArray.length
					break;				
			
				default:
					trace("False Tab name::Code Error in VideoBucketHolder.as in openSH2SnapTab method,");
					break;
			}				
			resultCount = totalXmlLength;
			totalXmlLength=Math.ceil(totalXmlLength/4);
			nxt =1;
			objAppModel.homeViewRef.updatePagination(resultCount,1,totalXmlLength,fullTabRef);
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
				videoBucket.videoTile.playBtn.videoURL = filmsArray[i].videoURL;
				videoBucket.videoTile.playBtn.chapterID = filmsArray[i].chapterID;
//				videoBucket.videoTile.playBtn.addEventListener(MouseEvent.CLICK,playButton_Handler(filmsArray[i].videoURL));
				videoBucket.videoTile.playBtn.addEventListener(MouseEvent.CLICK,playButton_Handler);
				
				videoBucket.videoTile.durationText.text=filmsArray[i].duration;
				videoBucket.videoTile.videoTitleText.text=filmsArray[i].videoTitle;
				videoBucket.videoTile.summaryText.text=filmsArray[i].description;				
			
				urlRequest = new URLRequest();
				urlRequest.url = objAppModel.baseURL+objAppModel.player+objAppModel.pid+objAppModel.content+filmsArray[i].image_url;
				loader = new Loader();
				loader.load(urlRequest);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imageLoaded(videoBucket.videoTile.videoThumb));				
				
				this.addChild(videoBucket);
				startY = (videoBucket.videoTile.height+13)+ VideoBucketConstants.VGAP+startY;
				//startY = (videoBucket.height/2)+ VideoBucketConstants.VGAP+startY;
				
				if(i%2==1)
				{
					startX = (videoBucket.videoTile.width+105)+VideoBucketConstants.HGAP+startX;
					//startX = (videoBucket.width/2)+VideoBucketConstants.HGAP+startX;
					startY = VideoBucketConstants.VIDEOTILE_Y;
				}	
				//VideoBucketConstants.VIDEOBUCKET_ARRAY.push(videoBucket);
			}
			
			// Below condition is remove reference of scroll pane buttons if already attached.
			if(filmsArray.length>4)
			{
				if(VideoBucketConstants.scrollBtnRef.length>0)
				{
					for(var j:int=0;j<VideoBucketConstants.scrollBtnRef.length;j++)
					{
						VideoBucketConstants.scrollBtnRef[j].parent.removeChild(VideoBucketConstants.scrollBtnRef[j]);
						VideoBucketConstants.scrollBtnRef[j]=null;
					}
				}
				previousButton = new ScrollPanPrevious();
				objAppModel.stageRef.addChild(previousButton);
				nextButton = new ScrollPanNext();
				objAppModel.stageRef.addChild(nextButton);
				
				previousButton.x = VideoBucketConstants.previousBtnX;
				previousButton.y = VideoBucketConstants.previousBtnY;
				previousButton.visible=false;				
				
				nextButton.x = VideoBucketConstants.nextBtnX;
				nextButton.y = VideoBucketConstants.nextBtnY;	
				
				previousButton.addEventListener(MouseEvent.CLICK,scrollPaneButtonEvents);
				nextButton.addEventListener(MouseEvent.CLICK,scrollPaneButtonEvents);
				
				VideoBucketConstants.scrollBtnRef[0]=previousButton;
				VideoBucketConstants.scrollBtnRef[1]=nextButton;
			}
		}
		
		private function scrollPaneButtonEvents(event:MouseEvent):void
		{			
			switch(event.currentTarget)
			{
				case nextButton:
					nxt++;
					//trace("totalXmlLength+"+totalXmlLength+"nxt----"+nxt)
					if(nxt<=totalXmlLength)
					{
						previousButton.visible=true		
						this.x = this.x - 922;
						objAppModel.homeViewRef.updatePagination(resultCount,nxt,totalXmlLength,fullTabRef);
						if(nxt==totalXmlLength)
						{
							nextButton.visible=false
							previousButton.visible=true		
						}
					}
					else
					{
						nextButton.visible=false;
					}
				break;
				
				case previousButton:					
					nxt--;
					if(nxt>=1)
					{
						this.x = this.x + 922;
						nextButton.visible=true;
						objAppModel.homeViewRef.updatePagination(resultCount,nxt,totalXmlLength,fullTabRef);
						if(nxt==1)
						{
							previousButton.visible=false
							nextButton.visible=true
						}						
					}
					else
					{
						previousButton.visible=false;
					}
				break;					
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
		
		private function playButton_Handler(event:MouseEvent):void
		{
			var videoPath:String = objAppModel.baseURL+objAppModel.player+objAppModel.pid+objAppModel.content+event.currentTarget.videoURL;	
			objAppModel.homeViewRef.back2videoBtn_ClickHandler(null,videoPath,fullTabRef,event.currentTarget.chapterID);		// Call for SH2Snap_Full animation play reverse
		}	
		
		/*private function duplicateDisplayObject( displayObject:DisplayObject ):DisplayObject 
		{
			var class_name:String = getQualifiedClassName( displayObject );
			var definition:Class = getDefinitionByName( class_name ) as Class;
			return new definition() as DisplayObject;
		}*/
	}
}

