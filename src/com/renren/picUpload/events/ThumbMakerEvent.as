package com.renren.picUpload.events 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com 
	 */
	public class ThumbMakerEvent extends Event 
	{
		public static const THUMB_MAKED:String = "thumbMaked";//缩略图制作完成
		private var _thumb:DisplayObject;
		
		
		
		public function ThumbMakerEvent(type:String,thumb:DisplayObject,bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this._thumb = thumb;
			super(type, bubbles, cancelable);
		} 
		
		public function get Thumb():DisplayObject
		{
			return this._thumb;
		}
		
		public override function clone():Event 
		{ 
			return new ThumbMakerEvent(type,_thumb,bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ThumbMakerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}