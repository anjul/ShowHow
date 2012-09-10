package code.model
{
	import code.services.BaseService;
	import code.services.ServiceConstants;
	import code.vo.AppVO;
	import code.vo.FilmsVO;
	import com.greensock.TweenLite;
	
	import flash.events.Event;
		
	public class AppModel extends BaseService
	{
		private static var objAppModel:AppModel;
		public var stageRef:Object;
		private var mediaXML:XML;
		private var currentServiceID:String="mediaelements";
		
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
					for(var i:uint=0;i<mediaXML.chapterlist.chapter.length();i++)
					{
						var strSplit = mediaXML.chapterlist.chapter.@level[i].toString().split(',');
												
						if(strSplit[0]==FilmsVO.LEVEL_BEGINNER || strSplit[1]==FilmsVO.LEVEL_BEGINNER)
						{
							contentPush(FilmsVO.LEVEL_BEGINNER,i);
						}
						
						if(strSplit[0]==FilmsVO.LEVEL_SMARTSTART || strSplit[1]==FilmsVO.LEVEL_SMARTSTART)
						{
							contentPush(FilmsVO.LEVEL_SMARTSTART,i);
						} 
						
						if(strSplit[0]==FilmsVO.LEVEL_INTERMEDIATE || strSplit[1]==FilmsVO.LEVEL_INTERMEDIATE)
						{
							contentPush(FilmsVO.LEVEL_INTERMEDIATE,i);
						} 
						
						if(strSplit[0]==FilmsVO.LEVEL_ADVANCED || strSplit[1]==FilmsVO.LEVEL_ADVANCED)
						{
							contentPush(FilmsVO.LEVEL_ADVANCED,i);
						}
					}
					trace("B>>"+FilmsVO.beginnerMediaArr.length+" I>>"+FilmsVO.intermediateMediaArr.length+" A>>"+FilmsVO.advancedMediaArr.length+" S>>"+FilmsVO.smartStartMediaArr.length)
					//loadXML(AppVO.BASEURL + ServiceConstants.TAGS_XML);
					break;
			}				
		}
		
		private function contentPush(mediaLevel:String,index:uint):void
		{			
			FilmsVO.objResult.title = mediaXML.chapterlist.chapter.result[index].title.toString();
			FilmsVO.objResult.description = mediaXML.chapterlist.chapter.result[index].description.toString();
			FilmsVO.objResult.image = mediaXML.chapterlist.chapter.result[index].image.@url.toString();
			FilmsVO.objResult.duration = mediaXML.chapterlist.chapter.result[index].duration.@time.toString();
			FilmsVO.objResult.pr_name = mediaXML.chapterlist.chapter.result[index].title.pr_name.toString();
			FilmsVO.objResult.sef_title = mediaXML.chapterlist.chapter.result[index].sef_title.toString();
			
			FilmsVO.objResult.title = mediaXML.chapterlist.chapter.presenter[index].@text;
			FilmsVO.objResult.presenterID = mediaXML.chapterlist.chapter.presenter[index].@id; 
			FilmsVO.objResult.videoURL = mediaXML.chapterlist.chapter.presenter[index].video.@url; 
			
			FilmsVO.objResult.audioID = mediaXML.chapterlist.chapter.presenter[index].audio.option.@id; 
			FilmsVO.objResult.audioURL = mediaXML.chapterlist.chapter.presenter[index].audio.option.@url; 
			FilmsVO.objResult.optionText = mediaXML.chapterlist.chapter.presenter[index].audio.option.@text; 
				
			if(mediaLevel==FilmsVO.LEVEL_BEGINNER)
			{
				FilmsVO.beginnerMediaArr.push(FilmsVO.objResult);
			}else if(mediaLevel==FilmsVO.LEVEL_INTERMEDIATE)
			{
				FilmsVO.intermediateMediaArr.push(FilmsVO.objResult);
			}else if(mediaLevel==FilmsVO.LEVEL_SMARTSTART)
			{
				FilmsVO.smartStartMediaArr.push(FilmsVO.objResult);
			}else if(mediaLevel==FilmsVO.LEVEL_ADVANCED)
			{
				FilmsVO.advancedMediaArr.push(FilmsVO.objResult);
			}
		}
	}
}class SingletonEnforcer{}