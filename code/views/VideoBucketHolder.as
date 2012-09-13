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
		private var filmsArr:Array=new Array();
		
		public function VideoBucketHolder()
		{		
			
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
		
		private function attachVideoTiles(filmsArray):void
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
				videoBucket.videoTile.playBtn.addEventListener(MouseEvent.CLICK,playButton_Handler);
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
		}
		
		private function imageLoaded(event:Event)
		{
			//videoBucket.videoTile.videoThumb.addChild(event.target.content);
			trace("Loaded")
		}

		private function playButton_Handler(event:MouseEvent):void
		{
			var index:Number = Number(event.currentTarget.parent.parent.name)
			var videoURL:String = AppVO.IMAGE_URL+filmsArr[index];
			trace(index+"Clicked Video = "+filmsArr[0]);
			objVideoPlayer.controlVideoPlayBack(false)
		}
		/*private function duplicateDisplayObject( displayObject:DisplayObject ):DisplayObject 
		{
			var class_name:String = getQualifiedClassName( displayObject );
			var definition:Class = getDefinitionByName( class_name ) as Class;
			return new definition() as DisplayObject;
		}*/
	}
}

