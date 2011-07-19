package com.renren.picUpload 
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	/**
	 * 生成图片的缩略图
	 * @author taowenzhang@gmail.com 
	 */
	public class ThumbMaker extends EventDispatcher
	{
		private var thumbWidth:Number = 100;
		private var _thumb:Sprite;
		
		public function ThumbMaker() 
		{
			
		}
		
		public function get thumb():Sprite
		{
			return this._thumb;
		}
		
		public function startMake(pic_data:ByteArray):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handle_load_complete);
			loader.load(pic_data);
		}
		
		private function handle_load_complete(evt:Event):void
		{
			var loader:Loader = evt.target.loader as Loader;
			var aspectRatio:Number;

			if (loader.width > loader.height)
			{
				aspectRatio = loader.height / loader.width;
				loader.width = thumbWidth;
				loader.height = loader.width * aspectRatio;
			}
			else
			{
				aspectRatio =  loader.width/loader.height;
				loader.height = thumbWidth;
				loader.width = loader.width * aspectRatio;
			}
			
			var bitmapData:BitmapData = new BitmapData(loader.width, loader.height);
			bitmapData.draw(loader, null, null, null, null, true);//最后一个参数允许平滑处理
			_thumb = new Sprite();
			_thumb.graphics.beginBitmapFill(bitmapData, null, false, false);
			_thumb.graphics.drawRect(0, 0, loader.width, loader.height);
			_thumb.graphics.endFill();
			dispatchEvent(new Event(Event.COMPLETE));//制作缩略图完成，通知。
		}
	}
}