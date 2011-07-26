package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import com.renren.picUpload.PicUploader;
	import flash.events.MouseEvent;
	import com.renren.picUpload.FileItem;
	import com.renren.picUpload.events.ThumbMakerEvent;
	import com.renren.picUpload.log;
	/**
	 * ...
	 * @author taowenzhang@gmail.com 
	 */
	public class Main extends Sprite
	{
		private var px:Number = 0;
		private var mainP:PicUploader = new PicUploader();
		private var fileList:FileReferenceList = new FileReferenceList();
		
		public function Main() 
		{
			mainP.addEventListener(ThumbMakerEvent.THUMB_MAKED, huandle_thumb_maked);
			stage.addEventListener(MouseEvent.CLICK,handle_stage_clicked);
			fileList.addEventListener(Event.SELECT, handle_file_selected);
		}
		
		
		function huandle_thumb_maked(evt:ThumbMakerEvent):void
		{
			this.stage.addChild(evt.Thumb);
			evt.Thumb.x = px;
			px += 120;
		}
		
		function handle_stage_clicked(evt:MouseEvent):void 
		{
			fileList.browse();
		}
		
		private function handle_file_selected(evt:Event):void
		{
			var i:uint = 0;
			for each(var file:FileReference in evt.target.fileList)
			{
				var fileItem:FileItem = new FileItem(i,file);
				mainP.addFileItem(fileItem);
				i++;
			}
			
			mainP.start();
			
		}
		
	}

}