package  
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import com.renren.picUpload.PicUploader;
	import flash.events.MouseEvent;
	import com.renren.picUpload.FileItem;
	import com.renren.picUpload.events.ThumbMakerEvent;
	import com.renren.picUpload.log;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com 
	 */
	public class Main extends MovieClip
	{
		private var px:Number = 0;
		private var py:Number = 0;
		private var mainP:PicUploader = new PicUploader();
		private var fileList:FileReferenceList = new FileReferenceList();
		private var fileThumb:Dictionary = new Dictionary();
		public function Main() 
		{
			mainP.addEventListener(ThumbMakerEvent.THUMB_MAKED, huandle_thumb_maked);
			stage.addEventListener(MouseEvent.CLICK,handle_stage_clicked);
			fileList.addEventListener(Event.SELECT, handle_file_selected);
			mainP.dataBlockNumLimit = 100;
			mainP.dataBlockSizeLimit = 10240;
			mainP.uploaderPoolSize = 30;
			mainP.picUploadNumOnce = 100;
			mainP.DBQCheckInterval = 100;
			mainP.init();
		}
		
		
		function huandle_thumb_maked(evt:ThumbMakerEvent):void
		{
			(fileThumb[evt.fileItem] as PicContainer).addThumb(evt.Thumb);
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
				var fileItem:FileItem = new FileItem(i, file);
				var tc:PicContainer = new PicContainer();
				fileThumb[fileItem] = tc;
				addThumbContainer(tc);
				mainP.addFileItem(fileItem);
				i++;
			}
			mainP.start();
		}
		
		private function addThumbContainer(tc:PicContainer):void
		{
			addChild(tc);
			tc.x = px;
			tc.y = py;
			if (px + 120 >= stage.stageWidth)
			{
				px = 0;
				py += 120;
			}
			else
			{
				px += 120;
			}
		}
	}

}