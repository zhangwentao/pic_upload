package com.renren.picUpload 
{
	/**
	 * DataBlock 上传者
	 * @author taowenzhang@gmail.com
	 */
	public class DBUploader
	{
		
		public static const STATUS_IDLE:int = 0;//空闲
		public static const STATUS_BUSY:int = 1;//忙
		
		[Event (name = "complete", type = "flash.events.Event")]
		
		
		private var _status:int = 0; 
		
		
		public function DBUploader() 
		{
			
		}
		
		
		public function get status():int
		{
			return this._status;
		}
		
		/**
		 * 上传dataBlock
		 * @param	dataBlock 
		 */
		public function upload(dataBlock:DataBlock):void
		{
			
		}
	}
}