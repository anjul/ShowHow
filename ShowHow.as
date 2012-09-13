package
{
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
		
		public function ShowHow()
		{
			objAppModel.stageRef = this;
			//objAppModel.loadXML(ServiceConstants.FILMS_LOCAL_XML_PATH); // First XML load call has sent
			objAppModel.loadXML(AppVO.BASEURL+ServiceConstants.FILMS_XML_PATH); // First XML load call has sent
			objVideoPlayer =VideoPlayer.getInstance();
			this.addChild(objVideoPlayer);
			
			homeView = new HomeView();
			this.addChild(homeView);
		}
	}
}