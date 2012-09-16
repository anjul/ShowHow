package code.events
{
	import flash.events.Event;
	
	public class PlaySelectedVideoEvent extends Event
	{
		public var url:String;
		public static const CLICK:String='videoClick'
		public function PlaySelectedVideoEvent(type:String,_url:String,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.url = _url;
		}
		
		override public function clone():Event
		{
			return new PlaySelectedVideoEvent(type,url,bubbles,cancelable);
		}
	}
}