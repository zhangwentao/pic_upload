package com.renren.picUpload 
{
	import com.renren.picUpload.events.DBUploaderEvent;
	import com.renren.util.net.ByteArrayUploader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import com.adobe.serialization.json.JSON;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import com.renren.external.ExternalEventDispatcher;
	import com.renren.external.ExternalEvent;
	import com.renren.picUpload.events.FileUploadEvent;
	import flash.utils.Timer;
	
	/**
	 * 上传 DataBlock 至服务器
	 * @author taowenzhang@gmail.com
	 */
	class DBUploader extends EventDispatcher
	{
		//"http://upload.renren.com/upload.fcgi?pagetype=addflash&hostid=200208111"
		public static var timer:Timer;
		private var uploader:ByteArrayUploader;
		private var dataBlock:DataBlock;		//上传的数据块
		private var _responseData:Object;
		private var reUploadTimes:int = 0;//重传次数
		
		public function DBUploader() 
		{
			
		}
		
		
		/**
		 * 上传dataBlock
		 * @param	dataBlock 
		 */
		public function upload(dataBlock:DataBlock):void
		{
			reUploadTimes = 0;//重设 重传次数
			this.dataBlock = dataBlock;
			dataBlock.file.status = FileItem.FILE_STATUS_IN_PROGRESS;//设置图片状态为:正在上传
			uploadProcess();
		}
		
		private function uploadProcess():void
		{
			uploader= new ByteArrayUploader();//用于上传二进制数据
			uploader.url = Config.uploadUrl;//上传cgiurl
			uploader.addEventListener(IOErrorEvent.IO_ERROR, handle_ioError);
			uploader.addEventListener(Event.COMPLETE, handle_upload_complete);

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
			if (!reUpload())
			{
				uploadErrorDo(1000);
				dispatchEvent(evt);
			}
		}
		
		private function reUpload():Boolean
		{
			if (reUploadTimes < Config.reUploadMaxTimes)
			{   
				log("开始重传" + dataBlock.file.fileReference.name + "的第" + dataBlock.index + "块","第"+(++reUploadTimes)+"次");
				timer.addEventListener(TimerEvent.TIMER,handleTimer);
				return true;
			}
			else
			{
				return false;
			}
			
			function handleTimer(evt:TimerEvent):void
			{
				uploadProcess(); 
				timer.removeEventListener(TimerEvent.TIMER,handleTimer); 
			}
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
				log("json error:", e);
			}
			
			switch(int(_responseData.code))
			{
				case 0:
					checkFileCode();
				break;
				
				case 501:
					var event:ExternalEvent = new ExternalEvent(FileUploadEvent.NOT_LOGIN);
					ExternalEventDispatcher.getInstance().dispatchEvent(event);
				break;
				
				case 503:
				case 504:
				case 508:
					uploadErrorDo(uint(_responseData.code));
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
				
				default:
					uploadErrorDo(code);
			}
		}
		
		private function uploadErrorDo(errorCode:uint):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.UPLOAD_ERROR);
			event.addParam("file", dataBlock.file.getInfoObject());
			event.addParam("errorCode", errorCode);
			dataBlock.dispose();//释放内存
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
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