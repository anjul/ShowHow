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
		
		public function ShowHow()
		{
			objAppModel.stageRef = this;
			objAppModel.loadXML(AppVO.BASEURL+ServiceConstants.FILMS_XML_PATH);
			
			videoPlayer = new VideoPlayer();
			this.addChild(videoPlayer);
			
			homeView = new HomeView();
			this.addChild(homeView);
		}
	}
}