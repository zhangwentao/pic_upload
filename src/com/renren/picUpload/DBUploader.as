package com.renren.picUpload 
{
	import com.renren.util.net.ByteArrayUploader;
	import flash.events.Event;
	/**
	 * DataBlock 上传者
	 * @author taowenzhang@gmail.com
	 */
	public class DBUploader
	{
		private var uploader:ByteArrayUploader = new ByteArrayUploader();//二进制数据上传者
		
		public function DBUploader() 
		{
			uploader.url = "";//上传cgiurl
			uploader.addEventListener(Event.COMPLETE, handle_upload_complete);
		}
				
		/**
		 * 上传dataBlock
		 * @param	dataBlock 
		 */
		public function upload(dataBlock:DataBlock):void
		{
			var urlVar:Object = uploader.urlVariables;
			uploader.upLoad(dataBlock.data);
		}
		
		private function handle_upload_complete(evt:Event):void
		{
			
		}
	}
}