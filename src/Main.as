package  
{
	import com.adobe.protocols.dict.Database;
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
	import com.renren.external.ExternalEvent;
	import com.renren.external.ExternalEventDispatcher;
	import com.renren.picUpload.events.FileUploadEvent;
	import flash.external.ExternalInterface;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONParseError;
	/**
	 * ...
	 * @author taowenzhang@gmail.com 
	 */
	public class Main extends MovieClip
	{
		private var fileIdPrifix:String="fileItem";
		private var picUploader:PicUploader = new PicUploader();
		private var fileList:FileReferenceList = new FileReferenceList();
		private var addBtn:AddBtn = new AddBtn();
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, function() { init(); } );
			addBtn.buttonMode = true;
			addBtn.mouseChildren = false;
			addChild(addBtn);
			picUploader.addEventListener(ThumbMakerEvent.THUMB_MAKED, huandle_thumb_maked);
			picUploader.addEventListener(ThumbMakerEvent.THUMB_MAKE_PROGRESS, handle_thumb_making);
			picUploader.addEventListener(PicUploadEvent.UPLOAD_PROGRESS, handle_upload_progress);
			picUploader.addEventListener(PicUploadEvent.UPLOAD_SUCCESS, handle_upload_success);
			picUploader.addEventListener(PicUploadEvent.UPLOAD_CANCELED, handle_upload_canceled);
			picUploader.addEventListener(PicUploadEvent.START_PROCESS_FILE, handle_file_process);
			
			addBtn.addEventListener(MouseEvent.CLICK,handle_stage_clicked);
			fileList.addEventListener(Event.SELECT, handle_file_selected);
			
			picUploader.dataBlockNumLimit = 100;
			picUploader.dataBlockSizeLimit = 10485760;
			picUploader.uploaderPoolSize = 30;
			picUploader.picUploadNumOnce = 100;
			picUploader.DBQCheckInterval = 100;
			picUploader.init();
		}
		
		private function handle_file_process(evt:PicUploadEvent):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_PROCESS_START);
			event.addParam("file", evt.fileItem.getInfoObject());
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
		}
		
		private function handle_upload_canceled(evt:PicUploadEvent):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_UPLOAD_CANCELED);
			event.addParam("file", evt.fileItem.getInfoObject());
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
		}
		
		private function init():void
		{
			ExternalEventDispatcher.getInstance().addExternalCall();
			ExternalInterface.addCallback("setBtnStatus", addBtn.setStatus);
			ExternalInterface.addCallback("cancelFile", picUploader.cancelAFile);
			ExternalInterface.call("flashReady");
		}
		
		private function handle_upload_success(evt:PicUploadEvent):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_UPLOAD_SUCCESS);
			event.addParam("file", evt.fileItem.getInfoObject());
			try {
				var resData:Object =  JSON.decode(evt.data);
				event.addParam("response", resData);
			}
			catch (e:JSONParseError)
			{
				ExternalInterface.call("console.log", "jsonParseError:" ,e);
			}
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
		}
		
		function handle_upload_progress(evt:PicUploadEvent):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_UPLOAD_PROGRESS);
			event.addParam("file", evt.fileItem.getInfoObject());
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
		}
		
		function handle_thumb_making(evt:ThumbMakerEvent):void
		{
			
		}
		
		function huandle_thumb_maked(evt:ThumbMakerEvent):void
		{
			
		}
		
		function handle_stage_clicked(evt:MouseEvent):void 
		{
			fileList.browse();
		}
		
		private function handle_file_selected(evt:Event):void
		{	
			var fileItemArr:Array = [];
			var i:uint = 0;
			for each(var file:FileReference in evt.target.fileList)
			{
				var fileItem:FileItem = new FileItem(fileIdPrifix, file);			
				picUploader.addFileItem(fileItem);
				
				fileItemArr.push(fileItem.getInfoObject());
				i++;
			}
			picUploader.start();
			
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_QUEUED);
			event.addParam("files",fileItemArr);
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
		}
	}
}