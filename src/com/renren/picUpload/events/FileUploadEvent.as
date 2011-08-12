package com.renren.picUpload.events 
{
	import com.renren.external.ExternalEvent
	
	/**
	 * ...
	 * @author wentao.zhang
	 */
	public class FileUploadEvent extends ExternalEvent
	{
		
		public static const FILE_EXCEEDS_SIZE_LIMIT:String = "fileExceedsSizeLimit";//上传的文件超出文件尺寸上限
		public static const ZERO_BYTE_FILE:String = "zeroByteFile";//文件为长度为0
		public static const QUEUE_LIMIT_EXCEEDED:String = "queueLimitExceeded";//上传队列以达到长度已达到上限
		public static const FILE_QUEUED:String = "fileQueued";//文件被加入队列
		public static const FILE_QUEUED_COMPLETE:String = "fileQueuedComplete";//选择的所有文件完成加入上传队列过程
		public static const FILE_UPLOAD_PROGRESS:String = "fileUploadProgress";//一个文件正在上传中
		public static const FILE_UPLOAD_SUCCESS:String = "fileUploadSuccess";//一个文件上传成功
		public static const ALL_FILE_UPLOAD_COMPLETE:String = "allFileUploadComplete";//上传流程完毕
		public static const FILE_UPLOAD_CANCELED:String = "fileUploadCanceled";//取消一个文件的上传
		public static const FILE_PROCESS_START:String = "fileProcessStart";//取消一个文件的上传
		
		
		public function FileUploadEvent(type:String) 
		{
			super(type);
		} 
		
	}

}