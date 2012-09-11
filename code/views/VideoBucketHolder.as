package code.views
{
	import code.views.HomeViewConstants;
	import code.views.VideoBucketConstants;
	import code.vo.FilmsVO;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class VideoBucketHolder extends MovieClip
	{
		private var videoBucket:VideoBucket;
		
		public function VideoBucketHolder()
		{		
		}		
		
		public function openSH2SnapTab(sh2SnapTab:Object):void
		{
			//trace(sh2SnapTab.name)
			
			switch(sh2SnapTab.name)
			{
				case VideoBucketConstants.SMART_START:
//					trace("StSm="+FilmsVO.smartStartMediaArr.length);
					//var myDuplicate:MovieClip = duplicateDisplayObject( videoBucket ) as MovieClip;
					attachVideoTiles(FilmsVO.smartStartMediaArr);
					break;
				
				case VideoBucketConstants.BEGINNER:
//					trace("Beginner="+FilmsVO.beginnerMediaArr.length);
					attachVideoTiles(FilmsVO.beginnerMediaArr);
					break;
				
				case VideoBucketConstants.INTERMEDIATE:
//					trace("Intermed="+FilmsVO.intermediateMediaArr.length);
					attachVideoTiles(FilmsVO.intermediateMediaArr);
					break;
				
				case VideoBucketConstants.ADVANCED:
//					trace("Adv="+FilmsVO.advancedMediaArr.length);
					attachVideoTiles(FilmsVO.advancedMediaArr);
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
			
			for(var i:uint=0;i<filmsArray.length;i++)
			{
				videoBucket = new VideoBucket();
				VideoBucketConstants.VIDEOBUCKET_ARRAY.push(videoBucket);
				videoBucket.x = startX;
				videoBucket.y = startY;
				this.addChild(videoBucket);
				startY = (videoBucket.height/2)+ VideoBucketConstants.VGAP+startY;
				
				if(i%2==1)
				{
					startX = (videoBucket.width/2)+VideoBucketConstants.HGAP+startX;
					startY = VideoBucketConstants.VIDEOTILE_Y;
				}					
			}			
		}
		
		/*private function duplicateDisplayObject( displayObject:DisplayObject ):DisplayObject 
		{
			var class_name:String = getQualifiedClassName( displayObject );
			var definition:Class = getDefinitionByName( class_name ) as Class;
			return new definition() as DisplayObject;
		}*/
	}
}

