package com.renren.picUpload 
{
	import com.adobe.serialization.json.JSON;
	import com.renren.external.ExternalEvent;
	import com.renren.external.ExternalEventDispatcher;
	import com.renren.picUpload.events.DBUploaderEvent;
	import com.renren.picUpload.events.FileUploadEvent;
	import com.renren.picUpload.events.PicUploadEvent;
	import com.renren.util.Logger;
	import com.renren.util.net.ByteArrayUploader;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	/**
	 * 上传 DataBlock 至服务器
	 * @author taowenzhang@gmail.com
	 */
	class DBUploader extends EventDispatcher
	{
		//"http://upload.renren.com/upload.fcgi?pagetype=addflash&hostid=200208111"
		public static var timer:Timer;//重试上传timer
		private var uploader:ByteArrayUploader;
		private var dataBlock:DataBlock;		//上传的数据块
		private var _responseData:Object;
		private var _rawResponseData:String;
		private var reUploadTimes:int = 0;//重传次数
		private var uploadStartTime:Number;//上传开始的时刻
		private var uploadTime:Number;
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
			uploadStartTime = new Date().getTime();
			uploader.upLoad(dataBlock.data);
		}
		
		public function get responseData():Object
		{
			return encodeURIComponent(_rawResponseData); 
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
			uploadTime = new Date().getTime()-uploadStartTime;//统计上传数据花费的时间
			_rawResponseData = String(uploader.data);
			try 
			{
				_responseData = JSON.decode(String(uploader.data));
				log("json:\n");
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
					var event:PicUploadEvent = new PicUploadEvent(PicUploadEvent.NOT_LOGIN,dataBlock.file);
					dispatchEvent(event);
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
			dataBlock.file.statistics.uploadTimeArr.push(uploadTime);
			dataBlock.file.statistics.dataSizeArr.push(dataBlock.data.length);
			var event:DBUploaderEvent = new DBUploaderEvent(DBUploaderEvent.COMPLETE);
			event.dataBlock = dataBlock;
			dispatchEvent(event);
			dataBlock.dispose();//释放内存
		}
		
		private function oneFileCompleteDo():void
		{
			dataBlock.file.statistics.uploadTimeArr.push(uploadTime);
			dataBlock.file.statistics.dataSizeArr.push(dataBlock.data.length);
			var event:DBUploaderEvent = new DBUploaderEvent(DBUploaderEvent.FILE_COMPLETE);
			event.dataBlock = dataBlock;
			dispatchEvent(event);
			dataBlock.dispose();//释放内存
		}
		
	}
}