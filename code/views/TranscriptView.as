package code.views
{		
	import code.component.VScrollbar;
	import code.events.AppEvents;
	import code.model.AppModel;
	import code.services.ServiceConstants;
	import code.vo.MetadataVO;
	import code.vo.TextVO;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class TranscriptView extends MovieClip
	{		
		private var objAppModel:AppModel = AppModel.getInstance();
		private var defaultScaleX:Number=0;
		private var defaultScaleY:Number=0;
		private var objVideoPlayer:VideoPlayer = VideoPlayer.getInstance();
		private var videoURL:String;
		private var videoCount:int = 0;
		private var chapterID:String;
		private var scroller:VScrollbar;
		private var transScroller:VScrollbar;
		private var fullTranscript:FullTranscriptWindow;
		private var seperator:Seperator;
		private var transcriptText:TextField;
		private var transcriptTitleText:TextField;
		private var miniTranscriptText:TextField;
		private var transcriptTextX:int = 0;
		private var transcriptTextY:int = 0;
		private var urlRequest:URLRequest;
		private var urlLoader:URLLoader;
		private var styleURL:String;
		private var sheet:StyleSheet = new StyleSheet();
		private var cssReady:Boolean = false;
		private var isLoaded:Boolean = true;
		private var playButton:PlayButtonIcon;	
		private var startX:int = 0;
		private var startY:int = 0;
		private var gap:int = 3;
		private var listScroller:VScrollbar;
		private var textClipVector:Vector.<TextField>; 
		private var textClipVector2:Vector.<TextField>; 
		private const GREEN:uint = 0x56D85A;
		private const INDIGO:uint = 0x56BAD8;
		
		public function TranscriptView()
		{
			loadCSS();
		}
		
		private function loadCSS():void
		{
			styleURL = objAppModel.baseURL+ServiceConstants.STYLESHEET;
			urlRequest = new URLRequest();
			urlRequest.url =  styleURL; 
			
			urlLoader = new URLLoader();
			urlLoader.load(urlRequest);
			
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, cssEvents);
			urlLoader.addEventListener(Event.COMPLETE, cssEvents);		
		}
		
		private function cssEvents(event:*):void
		{
			switch(event.type)
			{				
				case 'complete':
					sheet.parseCSS(urlLoader.data);
					cssReady = true;	 
					createTextField();
					break;
				
				case 'ioError':
					trace("IO Error or Bad File name error");
					break;
				
				default:
					trace("Desired Event Not Found");
					break;
			}
		}
		
		private function createTextField():void			
		{
			miniTranscriptText = new TextField();
			miniTranscriptText.multiline = true;
			miniTranscriptText.wordWrap = true;	
			miniTranscriptText.autoSize = TextFieldAutoSize.LEFT;
			miniTranscriptText.styleSheet = sheet;					
			miniTranscriptText.selectable = true;
			miniTranscriptText.width = 400;					
			HomeViewConstants.transcriptWindow.html_mc.addChild(miniTranscriptText);
			
			configure();
		}
		
		private function configure():void
		{
			this.addChild(HomeViewConstants.transcriptWindow);	
			objVideoPlayer.addEventListener(AppEvents.PLAY_NEXT_VIDEO,playNextVideo);			
		}
		
		public function playVideo():void
		{
			chapterID  = objAppModel.textArray[videoCount].chapterID;
			var url:String = objAppModel.getvideoURL(chapterID);
			videoURL = objAppModel.baseURL+objAppModel.player+objAppModel.pid+objAppModel.content+url;
			
			if(videoURL!=null)
			{
				objVideoPlayer.doPlayNext(videoURL,true);
			}
			loadHtmlText(objAppModel.getHtmlText(chapterID));
			HomeViewConstants.transcriptWindow.toolPanel.play();
		}
		
		public function loadHtmlText(htmltext:String):void
		{				
			miniTranscriptText.htmlText = htmltext;
			miniTranscriptText.mouseWheelEnabled =  true;
			miniTranscriptText.height  = miniTranscriptText.textHeight;
			
			if(scroller == null)
			{
				scroller = new VScrollbar();
				this.addChild(scroller);	
				scroller.configure = HomeViewConstants.transcriptWindow.html_mc;
			}
			else{
				this.removeChild(scroller);
				scroller = null;
				
				scroller = new VScrollbar();
				this.addChild(scroller);	
				scroller.configure = HomeViewConstants.transcriptWindow.html_mc;
			}		
			
			HomeViewConstants.transcriptWindow.product_txt.text = objAppModel.getProductName();
			HomeViewConstants.transcriptWindow.breadcrumTxt.text = objAppModel.getBreadcrumText();			
			handleToolPanel();
		}
		
		private function handleToolPanel():void
		{				
			HomeViewConstants.transcriptWindow.toolPanel.gotoAndPlay(2);
			var toolPanel:MovieClip = HomeViewConstants.transcriptWindow.toolPanel;
			toolPanel.transcriptBtn.addEventListener(MouseEvent.CLICK,toolPanelEvents);
			toolPanel.printBtn.addEventListener(MouseEvent.CLICK,toolPanelEvents);
			toolPanel.referItBtn.addEventListener(MouseEvent.CLICK,toolPanelEvents);
			toolPanel.favouriteBtn.addEventListener(MouseEvent.CLICK,toolPanelEvents);
			

			/*toolPanel.panel.plusSize.addEventListener(MouseEvent.CLICK,toolPanelEvents);
			toolPanel.panel.resetSize.addEventListener(MouseEvent.CLICK,toolPanelEvents);
			toolPanel.panel.minusSize.addEventListener(MouseEvent.CLICK,toolPanelEvents);*/
		}	
		
		private function toolPanelEvents(event:MouseEvent):void
		{
			//trace(event.currentTarget.name+"<>"+event.currentTarget);			
			
			switch(event.currentTarget.name)
			{
				case "transcriptBtn":
					objAppModel.homeViewRef.displayWindow(true);
				break;
				case "printBtn":
					
				break;
				case "referItBtn":
					
					break;
				case "favouriteBtn":
					
				break;
			}
			//objAppModel.homeViewRef.displayWindow(true);			
		}
		
		public function displayFullTranscriptWindow(_fullTranscript:*):void
		{
			objVideoPlayer.controlVideoPlayBack(false);	
			
			this.fullTranscript = _fullTranscript;
			fullTranscript.gotoAndPlay(2);			
			fullTranscript.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
		}
		
		private function enterFrameHandler(event:Event):void
		{
			if(event.currentTarget.currentFrame==65)
			{
				fullTranscript.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
				displayTranscript();
			}
		}
		
		private function displayTranscript():void
		{
			fullTranscript.html_mc.alpha=1;
			if(isLoaded)
			{
				var startX:int = transcriptTextX;
				var startY:int = transcriptTextY;
				var sepY:int = 0;
				var gap:int = 20;
				
				fullTranscript.back2videoBtn.buttonMode = true;
				fullTranscript.back2videoBtn.addEventListener(MouseEvent.CLICK,closeWindow);			
				fullTranscript.productNameMC.productTxt.text = objAppModel.getProductName();
				
				textClipVector = new Vector.<TextField>();
				for(var i:int=0;i<objAppModel.textArray.length;i++)
				{
					var textVO:TextVO = TextVO(objAppModel.textArray[i]);
					
					transcriptText = new TextField();
					transcriptText.multiline = true;
					transcriptText.wordWrap = true;	
					transcriptText.autoSize = TextFieldAutoSize.LEFT;
					transcriptText.styleSheet = sheet;					
					transcriptText.selectable = true;																
					transcriptText.mouseWheelEnabled = true;					
					transcriptText.width = 650;						
					transcriptText.htmlText = textVO.htmlText;			
					transcriptText.height = transcriptText.textHeight;
					transcriptText.y = startY;
					fullTranscript.html_mc.addChild(transcriptText);
					startY = startY+transcriptText.textHeight+gap;
					
					textClipVector.push(transcriptText);
					//Attatching Play Button
					
					playButton = new PlayButtonIcon();
					playButton.x = transcriptText.width+10;
					playButton.y = transcriptText.y;
					playButton.buttonMode = true;
					
					playButton.videoURL = objAppModel.getvideoURL(textVO.chapterID);
					playButton.htmlText = textVO.htmlText;
					
					playButton.addEventListener(MouseEvent.CLICK,playTranscript);
					fullTranscript.html_mc.addChild(playButton);
					
					seperator = new Seperator();
					seperator.y =  startY;		
					
					startY = seperator.y+gap;
					fullTranscript.html_mc.addChild(seperator);					
				}
				
				transScroller = new VScrollbar();
				transScroller.configure = fullTranscript.html_mc
				fullTranscript.addChild(transScroller);
				transScroller.x = fullTranscript.html_mc.width+72;
				transScroller.y = transcriptTextY+45;
			}
			transScroller.alpha = 1;
			isLoaded=false;
			displayTranscriptTitles()
		}
		
		private function displayTranscriptTitles():void
		{
			var sx:int = startX;
			var sy:int = startY;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "Arial";
			textFormat.size = 10;
			
			var textClip:MovieClip;
			textClipVector2 = new Vector.<TextField>();
			for(var i:uint=0;i<objAppModel.textArray.length;i++)
			{
				var textVO:TextVO = TextVO(objAppModel.textArray[i]);
				
				var titleText:TextField = new TextField();				
				titleText.defaultTextFormat = textFormat;
				titleText.textColor = INDIGO;
				titleText.multiline = true;
				titleText.wordWrap = true;	
				titleText.autoSize = TextFieldAutoSize.LEFT;
				titleText.text = textVO.chapterName;
				titleText.selectable = false;
				titleText.width = 130;
				titleText.height = 35;
				titleText.x = sx;
				titleText.y = sy;
				
				textClipVector2.push(titleText);
				
				textClip = new MovieClip();
				textClip.addChild(titleText);
				textClip.buttonMode = true;
				textClip.mouseChildren = false;
				textClip.title = titleText;
				//textClip.videoURL = array[i].videoURL;
				textClip.chapterID = textVO.chapterID;
				textClip.id = i;
				textClip.addEventListener(MouseEvent.CLICK,playButton_Handler);
				
				/*var seperator:Shape = new Shape();
				seperator.graphics.lineStyle(1, 0xBDBDBD, 1);
				seperator.graphics.moveTo(titleText.x,titleText.height+5);
				seperator.graphics.lineTo(titleText.width,titleText.height+5);				
				textClip.addChild(seperator);*/
				
				fullTranscript.listView.html_mc.addChild(textClip);
				sy = sy + titleText.height + gap;
			}
			listScroller = new VScrollbar(true);
			fullTranscript.listView.addChild(listScroller);	
			listScroller.configure = fullTranscript.listView.html_mc;
		}
		
		private function playButton_Handler(event:MouseEvent):void
		{
			var scrollY:int = getSelectedTextClipPosition(event.currentTarget.id);	
			fullTranscript.html_mc.y = -scrollY+120;		
			
			event.currentTarget.title.textColor = GREEN;
			
			//Setting Color Blue to Non Selected Texts
			for(var i:int=0;i<textClipVector2.length;i++)
			{
				if(event.currentTarget.id != i)
				{
					textClipVector2[i].textColor =  INDIGO;
				}
			}	
		}
		
		
		private function getSelectedTextClipPosition(index:int):int
		{
			return textClipVector[index].y;
		}
		
		private function playTranscript(event:MouseEvent):void
		{
			var currentVideoURL:String = objAppModel.baseURL
				+objAppModel.player+objAppModel.pid
				+objAppModel.content
				+event.currentTarget.videoURL;
			var currentTranscript:String = event.currentTarget.htmlText;
			
			closeWindow();
			objVideoPlayer.playClicked(null,currentVideoURL);
			loadHtmlText(currentTranscript);
		}
		
		private function playNextVideo(event:AppEvents):void
		{
			videoCount++;
			
			trace("Playing Next Video from playlist");
			
			if(videoCount >= objAppModel.textArray.length)
			{
				videoCount=0;
			}
			
			var url:String = objAppModel.getvideoURL(objAppModel.textArray[videoCount].chapterID);
			videoURL = objAppModel.baseURL+objAppModel.player+objAppModel.pid+objAppModel.content+url;
			
			if(videoURL!=null)
			{
				objVideoPlayer.doPlayNext(videoURL,true);
				loadHtmlText(objAppModel.getHtmlText(objAppModel.textArray[videoCount].chapterID));
			}
		}
		
		private function closeWindow(event:MouseEvent=null):void
		{
			fullTranscript.html_mc.alpha=0;
			transScroller.alpha=0;
			fullTranscript.addEventListener(Event.ENTER_FRAME,exitFrameHandler);
		}
		
		private function exitFrameHandler(event:Event):void
		{			
			event.currentTarget.prevFrame();
			if(event.currentTarget.currentFrame==1)
			{
				fullTranscript.removeEventListener(Event.ENTER_FRAME,exitFrameHandler);
				fullTranscript.visible=false;
			}
		}
	}
}