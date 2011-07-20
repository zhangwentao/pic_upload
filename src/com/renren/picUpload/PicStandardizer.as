package com.renren.picUpload 
{
	import com.adobe.images.JPGEncoder;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.display.Loader;
	import flash.display.BitmapData;
	
	/**
	 * 标准化图片尺寸
	 * 策略:使图片的长度和高度均在一个上限值以下
	 * @author taowenzhang@gmail.com 
	 */
	
	public class PicStandardizer extends EventDispatcher
	{
		private var _limit:Number = 1024;//上限值
		private var _data:ByteArray;//尺寸标准化后的图片数据
		private var _rawData:ByteArray;//原始数据
		/**
		 * 构造函数
		 * @param	limit	<Number>	图片宽度和高度的上限值
		 */
		public function PicStandardizer(limit:Number) 
		{
			this._limit = limit;
		}
		
		public function standardize(pic_data:ByteArray):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handle_load_complete);
			_rawData = pic_data;
			loader.load(pic_data);
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
				var jpgEncoder:JPGEncoder = new JPGEncoder(80);
				_data = jpgEncoder.encode(bitmapData);
			}
			dispatchEvent(new Event(Event.COMPLETE));//标准化后完毕后通知
		}
	}

}