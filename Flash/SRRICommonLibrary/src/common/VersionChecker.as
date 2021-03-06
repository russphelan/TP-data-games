package common
{
	// this class checks the version of flash player the player is using.
	
	import flash.system.Capabilities;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
		
	public class VersionChecker
	{	
		// called on start up in games. Compare the game's minimum requirement to your machine's version.
		public static function isValid( minVersion:Number = 0):Boolean
		{
			trace( "You are using Flash Player "+getVersion());
			return getVersion() >= minVersion;
		}
		
		public static function checkVersion():void
		{
			trace(getVersion());
		}
		
		public static function getVersion():Number
		{
			var rawVersion:String = Capabilities.version; // gets the OS & version
			
			// the first 4 characters are the OS. Throw those away. Change the ,'s to . 
			var cleanVersion:String = rawVersion.substring(4).split(",").join(".");
			var numberVersion:Number = Number(cleanVersion.substring(0, cleanVersion.indexOf(".", cleanVersion.indexOf(".") + 1)));
			return numberVersion;
		}
		
		public static function openAdobeWebsite():void{
			var url:URLRequest = new URLRequest("http://get.adobe.com/flashplayer/");
			navigateToURL(url, "_blank");
		}
		
		
		
		
		/* Code from http://michaelvandaniker.com/blog/2008/11/25/how-to-check-debug-swf/ */
		// Returns whether or not the .swf was compiled in debug mode.
		private static var hasDeterminedDebugStatus:Boolean = false;
		public static function get isDebug():Boolean
		{
			if(!hasDeterminedDebugStatus)
			{
				try
				{
					throw new Error();
				}
				catch(e:Error)
				{
					var stackTrace:String = e.getStackTrace();
					_isDebug = stackTrace != null && stackTrace.indexOf("[") != -1;
					hasDeterminedDebugStatus = true;
					return _isDebug;
				}
			}
			return _isDebug;
		}
		private static var _isDebug:Boolean;
	}
}