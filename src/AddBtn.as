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
			this.mouseChildren = false;
		}
		public function setStatus(status:uint):void
		{
			this.gotoAndStop(status);
		}
		
		public function setInfoTxt(txt:String):void
		{
			this.info_txt.text = txt;
		}
		
		public function disable():void
		{
			this.infoBtn.gotoAndStop(2);
			this.plusBtn.gotoAndStop(2);
		}
		
		public function enable():void
		{
			this.infoBtn.gotoAndStop(1);
			this.plusBtn.gotoAndStop(1);
		}
	}

}