package  
{
	import com.adobe.protocols.dict.Database;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.filters.BevelFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import com.renren.picUpload.PicUploader;
	import flash.events.MouseEvent;
	import com.renren.picUpload.FileItem;
	import com.renren.picUpload.events.ThumbMakerEvent;
	import com.renren.picUpload.log;
	import flash.ui.ContextMenu;
	import flash.utils.Dictionary;
	import com.renren.picUpload.events.PicUploadEvent;
	import com.renren.external.ExternalEvent;
	import com.renren.external.ExternalEventDispatcher;
	import com.renren.picUpload.events.FileUploadEvent;
	import flash.external.ExternalInterface;
	import flash.display.StageScaleMode;
	import com.renren.picUpload.Config;
	import flash.display.StageAlign;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.system.Security;
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
		
		private var filesOverflow:Array;
		private var filesQueued:Array;
		
		private var fileFilters:Array = new Array();
	
        
		public function Main() 
		{
			Security.allowInsecureDomain("www.renren.com");
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			addBtn.buttonMode = true;
			addBtn.mouseChildren = false;
			addChild(addBtn);
			picUploader.addEventListener(PicUploadEvent.UPLOAD_PROGRESS, handle_upload_progress);
			picUploader.addEventListener(PicUploadEvent.UPLOAD_SUCCESS, handle_upload_success);
			picUploader.addEventListener(PicUploadEvent.UPLOAD_CANCELED, handle_upload_canceled);
			picUploader.addEventListener(PicUploadEvent.START_PROCESS_FILE, handle_file_process);
			picUploader.addEventListener(IOErrorEvent.IO_ERROR, handle_IOError);
			picUploader.addEventListener(PicUploadEvent.QUEUE_LIMIT_EXCEEDED, handle_queue_limit_exceeded);
			picUploader.addEventListener(PicUploadEvent.FILE_QUEUED, handle_file_queued);
			
			addBtn.addEventListener(MouseEvent.CLICK,handle_stage_clicked);
			fileList.addEventListener(Event.SELECT, handle_file_selected);
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, function() { init(); } );
		}
		
		private function initFileFilters():void
		{
			for each(var fileterInfo:Array in Config.fileFilters)
			{
				var filter:FileFilter = new FileFilter(fileterInfo[0], fileterInfo[1]);
				fileFilters.push(filter);
			}
		}
		
		private function handle_queue_limit_exceeded(evt:PicUploadEvent):void
		{
			filesOverflow.push(evt.fileItem.getInfoObject());
		}
		
		private function handle_IOError(evt:IOErrorEvent):void
		{
			var event:ExternalEvent = new ExternalEvent("networkError");
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
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
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			this.contextMenu = cm;
			Config.getFlashVars(stage);
			initFileFilters();
			ExternalEventDispatcher.getInstance().addExternalCall();
			ExternalInterface.addCallback("setBtnStatus", addBtn.setStatus);
			ExternalInterface.addCallback("cancelFile", picUploader.cancelAFile);
			ExternalInterface.addCallback("setUploadUrl", Config.setUploadUrl);
			
			picUploader.init();
			picUploader.start();
			FileItem.id_prefix = fileIdPrifix + Math.round(Math.random() * 1000) +curTime();
			ExternalInterface.call(Config.flashReadyDo);
		}
		
		private function curTime():String
		{
			var date:Date = new Date();
			return ''+date.getHours() + date.getMinutes() + date.getSeconds();
		}
		
		private function handle_upload_success(evt:PicUploadEvent):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_UPLOAD_SUCCESS);
			event.addParam("file", evt.fileItem.getInfoObject());
			var resData:Object = evt.data
			event.addParam("response", resData);
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
		}
		
		function handle_upload_progress(evt:PicUploadEvent):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_UPLOAD_PROGRESS);
			event.addParam("file", evt.fileItem.getInfoObject());
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
		}
		
		
		function handle_stage_clicked(evt:MouseEvent):void 
		{
			fileList.browse(fileFilters);
		}
		
		private function handle_file_queued(evt:PicUploadEvent):void
		{
			filesQueued.push(evt.fileItem.getInfoObject());
		}
		
		private function handle_file_selected(evt:Event):void
		{	
			filesOverflow = new Array();
			filesQueued = new Array();
			
			var i:uint = 0;
			for each(var file:FileReference in evt.target.fileList)
			{
				var fileItem:FileItem = new FileItem(file);			
				picUploader.addFileItem(fileItem);
				i++;
			}
			
			
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_QUEUED);
			event.addParam("files",filesQueued);
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
			
			//用户选择的图片的总数超出一次可上传图片的数目
			if (filesOverflow.length>0)
			{
				var overflowEvt:ExternalEvent = new ExternalEvent(FileUploadEvent.QUEUE_LIMIT_EXCEEDED);
				overflowEvt.addParam("files", filesOverflow);
				ExternalEventDispatcher.getInstance().dispatchEvent(overflowEvt);
			}
		}
	}
}