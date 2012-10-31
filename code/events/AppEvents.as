package code.events
{
	import flash.events.Event;
	
	public class AppEvents extends Event
	{
		public static const INIT_XML_DATA_LOADED:String = "initXmlDataLoaded";
		public static const XML_DATA_LOAD_FAILURE:String = "xmlDataLoadedFailure";
		public static const PLAY_NEXT_VIDEO:String = "playNextVideo";
		public static const SEARCH_NOT_FOUND:String = "searchNotFound";
		public static const CLOSE_WINDOW:String = "closeWindow";
		
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