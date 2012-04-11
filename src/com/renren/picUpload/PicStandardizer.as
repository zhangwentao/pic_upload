package com.renren.picUpload 
{
	import com.renren.picUpload.events.EncodeCompleteEvent;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.renren.util.Logger;
	
	
	/**
	 * 标准化图片尺寸
	 * 策略:使图片的长度和高度均在一个上限值以下
	 * @author taowenzhang@gmail.com 
	 */
	
	class PicStandardizer extends EventDispatcher
	{
		public static const OVER_DIMENTION_EVENT:String = "overDimention";
		private var _limit:int;//上限值
		private var _data:ByteArray;//尺寸标准化后的图片数据
		private var _rawData:ByteArray;//原始数据
		private var temp_height:int = 0;
		private var temp_width:int = 0;
		private var compressStartTime:Number=0;//开始对图片进行处理的时刻
		public var compressTime:Number = 0;//对图片进行处理的总时间
		private var timer:Timer = new Timer(500);
		private var bitmapData:BitmapData;
		/**
		 * 构造函数
		 * @param	limit	<Number>	图片宽度和高度的上限值
		 */
		public function PicStandardizer(limit:int=1024) 
		{
			this._limit = limit;
		}
		
		public function standardize(pic_data:ByteArray):void
		{
			//ExternalInterface.call("console.log","resize")
			var loader:Loader = new Loader();
			timer.addEventListener(TimerEvent.TIMER,handleTimeout);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handle_progress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handle_load_io_error);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handle_load_complete);
			loader.contentLoaderInfo.addEventListener(Event.INIT, handle_init);
			_rawData = pic_data;
			//ExternalInterface.call("console.log","resize4")
			loader.loadBytes(pic_data);
		}
		
		private function handleTimeout(evt:TimerEvent):void
		{
			timer.stop();
			dispatchEvent(new Event(PicStandardizer.OVER_DIMENTION_EVENT));
		}
		
		private function handle_init(evt:Event):void
		{
			//ExternalInterface.call("console.log","init")
		}
		
		private function handle_progress(evt:ProgressEvent):void
		{
			//ExternalInterface.call("console.log","pro:",evt.bytesLoaded,evt.bytesTotal);
			if(evt.bytesLoaded==evt.bytesTotal)
			{
				//ExternalInterface.call("console.log","com");
				timer.start();
			}
		}
		
		private function handle_load_io_error(evt:IOErrorEvent):void
		{
			//ExternalInterface.call("console.log","ioerror")
		}
		
		public function get dataBeenStandaized():ByteArray
		{
			return this._data;
		}
		
		private function handle_load_complete(evt:Event):void
		{
			timer.stop();
			//ExternalInterface.call("console.log","resize2")
			var loader:Loader = evt.target.loader as Loader;
			if(!picSizeTest(loader.content as Bitmap))
			{
				dispatchEvent(new Event(PicStandardizer.OVER_DIMENTION_EVENT));
				return;
			}
			(loader.content as Bitmap).smoothing = true;//防止缩放产生锯齿
			var aspectRatio:Number = loader.content.width / loader.content.height;//图片的宽高比
			if (loader.content.width <= _limit)
			{
				//如果图片的宽高均在上限值以下
				_data = _rawData;
				dispatchEvent(new Event(Event.COMPLETE));//标准化后完毕后通知
			}
			else
			{
				temp_width = _limit;
				temp_height = Math.ceil(temp_width / aspectRatio);
				
				loader.content.height = temp_height;
				loader.content.width = temp_width;
				//ExternalInterface.call("console.log", "fuck size:", loader.content.height, loader.content.width);
				
				bitmapData = new BitmapData(temp_width, temp_height,true,0xFFFFFF);
				bitmapData.draw(loader);
				_data = new ByteArray();
				
				var jpgEncoder;
				log("playerVer:" + Config.playerVer);
				//if (Config.playerVer < 10)//如果flashPlayer版本低于10
					//jpgEncoder = new AsyncJPEGEncoderUseArray(Config.compressionQuality, 500, 500);
				//else
				jpgEncoder = new AsyncJPEGEncoder(Config.compressionQuality, 500, 500);
				jpgEncoder.addEventListener(EncodeCompleteEvent.COMPLETE, handle_encode_com);
				compressStartTime = new Date().getTime();
				jpgEncoder.encode(bitmapData);
			}
			
			
		}
		
		private function picSizeTest(pic:Bitmap):Boolean
		{
			//ExternalInterface.call("console.log",pic.width,pic.height);
			if(pic.width*pic.height>16777215)
				return false;
			if(pic.width > 8191 || pic.height > 8191)
				return false;
			return true
		}
		
		
		private function handle_encode_com(evt):void
		{
			var endTime:Number = new Date().getTime();
			compressTime = endTime - compressStartTime;
			bitmapData.dispose();
			_data = evt.data;
			//var file:FileReference = new FileReference();
			//FileReference(file).save(_data, "ok.jpg");
			dispatchEvent(new Event(Event.COMPLETE));//标准化后完毕后通知
		}
	}

}