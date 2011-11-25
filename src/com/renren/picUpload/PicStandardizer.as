package com.renren.picUpload 
{
	import com.renren.asyncJPEGEncode.AsyncJPEGEncoder;
	import com.renren.asyncJPEGEncode.EncodeCompleteEvent;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.display.Loader;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.display.Bitmap;
	
	/**
	 * 标准化图片尺寸
	 * 策略:使图片的长度和高度均在一个上限值以下
	 * @author taowenzhang@gmail.com 
	 */
	
	class PicStandardizer extends EventDispatcher
	{
		private var _limit:int;//上限值
		private var _data:ByteArray;//尺寸标准化后的图片数据
		private var _rawData:ByteArray;//原始数据
		private var temp_height:int = 0;
		private var temp_width:int = 0;
		
		
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
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handle_load_complete);
			_rawData = pic_data;
			loader.loadBytes(pic_data);
		}
		
		public function get dataBeenStandaized():ByteArray
		{
			return this._data;
		}
		
		private function handle_load_complete(evt:Event):void
		{
			var loader:Loader = evt.target.loader as Loader;
			(loader.content as Bitmap).smoothing = true;//防止缩放产生锯齿
			var aspectRatio:Number = loader.content.width / loader.content.height;//图片的宽高比

			if (loader.content.width <= _limit && loader.content.height <= _limit)
			{
				//如果图片的宽高均在上限值以下
				_data = _rawData;
				dispatchEvent(new Event(Event.COMPLETE));//标准化后完毕后通知
			}
			else
			{
				if (aspectRatio >= 1)//如果宽大于等于高
				{
					temp_width = _limit;
					temp_height = Math.ceil(temp_width / aspectRatio);
				}
				else//
				{
					temp_height = _limit;
					temp_width = Math.ceil(temp_height * aspectRatio);
				}
		        
				loader.content.height = temp_height;
				loader.content.width = temp_width;
				//ExternalInterface.call("console.log", "fuck size:", loader.content.height, loader.content.width);
				
				var bitmapData:BitmapData = new BitmapData(temp_width, temp_height,true,0xFFFFFF);
				bitmapData.draw(loader);
				_data = new ByteArray();
				
				var jpgEncoder;
				log("playerVer:" + Config.playerVer);
				//if (Config.playerVer < 10)//如果flashPlayer版本低于10
					//jpgEncoder = new AsyncJPEGEncoderUseArray(Config.compressionQuality, 500, 500);
				//else
				jpgEncoder = new AsyncJPEGEncoder(Config.compressionQuality, 500, 500);
				
				
				jpgEncoder.addEventListener(EncodeCompleteEvent.COMPLETE, handle_encode_com);
				jpgEncoder.encode(bitmapData);
			}
			
			function handle_encode_com(evt):void
			{
				bitmapData.dispose();
				_data = evt.data;
				//var file:FileReference = new FileReference();
				//FileReference(file).save(_data, "ok.jpg");
				dispatchEvent(new Event(Event.COMPLETE));//标准化后完毕后通知
			}
		}
	}

}