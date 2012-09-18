package code.views
{
	import code.model.AppModel;
	import code.views.HomeViewConstants;
	
	import flash.display.MovieClip;
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
		private var rowList:Array = [];	
		private var cloudMenuMc:CloudMenu_mc;		
			
		public function TagCloud()
		{
			initTagCloud();	
		}
		
		private function initTagCloud():void
		{
			for (var i:Number = 0; i<AppModel.tagsArray.length; i++)
			{		
				cloudMenuMc = new  CloudMenu_mc();	
				refTagCloudMc.addChild(cloudMenuMc);
				
				var fontSize:String =  AppModel.tagsArray[i].count;
				
				var tf:TextFormat = new TextFormat();
				tf.font = 'verdana';
				tf.color ='0xFF000000';
				tf.size = fontSize;
				
				/*var style:StyleSheet = new StyleSheet();
				style.setStyle("body",{fontFamily:'Arial'});			
				style.setStyle("link",{fontSize:fontSize,color:"#FFFFFF"});
				style.setStyle("over",{fontSize:fontSize,textDecoration:"underline",color:"#FF9C00"});*/
							
				cloudMenuMc.label_txt.autoSize = TextFieldAutoSize.LEFT;
				cloudMenuMc.label_txt.multiline = false;
				cloudMenuMc.label_txt.wordWrap = false;
				cloudMenuMc.label_txt.selectable = true;	
				cloudMenuMc.label_txt.defaultTextFormat = tf;
//				cloudMenuMc.label_txt.styleSheet = style;
				cloudMenuMc.label_txt.htmlText = "<link>"+ AppModel.tagsArray[i].label+"</link>";
				
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
				
				cloudMenuMc.addEventListener(MouseEvent.CLICK,onTagClicked);
				cloudMenuMc.mouseChildren=false;
				
				/*mc.onRollOver = function()
				{				
					this.label_txt.htmlText = "<over>" + this["TEXT"] + "</over>";
				}
				
				mc.onRollOut = mc.onReleaseOutside = function() 
				{			
					this.label_txt.htmlText = "<link>" + this["TEXT"] + "</link>";
				}			
				
				mc.onRelease = function() 
				{			
					this._this.showHideTag(this.keyword);
				}*/
				
				rowList.push(cloudMenuMc);	
			}
			
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
		
		private function onTagClicked(event:MouseEvent):void
		{
			trace("Tag Clicked")
		}
	}
}