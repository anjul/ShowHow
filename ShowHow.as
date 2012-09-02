package
{
	import code.model.AppModel;	
	import flash.display.MovieClip;
	
	public class ShowHow extends MovieClip
	{
		private var objAppModel:AppModel = AppModel.getInstance();
		
		public function ShowHow()
		{
			objAppModel.stageRef = this;
		}
	}
}