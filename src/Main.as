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
	import com.renren.picUpload.events.PicUploadEvent;
	
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
		private var scroll:ScrollBar = new ScrollBar(300,740);
		private var curCollumNum:uint = 0;
		private var container:Sprite = new Sprite();
		public function Main() 
		{
			addChild(container);
			addChild(scroll);
			
			scroll.target = container;
			mainP.addEventListener(ThumbMakerEvent.THUMB_MAKED, huandle_thumb_maked);
			mainP.addEventListener(ThumbMakerEvent.THUMB_MAKE_PROGRESS, handle_thumb_making);
			mainP.addEventListener(PicUploadEvent.UPLOAD_PROGRESS, handle_upload_progress);
			
			
			stage.addEventListener(MouseEvent.CLICK,handle_stage_clicked);
			fileList.addEventListener(Event.SELECT, handle_file_selected);
			mainP.dataBlockNumLimit = 100;
			mainP.dataBlockSizeLimit = 10240;
			mainP.uploaderPoolSize = 30;
			mainP.picUploadNumOnce = 100;
			mainP.DBQCheckInterval = 100;
			mainP.init();
		}
		
		function handle_upload_progress(evt:PicUploadEvent):void
		{
			(fileThumb[evt.fileItem] as ThumbContainer).status = ThumbContainer.STATUS_UPLOAD_PROGRESS;
		}
		
		function handle_thumb_making(evt:ThumbMakerEvent):void
		{
			(fileThumb[evt.fileItem] as ThumbContainer).status = ThumbContainer.STATUS_THUMB_MAKING;
		}
		
		function huandle_thumb_maked(evt:ThumbMakerEvent):void
		{
			(fileThumb[evt.fileItem] as ThumbContainer).status = ThumbContainer.STATUS_WAIT_FOR_UPLOAD;
			(fileThumb[evt.fileItem] as ThumbContainer).addThumb(evt.Thumb);
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
				var tc:ThumbContainer = new ThumbContainer();
				tc.status = ThumbContainer.STATUS_QUEUED;
				fileThumb[fileItem] = tc;
				addThumbContainer(tc);
				scroll.update();
				mainP.addFileItem(fileItem);
				i++;
			}
			mainP.start();
		}
		
		private function addThumbContainer(tc:ThumbContainer):void
		{
			container.addChild(tc);
			tc.x = px;
			tc.y = py;
			curCollumNum++;
			if (curCollumNum >6)
			{
				px = 0;
				py += 105;
				curCollumNum = 0;
			}
			else
			{
				px += 105;
			}
		}
	}

}