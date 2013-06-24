package odyssey
{
	//The costArrow is an object within the .swc. It has the following methods:
	// 	establish( treasureValue:int, goal:int): void;
	//			call this method to set up the cost arrow.
	// 	pay( cost:int): void;
	//			pay $. Give it a value, and it will animate it for you.
	
	import flash.events.Event;	
	import odyssey.events.BootyEventDispatcher;
	
	public class BootyBarMVC extends BootyMeter
	{
		public static const WIN:int = 1;	//used for win/lose/game isn't over
		public static const LOSE:int = 2;
		public static const NO:int = 0;
		
		private var BAR_HEIGHT:Number; 
		private var _dispatcher:BootyEventDispatcher = new BootyEventDispatcher(); // object that dispatches booty events		
		
		private var _booty:int = 0;			// how much booty the player currently has
		private var _startingBooty:int = 0;	// how much booty the player had at the start of a location
		private var _capital:int = 0;		// how much booty the player started the level with
		private var _goal:int = 0;			// how much booty the player needs to win
		private var _treasureValue:int = 0;	// how much booty the treasure is worth on this level
		private var _costs:int = 0;			// how many costs have racked up this location
		
		private var targetFrame:int; //used for animation logic
		private var displayBooty:int; //used for animation logic. Animated $
		private var _settingStartValue:Boolean; // animation logic. when it's true, the starting value will move along with the $.
		private var _animateBooty:Boolean = false;
		private var _lockedGhost:Boolean = false; // when this is true, the ghost can't be removed.
		
		private var _isGameOver:int = NO;	//an int based on whether or not the game is over.
		
		public function BootyBarMVC()
		{
			addEventListener(Event.ADDED_TO_STAGE, turnOff); 
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			BAR_HEIGHT = barBacking.height;
		}
		
		public function get dispatcher():BootyEventDispatcher
		{
			return _dispatcher;
		}
		public function get won():Boolean
		{
			return _isGameOver == WIN;	
		}
		public function get lost():Boolean
		{
			return _isGameOver == LOSE;
		}
		
		public function get booty():int
		{
			return _booty + _treasureValue - _costs;
		}
		public function get profitSoFar():int
		{
			return _booty;
		}
		public function get goal():int{
			return _goal;
		}
		public function get treasureValue():int{
			return _treasureValue;
		}
		public function get startingBooty():int{
			return _startingBooty;
		}
		public function get profit():int{
			return _treasureValue - _costs;
		}
		public function get costs():int{
			return _costs;
		}
		public function lockGhost():void {
			_lockedGhost = true;
		}
		public function unlockGhost():void {
			_lockedGhost = false;
		}
		
		private function turnOff(e:Event = null):void
		{
			// set the movieclip to its "off" state (grayed out) when its created.
			gotoAndStop(1);
			goalMVC.htmlText = "$0";
			myCash.booty.text = "";
			costArrow.visible = false;
		}
		
		// when a hook drop finishes, this method runs. 
		public function finishTreasureDrop(success:Boolean, cost:int = 0):void{
			if(success)
			{
				_booty += treasureValue;
				account();
				if(_booty >= _goal)
					_isGameOver = WIN;
				else
					_isGameOver = NO;
			} else
			{
				pay(cost);
				if(_booty + _treasureValue - costs <= 0)
				{
					_isGameOver = LOSE;
					account(true);
				}else
				{
					_isGameOver = NO;
				}
			}
			
		}
		// call this method at the start of each level
		public function initialize(capital:int, goal:int, treasureValue:int):void
		{
			// first, set all the numbers:
			_isGameOver = NO;
			_capital = capital;
			_goal = goal;
			_treasureValue = treasureValue;
			_booty = _capital;	
			_startingBooty = _capital;
			_costs = 0;
			
			goalMVC.htmlText = parseToCash(_goal);	// write the goal at the top
			animateBooty(true);
			costArrow.visible = true;
			costArrow.establish(_treasureValue, _goal);
		}
		
		// call this method whenever you spend money
		public function pay(cost:int):void
		{
			_costs += cost;	
			costArrow.pay(cost);
		}
		
		
		// call this method at the start of each location
		public function readyNewLocation():void
		{
			_isGameOver = NO;
			_startingBooty = _booty;
			animateBooty(true);
			costArrow.visible = true;
			costArrow.establish(_treasureValue, _goal);
			_costs = 0;
		}
		
		// accounting moves costs from the cost bar over to the booty bar.
		// call this account method if you drop an anchor, and game is not over (no winning or losing)
		public function payThenAccount():void {
			_booty = _booty - _costs + _treasureValue;
			animateBooty();
			_costs = 0;
		}
		
		// call this account method if the game IS over. It will turn off the player's controls.
		private function account(bankrupt:Boolean = false):void{
			_booty -= (bankrupt ? _booty : _costs);	
			_dispatcher.dispatchAccounting();
			animateBooty();
			_costs = 0;
		}
		
		
		// this method is called every frame. It handles the animation logic
		private function handleEnterFrame(e:Event):void{
			if(_animateBooty)
				subAnimateBooty();
		}
		
		private function animateBooty(setStartingValue:Boolean = false):void
		{
			var arg:int = getPercent(_booty)*10;	// convert percent to per thousand
			_settingStartValue = setStartingValue;
			targetFrame = arg;
			_animateBooty = true;
		}
		private function subAnimateBooty():void
		{
			var dist:Number = (targetFrame - currentFrame)/10;
			if(targetFrame > totalFrames)
				targetFrame = totalFrames;
			else if(targetFrame < 1)
				targetFrame = 1;
			
			dist = (targetFrame > currentFrame ? Math.ceil(dist) : Math.floor(dist));
			// rounding is based on whether the graph is moving up or down
			
			gotoAndStop(currentFrame + dist);
			
			if(((_goal*currentFrame)/1000) < 100)
			{
				myCash.booty.text = "$0";
			}else{
				myCash.booty.text = parseToCash((_goal*currentFrame)/1000);
			}
			
			if(_settingStartValue)
				costArrow.y = barPosition.y;
			
			if(currentFrame == targetFrame)
			{
				_settingStartValue = false;
				myCash.booty.text = parseToCash(_booty);
				_animateBooty = false;
				
				// check for winning or losing at the end of animation:
				if(won)
					_dispatcher.dispatchWin();
				else if(lost)
					_dispatcher.dispatchLose();
			}
		}
		
		// give this method a number, and it will return it in readable format. 3000 --> $3,000
		private function parseToCash(arg:int):String
		{
			var stringArg:String = String(arg);
			var outputString:String = "$";
			var backwardsString:String = "";
			var ticker:int = 0;
			
			for( var i:int = stringArg.length; i >= 0; i--){
				backwardsString += stringArg.charAt(i);
				if(ticker == 3 && i > 0){
					backwardsString += ",";
					ticker = 0;
				}
				ticker++;
			}
			for( var j:int = backwardsString.length; j >= 0; j--)
				outputString += backwardsString.charAt(j);
			
			return outputString;
		}
		
		// given a booty, this method returns what % it is of the goal
		private function getPercent(arg:int):int{
			var percent:int = (arg/_goal)*100;
			return percent;
		}
	}
}