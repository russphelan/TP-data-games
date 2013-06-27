package crossfade_handler
{
	import flash.events.TimerEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class DataTimerEvent extends TimerEvent
	{
		public static const TICK_WITH_DATA:String = "tickWithData";
		
		public var channel:SoundChannel;
		public var trans:SoundTransform;
		
		public function DataTimerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		private function tickDispatcher():void{
			
		}
	}
}