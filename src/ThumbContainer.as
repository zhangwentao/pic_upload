package  
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class ThumbContainer extends MovieClip 
	{
		public static const STATUS_UPLOAD_COMPLETE:int = 0;	//上传完成
		public static const STATUS_UPLOAD_PROGRESS:int = 1;	//上传中
		public static const STATUS_QUEUED:int = 2;			//已加入上传队列，等待下一步操作中
		public static const STATUS_THUMB_MAKING:int = 3;	//缩略图绘制中
		public static const STATUS_ERROR:int = 4;			//发生错误
		public static const STATUS_WAIT_FOR_UPLOAD:int = 5;	//
		
		private var container_width:Number = 100;
		private var container_height:Number = 100;
		private var _status:int;
		
		public function ThumbContainer() 
		{
			this.stop();
		}
		
		/**
		 * 加入 缩略图
		 * @param	thumb
		 */
		public function addThumb(thumb:Sprite):void
		{
			container.addChild(thumb);
			adjustThumbPos(thumb);
		}
		
		/**
		 * 调整缩略图位置
		 * @param	thumb
		 */
		private function adjustThumbPos(thumb:Sprite):void
		{
			thumb.x = (container_width - thumb.width) / 2;
			thumb.y = (container_height - thumb.height) / 2;
		}
		
		public function get status():int 
		{
			return _status;
		}
		
		public function set status(value:int):void 
		{
			_status = value;
			displayStatus(_status);
		}
		
		/**
		 * 
		 * @param	status
		 */
		private function displayStatus(status:int):void
		{
			switch(status)
			{
				case STATUS_QUEUED:
					setInfoTxt("等待中");
				break;
				
				case STATUS_THUMB_MAKING:
					setInfoTxt("截取缩略图");
				break;
				
				case STATUS_UPLOAD_COMPLETE:
					setInfoTxt("上传完毕");
				break;
				
				case STATUS_UPLOAD_PROGRESS:
					setInfoTxt("上传中");
				break;
				
				case STATUS_WAIT_FOR_UPLOAD:
					setInfoTxt("待上传");
				break;
			}
		}
		
		private function setInfoTxt(txt:String):void
		{
			info_txt.text = txt;
		}
		
	}

}