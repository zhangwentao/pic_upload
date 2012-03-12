package
{
	import com.adobe.protocols.dict.Database;
	import com.adobe.serialization.json.JSON;
	import com.renren.external.ExternalEvent;
	import com.renren.external.ExternalEventDispatcher;
	import com.renren.picUpload.Config;
	import com.renren.picUpload.FileItem;
	import com.renren.picUpload.PicUploader;
	import com.renren.picUpload.events.FileUploadEvent;
	import com.renren.picUpload.events.PicUploadEvent;
	import com.renren.picUpload.events.ThumbMakerEvent;
	import com.renren.picUpload.log;
	import com.renren.util.Logger;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.BevelFilter;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.ui.ContextMenu;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class Main extends MovieClip
	{
		private var fileIdPrifix:String = "fileItem";
		private var picUploader:PicUploader = new PicUploader();
		private var fileList:FileReferenceList = new FileReferenceList();
		private var addBtn:AddBtn = new AddBtn();
		
		private var filesOverflow:Array;
		private var filesZeroByte:Array;
		private var filesSizeExceeded:Array;
		
		private var invalidFiles:Array;
		private var filesQueued:Array;
		
		private var fileFilters:Array = new Array();
		
		private var startTime:Number;
		private var alertedNotLogin:Boolean = false;
		
		private var uploadType:int = 1;
		
		public function Main()
		{
		
			Logger.status = Logger.STATUS_OFF;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			Security.allowInsecureDomain("*");
			addBtn.buttonMode = true;
			addBtn.mouseChildren = false;
			addChild(addBtn);
			picUploader.addEventListener(PicUploadEvent.UPLOAD_PROGRESS, handle_upload_progress);
			picUploader.addEventListener(PicUploadEvent.UPLOAD_SUCCESS, handle_upload_success);
			picUploader.addEventListener(PicUploadEvent.UPLOAD_CANCELED, handle_upload_canceled);
			picUploader.addEventListener(PicUploadEvent.START_PROCESS_FILE, handle_file_process);
			picUploader.addEventListener(IOErrorEvent.IO_ERROR, handle_IOError);
			picUploader.addEventListener(PicUploadEvent.QUEUE_LIMIT_EXCEEDED, handle_queue_limit_exceeded);
			picUploader.addEventListener(PicUploadEvent.ZERO_BYTE_FILE, handle_invalid_files);
			picUploader.addEventListener(PicUploadEvent.FILE_EXCEEDS_SIZE_LIMIT, handle_invalid_files);
			picUploader.addEventListener(PicUploadEvent.FILE_QUEUED, handle_file_queued);
			picUploader.addEventListener(PicUploadEvent.NOT_LOGIN, handle_notLogin);
			addBtn.addEventListener(MouseEvent.CLICK, handle_stage_clicked);
			fileList.addEventListener(Event.SELECT, handle_file_selected);
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, function()
					{
						init();
					});
		}
		
		function getWordGroup(src:String):Array
		{
			var result:Array = [];
			var n:Number = Math.pow(2, src.length);
			for (var i:int = 0; i < n; i++)
			{
				var temp = formate(src, NToS(i, src.length));
				result.push(temp);
			}
			return result;
		}
		
		function NToS(a:Number, count:Number):String
		{
			var result:String = '';
			var s:String = a.toString(2);
			for (var i:int = 0; i < (count - s.length); i++)
			{
				result += '0';
			}
			result += s;
			return result;
		}
		
		function formate(src:String, pat:String):String
		{
			var gSrc:Array = src.split('');
			var gPat:Array = pat.split('');
			for (var i:int = 0; i < src.length; i++)
			{
				gSrc[i] = Boolean(int(gPat[i])) ? gSrc[i].toUpperCase() : gSrc[i].toLowerCase();
			}
			return gSrc.toString().replace(/,/g, '');
		}
		
		private function handle_notLogin(evt:PicUploadEvent):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.NOT_LOGIN);
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
		}
		
		private function showLog(value:int):String
		{
			if (value == 1)
			{
				Logger.status = Logger.STATUS_ON;
				return "log ON";
			}
			else
			{
				Logger.status = Logger.STATUS_OFF
				return "log OFF"
			}
		}
		
		private function handle_invalid_files(evt:PicUploadEvent):void
		{
			var fileObj:Object = evt.fileItem.getInfoObject();
			fileObj["errorType"] = evt.type;
			invalidFiles.push(fileObj);
		}
		
		private function initFileFilters():void
		{
			
			
			for each (var fileterInfo:Array in Config.fileFilters)
			{
				var fileTypeArray:Array = [];
				var typeSrc:Array =  String(fileterInfo[1]).split(",");
				var result:String = '';
				for ( var i:int = 0; i < typeSrc.length; i++)
				{
					fileTypeArray = fileTypeArray.concat(getWordGroup(typeSrc[i]));
					
				}
				result += "*." + fileTypeArray[i];
				for (i = 1; i < fileTypeArray.length; i++)
				{
					result += ";*." + fileTypeArray[i];
				}
				//var fileType:String = fileterInfo[1] + ";" + String(fileterInfo[1]).toLocaleUpperCase();
				var fileType:String = result;
				trace("fileTypeArray:",fileTypeArray);
				var filter:FileFilter = new FileFilter(fileterInfo[0], fileType);
			
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
			log("delete:" + evt.fileItem.id);
			addBtn.setInfoTxt("还能添加" + (Config.picUploadNumOnce - picUploader.fileItemQueuedNum) + "张");
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_UPLOAD_CANCELED);
			event.addParam("file", {id: evt.fileItem.id});
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
			if (picUploader.fileItemQueuedNum < Config.picUploadNumOnce)
			{
				addBtn.buttonMode = true;
				addBtn.mouseChildren = addBtn.mouseEnabled = true;
				addBtn.enable();
			}
		}
		
		private function encode(obj:Object):String
		{
			var result:String;
			try
			{
				result = JSON.encode(obj);
			}
			catch (err:Error)
			{
				log("jsonEncodeError:", err);
			}
			return result;
		}
		
		private function init():void
		{
			try
			{
				var cm:ContextMenu = new ContextMenu();
				cm.hideBuiltInItems();
				this.contextMenu = cm;
				Config.getFlashVars(stage);
				initFileFilters();
				
				
				ExternalInterface.addCallback("setBtnStatus", addBtn.setStatus);
				ExternalInterface.addCallback("cancelFile", picUploader.cancelAFile);
				ExternalInterface.addCallback("setUploadUrl", Config.setUploadUrl);
				ExternalInterface.addCallback("jsonEncode", this.encode);
				ExternalInterface.addCallback("showLog", this.showLog);
				ExternalInterface.addCallback("getStatistics",picUploader.statistics.getJSONformate);
				ExternalEventDispatcher.getInstance().addExternalCall();
				checkVersion();
				
				picUploader.init();
				picUploader.start();
				FileItem.id_prefix = fileIdPrifix + Math.round(Math.random() * 1000) + curTime();
				
				addBtn.setInfoTxt("还能添加" + Config.picUploadNumOnce + "张");
				
				ExternalInterface.call(Config.flashReadyDo);
			}
			catch(e:SecurityError)
			{
				
			}
		}
		
		private function curTime():String
		{
			var date:Date = new Date();
			return '' + date.getHours() + date.getMinutes() + date.getSeconds();
		}
		
		private function checkVersion():void
		{
			var version:String = Capabilities.version;
			log("ver:" + version);
			Config.playerVer = int(version.split(/[ ,]/)[1]);
		}
		
		private function handle_upload_success(evt:PicUploadEvent):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_UPLOAD_SUCCESS);
			event.addParam("file", evt.fileItem.getInfoObject());
			var resData:String = String(evt.data);
			event.addParam("response", resData);
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
			
			var endTime:Number = new Date().getTime() - startTime;
			log(evt.fileItem.id + ":success");
			log("totalTime:", endTime);
			//ExternalInterface.call("alert", evt.fileItem.id);
		}
		
		function handle_upload_progress(evt:PicUploadEvent):void
		{
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_UPLOAD_PROGRESS);
			event.addParam("file", evt.fileItem.getInfoObject());
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
		}
		
		function handle_stage_clicked(evt:MouseEvent):void
		{
			if(evt.target == addBtn.upload_btn)
			{
				uploadType = 1;
			}
			else if(evt.target == addBtn.send_btn)
			{
				uploadType = 2;
			}
			fileList.browse(fileFilters);
		}
		
		private function handle_file_queued(evt:PicUploadEvent):void
		{
			filesQueued.push(evt.fileItem.getInfoObject());
			if (picUploader.fileItemQueuedNum >= Config.picUploadNumOnce)
			{
				//addBtn.setInfoTxt("已满"+Config.picUploadNumOnce+"张照片");
				addBtn.buttonMode = false;
				addBtn.mouseChildren = addBtn.mouseEnabled = false;
				addBtn.disable();
			}
			else
			{
			}
			addBtn.setInfoTxt("还能添加" + (Config.picUploadNumOnce - picUploader.fileItemQueuedNum) + "张");
		}
		
		private function handle_file_selected(evt:Event):void
		{
			startTime = startTime ? startTime : new Date().getTime();
			filesOverflow = new Array();
			filesQueued = new Array();
			filesZeroByte = new Array();
			filesSizeExceeded = new Array();
			invalidFiles = new Array();
			var allSelectedFileNum:int = evt.target.fileList.length;
			var i:uint = 0;
			
			var allowAddFileNum:int = Config.picUploadNumOnce - picUploader.fileItemQueuedNum;
			
			trace("allowAddFileNum:" + allowAddFileNum);
			for each (var file:FileReference in evt.target.fileList)
			{
				if (picUploader.fileItemQueuedNum >= Config.picUploadNumOnce)
					break;
				var fileItem:FileItem = new FileItem(file);
				picUploader.addFileItem(fileItem);
				i++;
			}
			
			//for (var fileIndex:int = 0; fileIndex < ; fileIndex++)
			//{
			//var fr:FileReference = (evt.target.fileList)[fileIndex];
			//var fileItem:FileItem = new FileItem(fr);			
			//picUploader.addFileItem(fileItem);
			//i++;
			//}
			
			for (var tempi:int = i; tempi < evt.target.fileList.length; tempi++)
			{
				filesOverflow.push(new FileItem(evt.target.fileList[tempi]).getInfoObject());
			}
			
			var event:ExternalEvent = new ExternalEvent(FileUploadEvent.FILE_QUEUED);
			event.addParam("files", filesQueued);
			event.addParam("type",uploadType);
			ExternalEventDispatcher.getInstance().dispatchEvent(event);
			filesQueued = null;
			
			//用户选择的图片的总数超出一次可上传图片的数目
			if (filesOverflow.length > 0)
			{
				var overflowEvt:ExternalEvent = new ExternalEvent(FileUploadEvent.QUEUE_LIMIT_EXCEEDED);
				overflowEvt.addParam("selected", allSelectedFileNum);
				overflowEvt.addParam("files", filesOverflow);
				ExternalEventDispatcher.getInstance().dispatchEvent(overflowEvt);
			}
			
			if (invalidFiles.length > 0)
			{
				var queueErrorEvt:ExternalEvent = new ExternalEvent(FileUploadEvent.QUEUED_ERROR);
				queueErrorEvt.addParam("files", invalidFiles);
				ExternalEventDispatcher.getInstance().dispatchEvent(queueErrorEvt);
			}
		}
	}
}