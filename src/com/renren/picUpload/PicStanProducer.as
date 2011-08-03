package com.renren.picUpload
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class PicStanProducer extends Sprite
	{
		private var raw_check_timer:Timer = new Timer(500);//检查原料区准备好否的定时器。
		private var soProxy:SOProxy = new SOProxy();
		private var picStandizer:PicStandardizer = new PicStandardizer();
		
		public function PicStanProducer() 
		{
			log("initPicStanProducer");
			init();
			start();
		}
		
		private function start():void
		{
			raw_check_timer.start();
		}
		
		private function init():void
		{
			raw_check_timer.addEventListener(TimerEvent.TIMER, handle_raw_check_timer);
		}
		
		private function handle_raw_check_timer(evt:TimerEvent):void
		{
			if (soProxy.rawReady)
			{
				compressPic();
			}
		}
		
		private function compressPic():void
		{
			var beCompressData:ByteArray = soProxy.getRaw();
			picStandizer.addEventListener(Event.COMPLETE, handle_pic_resized);
			picStandizer.standardize(beCompressData);
		}
		
		private function handle_pic_resized(evt:Event):void
		{
			soProxy.addProduct(picStandizer.dataBeenStandaized);
		}
	}

}