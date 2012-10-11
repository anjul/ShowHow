package code.views
{		
	import code.component.Scrollbar;
	import code.events.AppEvents;
	import code.model.AppModel;
	import code.services.ServiceConstants;
	import code.vo.MetadataVO;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class TranscriptView extends MovieClip
	{		
		private var objAppModel:AppModel = AppModel.getInstance();
		private var defaultScaleX:Number=0;
		private var defaultScaleY:Number=0;
		private var objVideoPlayer:VideoPlayer = VideoPlayer.getInstance();
		private var videoURL:String;
		private var videoCount:int=0;
		private var chapterID:String;
		private var scroller:code.component.Scrollbar;
		private var fullTranscript:FullTranscriptWindow;
		private var seperator:Seperator;
		private var transcriptText:TextField;
		private var transcriptTextX:int = 0;
		private var transcriptTextY:int = 0;
		private var urlRequest:URLRequest;
		private var urlLoader:URLLoader;
		private var styleURL:String;
		private var sheet:StyleSheet = new StyleSheet();
		private var cssReady:Boolean = false;
		private var isLoaded:Boolean = true;
		private var transScroller:code.component.Scrollbar;
		
		public function TranscriptView()
		{
			configure();
			loadCSS();
		}
		
		private function configure():void
		{
			this.addChild(HomeViewConstants.transcriptWindow);	
			objVideoPlayer.addEventListener(AppEvents.PLAY_NEXT_VIDEO,playNextVideo);
			
			HomeViewConstants.transcriptWindow.height = HomeViewConstants.transcriptWindow.height-5;			
			defaultScaleX = HomeViewConstants.transcriptWindow.html_mc.scaleX;
			defaultScaleY = HomeViewConstants.transcriptWindow.html_mc.scaleY;
			scroller=new code.component.Scrollbar(HomeViewConstants.transcriptWindow.html_mc)
			this.addChild(scroller);
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
			//objVideoPlayer.playClicked(null,videoURL);
		}
		
		public function loadHtmlText(htmltext:String):void
		{			
			HomeViewConstants.transcriptWindow.html_mc.chapterTxt.htmlText = htmltext;
			HomeViewConstants.transcriptWindow.html_mc.chapterTxt.mouseWheelEnabled =  false;
			HomeViewConstants.transcriptWindow.product_txt.text = objAppModel.getProductName();
			HomeViewConstants.transcriptWindow.breadcrumTxt.text = objAppModel.getBreadcrumText();			
			handleToolPanel();
		}
		
		private function handleToolPanel():void
		{				
			HomeViewConstants.transcriptWindow.toolPanel.gotoAndPlay(2);
			var toolPanel:MovieClip = HomeViewConstants.transcriptWindow.toolPanel;
			toolPanel.transcript.addEventListener(MouseEvent.CLICK,toolPanelEvents);

			/*toolPanel.panel.plusSize.addEventListener(MouseEvent.CLICK,toolPanelEvents);
			toolPanel.panel.resetSize.addEventListener(MouseEvent.CLICK,toolPanelEvents);
			toolPanel.panel.minusSize.addEventListener(MouseEvent.CLICK,toolPanelEvents);*/
		}	
		
		private function toolPanelEvents(event:MouseEvent):void
		{
			trace(event.currentTarget.name+"<>"+event.currentTarget);			
			objAppModel.homeViewRef.displayWindow(true);			
		}
		
		public function displayFullTranscriptWindow(_fullTranscript:*):void
		{
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
		
		private function displayTranscript():void
		{
			fullTranscript.html_mc.alpha=1;
			if(isLoaded)
			{
				var startX:int = transcriptTextX;
				var startY:int = transcriptTextY;
				var gap:int = 120;
				//trace(">>"+fullTranscript.back2videoBtn)
				fullTranscript.back2videoBtn.addEventListener(MouseEvent.CLICK,closeWindow);			
				fullTranscript.productNameMC.productTxt.text = objAppModel.getProductName();
				
				for(var i:int=0;i<objAppModel.textArray.length;i++)
				{
					transcriptText = new TextField();
					transcriptText.htmlText = objAppModel.textArray[i].htmlText;
					transcriptText.selectable = false;
					
					fullTranscript.html_mc.addChild(transcriptText);
					transcriptText.styleSheet = sheet;
					transcriptText.autoSize = TextFieldAutoSize.LEFT;
					//transcriptText.antiAliasType =  AntiAliasType.ADVANCED;
					transcriptText.mouseWheelEnabled = false;
					transcriptText.multiline =true;
					transcriptText.wordWrap = true;
					//transcriptText.embedFonts = true;
	
					transcriptText.width = 700;
					transcriptText.y = startY;
					startY = startY + gap;
					
					//refArr.push(transcriptText);
					
					seperator = new Seperator();
					fullTranscript.html_mc.addChild(seperator);
					seperator.y =  transcriptText.y +gap;
					
					//refArr.push(seperator);
					
				}
				transScroller=new code.component.Scrollbar(fullTranscript.html_mc)
				fullTranscript.addChild(transScroller);
				transScroller.x =fullTranscript.html_mc.width+72;
				transScroller.y =transcriptTextY+45;
			}
			transScroller.alpha=1;
			isLoaded=false;

		}
		
		private function cssEvents(event:*):void
		{
			switch(event.type)
			{				
				case 'complete':
					sheet.parseCSS(urlLoader.data);
					cssReady = true;	 
					break;
				
				case 'ioError':
					trace("IO Error or Bad File name error");
					break;
				
				default:
					trace("Desired Event Not Found");
					break;
			}
		}
		
		private function playNextVideo(event:AppEvents):void
		{
			videoCount++;
			
			trace("Playing Next Video from playlist");
			
			if(videoCount>=objAppModel.textArray.length)
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
		
		private function closeWindow(event:MouseEvent):void
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