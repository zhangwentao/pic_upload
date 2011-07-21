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
	/**
	 * 主上传处理
	 * @author taowenzhang@gmail.com 
	 */
	public class MainProcess extends EventDispatcher
	{
		private var dataBlockMaxAmount:uint = 3;//DataBlock对象的数量上限值
		private var uploaderPoolSize:uint = 20;//DBUploader对象池容量
		private var fileItemQueueSize:uint= 100;//File队列容量
		
		private var fileItemQueue:CirularQueue;//用户选择的文件的File队列
		private var DBqueue:CirularQueue;//DataBlock队列
		private var uploaderPool:ObjectPool;//DataBlockUploader对象池
		
		private var lock:Boolean;//加载本地文件到内存锁(目的:逐个加载本地文件,一个加载完,才能加载下一个)
		private var UPMonitorTimer:Timer;//uploader对象池监控timer
		private var DBQMonitorTimer:Timer;//DataBlock队列监控timer
		
		private var curProcessFile:FileItem;
		
		public function MainProcess() 
		{
			init();
		}
		
		/**
		 * 初始化
		 */
		private function init():void
		{
			fileItemQueue = new CirularQueue(fileItemQueueSize);
			DBqueue = new CirularQueue(dataBlockMaxAmount);
			fileItemQueue = new CirularQueue(fileItemQueueSize);
			DBQMonitorTimer = new Timer(500);
			UPMonitorTimer = new Timer(500);
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
		}
		
		/**
		 * 添加FileItem对象
		 * @param	fileItem	<FileItem>	
		 */
		public function addFileItem(fileItem:FileItem):void
		{
			fileItemQueue.enQueue(fileItem);
		}
		
		
		/**
		 * 监控DBuploader对象池:
		 * TODO:1.有空闲DBuploader时，从DataBlock对象队列中取对象上传。
		 */
		private function uploaderPoolMonitor():void
		{
			trace("checkUploader");
			trace(uploaderPool.isEmpty, DBqueue.isEmpty);
			if (uploaderPool.isEmpty || DBqueue.isEmpty)
			{
				/*如果没有空闲的DBUploader对象或者没有需要上传的数据块，就什么都不做*/
				return;
			}
			trace("startUpload");
			/*用一个uploader上传一个dataBlock*/
			var uploader:DBUploader = uploaderPool.fetch() as DBUploader;
			var dataBlock:DataBlock = DBqueue.deQueue() as DataBlock;
			uploader.upload(dataBlock);
		}
		
		/**
		 * 监控DBQueue队列：
		 * TODO:1.如果为上传的DataBlock对象数量小于上限，就去从用户选择的文件中加载文件.
		 */
		private function DBQueueMonitor():void
		{
			if (DBqueue.length >= dataBlockMaxAmount || fileItemQueue.isEmpty || lock)
			{
				/*如果DBQueue中的DataBlock数量大于等于的上限或者。。就什么都不做*/
				return;
			}
			
			curProcessFile = fileItemQueue.deQueue();
			curProcessFile.fileReference.addEventListener(Event.COMPLETE, handle_fileData_loaded);
			lock = true;//上锁
			curProcessFile.fileReference.load();
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
			var thumbMaker:ThumbMaker = new ThumbMaker();
			thumbMaker.addEventListener(Event.COMPLETE, handle_thumb_maked);
			thumbMaker.make(picData);
			
			function handle_thumb_maked(evt:Event):void
			{
				//TODO:调度事件，通知截图已经完成
				dispatchEvent(evt);
			}
		}
		
		private function resizePic(picData:ByteArray):void
		{
			trace("resize");
			var resizer:PicStandardizer = new PicStandardizer();
			resizer.addEventListener(Event.COMPLETE, handle_pic_resized);
			resizer.standardize(picData);
		}
		
		private function handle_pic_resized(evt:Event):void
		{
			trace("handleResized");
			var picData:ByteArray = (evt.target as PicStandardizer).dataBeenStandaized;
			var fileSlicer:DataSlicer = new DataSlicer();
			var dataArr:Array = fileSlicer.slice(picData);
		
			picData.clear();//释放内存
			for (var i:int = 0; i < dataArr.length; i++)
			{
				trace("enqueue");
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
			var uploader:DBUploader = evt.target as DBUploader;
			uploaderPool.put(uploader);
		}
	}

}