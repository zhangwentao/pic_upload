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
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import com.renren.picUpload.events.ThumbMakerEvent;
	import com.renren.util.img.ExifInjector;
	/**
	 * 上传主程序
	 * @author taowenzhang@gmail.com 
	 */
	public class MainProcess extends EventDispatcher
	{
		private var dataBlockNumLimit:uint = 50;//DataBlock对象的数量上限值.
		private var dataBlockSizeLimit:uint = 20480;    //文件切片大小的上限单位字节
		private var uploaderPoolSize:uint = 20;	//DBUploader对象池容量(uploader总数量)
		private var fileItemQueueSize:uint = 5;	//File队列大小
		private var picUploadNumOnce:uint;     	//一次可以上传的照片数量
		private var fileItemQueue:CirularQueue;	//用户选择的文件的File队列
		private var DBqueue:CirularQueue;		//DataBlock队列
		private var uploaderPool:ObjectPool;	//DataBlockUploader对象池
		private var lock:Boolean;				//加载本地文件到内存锁(目的:逐个加载本地文件,一个加载完,才能加载下一个)
		private var UPMonitorTimer:Timer;		//uploader对象池监控timer
		private var DBQMonitorTimer:Timer;		//DataBlock队列监控timer
		
		private var curProcessFile:FileItem;		//当前从本地加载的图片文件
		private var curProcessFileExif:ByteArray;	//当前处理的文件的EXIF信息
		
		public function MainProcess() 
		{
			init();
		}
		
		/**
		 * 初始化
		 */
		private function init():void
		{
			DataSlicer.block_size_limit = dataBlockSizeLimit;//文件切片上限
			
			DBqueue = new CirularQueue(200);//TODO:应该是一个不限长度的队列
			
			fileItemQueue = new CirularQueue(fileItemQueueSize);
			
			DBQMonitorTimer = new Timer(500);
			UPMonitorTimer = new Timer(100);
			
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
			uploaderPool = new ObjectPool(uploaderPoolSize);
			for (var i:int = 0; i < uploaderPool.size; i++)
			{
				uploaderPool.put(new DBUploader());
			}
		}
		
		/**
		 * 启动上传进程
		 */
		public function launch():void
		{
			DBQMonitorTimer.start();
			UPMonitorTimer.start();
			log("开启 mainProccessor");
		}
		
		/**
		 * 添加FileItem对象
		 * @param	fileItem	<FileItem>	
		 */
		public function addFileItem(fileItem:FileItem):void
		{
			
			if (fileItemQueue.isFull)
			{
				log("[fileItemQueue]已满");
				return;
			}
			else
			{
				fileItemQueue.enQueue(fileItem);
				log("[" + fileItem.fileReference.name + "]加入上传队列");
			}
			log("fileQueuelength:"+fileItemQueue.count)
		}
		
		
		/**
		 * 监控DBuploader对象池:
		 * TODO:1.有空闲DBuploader时，从DataBlock对象队列中取对象上传。
		 */
		private function uploaderPoolMonitor():void
		{
			
			log("!!!Uploader空闲数量:"+uploaderPool.length,"***上传缓冲区长度:"+DBqueue.count);
			if (uploaderPool.isEmpty || DBqueue.isEmpty)
			{
				/*如果没有空闲的DBUploader对象或者没有需要上传的数据块，就什么都不做*/
				return;
			}
			
			/*用一个uploader上传一个dataBlock*/
			var uploader:DBUploader = uploaderPool.fetch() as DBUploader;
			var dataBlock:DataBlock = DBqueue.deQueue() as DataBlock;
			log("开始上传 [" + dataBlock.file.fileReference.name + "] 的第" + dataBlock.index + "块数据");
			uploader.addEventListener(DBUploaderEvent.COMPLETE, handle_dataBlock_uploaded);
			uploader.upload(dataBlock);
		}
		
		/**
		 * 监控DBQueue队列：
		 * TODO:1.如果为上传的DataBlock对象数量小于上限，就去从用户选择的文件中加载文件.
		 */
		private function DBQueueMonitor():void
		{
			if (DBqueue.count >= dataBlockNumLimit || fileItemQueue.isEmpty || lock)
			{
				/*如果DBQueue中的DataBlock数量大于等于的上限或者。。就什么都不做*/
				return;
			}
			
			curProcessFile = fileItemQueue.deQueue();
			curProcessFile.fileReference.addEventListener(Event.COMPLETE, handle_fileData_loaded);
			lock = true;//上锁
			curProcessFile.fileReference.load();
			log("!!!上传缓冲区有空间,开始加载上传队列中的文件!!!DBQueue.length:"+DBqueue.count);
		}
		
		
		/**
		 * 处理本地文件加载完毕。
		 * TODO:1.压缩图片
		 * TODO:2.生成缩略图
		 * TODO:3.文件分块，放入DataBlock队列
		 * @param	evt
		 */
		function handle_fileData_loaded(evt:Event):void
		{
			log("[" + curProcessFile.fileReference.name + "]加载到内存");
			var fileData:ByteArray = evt.target.data as ByteArray;//从本地加载的图片数据
			var temp:ByteArray = new ByteArray();
			fileData.position = 0;
			fileData.readBytes(temp, 0, fileData.length);
			makeThumb(temp,curProcessFile);
			temp = new ByteArray();
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
			log("[" + curProcessFile.fileReference.name + "]开始缩略图制作");
			var thumbMaker:ThumbMaker = new ThumbMaker();
			thumbMaker.addEventListener(ThumbMakerEvent.THUMB_MAKED, handle_thumb_maked);
			thumbMaker.make(picData);
			
			function handle_thumb_maked(evt:Event):void
			{
				dispatchEvent(evt);
				log("[" + curProcessFile.fileReference.name + "]的缩略图制作完成");
				//TODO:调度事件，通知截图已经完成
			}
		}
		
		private function resizePic(picData:ByteArray):void
		{
			log("["+curProcessFile.fileReference.name+"]开始标准化");
			var resizer:PicStandardizer = new PicStandardizer();
			resizer.addEventListener(Event.COMPLETE, handle_pic_resized);
			curProcessFileExif = ExifInjector.extract(picData);//提取Exif
			log("[" + curProcessFile.fileReference.name + "]EXIF 提取完毕");
			resizer.standardize(picData);
		}
		
		private function handle_pic_resized(evt:Event):void
		{
			log("["+curProcessFile.fileReference.name+"]标准化完毕");
			var picData:ByteArray = (evt.target as PicStandardizer).dataBeenStandaized;
			picData = ExifInjector.inject(curProcessFileExif, picData);//插入exif
			log("[" + curProcessFile.fileReference.name + "]EXIF 装入完毕");
			var fileSlicer:DataSlicer = new DataSlicer();
			var dataArr:Array = fileSlicer.slice(picData);
		    log("["+curProcessFile.fileReference.name + "]被分成了" + dataArr.length + "块");
			picData.clear();//释放内存
			for (var i:int = 0; i < dataArr.length; i++)
			{
				log("["+curProcessFile.fileReference.name + "]的第"+i+"块被加入上传缓存区");
				var dataBlock:DataBlock = new DataBlock(curProcessFile,i,dataArr.length,dataArr[i]);
				DBqueue.enQueue(dataBlock);
			}
			lock = false;
		}
		
		/**
		 * DBUploader成功上传数据完毕后执行:
		 * TODO:1.把成功上传后的DBUploader对象放回DBUploader对象池。
		 * TODO:2.
		 * @param	evt	<DBUploaderEvent>
		 */
		private function handle_dataBlock_uploaded(evt:DBUploaderEvent):void
		{
			log("["+evt.dataBlock.file.fileReference.name+"]的第"+evt.dataBlock.index+"块上传完毕，释放空间");
			var uploader:DBUploader = evt.target as DBUploader;
			uploaderPool.put(uploader);
		}
	}

}