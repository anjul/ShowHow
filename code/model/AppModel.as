package code.model
{
	import code.events.AppEvents;
	import code.services.BaseService;
	import code.services.ServiceConstants;
	import code.views.HomeView;
	import code.views.HomeViewConstants;
	import code.views.VideoPlayer;
	import code.vo.AppVO;
	import code.vo.FilmConstants;
	import code.vo.FilmVO;
	import code.vo.PreferencesVO;
	import code.vo.TagsVO;
	import code.vo.TextVO;
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
		
	public class AppModel extends BaseService
	{
		private static var objAppModel:AppModel;
		public var stageRef:Object;
		
		private var mediaXML:XML;
		private var preferenceXML:XML;
		private var tagXML:XML;
		private var textXML:XML;
		
		private var currentServiceID:String="mediaelements";
		public  var homeViewRef:HomeView;
		
		public static var AUTOPLAY_VIDEO_URL:String;
		public static var player:String="player/"
		public static var content:String="/content/"		
		public static var BASE_URL:String;
		public static var PID:String;
		public static var tagsArray:Array=[];
		public static var textArray:Array=[];
		
		private var prefPresenterOptionTxt:String;
		private var audioOptionTxt:String;
		private var audioAccent:String;
		private var textOption:String;
		
		private var preferencVO:PreferencesVO;
		private var tagsVO:TagsVO;
		private var textVO:TextVO;
		private var productName:String;	
			
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
		
		protected override function onProgress(evt:ProgressEvent):void
		{
			//trace((evt.bytesTotal/evt.bytesLoaded*100)+"%")
		}
		
		protected override function onResult(evt:Event):void
		{
			super.onResult(evt);
			var oXML:XML = XML(evt.target.data);
			//trace(oXML.name())
			var xmlID:String = oXML.name().toString() == "" ? currentServiceID : oXML.name().toString();
			var i:int;
			
			switch(xmlID)
			{				
				case ServiceConstants.FILMS_XML:
					mediaXML = oXML.copy();
					AppModel.AUTOPLAY_VIDEO_URL = AppModel.BASE_URL+AppModel.player+AppModel.PID+AppModel.content+mediaXML.teaser.@url.toString();
					
					for(i=0;i<mediaXML.chapterlist.chapter.length();i++)
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
					loadXML(ServiceConstants.FULL_PATH+ServiceConstants.PREFERENCES_XML_PATH);
					//trace("B>>"+FilmsVO.beginnerMediaArr.length+" I>>"+FilmsVO.intermediateMediaArr.length+" A>>"+FilmsVO.advancedMediaArr.length+" S>>"+FilmsVO.smartStartMediaArr.length)
					//loadXML(AppVO.BASEURL + ServiceConstants.TAGS_XML);
					break;
				
				case ServiceConstants.PREFERENCES_XML:
					preferenceXML = oXML.copy();					
					
					preferencVO = new PreferencesVO();					
					preferencVO.userPresenterId = preferenceXML.user.presenter.@id.toString();
					preferencVO.userAccentId = preferenceXML.user.accent.@id.toString();
					preferencVO.userAudioId = preferenceXML.user.audio.@id.toString();
					preferencVO.userTextId = preferenceXML.user.text.@id.toString();
										
					loadXML(ServiceConstants.FULL_PATH+ServiceConstants.TAGS_XML_PATH);
					break;
				
				case ServiceConstants.TAGS_XML:
					tagXML = oXML.copy();
					
					for(i=0;i<tagXML.tag.length();i++)
					{
						tagsVO = new TagsVO();
						tagsVO.label = tagXML.tag.label[i].toString();
						tagsVO.keyword = tagXML.tag.keyword[i].toString();
						tagsVO.count = tagXML.tag.count[i].toString();	
							
						tagsArray.push(tagsVO);
					}
					
					loadXML(ServiceConstants.FULL_PATH+ServiceConstants.TEXT_XML_PATH);
					break; 
				
				case ServiceConstants.TEXT_XML:
					textXML = oXML.copy();	
					
					for(i=0;i<textXML.chapter.length();i++)
					{
						textVO = new TextVO();
						textVO.chapterName = textXML.chapter.chaptername[i].toString();
						textVO.htmlText = textXML.chapter.htmltext[i].toString();
						
						textArray.push(textVO);
					}
					textVO.breadcrumbs=textXML.breadcrumbs[0].toString();
					textVO.productName=productName=textXML.productname[0].toString();
//					HomeViewConstants.homeBtn.productNameTxt.text=productName
					//trace(textVO.breadcrumbs+"---"+textVO.productName)	
					dispatchEvent(new AppEvents(AppEvents.INIT_XML_DATA_LOADED));
					break; 
			}				
		}
		
		public function getProductName():String
		{				
			return textVO.productName;
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
		
		public function getPresenterOptionText(value:int):String
		{		
			var index:int=value-1;
			prefPresenterOptionTxt = preferenceXML.presenter.option[index].@id == value.toString() ? preferenceXML.presenter.option[index].toString():"Default Text";
			return prefPresenterOptionTxt;
		}
		
		public function getAudioOptionText(value:int):String
		{		
			var index:int=value-1;
			audioOptionTxt = preferenceXML.audiooptions.option[index].@id == value.toString() ? preferenceXML.presenter.option[index].toString():"Default Text";
			return audioOptionTxt;
		}
		
		public function getAudioAccent(value:int):String
		{		
			var index:int=value-1;
			audioAccent = preferenceXML.audiooptions.option.accent[index].@id == value.toString() ? preferenceXML.presenter.option.accent[index].toString():"Default Text";
			return audioAccent;
		}
		
		public function getTextOption(value:int):String
		{		
			var index:int=value-1;
			textOption = preferenceXML.textoptions.option[index].@id == value.toString() ? preferenceXML.presenter.option[index].toString():"Default Text";
			return textOption;
		}
	}
}class SingletonEnforcer{}