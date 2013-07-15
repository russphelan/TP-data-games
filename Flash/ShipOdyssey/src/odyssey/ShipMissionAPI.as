package odyssey
{
	import flash.display.SimpleButton;
	import flash.events.Event;
	import odyssey.missions.Missions;
	import odyssey.missions.MissionData;

	
	public class ShipMissionAPI
	{
		private var beginMission:Function;
		public var getHuntMission:Function;
		public var getCurrentMission:Function;
		public var restartMission:Function;
		public var setGameTitle:Function;
		
		public function ShipMissionAPI (begin:Function, restart:Function, cm:Function, hm:Function, setGTitle:Function) {
			beginMission = begin;
			restartMission = restart;
			getCurrentMission = cm;
			getHuntMission = hm;
			setGameTitle = setGTitle;
		}
		
		public function startHunt(num:int, e:Event = null, autoStart:Boolean = false):void {
			var md:MissionData = Missions.getMission(num);
			var stripBtnListeners:Boolean = (e ? true : false);
			beginMission(md, stripBtnListeners, autoStart);
		}
	}
}