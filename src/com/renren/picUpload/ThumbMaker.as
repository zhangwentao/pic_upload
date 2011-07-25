package com.renren.picUpload 
{
	import com.renren.picUpload.events.ThumbMakerEvent;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
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
		private var _limit:Number;
		private var _thumb:DisplayObject;
		
		/**
		 * 构造函数
		 * @param	limit	<Number>	长度和宽度的上限值
		 */
		public function ThumbMaker(limit:Number = 100) 
		{
			this._limit = limit;
		}
				
		public function make(pic_data:ByteArray):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handle_load_complete);
			loader.loadBytes(pic_data);
		}
		
		private function handle_load_complete(evt:Event):void
		{
			var loader:Loader = evt.target.loader as Loader;
			var aspectRatio:Number = loader.width/loader.height;
			
			if (loader.width <= _limit && loader.height <= _limit)
			{
				//如果图片的宽高均在上限值以下
				_thumb = loader.content;
			}
			else
			{
				if (aspectRatio >= 1)//如果宽大于等于高
				{
					loader.content.width = _limit;
					loader.content.height = loader.content.width / aspectRatio;
				}
				else
				{
					loader.content.height = _limit;
					loader.content.width = loader.content.height * aspectRatio;
				}
				
				var bitmapData:BitmapData = new BitmapData(loader.content.width, loader.content.height);
				bitmapData.draw(loader);
				var result = new Sprite(); 
				result.graphics.beginBitmapFill(bitmapData, null, false, false);
				result.graphics.drawRect(0, 0, loader.content.width, loader.content.height);
				result.graphics.endFill();
				_thumb = result;
			}
			dispatchEvent(new ThumbMakerEvent(ThumbMakerEvent.THUMB_MAKED,this._thumb));//制作缩略图完成.
		}
	}
}