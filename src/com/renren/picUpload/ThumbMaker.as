package com.renren.picUpload 
{
	import com.adobe.protocols.dict.events.DisconnectedEvent;
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
		
		public function ThumbMaker(limit = 100) 
		{
			
		}
		
		public function get thumb():Sprite
		{
			return this._thumb;
		}
		
		public function make(pic_data:ByteArray):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handle_load_complete);
			loader.load(pic_data);
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
					loader.width = _limit;
					loader.height = loader.width / aspectRatio;
				}
				else//
				{
					loader.height = _limit;
					loader.width = loader.height * aspectRatio;
				}
				var bitmapData:BitmapData = new BitmapData(loader.width, loader.height);
				bitmapData.draw(loader, null, null, null, null, true);//最后一个参数允许平滑处理
				_thumb = new Sprite();
				_thumb.graphics.beginBitmapFill(bitmapData, null, false, false);
				_thumb.graphics.drawRect(0, 0, loader.width, loader.height);
				_thumb.graphics.endFill();
			}
			dispatchEvent(new Event(Event.COMPLETE));//制作缩略图完成.
		}
	}
}