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
	import code.vo.MetadataVO;
	import code.vo.PreferencesVO;
	import code.vo.TagsVO;
	import code.vo.TextVO;
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
		
	public class AppModel extends BaseService
	{
		private static var objAppModel:AppModel;
		public var stageRef:Object;
		
		private var mediaXML:XML;
		private var preferenceXML:XML;
		private var tagXML:XML;
		private var textXML:XML;
		private var metadataXML:XML;
		
		private var currentServiceID:String="mediaelements";
		public  var homeViewRef:HomeView;
		
		public var autoPlayVideoURL:String;
		public var player:String="player/"
		public var content:String="/content/"		
		public var baseURL:String;
		public var pid:String;
		public var tagsArray:Array=[];
		public var textArray:Array=[];
		public var metadataArray:Array=[];
		
		private var prefPresenterOptionTxt:String;
		private var audioOptionTxt:String;
		private var audioAccent:String;
		private var textOption:String;
		
		private var preferencVO:PreferencesVO;
		private var tagsVO:TagsVO;
		private var textVO:TextVO;
		private var metadataVO:MetadataVO;
		private var productName:String;	
		public var count=0;
		private var percentageCount:int=0;
		private var loadingPercentage:int=0;
			
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
		
		protected override function onProgress(event:ProgressEvent):void
		{
			var percentage:int = (Math.ceil((event.bytesLoaded/event.bytesTotal))/4);			
			loadingPercentage = percentageCount+percentage;
			objAppModel.stageRef.preloadingClip.loaderText.text = loadingPercentage.toString()+"%";
		}
		
		protected override function onResult(evt:Event):void
		{
			super.onResult(evt);
			var oXML:XML = XML(evt.target.data);
			//trace(oXML.name())
			var xmlID:String = oXML.name().toString() == "" ? currentServiceID : oXML.name().toString();
			var i:int;
			percentageCount = loadingPercentage;
			
			switch(xmlID)
			{				
				case ServiceConstants.FILMS_XML:
					mediaXML = oXML.copy();
					autoPlayVideoURL = baseURL+player+pid+content+mediaXML.teaser.@url.toString();
					
					for(i=0;i<mediaXML.chapterlist.chapter.length();i++)
					{
						
						var strSplit= mediaXML.chapterlist.chapter.@level[i].toString().split(',');
						//filmVO.chapterID = mediaXML.chapterlist.chapter.@id[i].toString();	
						
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
						textVO.chapterID = textXML.chapter.@id[i].toString();
						textVO.chapterName = textXML.chapter.chaptername[i].toString();
						textVO.htmlText = textXML.chapter.htmltext[i].toString();						
						textArray.push(textVO);
					}
					textVO.breadcrumbs=textXML.breadcrumbs[0].toString();
					textVO.productName=productName=textXML.productname[0].toString();
					dispatchEvent(new AppEvents(AppEvents.INIT_XML_DATA_LOADED));
					//loadXML("assets/xmlData/metadata.xml");
					//loadXML(ServiceConstants.FULL_PATH+ServiceConstants.METADATA_XML_PATH);					
					break; 
				
				/*case ServiceConstants.METADATA_XML:
					metadataXML = oXML.copy();
					
					for(i=0;i<metadataXML.filmDetails.length();i++)
					{
						metadataVO = new MetadataVO();
						metadataVO.title = metadataXML.filmDetails.title[i].toString();
						metadataVO.description = metadataXML.filmDetails.description[i].toString();
						metadataVO.imageURL =  metadataXML.filmDetails.image.@url[i].toString();	
						metadataVO.duration =  metadataXML.filmDetails.duration.@time[i].toString();
						metadataVO.videoURL =  metadataXML.filmDetails.video.@url[i].toString();
						metadataVO.audioURL =  metadataXML.filmDetails.audio.@url[i].toString();
						metadataArray.push(metadataVO);
					}	
					
					for(i=0;i<metadataXML.markers.length();i++)
					{
						metadataVO = new MetadataVO();
						metadataVO.markerID = metadataXML.markers.marker.@id[i].toString();						
						metadataVO.markerTime =  metadataXML.markers.marker.@time[i].toString();
						metadataVO.markerText = metadataXML.markers.marker.text[i].toString();
						metadataArray.push(metadataVO);
					}	
					
					for(i=0;i<metadataXML.cuelist.length();i++)
					{
						metadataVO = new MetadataVO();
						metadataVO.cuepointID = metadataXML.cuelist.cuepoint[i].@id[i].toString();
						metadataVO.cuepointTime = metadataXML.cuelist.cuepoint[i].@time[i].toString();
						metadataVO.subtitle =  metadataXML.cuelist.cuepoint[i].subtitle[i].toString();	
						metadataVO.heading =  metadataXML.cuelist.cuepoint[i].heading[i].toString();		
						metadataArray.push(metadataVO);
					}	
					MetadataVO.htmlText = metadataXML.htmltext.toString();						
					dispatchEvent(new AppEvents(AppEvents.INIT_XML_DATA_LOADED));
					break; */
			}				
		}
		
		protected override function onError(evt:IOErrorEvent):void
		{
			dispatchEvent(new AppEvents(AppEvents.XML_DATA_LOAD_FAILURE));
		}
		
		public function getBreadcrumText():String
		{				
			return textVO.breadcrumbs;
		}
		
		public function getProductName():String
		{				
			return textVO.productName;
		}
		
				
		private function contentPush(mediaLevel:String,index:uint):void
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
		
		public function getvideoURL(chapterID:String):String	// This  method wiill return videoURL if get correct chapterID 
		{
			var videoURL:String;
			for(var i:int=0;i<mediaXML.chapterlist.chapter.length();i++)
			{
				if(chapterID == mediaXML.chapterlist.chapter.@id[i].toString())
				{
					videoURL = mediaXML.chapterlist.chapter.presenter[i].video.@url.toString();
					break;
				}				
			}
			return videoURL;
		}
		
		public function getHtmlText(chapterID:String):String		// This methos wil return HTML Text on bases of chapter ID
		{
			var str:String;
			for(var i:int=0;i<textArray.length;i++)
			{
				if(chapterID == textArray[i].chapterID)
				{
					str = textArray[i].htmlText
					break;
				}
			}
			return str;
		}
	}
}class SingletonEnforcer{}