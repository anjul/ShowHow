package code.model
{
	import code.services.BaseService;
	import code.services.ServiceConstants;
	import code.views.VideoPlayer;
	import code.vo.AppVO;
	import code.vo.FilmConstants;
	import code.vo.FilmVO;
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
		
	public class AppModel extends BaseService
	{
		private static var objAppModel:AppModel;
		public var stageRef:Object;
		private var mediaXML:XML;
		private var currentServiceID:String="mediaelements";
		public static var AUTOPLAY_VIDEO_URL:String;
		
		public function AppModel(singletonEnf:SingletonEnforcer)
		{
			if(singletonEnf == null)
			{
				throw new Error("You can't use "+this+" Class constructor to instantiate object, Use getInstance() instead.")
			}
		}
		
		public static function getInstance():AppModel
		{
			if(objAppModel == null)
			{
				objAppModel = new AppModel(new SingletonEnforcer());
			}
			return objAppModel;
		}
		
		public function tweenManager(target:Object,duration:Number,vars:Object):TweenLite
		{
			var myTween:TweenLite = new TweenLite(target, duration, vars);
			return myTween;			
		}
		
		protected override function onResult(evt:Event):void
		{
			super.onResult(evt);
			var oXML:XML = XML(evt.target.data);
			//trace(oXML.name())
			var xmlID:String = oXML.name().toString() == "" ? currentServiceID : oXML.name().toString();
			
			switch(xmlID)
			{
				case ServiceConstants.FILMS_XML:
					mediaXML = oXML.copy();
					AppModel.AUTOPLAY_VIDEO_URL = mediaXML.teaser.@url.toString();
					
					for(var i:int=0;i<mediaXML.chapterlist.chapter.length();i++)
					{
						var strSplit = mediaXML.chapterlist.chapter.@level[i].toString().split(',');
												
						if(strSplit[0]==FilmConstants.LEVEL_BEGINNER || strSplit[1]==FilmConstants.LEVEL_BEGINNER)
						{
							contentPush(FilmConstants.LEVEL_BEGINNER,i);
						}
						
						if(strSplit[0]==FilmConstants.LEVEL_SMARTSTART || strSplit[1]==FilmConstants.LEVEL_SMARTSTART)
						{
							contentPush(FilmConstants.LEVEL_SMARTSTART,i);
						} 
						
						if(strSplit[0]==FilmConstants.LEVEL_INTERMEDIATE || strSplit[1]==FilmConstants.LEVEL_INTERMEDIATE)
						{
							contentPush(FilmConstants.LEVEL_INTERMEDIATE,i);
						} 
						
						if(strSplit[0]==FilmConstants.LEVEL_ADVANCED || strSplit[1]==FilmConstants.LEVEL_ADVANCED)
						{
							contentPush(FilmConstants.LEVEL_ADVANCED,i);
						}
					}
					//trace("B>>"+FilmsVO.beginnerMediaArr.length+" I>>"+FilmsVO.intermediateMediaArr.length+" A>>"+FilmsVO.advancedMediaArr.length+" S>>"+FilmsVO.smartStartMediaArr.length)
					//loadXML(AppVO.BASEURL + ServiceConstants.TAGS_XML);
					break;
			}				
		}
		
		private function contentPush(mediaLevel:String,index:uint):void
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
				
			if(mediaLevel==FilmConstants.LEVEL_BEGINNER)
			{
				FilmConstants.beginnerMediaArr.push(filmVO);		
			}
			else if(mediaLevel==FilmConstants.LEVEL_INTERMEDIATE)
			{
				FilmConstants.intermediateMediaArr.push(filmVO);
			}
			else if(mediaLevel==FilmConstants.LEVEL_SMARTSTART)
			{
				FilmConstants.smartStartMediaArr.push(filmVO);
			}
			else if(mediaLevel==FilmConstants.LEVEL_ADVANCED)
			{
				FilmConstants.advancedMediaArr.push(filmVO);
			}
		}
	}
}class SingletonEnforcer{}