package org.asclub.net
{
    import flash.external.*;

    final public class JSCaller extends Object
    {

        public function JSCaller()
        {
            return;
        }// end function

        public static function addCallback(param1:String, param2:Function) : void
        {
            if (ExternalInterface.available)
            {
                ExternalInterface.addCallback(param1, param2);
            }
            return;
        }// end function

        public static function call(param1:String, ... args)
        {
            if (ExternalInterface.available)
            {
                args.unshift(param1);
                return ExternalInterface.call.apply(ExternalInterface, args);
            }
            return null;
        }// end function

        public static function get objectID() : String
        {
            if (ExternalInterface.available)
            {
            }
            return null;
        }// end function

    }
}
