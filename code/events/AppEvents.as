package code.events
{
	import flash.events.Event;
	
	public class AppEvents extends Event
	{
		public static const INIT_XML_DATA_LOADED:String = "init_xml_data_loaded";
		public static const XML_DATA_LOAD_FAILURE:String = "xml_data_loaded_failure";
		public var data:Object;
		
		public function AppEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}