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
	class ThumbMaker extends EventDispatcher
	{
		private var _limit:Number;
		private var _fileItem:FileItem;
		private var _thumb:Sprite;
		
		/**
		 * 构造函数
		 * @param	limit	<Number>	长度和宽度的上限值
		 */
		public function ThumbMaker(limit:Number = 100)
		{
			this._limit = limit;
		}
		
		public function make(pic_data:ByteArray, fileItem:FileItem):void
		{
			this._fileItem = fileItem;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handle_load_complete);
			loader.loadBytes(pic_data);
		
		}
		
		private function handle_load_complete(evt:Event):void
		{
			var loader:Loader = evt.target.loader as Loader;
			var aspectRatio:Number = loader.width / loader.height;
			
			if (aspectRatio >= 1) //如果宽大于等于高
			{
				loader.content.height = _limit;
				loader.content.width = loader.content.height * aspectRatio;
			}
			else
			{
				loader.content.width = _limit;
				loader.content.height = loader.content.width / aspectRatio;
			}
			
			var bitmapData:BitmapData = new BitmapData(_limit, _limit);
			bitmapData.draw(loader);
			var result = new Sprite();
			result.graphics.beginBitmapFill(bitmapData, null, false, false);
			result.graphics.drawRect(0, 0, _limit, _limit);
			result.graphics.endFill();
			_thumb = result;
			
			dispatchEvent(new ThumbMakerEvent(ThumbMakerEvent.THUMB_MAKED, this._thumb, _fileItem)); //制作缩略图完成.
		}
	}
}