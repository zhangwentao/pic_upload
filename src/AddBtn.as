package  
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class AddBtn extends MovieClip 
	{
		
		public function AddBtn() 
		{
			
		}
		
		public function setStatus(status:uint):void
		{
			switch(status)
			{
				case 1:
					this.gotoAndStop(1);
				break;
				
				case 2:
					this.gotoAndStop(2);
				break;
			}
		}
	}

}