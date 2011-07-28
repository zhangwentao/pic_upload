package  
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class PicContainer extends MovieClip 
	{
		private var container_width:Number = 100;
		private var container_height:Number = 100;
		
		public function PicContainer() 
		{
			
		}
		
		public function addThumb(thumb:Sprite):void
		{
			container.addChild(thumb);
			thumb.x = (container_width - thumb.width) / 2;
			thumb.y = (container_height - thumb.height) / 2;
		}
	}

}