package com.renren.picUpload.events 
{
	import com.renren.picUpload.FileItem;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com 
	 */
	public class ThumbMakerEvent extends Event 
	{
		public static const THUMB_MAKED:String = "thumbMaked";//缩略图制作完成
		public static const THUMB_MAKE_PROGRESS:String = "thumbMakeProgress";//制作中
		
		private var _thumb:Sprite;
		private var _fileItem:FileItem;
		
		
		public function ThumbMakerEvent(type:String,thumb:Sprite,fileItem:FileItem,bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this._thumb = thumb;
			this._fileItem = fileItem;
			super(type, bubbles, cancelable);
		} 
		
		/**
		 * 获取缩略图
		 */
		public function get Thumb():Sprite
		{
			return this._thumb;
		}
		
		/**
		 * 获取操作的fileItem的对象
		 */
		public function get fileItem():FileItem 
		{
			return _fileItem;
		}
		
		public override function clone():Event 
		{ 
			return new ThumbMakerEvent(type,_thumb,_fileItem,bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ThumbMakerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}