package code.component
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class VScrollbar extends Sprite
	{
		private var top		:Number;
		private var bottom	:Number;
		private var dragBot	:Number;
		private var range	:Number;
		private var ratio	:Number;
		private var sPos	:Number;
		private var ctrl	:Number;
		private var sBuffer	:Number;
		private var arrowMove:Number;
		private var isUp	:Boolean;
		private var isDown	:Boolean;
		private var isArrow	:Boolean;
		private var targetMC:MovieClip;
		private var track	:MovieClip;
		private var dragHandleMC:MovieClip;
		private var upScrollControl:MovieClip;
		private var downScrollControl:MovieClip;		
		private var upScrollControlHeight:Number;
		private var downScrollControlHeight:Number;
		private var sRect:Rectangle;
		private var sBar:MovieClip;
		
		public function VScrollbar(isListViewScroller:Boolean=false):void
		{
			if(isListViewScroller)
			{
				sBar = new ListScrollbarAssets();
			}
			else
			{
				sBar = new ScrollbarAssets();
			}
			addChild(sBar);
		}
		
		public function set configure(target:MovieClip):void
		{
//			var sBar:MovieClip = new ScrollbarAssets();
			
			sBar.y = target.y-37;
			//sBar.x = -8;
			dragHandleMC = sBar.dragHandleMC;	
			track = sBar.track;
			upScrollControl = sBar.upScrollControl;
			downScrollControl = sBar.downScrollControl;
			
			// Add the Listener for scroll drag Handler
			dragHandleMC.useHandCursor = true;
			dragHandleMC.buttonMode = true;
			dragHandleMC.addEventListener(MouseEvent.MOUSE_DOWN, dragScroll);
			dragHandleMC.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			init(target);
		}
		
		public function init(target:MovieClip):void
		{	
			targetMC = target;
			sBuffer = 2;
			ratio = 2;
			if (targetMC.height <= track.height)
			{
				this.visible = false;
			}			
			upScrollControlHeight = upScrollControl.height;
			downScrollControlHeight = downScrollControl.height;
			
			top = dragHandleMC.y;
			dragBot = (dragHandleMC.y + track.height) - dragHandleMC.height;
			bottom = track.height - (dragHandleMC.height/sBuffer);
			
			range = bottom - top;
			sRect = new Rectangle(0,top,0,dragBot);
			ctrl = targetMC.y;
			
			isUp = false;
			isDown = false;
			arrowMove = 5;
			
			// Add the listerner for upArrow
			upScrollControl.useHandCursor = true;
			upScrollControl.buttonMode = true;
			upScrollControl.addEventListener(Event.ENTER_FRAME, upScrollControlHandler);
			upScrollControl.addEventListener(MouseEvent.MOUSE_DOWN, upScroll);
			upScrollControl.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			
			// Add the listerner for downArrow
			downScrollControl.useHandCursor = true;
			downScrollControl.buttonMode = true;
			downScrollControl.addEventListener(Event.ENTER_FRAME, downScrollControlHandler);
			downScrollControl.addEventListener(MouseEvent.MOUSE_DOWN, downScroll);
			downScrollControl.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			
			//setMask(); 
			this.x = targetMC.x+targetMC.width;
			this.y = targetMC.y+2;			
		}
		
		// Set mask for the content 
		private function setMask()
		{
			var square:Sprite = new Sprite();
			square.graphics.beginFill(0x000000);
			square.graphics.drawRect(targetMC.x, targetMC.y, targetMC.width+5, (track.height+downScrollControlHeight));
			square.cacheAsBitmap = true;
			targetMC.cacheAsBitmap = true;
			targetMC.parent.addChild(square);			
			targetMC.mask = square;	
		}
		// Up Arrow Press
		public function upScroll(event:MouseEvent):void 
		{
			isUp = true;
		}
		
		// Up Arrow Press
		public function downScroll(event:MouseEvent):void 
		{
			isDown = true;
		}
		
		// Checking if up arrow is press.
		public function upScrollControlHandler(event:Event):void
		{
			if (isUp)
			{
				if (dragHandleMC.y > top) 
				{
					dragHandleMC.y-=arrowMove;
					if (dragHandleMC.y < top) 
					{
						dragHandleMC.y = top;
					}
					startScroll();
				}
			}
		}
		
		// Checking if down arrow is press.
		public function downScrollControlHandler(event:Event):void {
			if (isDown) {
				if (dragHandleMC.y < dragBot) {
					dragHandleMC.y+=arrowMove;
					if (dragHandleMC.y > dragBot) {
						dragHandleMC.y = dragBot;
					}
					startScroll();
				}
			}
		}
		
		public function dragScroll(event:MouseEvent):void
		{			
			dragHandleMC.startDrag(false, sRect);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveScroll);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			this.addEventListener(MouseEvent.MOUSE_MOVE, moveScroll);
		}
		
		
		public function stopScroll(event:MouseEvent):void
		{
			isUp = false;
			isDown = false;
			dragHandleMC.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveScroll);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScroll);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, moveScroll);
		}
		
		public function moveScroll(event:MouseEvent):void
		{
			startScroll();
			
		}
		
		// scroll the content
		public function startScroll():void 
		{
			ratio = (targetMC.height - range)/range;
			sPos = (dragHandleMC.y * ratio) - ctrl;	
			targetMC.y = -sPos;
		}
	}
}