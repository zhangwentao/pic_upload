package com.renren.picUpload
{
	import com.renren.util.Logger;
	public function log(...param):void
	{
		Logger.status = Logger.STATUS_OFF;
		Logger.log(param);
	}
} 