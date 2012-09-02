package code.model
{
	public class AppModel
	{
		private static var objAppModel:AppModel;
		public var stageRef:Object;
		
		public function AppModel(singletonEnf:SingletonEnforcer)
		{
			if(singletonEnf == null)
			{
				throw new Error("You can use "+this+" Class constructor to instaiate object, Use getInstance() instead.")
			}
		}
		public static function getInstance():AppModel
		{
			if(objAppModel == null)
			{
				objAppModel = new objAppModel(new SingletonEnforcer());
			}
			return objAppModel;
		}
	}
}class SingletonEnforcer