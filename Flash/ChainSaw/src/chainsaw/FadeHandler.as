package chainsaw{
	import flash.events.Event;
	
	public class FadeHandler{
		
		import flash.events.Event;
		import flash.events.TimerEvent;
		import flash.media.Sound;
		import flash.media.SoundChannel;
		import flash.media.SoundMixer;
		import flash.media.SoundTransform;
		import flash.utils.Timer;
		
		private var mframeRate:uint = 24;
		private var mDeltaVol:Number = 1/mNumberOfSteps; //size of each volume increment
		private var mFunctionOnFadeInTimerTick:Function;
		private var mNumberOfSteps:uint = mFadeTime/mTickLength; //number of volume increments to get from 0 to 1 vol
		private var mFadeTime:uint = 1000; //time the fade takes in ms
		private var mTickLength:Number = mFadeTime/mNumberOfSteps;
		
		public function fadeIn(s:Sound):void{
			var time:Timer = new Timer(mTickLength, mNumberOfSteps);
			time.addEventListener(TimerEvent.TIMER, 
			var channel:SoundChannel = s.play(0, 0);
			 var trans:SoundTransform = channel.soundTransform;
			channel.addEventListener(Event.SOUND_COMPLETE, onFadeInPlaybackComplete);
			mFunctionOnFadeInTimerTick = onFadeInTimerTick(trans, channel);
		}
		
		public function fadeOut():void{
			
		}
		
		
		private function onFadeInPlaybackComplete(e:Event):void{
			
		}
		
		private function onFadeInTimerTick(trans:SoundTransform, channel:SoundChannel):Function{
			return function(e:Event):void{
				if(channel.leftPeak<1 && channel.rightPeak<1){
					trans.volume += mDeltaVol;
					channel.soundTransform = trans;
				}else{
					removeEventListener(Event.ENTER_FRAME, mFunctionOnFadeInEnterFrame);
				}
			}
		}
	}
}