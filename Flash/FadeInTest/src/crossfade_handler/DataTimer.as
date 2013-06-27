package crossfade_handler
{
	import crossfade_handler.DataTimerEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class DataTimer extends Timer
	{
		public function DataTimer(delay:Number, repeatCount:int=0)
		{
			super(delay, repeatCount);
		}
		
		private function dataTick():void{
			this.addEventListener(TimerEvent.TIMER, dispatchDataEvent);
		}
		
		private function dispatchDataEvent(te:TimerEvent):void{
			dispatchEvent(new DataTimerEvent(DataTimerEvent.TICK_WITH_DATA));
		}
	}
}