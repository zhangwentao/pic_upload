package com.renren.picUpload 
{
	import com.adobe.serialization.json.JSON;
	import com.renren.external.ExternalEvent;
	import com.renren.external.ExternalEventDispatcher;
	import com.renren.picUpload.events.DBUploaderEvent;
	import com.renren.picUpload.events.FileUploadEvent;
	import com.renren.picUpload.events.PicUploadEvent;
	import com.renren.util.net.ByteArrayUploader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	/**
	 * 上传DataBlock至服务器
	 * @author taowenzhang@gmail.com
	 */
	class DBUploader extends EventDispatcher
	{
		//"http://upload.renren.com/upload.fcgi?pagetype=addflash&hostid=200208111"
		public static var timer:Timer;			//重试上传timer
		private var uploader:ByteArrayUploader;
		private var dataBlock:DataBlock;			//上传的数据块
		private var _responseData:Object;
		private var _rawResponseData:String;
		private var reUploadTimes:int = 0;			//重传次数
		
		public function DBUploader() 
		{
			
		}
		
		/**
		 * 上传dataBlock
		 * @param	dataBlock 	<DataBlock>
		 */
		public function upload(dataBlock:DataBlock):void
		{
			reUploadTimes = 0;//重设重传次数
			this.dataBlock = dataBlock;

			if (dataBlock.fileItem.status == FileItem.FILE_STATUS_CANCELLED)
			{
				cancelProcess();
				return;
			}
			
			dataBlock.fileItem.status = FileItem.FILE_STATUS_IN_PROGRESS;//设置图片状态为:正在上传
			
			dataBlock.fileItem.addEventListener(FileItem.FILE_EVENT_CANCELLED,handleFileCancelled);
			
			uploadProcess();
		}
		
		private function handleFileCancelled(evt:Event):void
		{
			cancel();
		}
		
		/**
		 * 取消当前的上传操作
		 */
		public function cancel():void
		{
			uploader.cancel();
			cancelProcess();
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
			urlVar["uploadid"] = dataBlock.fileItem.id;
			
			uploader.upLoad(dataBlock.data);
		}
		
		public function get responseData():Object
		{
			return _rawResponseData; 
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
		
		/**
		 * 网络
		 * @return <Boolean>  
		 * 
		 */		
		private function reUpload():Boolean
		{
			if (reUploadTimes < Config.reUploadMaxTimes)
			{   
				log("开始重传" + dataBlock.fileItem.fileReference.name + "的第" + dataBlock.index + "块","第"+(++reUploadTimes)+"次");
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
		 * @see http://doc.d.xiaonei.com/index.php?title=Upload_interface
		 */
		private function handle_upload_complete(evt:Event):void
		{
			
			_rawResponseData = String(uploader.data);
			try 
			{
				_responseData = JSON.decode(String(uploader.data));
			}
			catch (e)
			{
				log("json string returned from server is invalidate:", e);
			}
			
			switch(int(_responseData.code))
			{
				case 0:
					//数据块上传成功
					checkFileCode();
				break;
				     
				case 501:
					//用户未登录
					var event:PicUploadEvent = new PicUploadEvent(PicUploadEvent.NOT_LOGIN,dataBlock.fileItem);
					dispatchEvent(event);
				break;
				
				case 503:
				case 504:
				case 508:
				case 536：
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
					//此图片处理成功
					oneFileCompleteDo();
				break;
				
				
				case 523:
					//仍有数据块待上传
					oneBlockCompleteDo();
				break;
				    
				default:
					uploadErrorDo(code);
			}
		}
		
		/**
		 * 取消上传操作
		 */		
		private function cancelProcess():void
		{
			var event:DBUploaderEvent = new DBUploaderEvent(DBUploaderEvent.UPLOAD_CANCELED);
			event.dataBlock = dataBlock;
			dispatchEvent(event);
			dataBlock.dispose();//释放内存
		}

		/**
		 * 处理上传错误
		 * @param errorCode
		 * 
		 */		
		private function uploadErrorDo(errorCode:uint):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.UPLOAD_ERROR);
			event.addParam("file", dataBlock.fileItem.getInfoObject());
			event.addParam("errorCode", errorCode);
			dataBlock.dispose();//释放内存
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
		}
		
		/**
		 * 一个数据块上传完成后的操作
		 * 
		 */		
		private function oneBlockCompleteDo():void
		{
			var event:DBUploaderEvent = new DBUploaderEvent(DBUploaderEvent.UPLOAD_BLOCK_COMPLETE);
			event.dataBlock = dataBlock;
			dispatchEvent(event);
			dataBlock.dispose();//释放内存
		}
		
		/**
		 * 一个文件上传完成后的操作
		 * 
		 */		
		private function oneFileCompleteDo():void
		{
			var event:DBUploaderEvent = new DBUploaderEvent(DBUploaderEvent.UPLOAD_FILE_COMPLETE);
			event.dataBlock = dataBlock;
			dispatchEvent(event);
			dataBlock.dispose();//释放内存
		}
		
	}
}