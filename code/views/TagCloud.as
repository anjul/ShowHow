package code.views
{
	import code.events.AppEvents;
	import code.model.AppModel;
	import code.model.TagCloudModel;
	import code.services.ServiceConstants;
	import code.views.HomeViewConstants;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TagCloud
	{
		private var objAppModel:AppModel = AppModel.getInstance();
		private var refTagCloudMc:Object = HomeViewConstants.welcomeMC.InformationCloud_mc;
		
		private var xPos:int = 0;
		private var yPos:int = 0;
		private var maxWidth:int = 0;
		private var maxHeight:int = 0;
		private var tagFullX:int = 0;
		private var tagFullY:int = 73;
		
		private var rowList:Array = [];	
		private var requestedVideoURL:String;
		private var cloudMenuMc:CloudMenu_mc;	
		private var objVideoPlayer:VideoPlayer=VideoPlayer.getInstance();
		private var objTagCloudModel:TagCloudModel=TagCloudModel.getInstance();
			
		public function TagCloud()
		{
			initTagCloud();	
		}
		
		private function initTagCloud():void
		{
			for (var i:Number = 0; i<objAppModel.tagsArray.length; i++)
			{		
				cloudMenuMc = new  CloudMenu_mc();	
				refTagCloudMc.addChild(cloudMenuMc);
				cloudMenuMc.tempText = objAppModel.tagsArray[i].label;
				var fontSize:String =  objAppModel.tagsArray[i].count;
							
				var styles:StyleSheet = new StyleSheet();
				styles.setStyle("body",{fontFamily:'Arial'});			
				styles.setStyle("link",{fontSize:fontSize});
				styles.setStyle("over",{fontSize:fontSize,textDecoration:"underline",color:"#FF9C00"});
							
				cloudMenuMc.label_txt.autoSize = TextFieldAutoSize.LEFT;
				cloudMenuMc.label_txt.multiline = false;
				cloudMenuMc.label_txt.wordWrap = false;
				cloudMenuMc.label_txt.selectable = true;			
				cloudMenuMc.label_txt.styleSheet = styles;
				cloudMenuMc.label_txt.htmlText = "<link>"+objAppModel.tagsArray[i].label+"</link>";
				
				cloudMenuMc.x = xPos + 5;
				cloudMenuMc.y = yPos;			
				
				maxHeight = (maxHeight < cloudMenuMc.height) ? cloudMenuMc.height : maxHeight;
				
				if ((cloudMenuMc.x + cloudMenuMc.width + 5) >= (refTagCloudMc.content_mc.width))
				{			
					xPos = 0;
					yPos += maxHeight;
					rowList = AdjustRow(rowList, yPos);
					
					cloudMenuMc.x = xPos + 5;
					cloudMenuMc.y = yPos;
					
					maxHeight = 0;
					maxHeight = (maxHeight < cloudMenuMc.height) ? cloudMenuMc.height : maxHeight;
				}			
				
				xPos += cloudMenuMc.width;	
				
				cloudMenuMc.buttonMode = true;
				
				cloudMenuMc.addEventListener(MouseEvent.CLICK,tagEvents);
				cloudMenuMc.addEventListener(MouseEvent.ROLL_OVER,tagEvents);
				cloudMenuMc.addEventListener(MouseEvent.ROLL_OUT,tagEvents);
				cloudMenuMc.mouseChildren=false;
				
				rowList.push(cloudMenuMc);	
				objTagCloudModel.addEventListener(AppEvents.INIT_XML_DATA_LOADED,xmlDataLoaded);
				objTagCloudModel.addEventListener(AppEvents.XML_DATA_LOAD_FAILURE,xmlDataLoadFailure);
			}
			
			HomeViewConstants.smartStartMC.tag_full.back2videoBtn_mc.buttonMode=true;
			HomeViewConstants.smartStartMC.tag_full.back2videoBtn_mc.addEventListener(MouseEvent.CLICK,backButtonHandler);			
			
			yPos += maxHeight;
			rowList = AdjustRow(rowList, yPos);
		}
				
		private function AdjustRow(rowList:Array, maxHeight:Number):Array
		{		
			for (var i = 0; i < rowList.length; i++)
			{
				rowList[i]._y = maxHeight - rowList[i]._height;
			}			
			return [];
		}
		
		private function tagEvents(event:MouseEvent):void
		{
			switch(event.type)
			{
				case 'click':					
					objVideoPlayer.controlVideoPlayBack(false);	// Pausing Video Player
					HomeViewConstants.smartStartMC.tag_full.gotoAndPlay(2);
					HomeViewConstants.smartStartMC.tag_full.mouseChildren=true;
					var tagName:String = event.currentTarget.tempText;					
					objTagCloudModel.loadXML(ServiceConstants.FULL_PATH+ServiceConstants.TAG_XML_PATH+tagName);					
				break;
				case 'rollOver':
					event.currentTarget.label_txt.htmlText = "<over>"+event.currentTarget.tempText+"</over>";
				break;
				case 'rollOut':
					event.currentTarget.label_txt.htmlText = "<link>"+event.currentTarget.tempText+"</link>";
				break;
			}			
		}
		
		private function xmlDataLoaded(event:AppEvents):void
		{
			var obj:Object = new Object();
			obj.name = "tagCloud";
			obj.tag_full = HomeViewConstants.smartStartMC.tag_full;
			objAppModel.homeViewRef.attachVideoBucket(obj)
		}
		
		private function xmlDataLoadFailure(event:AppEvents):void
		{
			trace("Requested Cloud data load faliure");
		}
		
		private function backButtonHandler(event:MouseEvent):void
		{			
			HomeViewConstants.smartStartMC.tag_full.addEventListener(Event.ENTER_FRAME,frameUpdate)
			if(objAppModel.homeViewRef.contains(HomeViewConstants.refVideoBucket))
			{
				objAppModel.homeViewRef.removeChild(HomeViewConstants.refVideoBucket)
			}
			HomeViewConstants.smartStartMC.tag_full.totalResultTxt.text=HomeViewConstants.smartStartMC.tag_full.currentPageTxt.text="";
			HomeViewConstants.refVideoBucket=null;
			if(VideoBucketConstants.scrollBtnRef[0]!=null && VideoBucketConstants.scrollBtnRef[1]!=null)
			{
				VideoBucketConstants.scrollBtnRef[0].visible=false
				VideoBucketConstants.scrollBtnRef[1].visible=false
			}
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