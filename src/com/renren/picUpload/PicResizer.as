package com.renren.picUpload 
{
	import com.adobe.images.JPGEncoder;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	/**
	 * 缩小图片尺寸
	 * 策略:比较图片的宽高,其中较大的如果超过尺寸上限,就将图片较长的设置为上限值,
	 * 然后，按比例，调整另外一个。
	 * @author taowenzhang@gmail.com 
	 */
	
	public class PicResizer extends EventDispatcher
	{
		private var limit:Number = 1024;
		private var _data:ByteArray;//尺寸调整后的图片数据
		
		public function PicResizer() 
		{
			
		}
		
		public function startResize(pic_data:ByteArray):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handle_load_complete);
			loader.load(pic_data);
		}
		
		public function get data():ByteArray
		{
			return this._data;
		}
		
		private function handle_load_complete(evt:Event):void
		{
			var loader:Loader = evt.target.loader as Loader;
			var aspectRatio:Number;

			if (loader.width > loader.height)
			{
				aspectRatio = loader.height / loader.width;
				loader.width = limit;
				loader.height = loader.width * aspectRatio;
			}
			else
			{
				aspectRatio =  loader.width/loader.height;
				loader.height = limit;
				loader.width = loader.width * aspectRatio;
			}
			
			var bitmapData:BitmapData = new BitmapData(loader.width, loader.height);
			bitmapData.draw(loader, null, null, null, null, true);//最后一个参数允许平滑处理
			var jpgEncoder:JPGEncoder = new JPGEncoder(80);
			_data = jpgEncoder.encode(bitmapData);
			dispatchEvent(new Event(Event.COMPLETE));//压缩完毕后通知
		}
	}

}