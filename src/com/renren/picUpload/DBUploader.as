package com.renren.picUpload 
{
	import com.renren.picUpload.events.DBUploaderEvent;
	import com.renren.util.net.ByteArrayUploader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	/**
	 * DataBlock 上传者
	 * @author taowenzhang@gmail.com
	 */
	public class DBUploader extends EventDispatcher
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
			//this.dataBlock = dataBlock;
			//dataBlock.file.status = FileItem.FILE_STATUS_IN_PROGRESS;//设置图片状态为:正在上传
			//var urlVar:Object = uploader.urlVariables;
			//urlVar["block_index"] = dataBlock.index;
			//urlVar["block_count"] = dataBlock.count;
			//urlVar["upload_id"] = dataBlock.file.id;
			//uploader.upLoad(dataBlock.data);
			
			//------test----------
				setTimeout(dispatch, 500);
				function dispatch():void
				{
					trace("上传完毕");
					dispatchEvent(new DBUploaderEvent(DBUploaderEvent.COMPLETE));
				}
			//--------------------
		}
		
		private function handle_upload_complete(evt:Event):void
		{
			trace("上传完毕");
			dataBlock.dispose();//释放内存
		}
	}
}