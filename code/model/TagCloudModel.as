package code.model
{
	import code.events.AppEvents;
	import code.services.BaseService;
	import code.vo.FilmConstants;
	import code.vo.FilmVO;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	public class TagCloudModel extends BaseService
	{
		private static var objTagCloudModel:TagCloudModel;
		
		public function TagCloudModel(singletonEnf:SingletonEnforcer)
		{
			if(singletonEnf == null)
			{
				throw new Error("You can't use "+this+" Class constructor to instantiate object, Use getInstance() instead.")
			}
		}
		
		public static function getInstance():TagCloudModel
		{
			if(objTagCloudModel==null)
			{
				objTagCloudModel=new TagCloudModel(new SingletonEnforcer());
			}
			return objTagCloudModel;
		}
		
		protected override function onProgress(evt:ProgressEvent):void
		{
			trace((evt.bytesTotal/evt.bytesLoaded*100)+"%")
		}
		
		protected override function onResult(evt:Event):void
		{
			super.onResult(evt);
			var mediaXML:XML = XML(evt.target.data);
			FilmConstants.tagMediaArray = [];
			
			for(var index:uint=0;index<mediaXML.chapterlist.chapter.length();index++)
			{
				var filmVO:FilmVO = new FilmVO();
				filmVO.videoTitle = mediaXML.chapterlist.chapter.result[index].title.toString();
				filmVO.description = mediaXML.chapterlist.chapter.result[index].description.toString();
				filmVO.image_url = mediaXML.chapterlist.chapter.result[index].image.@url.toString();
				filmVO.duration = mediaXML.chapterlist.chapter.result[index].duration.@time.toString();
				filmVO.pr_name = mediaXML.chapterlist.chapter.result[index].title.pr_name.toString();
				filmVO.sef_title = mediaXML.chapterlist.chapter.result[index].sef_title.toString();
				
				filmVO.presenterTitle = mediaXML.chapterlist.chapter.presenter[index].@text.toString();
				filmVO.presenterID = mediaXML.chapterlist.chapter.presenter[index].@id.toString();
				filmVO.videoURL = mediaXML.chapterlist.chapter.presenter[index].video.@url.toString();
				
				filmVO.audioID = mediaXML.chapterlist.chapter.presenter[index].audio.option.@id.toString();
				filmVO.audioURL = mediaXML.chapterlist.chapter.presenter[index].audio.option.@url.toString();
				filmVO.optionText = mediaXML.chapterlist.chapter.presenter[index].audio.option.@text.toString();
				
				FilmConstants.tagMediaArray.push(filmVO);
			}
			dispatchEvent(new AppEvents(AppEvents.INIT_XML_DATA_LOADED));
		}			
	}
}class SingletonEnforcer{}