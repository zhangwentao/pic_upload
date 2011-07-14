package com.renren.picUpload 
{
	import com.renren.picUpload.events.DBUploaderEvent;
	import com.renren.util.CirularQueue;
	import com.renren.util.net.SimpleURLLoader;
	import com.renren.util.ObjectPool;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * 主上传处理
	 * @author taowenzhang@gmail.com 
	 */
	public class MainProcess
	{
		private var dataBlockMaxAmount:uint;//DataBlock对象的数量上限值
		
		private var fileQueue:CirularQueue;//用户选择的文件的File队列
		private var DBqueue:CirularQueue;//DataBlock队列
		private var uploaderPool:ObjectPool;//DataBlockUploader对象池
		private var lock:Boolean;//加载本地文件到内存锁(目的:逐个加载本地文件)
		private var UPMonitorTimer:Timer;//uploader对象池监控timer
		private var DBQMonitorTimer:Timer;//DataBlock队列监控timer
		
		public function MainProcess() 
		{
			init();
		}
		
		/**
		 * 初始化
		 */
		private function init():void
		{
			DBQMonitorTimer = new Timer(100);
			UPMonitorTimer = new Timer(100);
			DBQMonitorTimer.addEventListener(TimerEvent.TIMER, function() { DBQueueMonitor(); } );
			UPMonitorTimer.addEventListener(TimerEvent.TIMER, function() { uploaderPoolMonitor(); } );
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
		 * 添加File对象数组
		 * @param	files	<File>	
		 */
		public function pushFiles(files:Array):void
		{
			
		}
		
		/**
		 * 监控DBuploader对象池:
		 * TODO:1.有空闲DBuploader时，从DataBlock对象队列中取对象上传。
		 */
		private function uploaderPoolMonitor():void
		{
			if (uploaderPool.isEmpty || DBqueue.isEmpty)
			{
				/*如果没有空闲的DBUploader对象，就什么都不做*/
				return;
			}
			
			/*用一个uploader上传一个dataBlock*/
			var uploader:DBUploader = uploaderPool.fetch() as DBUploader;
			var dataBlock:DataBlock = DBqueue.deQueue() as DataBlock;
			uploader.upload(dataBlock);
		}
		
		/**
		 * 监控DBQueue队列：
		 * TODO:1.如果为上传的DataBlock对象数量小于上限，就去从用户选择的文件中加载文件，并分块。
		 * 
		 */
		private function DBQueueMonitor():void
		{
			if (DBqueue.length >= dataBlockMaxAmount || fileQueue.isEmpty || lock)
			{
				/*如果DBQueue中的DataBlock数量大于等于的上限，什么都不做*/
				return;
			}
			
			var file:File = fileQueue.deQueue();
			file.fileReference.addEventListener(Event.COMPLETE, handleFileLoaded);
			lock = true;
			file.fileReference.load();
		}
		
		/**
		 * 处理本地文件加载完毕。
		 * @param	evt
		 */
		function handleFileLoaded(evt:Event):void
		{
			evt.target.removeEventListener(Event.COMPLETE, handleFileLoaded);
			var fileSlicer:FileSlicer = new FileSlicer();
			var DBArr:Array = fileSlicer.slice(evt.target.data);
			for (var i:int = 0; i < DBArr.length; i++)
			{
				DBqueue.enQueue(DBArr[i]);
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