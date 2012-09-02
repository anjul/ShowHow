package
{
	import code.model.AppModel;
	import code.views.HomeView;
	import code.views.VideoPlayer;
	
	import flash.display.MovieClip;
	
	public class ShowHow extends MovieClip
	{
		private var objAppModel:AppModel = AppModel.getInstance();
		private var videoPlayer:VideoPlayer;
		private var homeView:HomeView;
		
		public function ShowHow()
		{
			objAppModel.stageRef = this;
			
			videoPlayer = new VideoPlayer();
			this.addChild(videoPlayer);
			
			homeView = new HomeView();
			this.addChild(homeView);
		}
	}
}