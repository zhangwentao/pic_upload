package com.renren.picUpload 
{
	import com.renren.picUpload.events.EncodeCompleteEvent;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.display.Loader;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	
	/**
	 * 标准化图片尺寸
	 * 策略:使图片的长度和高度均在一个上限值以下
	 * @author taowenzhang@gmail.com 
	 */
	
	class PicStandardizer extends EventDispatcher
	{
		private var _limit:Number;//上限值
		private var _data:ByteArray;//尺寸标准化后的图片数据
		private var _rawData:ByteArray;//原始数据
		
		
		
		/**
		 * 构造函数
		 * @param	limit	<Number>	图片宽度和高度的上限值
		 */
		public function PicStandardizer(limit:Number=1024) 
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
			var aspectRatio:Number = loader.width / loader.height;//图片的宽高比

			if (loader.width <= _limit && loader.height <= _limit)
			{
				//如果图片的宽高均在上限值以下
				_data = _rawData;
				dispatchEvent(new Event(Event.COMPLETE));//标准化后完毕后通知
			}
			else
			{
				if (aspectRatio >= 1)//如果宽大于等于高
				{
					loader.width = _limit;
					loader.height = loader.width / aspectRatio;
				}
				else//
				{
					loader.height = _limit;
					loader.width = loader.height * aspectRatio;
				}
				
				var bitmapData:BitmapData = new BitmapData(loader.width, loader.height);
				bitmapData.draw(loader);
				var jpgEncoder:AsyncJPEGEncoder = new AsyncJPEGEncoder(50,500,500);
				jpgEncoder.addEventListener(EncodeCompleteEvent.COMPLETE, handle_encode_com);
				jpgEncoder.encode(bitmapData);
			}
			
			
			
		}
		private function handle_encode_com(evt:EncodeCompleteEvent):void
		{
			_data = evt.data;
			dispatchEvent(new Event(Event.COMPLETE));//标准化后完毕后通知
		}
		
	}

}