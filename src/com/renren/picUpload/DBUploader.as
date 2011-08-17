package com.renren.picUpload 
{
	import com.renren.picUpload.events.DBUploaderEvent;
	import com.renren.util.net.ByteArrayUploader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import com.adobe.serialization.json.JSON;
	import flash.external.ExternalInterface;
	
	/**
	 * 上传 DataBlock 至服务器
	 * @author taowenzhang@gmail.com
	 */
	class DBUploader extends EventDispatcher
	{
		//"http://upload.renren.com/upload.fcgi?pagetype=addflash&hostid=200208111"
		public static var upload_url:String = Config.uploadUrl;
		private var uploader:ByteArrayUploader;
		private var dataBlock:DataBlock;		//上传的数据块
		private var _responseData:Object;
		
		public function DBUploader() 
		{
		}
		
		private function init():void
		{
			uploader= new ByteArrayUploader();//用于上传二进制数据
			uploader.url = upload_url;//上传cgiurl
			uploader.addEventListener(IOErrorEvent.IO_ERROR, handle_ioError);
			uploader.addEventListener(Event.COMPLETE, handle_upload_complete);
		}
		
		/**
		 * 上传dataBlock
		 * @param	dataBlock 
		 */
		public function upload(dataBlock:DataBlock):void
		{
			init();
			this.dataBlock = dataBlock;
			dataBlock.file.status = FileItem.FILE_STATUS_IN_PROGRESS;//设置图片状态为:正在上传
			
			var urlVar:Object = uploader.urlVariables;
			
			urlVar["block_index"] = dataBlock.index;
			urlVar["block_count"] = dataBlock.count;
			urlVar["uploadid"] = dataBlock.file.id;
			
			uploader.upLoad(dataBlock.data);
		}
		
		public function get responseData():Object
		{
			return _responseData; 
		}
		
		/**
		 * 处理ioError
		 * @param	evt		<ioErrorEvent>	
		 */
		private function handle_ioError(evt:IOErrorEvent):void
		{
			dispatchEvent(evt);
		}
		
		/**
		 * 上传完毕服务器返回数据后调用
		 * @param	evt		<Event>
		 */
		private function handle_upload_complete(evt:Event):void
		{
			try 
			{
				_responseData = JSON.decode(String(uploader.data));
			}
			catch (e)
			{
				ExternalInterface.call("console.log", "json error");
			}
			
			switch(int(_responseData.code))
			{
				case 0:
					checkFileCode();
				break;
			}
		}
		
		private function checkFileCode():void
		{
			var code:int = int(_responseData.files[0].code);
			switch(code)
			{
				case 0:
					oneFileCompleteDo();
				break;
				
				case 523:
					oneBlockCompleteDo();
				break;
			}
		}
		
		private function oneBlockCompleteDo():void
		{
			var event:DBUploaderEvent = new DBUploaderEvent(DBUploaderEvent.COMPLETE);
			event.dataBlock = dataBlock;
			dispatchEvent(event);
			dataBlock.dispose();//释放内存
		}
		
		private function oneFileCompleteDo():void
		{
			var event:DBUploaderEvent = new DBUploaderEvent(DBUploaderEvent.FILE_COMPLETE);
			event.dataBlock = dataBlock;
			dispatchEvent(event);
			dataBlock.dispose();//释放内存
		}
		
	}
}