package code.views
{		
	import code.component.Scrollbar;
	import code.events.AppEvents;
	import code.model.AppModel;
	import code.vo.MetadataVO;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

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
		
		public function TranscriptView()
		{
			configure();
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
			videoURL = AppModel.BASE_URL+AppModel.player+AppModel.PID+AppModel.content+url;
			
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
			trace(event.currentTarget.name+"<>"+event.currentTarget)
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
			videoURL = AppModel.BASE_URL+AppModel.player+AppModel.PID+AppModel.content+url;
			
			if(videoURL!=null)
			{
				objVideoPlayer.doPlayNext(videoURL,true);
				loadHtmlText(objAppModel.getHtmlText(objAppModel.textArray[videoCount].chapterID));
			}
		}
	}
}