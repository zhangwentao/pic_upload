package com.renren.picUpload 
{
	import flash.display.Stage;
	import flash.utils.describeType;
	import flash.external.ExternalInterface;
	/**
	 * 配置信息
	 * @author taowenzhang@gmail.com 
	 */
	public class Config
	{
		public static var flashReadyDo:String;					//flash准备好被js调用方法后，调用这个js方法
		public static var maxSingleFileSize:Number = 1024*1024*8;	//单个上传文件的最大长度
		public static var dataBlockNumLimit:Number = 50;			//DataBlock对象的数量上限值
		public static var dataBlockSizeLimit:Number = 1024*1000;  //文件切片大小的上限单位字节
		public static var uploaderPoolSize:Number = 60;			//DBUploader对象池容量(uploader总数量)
		public static var picUploadNumOnce:Number = 100;     		//一次可以上传的照片数量
		public static var DBQCheckInterval:Number = 80;			//dataBlock队列检查间隔
		public static var UPCheckInterval:Number = 100;			//uploader对象池检查间隔
		public static var uploadUrl:String;						//上传url
		public static var fileFilters:Array = [["图片文件(*.jpg;*.png;*.gif;*.bmp)", "*.jpg;*.png;*.gif;*.bmp"]];//文件类型筛选
		public static var reUploadMaxTimes:Number = 20;
		public static var reUploadDelayTime:Number = 200;//上传错误后重传间隔

		public static function setUploadUrl(url:String):Boolean
		{
			uploadUrl = url;
			return true;
		}
		
		public static function getFlashVars(stage:Stage):void
		{
			var infoObj:Object = stage.loaderInfo.parameters;
			var params:Array = getAllparamsName();
			for each(var paraName:String in params)
			{
				if (Config[paraName] is Number )
				{
					Config[paraName] = infoObj[paraName]?infoObj[paraName]:Number(Config[paraName]);
				}
				Config[paraName] = infoObj[paraName]?infoObj[paraName]:Config[paraName];
			}
		}
		
		public static function getAllparamsName():Array
		{
			var paramsArray:Array = new Array();
			var varXmlList:XMLList = describeType(Config).variable;
			for each(var varXml:XML in varXmlList)
			{
				paramsArray.push(varXml.@name);
			}
			return paramsArray;
		}
	}
}