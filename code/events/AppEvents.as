package code.events
{
	import flash.events.Event;
	
	public class AppEvents extends Event
	{
		public static const INIT_XML_DATA_LOADED:String = "init_xml_data_loaded";
		public static const XML_DATA_LOAD_FAILURE:String = "xml_data_loaded_failure";
		public static const PLAY_NEXT_VIDEO:String = "play_next_video";
		
		public function AppEvents(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new AppEvents(type,bubbles,cancelable);
		}
	}
}