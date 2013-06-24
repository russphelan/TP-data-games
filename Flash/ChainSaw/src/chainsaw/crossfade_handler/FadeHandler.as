package chainsaw.crossfade_handler{
	import flash.events.Event;
	
	public class FadeHandler{
		
		import flash.events.Event;
		import flash.events.TimerEvent;
		import flash.media.Sound;
		import flash.media.SoundChannel;
		import flash.media.SoundMixer;
		import flash.media.SoundTransform;
		import flash.utils.Timer;
		import chainsaw.crossfade_handler.DataTimer;
		
		private var mframeRate:uint = 24;
		private var mDeltaVol:Number = 1/mNumberOfSteps; //size of each volume increment
		private var mNumberOfSteps:uint = mFadeTime/mTickLength; //number of volume increments to get from 0 to 1 vol
		private var mFadeTime:uint = 1000; //time the fade takes in ms
		private var mTickLength:Number = mFadeTime/mNumberOfSteps;
		private var mSound:Sound
		private var mChannel:SoundChannel;
		
		//constructor. takes sound obj.
		public function FadeHandler(s:Sound, fadeTime:uint):void{
			mFadeTime = fadeTime; 
			mSound = s;
			mChannel = mSound.play(0, 0);
			mChannel.addEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);
			var t:SoundTransform = mChannel.soundTransform;
			t.volume = 0; //sound comes in muted
			mChannel.soundTransform = t;
		}
		
		public function fadeIn():void{
			//makes timer, starts ticking. ticks go to addData(), where they are filled with SoundTransform and SoundmChannel objs.
			var dt:DataTimer = new DataTimer(mTickLength, mNumberOfSteps); //creating new DataTimer to tick and send data
			dt.addEventListener(DataTimerEvent.TICK_WITH_DATA, getTransform); //listens for data ticks to send to addData
			dt.start();
		}
		
		private function getTransform(dte:DataTimerEvent):void{
			
			var trans:SoundTransform = mChannel.soundTransform;
			dte.trans = trans;
			
			onFadeInTimerTick(dte); //send event filled with SoundTransform to onFadeInTimerTick
		}
		
		
		public function fadeOut():void{
			
		}
		
		
		private function onPlaybackComplete(e:Event):void{
			
		}
		
		private function onFadeInTimerTick(dte:DataTimerEvent):void{
			if(mChannel.leftPeak<1 && mChannel.rightPeak<1){
				dte.trans.volume += mDeltaVol;
				mChannel.soundTransform = dte.trans;
			}
		}
	}
}