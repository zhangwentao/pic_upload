package com.renren.picUpload 
{
	import com.renren.external.ExternalEvent;
	import com.renren.external.ExternalEventDispatcher;
	import com.renren.picUpload.DataSlicer;
	import com.renren.picUpload.events.DBUploaderEvent;
	import com.renren.picUpload.events.FileItemEvent;
	import com.renren.picUpload.events.FileUploadEvent;
	import com.renren.picUpload.events.PicUploadEvent;
	import com.renren.picUpload.events.ThumbMakerEvent;
	import com.renren.util.CirularQueue;
	import com.renren.util.ObjectPool;
	import com.renren.util.img.ExifInjector;
	import com.renren.util.net.SimpleURLLoader;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	
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
		private var fileItemQueue:Vector.<FileItem>;		//用户选择的文件的File队列
		private var DBqueue:Array;						//DataBlock队列
		private var uploaderPool:ObjectPool;			//DataBlockUploader对象池
		private var loadFileLock:Boolean;				//加载本地文件到内存锁(目的:逐个加载本地文件,一个加载且处理完毕,才能加载下一个)
		private var UPMonitorTimer:Timer;				//uploader对象池监控timer
		private var DBQMonitorTimer:Timer;				//DataBlock队列监控timer
		private var  _fileItemQueuedNum:uint = 0;     	//已加入上传队列的FileItem数量
		private var curProcessFile:FileItem;			//当前从本地加载的图片文件
		
		private var curProcessFileExif:ByteArray;		//当前处理的文件的EXIF信息
		
		private var lockCheckerTimer:Timer = new Timer(4000);//
		
		
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
			lockCheckerTimer.addEventListener(TimerEvent.TIMER, checkLock);
			DBUploader.timer = new Timer(Config.reUploadDelayTime);
			DBUploader.timer.start();
			DataSlicer.block_size_limit = Config.dataBlockSizeLimit;//设置文件切片上限
			DBqueue = new Array();//TODO:应该是一个不限长度的队列,因为这里存在一种'超支'的情况。
			fileItemQueue = new Vector.<FileItem>();//
			DBQMonitorTimer = new Timer(Config.DBQCheckInterval);
			UPMonitorTimer = new Timer(Config.UPCheckInterval);
			DBQMonitorTimer.addEventListener(TimerEvent.TIMER, function() { DBQueueMonitor(); } );
			UPMonitorTimer.addEventListener(TimerEvent.TIMER, function() { uploaderPoolMonitor(); } );
			initUploaderPoll();
		}
		
		/**
		 * 初始化uploader对象池
		 * 1.创建对象池对象，并以DBUploader对象填充
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
			if(_fileItemQueuedNum<Config.picUploadNumOnce)
			{
				fileItem.status = FileItem.FILE_STATUS_QUEUED;//修改文件状态为:已加入上传队列
				fileItemQueue.push(fileItem);   
				_fileItemQueuedNum++;
				dispatchEvent(new FileItemEvent(FileItemEvent.FILE_QUEUED,fileItem));
			}
			else
			{
				
			}
			
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
				result = false;
				var event:PicUploadEvent = new PicUploadEvent(PicUploadEvent.ZERO_BYTE_FILE, fileItem);
				dispatchEvent(event);
			}
			
			if (fileItem.fileReference.size > Config.maxSingleFileSize)
			{
				result = false;
				var event2:PicUploadEvent = new PicUploadEvent(PicUploadEvent.FILE_EXCEEDS_SIZE_LIMIT, fileItem);
				dispatchEvent(event2);
			}
			return result;
		}
		
		
		public function cancelUpload(fileItemId:String):void
		{
			for(var i:int = 0; i<fileItemQueue.length;i++)
			{
				var fileItem = fileItemQueue[i];
				
				if (fileItem.id == fileItemId)
				{
					fileItemQueue.splice(i,1);
					_fileItemQueuedNum--;
					fileItem.status = FileItem.FILE_STATUS_CANCELLED;
					dispatchEvent(new FileItemEvent(FileItemEvent.UPLOAD_CANCELED,fileItem));
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
			//log("!!!Uploader空闲数量:"+uploaderPool.length,"***上传缓冲区长度:"+DBqueue.length);
			if (uploaderPool.isEmpty || !DBqueue.length)
			{
				/*如果没有空闲的DBUploader对象或者没有需要上传的数据块，就什么都不做*/
				return;
			}
			
			/*用一个uploader上传一个dataBlock*/
			var uploader:DBUploader = uploaderPool.fetch() as DBUploader;
			var dataBlock:DataBlock = DBqueue.shift() as DataBlock;
			log("***上传缓冲区长度:"+DBqueue.length);
			log("开始上传 [" + dataBlock.fileItem.fileReference.name + "] 的第" + dataBlock.index + "块数据");
			uploader.addEventListener(DBUploaderEvent.FILE_COMPLETE, handle_file_uploaded);
			uploader.addEventListener(DBUploaderEvent.COMPLETE, handle_dataBlock_uploaded);
			uploader.addEventListener(DBUploaderEvent.UPLOAD_CANCELED, handle_uploade_canceled);
            uploader.addEventListener(IOErrorEvent.IO_ERROR, handle_IOError);
			uploader.addEventListener(PicUploadEvent.NOT_LOGIN, handle_notLogin);
			dispatchEvent(new PicUploadEvent(PicUploadEvent.UPLOAD_PROGRESS,dataBlock.fileItem));
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
		 * 1.如果未上传的DataBlock对象数量小于上限，就去从用户选择的文件中加载文件.
		 */
		private function DBQueueMonitor():void
		{
			if (DBqueue.length >= Config.dataBlockNumLimit || !fileItemQueue.length || loadFileLock)
			{
				/*如果DBQueue中的DataBlock数量大于等于的上限或者。。就什么都不做*/
				return;
			}
			
			loadFileLock = true;//上锁log("上锁");
		
			do{
				curProcessFile = fileItemQueue.shift();
			    if (fileItemQueue.length == 0)
					break;
				
			}while (curProcessFile.status == FileItem.FILE_STATUS_CANCELLED)
			
			if (curProcessFile.status == FileItem.FILE_STATUS_CANCELLED)
			{
				loadFileLock = false;
				return;
			}
			
			log("[" + curProcessFile.fileReference.name + "]增加监听");
			
			curProcessFile.fileReference.addEventListener(Event.COMPLETE, handle_fileData_loaded);
			curProcessFile.fileReference.addEventListener(IOErrorEvent.IO_ERROR, handle_loadFile_IOError);
			
			curProcessFile.fileReference.load();
			dispatchEvent(new FileItemEvent(FileItemEvent.START_PROCESS_FILE,curProcessFile));
			
			log("!!!上传缓冲区有空间,开始加载上传队列中的["+curProcessFile.fileReference.name+"]文件!!!DBQueue.length:"+DBqueue.length);
		}
		
		
			
		private function handle_loadFile_IOError(evt:IOErrorEvent):void
		{
			log("load [" + curProcessFile.fileReference.name + "] Error");
			loadFileLock = false;
			dispatchEvent(new FileItemEvent(FileItemEvent.LOAD_LOCAL_FILE_IO_ERROR,curProcessFile));
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
			log("[" + curProcessFile.fileReference.name + "]加载到内存");
			curProcessFile.fileReference.removeEventListener(Event.COMPLETE, handle_fileData_loaded);
			
			var fileData:ByteArray = evt.target.data as ByteArray;//从本地加载的图片数据
			
			var imgType:String = IMGValidater.validate(fileData);
			
			if (imgType == IMGValidater.INVALIDATE_IMG_TYPE)
			{
				log("[" + curProcessFile.fileReference.name + "]不是有效图片文件");
				dispatchEvent(new FileItemEvent(FileItemEvent.INVALIDATE_IMG_TYPE,curProcessFile));
				loadFileLock = false;
				log("开锁");
				return;
			}
			
			if (imgType == IMGValidater.IMG_TYPE_BMP)
			{
				sliceData(fileData);
				return;
			}
			
			if(imgType == IMGValidater.IMG_TYPE_JPG)
			{
				curProcessFileExif = ExifInjector.extract(picData);//提取Exif
				log("[" + curProcessFile.fileReference.name + "]EXIF 提取完毕");
			}
			
			resizePic(fileData);
		}
		
		
		private function resizePic(picData:ByteArray):void
		{
			log("[" + curProcessFile.fileReference.name + "]开始标准化");
			var resizer:PicStandardizer = new PicStandardizer(int(Config.maxPicSize));
			resizer.addEventListener(Event.COMPLETE, handle_pic_resized);
			resizer.standardize(picData);
		}
		
		private function handle_pic_resized(evt:Event):void
		{
			log("["+curProcessFile.fileReference.name+"]标准化完毕");
			var picData:ByteArray = (evt.target as PicStandardizer).dataBeenStandaized;
			picData = ExifInjector.inject(curProcessFileExif, picData);//插入exif
			log("[" + curProcessFile.fileReference.name + "]EXIF 装入完毕");
			sliceData(picData);
		}
		
		private function sliceData(picData:ByteArray):void
		{
			log("sliceData", "lock:" + loadFileLock);
			var fileSlicer:DataSlicer = new DataSlicer();
			var dataArr:Array = fileSlicer.slice(picData);
		    log("["+curProcessFile.fileReference.name + "]被分成了" + dataArr.length + "块");
			picData.clear();//释放内存
			for (var i:int = 0; i < dataArr.length; i++)
			{
				log("["+curProcessFile.fileReference.name + "]的第"+i+"块被加入上传缓存区");
				var dataBlock:DataBlock = new DataBlock(curProcessFile,i,dataArr.length,dataArr[i]);
				DBqueue.push(dataBlock);
				curProcessFile.dataBlockArr.push(dataBlock);
			}
			loadFileLock = false;
			log("sliceOver", "lock:" + loadFileLock);
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
			log("[" + evt.dataBlock.fileItem.fileReference.name + "]上传完毕");
			log("fileQueueNum:" + fileItemQueue.count);
			evt.dataBlock.fileItem.status = FileItem.FILE_STATUS_SUCCESS;
			var uploader:DBUploader = evt.target as DBUploader;
			uploaderPool.put(uploader);
			var event:PicUploadEvent = new PicUploadEvent(PicUploadEvent.UPLOAD_SUCCESS, evt.dataBlock.fileItem);
			event.data = evt.target.responseData;
			dispatchEvent(event);
		}
		
		private function handle_dataBlock_uploaded(evt:DBUploaderEvent):void
		{
			log("[" + evt.dataBlock.fileItem.fileReference.name + "]的第" + evt.dataBlock.index + "块上传完毕，释放空间");
			log("fileQueueNum:" + fileItemQueue.count);
			var uploader:DBUploader = evt.target as DBUploader;
			uploaderPool.put(uploader);
		}
		
		private function handle_uploade_canceled(evt:DBUploaderEvent):void
		{
			var uploader:DBUploader = evt.target as DBUploader;
			uploaderPool.put(uploader);
		}

	}

}