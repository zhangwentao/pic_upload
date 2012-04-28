package 
{
	import flash.external.ExternalInterface;
    import flash.utils.*;
    import org.asclub.net.*;

    final public class ImagePreParser extends Object
    {
        private static const JPGHexTag:Array = [[255, 192, 0, 17, 8]];
        private static const PNGHexTag:Array = [[73, 72, 68, 82]];
        private static const GIFHexTag:Array = [[33, 249, 4], [0, 44]];
        private static var fileType:String;
        private static var hexTag:Array;
        private static var APPnTag:Array;
        private static var leapLength:int;
        private static var address:uint;
        private static var byte:uint;
        private static var index:uint = 0;
        private static var match:Boolean = false;
        private static var isAPPnExist:Boolean = false;
        public static var contentWidth:uint;
        public static var contentHeight:uint;
        private static var fileData:ByteArray;

        public function ImagePreParser()
        {
            return;
        }// end function

        public static function parse(param1:ByteArray) : void
        {
			reinit();
			leapLength = 0;
            fileData = param1;
            fileData.position = 0;
            if (FileTypeCheck.isPNG(param1))
            {
				//ExternalInterface.call("alert","png");
                fileType = "png";
                hexTag = PNGHexTag;
                matchHexTag();
            }
            else if (FileTypeCheck.isJPEG(param1))
            {
//				ExternalInterface.call("alert","jpg");
                fileType = "jpg";
                hexTag = JPGHexTag;
                APPnTag = [];
                JPGAPPnMatch();
            }
            else if (FileTypeCheck.isGIF(param1))
            {
//				ExternalInterface.call("alert","gif");
                fileType = "gif";
                hexTag = GIFHexTag;
                leapLength = 4;
                matchHexTag();
            }
            return;
        }// end function

		
		private static function reinit():void
		{
			hexTag = null;
			APPnTag = null;
			leapLength = 0;
			address = 0;
			byte = 0;
			index = 0;
			match = false;
			isAPPnExist = false;
			contentWidth =0;
			contentHeight= 0;
			fileData= null;
		}
		
        private static function matchHexTag()
        {
            var _loc_1:* = hexTag.length;
            while (fileData.bytesAvailable > hexTag[0].length)
            {
                
                match = false;
                byte = fileData.readUnsignedByte();
                var _loc_3:* = address + 1;
                address = _loc_3;
                if (byte == hexTag[0][index])
                {
                    match = true;
                    if (index >= (hexTag[0].length - 1) && _loc_1 == 1)
                    {
                        getWidthAndHeight();
                        break;
                    }
                    else if (index >= (hexTag[0].length - 1) && _loc_1 > 1)
                    {
                        hexTag.shift();
                        index = 0;
                        matchHexTag();
                        break;
                    }
                }
                if (match)
                {
					index = index + 1;
                
                    continue;
                }
                index = 0;
            }
            return;
        }// end function

        private static function JPGAPPnMatch()
        {
            while (fileData.bytesAvailable > leapLength)
            {
                
                match = false;
                byte = fileData.readUnsignedByte();
                var _loc_2:* = address + 1;
                address = _loc_2;
                if (byte == 255)
                {
                    byte = fileData.readUnsignedByte();
					address = address + 1;
                    
                    if (byte >= 225 && byte <= 239)
                    {
                        isAPPnExist = true;
                        leapLength = fileData.readUnsignedShort() - 2;
                        leapBytes(leapLength);
                        JPGAPPnMatch();
                    }
                }
                if (byte != 255 && leapLength != 0)
                {
                    matchHexTag();
                    break;
                }
                if (address > 100 && isAPPnExist == false)
                {
                    matchHexTag();
                    break;
                }
            }
            return;
        }// end function

        private static function leapBytes(param1:uint) : void
        {
            var _loc_2:uint = 0;
            while (_loc_2 < param1)
            {
                
                fileData.readByte();
                _loc_2 = _loc_2 + 1;
            }
            address = address + param1;
            return;
        }// end function

        private static function getWidthAndHeight()
        {
            if (fileType == "gif")
            {
                leapBytes(leapLength);
            }
            switch(fileType)
            {
                case "png":
                {
                    contentWidth = fileData.readUnsignedInt();
                    contentHeight = fileData.readUnsignedInt();
                    break;
                }
                case "gif":
                {
                    contentWidth = fileData.readUnsignedShort();
                    contentHeight = fileData.readUnsignedShort();
                    break;
                }
                case "jpg":
                {
                    contentHeight = fileData.readUnsignedShort();
                    contentWidth = fileData.readUnsignedShort();
                    break;
                }
                default:
                {
                    break;
                }
            }
            return;
        }// end function

    }
}
