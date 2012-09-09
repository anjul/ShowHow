package code.model
{
	import code.services.BaseService;
	import code.services.ServiceConstants;
	import code.vo.AppVO;
	
	import flash.events.Event;
		
	public class AppModel extends BaseService
	{
		private static var objAppModel:AppModel;
		public var stageRef:Object;
		private var productsXML:XML;
		private var currentServiceID:String="1";
		
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
		
		protected override function onResult(evt:Event):void
		{
			super.onResult(evt);
			var oXML:XML = XML(evt.target.data);
			//trace(oXML)
			var xmlID:String = oXML.@id.toString() == "" ? currentServiceID : oXML.@id.toString();
			/*switch(xmlID)
			{
				case ServiceConstants.FILMS_XML;
					productsXML = oXML.copy();
					//loadXML(AppVO.BASEURL + ServiceConstants.TAGS_XML);
					break;
				
			}*/
				
		}
	}
}class SingletonEnforcer{}