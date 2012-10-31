package code.services
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class BaseService implements IEventDispatcher
	{
		private var evtDispatcher:EventDispatcher;
		public static var isServiceConnecting:Boolean;
		
		private var webserviceURL:URLRequest;
		private var webserviceParamas:URLVariables;
		protected var isHTTPCall:Boolean;
		
		public function BaseService()
		{
			evtDispatcher = new EventDispatcher(this);
		}
		
		public function loadXML(xmlPath:String):void 
		{			
			isHTTPCall = false;
			//trace("Path ="+xmlPath)
			webserviceURL = new URLRequest(xmlPath);
			connectWebservice();
		}
		
		private function connectWebservice():void
		{
			var objHTTP:URLLoader = new URLLoader();
			webserviceURL.method = URLRequestMethod.POST;
			
			
			//objHTTP.addEventListener(Event.COMPLETE, onResult);
			objHTTP.addEventListener(ProgressEvent.PROGRESS,onProgress);
			objHTTP.addEventListener(Event.COMPLETE, checkContent);
			objHTTP.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			//isServiceConnecting = true;
			
			objHTTP.load(webserviceURL);			
			
			// TODO: Needs to add this message on the basis of current service
			//objUtilities.showLoader();			
		}
		
		protected function checkContent(evt:Event):void
		{
			var oXML:XML = XML(evt.target.data);			
			onResult(evt);
		}
		
		protected function onProgress(evt:ProgressEvent):void
		{				
		}
		
		protected function onResult(evt:Event):void
		{
		}
		
		protected function onError(evt:IOErrorEvent):void
		{						
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=true):void
		{
			evtDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			evtDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return evtDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return evtDispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return evtDispatcher.willTrigger(type);
		}
	}
}