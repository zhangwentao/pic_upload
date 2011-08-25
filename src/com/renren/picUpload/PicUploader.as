package com.renren.picUpload 
{
	import com.renren.picUpload.events.DBUploaderEvent;
	import com.renren.picUpload.DataSlicer;
	import com.renren.util.CirularQueue;
	import com.renren.util.net.SimpleURLLoader;
	import com.renren.util.ObjectPool;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import com.renren.picUpload.events.ThumbMakerEvent;
	import com.renren.util.img.ExifInjector;
	import com.renren.picUpload.events.PicUploadEvent;
	import flash.external.ExternalInterface;
	import flash.events.IOErrorEvent;
	import com.renren.picUpload.events.FileUploadEvent;
	/**
	 * 缩略图绘制完毕事件
	 */
	[Event(name = ThumbMakerEvent.THUMB_MAKED, type = "ThumbMakerEvent")]
	
	/**
	 * 图片上传成功事件
	 */
	[Event(name = PicUploadEvent.UPLOAD_SUCCESS, type = "PicUploadEvent")]
	
	/**
	 * 缩略图制作中
	 */
	[Event(name = ThumbMakerEvent.THUMB_MAKE_PROGRESS, type = "ThumbMakerEvent")]
	
	/**
	 * 上传主程序
	 * @author taowenzhang@gmail.com 
	 */
	public class PicUploader extends EventDispatcher
	{
		private var fileItemQueue:CirularQueue;			//用户选择的文件的File队列
		private var DBqueue:Array;						//DataBlock队列
		private var uploaderPool:ObjectPool;			//DataBlockUploader对象池
		private var lock:Boolean;						//加载本地文件到内存锁(目的:逐个加载本地文件,一个加载完,才能加载下一个)
		private var UPMonitorTimer:Timer;				//uploader对象池监控timer
		private var DBQMonitorTimer:Timer;				//DataBlock队列监控timer
		public var fileItemQueuedNum:uint = 0;     	//已加入上传队列的FileItem数量
		private var curProcessFile:FileItem;			//当前从本地加载的图片文件
		private var curFileReference:FileReference;
		private var curProcessFileExif:ByteArray;		//当前处理的文件的EXIF信息
		
		
		/**
		 * 构造函数
		 */
		public function PicUploader() 
		{
			
		}
		
		/**
		 * 初始化
		 */
		public function init():void
		{
			DBUploader.timer = new Timer(Config.reUploadDelayTime);
			DBUploader.timer.start();
			DataSlicer.block_size_limit = Config.dataBlockSizeLimit;//设置文件切片上限
			DBqueue = new Array();//TODO:应该是一个不限长度的队列,因为这里存在一种'超支'的情况。
			fileItemQueue = new CirularQueue(Config.picUploadNumOnce);
			DBQMonitorTimer = new Timer(Config.DBQCheckInterval);
			UPMonitorTimer = new Timer(Config.UPCheckInterval);
			DBQMonitorTimer.addEventListener(TimerEvent.TIMER, function() { DBQueueMonitor(); } );
			UPMonitorTimer.addEventListener(TimerEvent.TIMER, function() { uploaderPoolMonitor(); } );
			initUploaderPoll();
		}
		
		/**
		 * 初始化uploader对象池
		 * 1.创建对象池对象，并以 DBUploader对象填充
		 */
		private function initUploaderPoll():void
		{
			uploaderPool = new ObjectPool(Config.uploaderPoolSize);
			for (var i:int = 0; i < uploaderPool.size; i++)
			{
				uploaderPool.put(new DBUploader());
			}
		}
		
		/**
		 * 启动上传进程
		 */
		public function start():void
		{
			DBQMonitorTimer.start();
			UPMonitorTimer.start();
			log("开启上传进程");
		}
		
		/**
		 * 关闭上传进程
		 */
		public function stop():void
		{
			DBQMonitorTimer.stop();
			UPMonitorTimer.stop();
			log("关闭上传进程");
		}
		
		/**
		 * 添加FileItem对象
		 * @param	fileItem	<FileItem>	
		 */
		public function addFileItem(fileItem:FileItem):void
		{
			if(fileItemQueuedNum >= Config.picUploadNumOnce)
			{
				var event:PicUploadEvent = new PicUploadEvent(PicUploadEvent.QUEUE_LIMIT_EXCEEDED, fileItem);
				dispatchEvent(event);
				log("超过了一次可上传的最大数量:"+Config.picUploadNumOnce);
				return;
			}
			
			if (!validateFile(fileItem))
			{
				dispatchEvent(new PicUploadEvent(PicUploadEvent.FILE_QUEUED, fileItem));
				return;
			}
			
			
			fileItemQueue.enQueue(fileItem);   
			fileItem.status = FileItem.FILE_STATUS_QUEUED;//修改文件状态为:已加入上传队列
			fileItemQueuedNum++;
			dispatchEvent(new PicUploadEvent(PicUploadEvent.FILE_QUEUED, fileItem));
			
			
			log("fileQueuelength:"+fileItemQueue.count)
		}
	
		
		/**
		 * 验证文件是否合法
		 * 1.文件是否为空文件
		 * @param	fileItem
		 * @return	<Boolean>	是否合法
		 */
		private function validateFile(fileItem:FileItem):Boolean
		{
			var result:Boolean = true;
			if (fileItem.fileReference.size == 0)
			{
				var event:PicUploadEvent = new PicUploadEvent(PicUploadEvent.ZERO_BYTE_FILE, fileItem);
				dispatchEvent(event);
				result = false;
			}
			
			if (fileItem.fileReference.size > Config.maxSingleFileSize)
			{
				var event2:PicUploadEvent = new PicUploadEvent(PicUploadEvent.FILE_EXCEEDS_SIZE_LIMIT, fileItem);
				dispatchEvent(event);
				result = false;
			}
			
			return result;
		}
		
		public function cancelAFile(fileId:String):void
		{
			var arr:Array = fileItemQueue.toArray();
			
			for each(var file:FileItem in arr)
			{
				if (file.id == fileId)
				{
					switch(file.status)
					{
						case FileItem.FILE_STATUS_QUEUED:
						case FileItem.FILE_STATUS_SUCCESS:
							fileItemQueuedNum--;//
							file.status = FileItem.FILE_STATUS_CANCELLED;
							var event:PicUploadEvent = new PicUploadEvent(PicUploadEvent.UPLOAD_CANCELED, file);
							dispatchEvent(event);
						break;
						
						
					}
					return;
				}
			}
		}
		
		/**
		 * 监控DBuploader对象池:
		 * TODO:1.有空闲DBuploader时，从DataBlock对象队列中取对象上传。
		 */
		private function uploaderPoolMonitor():void
		{
			
			log("!!!Uploader空闲数量:"+uploaderPool.length,"***上传缓冲区长度:"+DBqueue.length);
			if (uploaderPool.isEmpty || !DBqueue.length)
			{
				/*如果没有空闲的DBUploader对象或者没有需要上传的数据块，就什么都不做*/
				return;
			}
			
			/*用一个uploader上传一个dataBlock*/
			var uploader:DBUploader = uploaderPool.fetch() as DBUploader;
			var dataBlock:DataBlock = DBqueue.shift() as DataBlock;
			log("***上传缓冲区长度:"+DBqueue.length);
			log("开始上传 [" + dataBlock.file.fileReference.name + "] 的第" + dataBlock.index + "块数据");
			uploader.addEventListener(DBUploaderEvent.FILE_COMPLETE, handle_file_uploaded);
			uploader.addEventListener(DBUploaderEvent.COMPLETE, handle_dataBlock_uploaded);
            uploader.addEventListener(IOErrorEvent.IO_ERROR, handle_IOError);
			uploader.addEventListener(PicUploadEvent.NOT_LOGIN, handle_notLogin);
			dispatchEvent(new PicUploadEvent(PicUploadEvent.UPLOAD_PROGRESS,dataBlock.file));
			uploader.upload(dataBlock);
		}
		
		private function handle_notLogin(evt:PicUploadEvent):void
		{
			dispatchEvent(evt);
		}
		
		private function handle_IOError(evt:IOErrorEvent):void
		{
			dispatchEvent(evt);
		}
		
		/**
		 * 监控DBQueue队列：
		 * TODO:1.如果为上传的DataBlock对象数量小于上限，就去从用户选择的文件中加载文件.
		 */
		private function DBQueueMonitor():void
		{
			log("fileQueueNum:"+fileItemQueue.count,"lock:"+lock,"dbqueuelength:"+DBqueue.length);
			if (DBqueue.length >= Config.dataBlockNumLimit || fileItemQueue.isEmpty || lock)
			{
				/*如果DBQueue中的DataBlock数量大于等于的上限或者。。就什么都不做*/
				return;
			}
			lock = true;//上锁
			log("上锁");
			curProcessFile = fileItemQueue.deQueue();
			
			while (curProcessFile.status == FileItem.FILE_STATUS_CANCELLED)
			{
			    if (fileItemQueue.count == 0)
					break;
				curProcessFile = fileItemQueue.deQueue();
			}
			curFileReference = curProcessFile.fileReference;
			log("[" + curFileReference.name + "]增加监听");
			curFileReference.addEventListener(Event.COMPLETE, handle_fileData_loaded);
			curFileReference.addEventListener(IOErrorEvent.IO_ERROR, handle_loadFile_IOError);
			curFileReference.addEventListener(Event.OPEN, handle_load_open);
			curFileReference.load();
			log("!!!上传缓冲区有空间,开始加载上传队列中的["+curFileReference.name+"]文件!!!DBQueue.length:"+DBqueue.length);
		}
		
		private function handle_load_open(evt:Event):void
		{
			log("[" + evt.target.name + "] startLoad");
		}
		
		private function handle_loadFile_IOError(evt:IOErrorEvent):void
		{
			log("load [" + curFileReference.name + "] Error");
			lock = false;
			log("开锁");
		}
		
		/**
		 * 处理本地文件加载完毕。
		 * TODO:1.压缩图片
		 * TODO:2.生成缩略图
		 * TODO:3.文件分块，放入DataBlock队列
		 * @param	evt
		 */
		private function handle_fileData_loaded(evt:Event):void
		{
			log("[" + curFileReference.name + "]加载到内存");
			var fileData:ByteArray = evt.target.data as ByteArray;//从本地加载的图片数据
			var temp:ByteArray = new ByteArray();
			
			
			if (BMPValidater.validate(fileData))
			{
				sliceData(fileData);
				return;
			}
			
			fileData.position = 0;
			fileData.readBytes(temp, 0, fileData.length);
			resizePic(temp);
			fileData.clear();//释放内存
		}
		
		/**
		 * 获取缩略图
		 * @param	picData	<ByteArray>	
		 * @param	file	<FileItem>
		 */
		private function makeThumb(picData:ByteArray,file:FileItem):void
		{
			log("[" + curFileReference.name + "]开始缩略图制作");
			var thumbMaker:ThumbMaker = new ThumbMaker();
			thumbMaker.addEventListener(ThumbMakerEvent.THUMB_MAKED, handle_thumb_maked);
			thumbMaker.make(picData,file);
			dispatchEvent(new ThumbMakerEvent(ThumbMakerEvent.THUMB_MAKE_PROGRESS,null, file));//制作缩略图中
			function handle_thumb_maked(evt:Event):void
			{
				dispatchEvent(evt);
				log("[" + curFileReference.name + "]的缩略图制作完成");
				//TODO:调度事件，通知截图已经完成
			}
		}
		
		private function resizePic(picData:ByteArray):void
		{
			var event:PicUploadEvent = new PicUploadEvent(PicUploadEvent.START_PROCESS_FILE, curProcessFile);
			dispatchEvent(event);
			
			log("[" + curFileReference.name + "]开始标准化");
			
			var resizer:PicStandardizer = new PicStandardizer();
			resizer.addEventListener(Event.COMPLETE, handle_pic_resized);
			curProcessFileExif = ExifInjector.extract(picData);//提取Exif
			log("[" + curFileReference.name + "]EXIF 提取完毕");
			resizer.standardize(picData);
		}
		
		private function handle_pic_resized(evt:Event):void
		{
			
			log("["+curFileReference.name+"]标准化完毕");
			var picData:ByteArray = (evt.target as PicStandardizer).dataBeenStandaized;
			picData = ExifInjector.inject(curProcessFileExif, picData);//插入exif
			log("[" + curFileReference.name + "]EXIF 装入完毕");
			sliceData(picData);
		}
		
		private function sliceData(picData:ByteArray):void
		{
			log("sliceData", "lock:" + lock);
			var fileSlicer:DataSlicer = new DataSlicer();
			var dataArr:Array = fileSlicer.slice(picData);
		    log("["+curFileReference.name + "]被分成了" + dataArr.length + "块");
			picData.clear();//释放内存
			for (var i:int = 0; i < dataArr.length; i++)
			{
				log("["+curFileReference.name + "]的第"+i+"块被加入上传缓存区");
				var dataBlock:DataBlock = new DataBlock(curProcessFile,i,dataArr.length,dataArr[i]);
				DBqueue.push(dataBlock);
			}
			lock = false;
			log("sliceOver", "lock:" + lock);
			log("开锁");
		}
		
		/**
		 * DBUploader成功上传数据完毕后执行:
		 * TODO:1.把成功上传后的DBUploader对象放回DBUploader对象池。
		 * TODO:2.
		 * @param	evt	<DBUploaderEvent>
		 */
		private function handle_file_uploaded(evt:DBUploaderEvent):void
		{
			log("[" + evt.dataBlock.file.fileReference.name + "]上传完毕");
			log("fileQueueNum:" + fileItemQueue.count);
			evt.dataBlock.file.status = FileItem.FILE_STATUS_SUCCESS;
			var uploader:DBUploader = evt.target as DBUploader;
			uploaderPool.put(uploader);
			var event:PicUploadEvent = new PicUploadEvent(PicUploadEvent.UPLOAD_SUCCESS, evt.dataBlock.file);
			event.data = evt.target.responseData;
			dispatchEvent(event);
		}
		
		private function handle_dataBlock_uploaded(evt:DBUploaderEvent):void
		{
			log("[" + evt.dataBlock.file.fileReference.name + "]的第" + evt.dataBlock.index + "块上传完毕，释放空间");
			log("fileQueueNum:" + fileItemQueue.count);
			var uploader:DBUploader = evt.target as DBUploader;
			uploaderPool.put(uploader);
			
		}
	}

}