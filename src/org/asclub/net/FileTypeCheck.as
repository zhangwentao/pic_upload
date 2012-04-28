package org.asclub.net
{
    import flash.utils.*;

    final public class FileTypeCheck extends Object
    {
        private static var _fileData:ByteArray;

        public function FileTypeCheck()
        {
            return;
        }// end function

        public static function isBMP(param1:ByteArray) : Boolean
        {
            param1.position = 0;
            if (param1.bytesAvailable < 2)
            {
                return false;
            }
            return param1.readUTFBytes(2).toLocaleUpperCase() == "BM";
        }// end function

        public static function isFLV(param1:ByteArray) : Boolean
        {
            param1.position = 0;
            if (param1.bytesAvailable < 3)
            {
                return false;
            }
            return param1.readUTFBytes(3).toLocaleUpperCase() == "FLV";
        }// end function

        public static function isPNG(param1:ByteArray) : Boolean
        {
            _fileData = param1;
            _fileData.position = 0;
            if (_fileData.bytesAvailable < 8)
            {
                return false;
            }
            var _loc_2:Array = [137, 80, 78, 71, 13, 10, 26, 10];
            return _loc_2.every(everyCallBack);
        }// end function

        public static function isGIF(param1:ByteArray) : Boolean
        {
            _fileData = param1;
            _fileData.position = 0;
            if (_fileData.bytesAvailable < 6)
            {
                return false;
            }
            var _loc_2:Array = [71, 73, 70, 56, 57, 97];
            var _loc_3:Array = [71, 73, 70, 56, 55, 97];
            var _loc_4:* = _loc_2.every(everyCallBack);
            var _loc_5:* = _loc_3.every(everyCallBack);
            return _loc_4 || _loc_5;
        }// end function

        public static function isJPEG(param1:ByteArray) : Boolean
        {
            _fileData = param1;
            _fileData.position = 0;
            if (_fileData.bytesAvailable < 2)
            {
                return false;
            }
            var _loc_2:Array = [255, 216];
            return _loc_2.every(everyCallBack);
        }// end function

        public static function isTGA(param1:ByteArray) : Boolean
        {
            _fileData = param1;
            _fileData.position = 0;
            if (_fileData.bytesAvailable < 5)
            {
                return false;
            }
            var _loc_2:Array = [0, 0, 2, 0, 0];
            var _loc_3:Array = [0, 0, 16, 0, 0];
            var _loc_4:* = _loc_2.every(everyCallBack);
            var _loc_5:* = _loc_3.every(everyCallBack);
            return _loc_4 || _loc_5;
        }// end function

        public static function isPCX(param1:ByteArray) : Boolean
        {
            param1.position = 0;
            if (param1.bytesAvailable < 1)
            {
                return false;
            }
            return param1.readInt() == 10;
        }// end function

        public static function isTIFF(param1:ByteArray) : Boolean
        {
            _fileData = param1;
            _fileData.position = 0;
            if (_fileData.bytesAvailable < 2)
            {
                return false;
            }
            var _loc_2:Array = [77, 77];
            var _loc_3:Array = [73, 73];
            var _loc_4:* = _loc_2.every(everyCallBack);
            var _loc_5:* = _loc_3.every(everyCallBack);
            return _loc_4 || _loc_5;
        }// end function

        public static function isICO(param1:ByteArray) : Boolean
        {
            _fileData = param1;
            _fileData.position = 0;
            if (_fileData.bytesAvailable < 8)
            {
                return false;
            }
            var _loc_2:Array = [0, 0, 1, 0, 1, 0, 32, 32];
            return _loc_2.every(everyCallBack);
        }// end function

        public static function isCUR(param1:ByteArray) : Boolean
        {
            return false;
        }// end function

        public static function isIFF(param1:ByteArray) : Boolean
        {
            _fileData = param1;
            _fileData.position = 0;
            if (_fileData.bytesAvailable < 8)
            {
                return false;
            }
            var _loc_2:Array = [70, 79, 82, 77];
            return _loc_2.every(everyCallBack);
        }// end function

        public static function isANI(param1:ByteArray) : Boolean
        {
            _fileData = param1;
            _fileData.position = 0;
            if (_fileData.bytesAvailable < 8)
            {
                return false;
            }
            var _loc_2:Array = [82, 73, 70, 70];
            return _loc_2.every(everyCallBack);
        }// end function

        private static function everyCallBack(param1:int, param2:int, param3:Array) : Boolean
        {
            return _fileData[param2] == param1;
        }// end function

    }
}
