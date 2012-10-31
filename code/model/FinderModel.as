package code.model
{
	import code.events.AppEvents;
	import code.services.BaseService;
	import code.vo.FilmConstants;
	import code.vo.FilmVO;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	public class FinderModel extends BaseService
	{
		private static var objFinderModel:FinderModel;
		
		public function FinderModel(singletonEnf:SingletonEnforcer)
		{
			if(singletonEnf == null)
			{
				throw new Error("You can't use "+this+" Class constructor to instantiate object, Use getInstance() instead.")
			}
		}
		
		public static function getInstance():FinderModel
		{
			if(objFinderModel==null)
			{
				objFinderModel=new FinderModel(new SingletonEnforcer());
			}
			return objFinderModel;
		}
		
		protected override function onProgress(evt:ProgressEvent):void
		{
			trace((evt.bytesTotal/evt.bytesLoaded*100)+"%")
		}
		
		protected override function onResult(evt:Event):void
		{
			super.onResult(evt);
			var mediaXML:XML = XML(evt.target.data);
			FilmConstants.finderMediaArray = [];
			if(mediaXML.chapterlist.chapter.length()>0)
			{
				for(var index:uint=0;index<mediaXML.chapterlist.chapter.length();index++)
				{
					var filmVO:FilmVO = new FilmVO();
					filmVO.chapterID = mediaXML.chapterlist.chapter.@id[index].toString();
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
					
					FilmConstants.finderMediaArray.push(filmVO);
				}
				dispatchEvent(new AppEvents(AppEvents.INIT_XML_DATA_LOADED));
			}
			else{
				trace("Search Text Doesn't found")
				dispatchEvent(new AppEvents(AppEvents.SEARCH_NOT_FOUND));
			}
		}			
	}
}class SingletonEnforcer{}