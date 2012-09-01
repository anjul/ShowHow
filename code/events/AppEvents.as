package code.events
{
	import flash.events.Event;
	
	public class AppEvents extends Event
	{
		public function AppEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}