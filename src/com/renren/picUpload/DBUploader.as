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
		private var uploader:ByteArrayUploader = new ByteArrayUploader();//用于上传二进制数据
		
		private var dataBlock:DataBlock;//上传的数据块
		
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
			this.dataBlock = dataBlock;
			var urlVar:Object = uploader.urlVariables;
			urlVar["block_index"] = dataBlock.index;
			urlVar["block_count"] = dataBlock.count;
			urlVar["upload_id"] = dataBlock.file.id;
			uploader.upLoad(dataBlock.data);
		}
		
		private function handle_upload_complete(evt:Event):void
		{
			dataBlock.dispose();//释放内存
		}
	}
}