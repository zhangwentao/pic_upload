package  
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class AddBtn extends MovieClip 
	{
		public function setStatus(status:uint):void
		{
			this.gotoAndStop(status);
		}
	}

}