package
{
	import code.events.AppEvents;
	import code.model.AppModel;
	import code.services.ServiceConstants;
	import code.views.HomeView;
	import code.views.VideoPlayer;
	import code.vo.AppVO;
	
	import flash.display.MovieClip;
	
	public class ShowHow extends MovieClip
	{
		private var objAppModel:AppModel = AppModel.getInstance();
		private var videoPlayer:VideoPlayer;
		private var homeView:HomeView;
		private var objVideoPlayer:VideoPlayer;
		
		private var _dataUrl:String;
		private var _filmId:String;
		private var _omniId:String;	
		private var _baseUrl:String;
		private var _productID:String;
		private var fullPath:String;//= baseUrl + product + productId + "/";
		
		private var product:String="product/";
		
		public function ShowHow()
		{
			//trace(">>>>"+this.loaderInfo.parameters.baseUrl)
			loadFlashVars();	
			
		}
			
		private function loadFlashVars():void
		{
			if(this.loaderInfo.parameters.filmId!=undefined||this.loaderInfo.parameters.omniId||this.loaderInfo.parameters.productId||this.loaderInfo.parameters.dataUrl)
			{
				_filmId=this.loaderInfo.parameters.filmId;
				_omniId=this.loaderInfo.parameters.omniId;
				_baseUrl=AppModel.BASE_URL=this.loaderInfo.parameters.baseUrl;
				_productID=AppModel.PID=this.loaderInfo.parameters.productId;
				_dataUrl=this.loaderInfo.parameters.dataUrl;
				
				ServiceConstants.FULL_PATH = _baseUrl+product+_productID;
				
				trace("FlashVars="+_filmId+_omniId+_baseUrl+_dataUrl+_productID)
				debugText.text = "Film ID="+_filmId+"=Omni ID="+_omniId+"=BaseURL="+_baseUrl+"=DataURL="+_dataUrl+"=PID="+_productID;
			}
			else
			{
				ServiceConstants.FULL_PATH = "http://www.showhow2.com/product/1/";
				AppModel.BASE_URL = "http://www.showhow2.com/";
				AppModel.PID = "1";
				debugText.text = "No FlashVars recieved"+_filmId+_omniId+_baseUrl+_dataUrl+_productID
				//throw new Error("No FlashVars recieved");
			}
			init();
		}
		
		private function init():void
		{
			objAppModel.stageRef = this;
			objAppModel.addEventListener(AppEvents.INIT_XML_DATA_LOADED,initXmlDataLoaded);
			objAppModel.addEventListener(AppEvents.XML_DATA_LOAD_FAILURE,failToLoadXmlData);
			
			//objAppModel.loadXML(ServiceConstants.FILMS_LOCAL_XML_PATH); // First XML load call has sent
			objAppModel.loadXML(ServiceConstants.FULL_PATH+ServiceConstants.FILMS_XML_PATH); // First XML load call has sent			
		}
		
		private function initXmlDataLoaded(event:AppEvents):void
		{
			preloadingClip.visible=false;
			
			objVideoPlayer=VideoPlayer.getInstance();
			this.addChild(objVideoPlayer);
			
			homeView = new HomeView();
			this.addChild(homeView);
			objAppModel.homeViewRef = homeView;
		}
		
		private function failToLoadXmlData(event:AppEvents):void
		{
			trace("XML Loading Failed")
		}
	}
}