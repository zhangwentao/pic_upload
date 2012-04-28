package org.asclub.net
{
    import flash.events.*;
    import flash.net.*;

    public class WebLoader extends EventDispatcher
    {
        private var urlLoader:URLLoader;
        public var data:Object;
        private var _urlRequest:URLRequest;

        public function WebLoader()
        {
            this.urlLoader = new URLLoader();
            this.urlLoader.addEventListener(Event.COMPLETE, this.loadCompleteHandler);
            this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.loadErrorHandler);
            this.urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.loadHTTPStatusHandler);
            this.urlLoader.addEventListener(ProgressEvent.PROGRESS, this.loadProgressHandler);
            this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.loadSecurityErrorHandler);
            this.urlLoader.addEventListener(Event.OPEN, this.loadOpenHandler);
            this._urlRequest = new URLRequest();
            return;
        }// end function

        public function load(param1:String, param2:Object = null, param3:String = null, param4:String = null, param5:Array = null, param6:String = null) : void
        {
            var _loc_7:URLVariables = null;
            var _loc_8:String = null;
            this._urlRequest.url = param1;
            this._urlRequest.method = param3 == null ? (URLRequestMethod.GET) : (param3);
            if (param4 != null)
            {
                this._urlRequest.contentType = param4;
            }
            if (param5 != null)
            {
                this._urlRequest.requestHeaders = param5;
            }
            if (param2 != null)
            {
                _loc_7 = new URLVariables();
                for (_loc_8 in param2)
                {
                    
                    _loc_7[_loc_8] = param2[_loc_8];
                }
                this._urlRequest.data = _loc_7;
            }
            if (param6 != null)
            {
                this.urlLoader.dataFormat = param6;
            }
            this.urlLoader.load(this._urlRequest);
            return;
        }// end function

        public function dispose() : void
        {
            this.urlLoader.removeEventListener(Event.COMPLETE, this.loadCompleteHandler);
            this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.loadErrorHandler);
            this.urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.loadHTTPStatusHandler);
            this.urlLoader.removeEventListener(ProgressEvent.PROGRESS, this.loadProgressHandler);
            this.urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.loadSecurityErrorHandler);
            this.urlLoader.removeEventListener(Event.OPEN, this.loadOpenHandler);
            return;
        }// end function

        private function loadCompleteHandler(event:Event) : void
        {
            this.data = event.currentTarget.data;
            dispatchEvent(event);
            return;
        }// end function

        private function loadErrorHandler(event:IOErrorEvent) : void
        {
            dispatchEvent(event);
            return;
        }// end function

        private function loadHTTPStatusHandler(event:HTTPStatusEvent) : void
        {
            dispatchEvent(event);
            return;
        }// end function

        private function loadProgressHandler(event:ProgressEvent) : void
        {
            this.data = event.currentTarget.data;
            dispatchEvent(event);
            return;
        }// end function

        private function loadSecurityErrorHandler(event:SecurityErrorEvent) : void
        {
            dispatchEvent(event);
            return;
        }// end function

        private function loadOpenHandler(event:Event) : void
        {
            dispatchEvent(event);
            return;
        }// end function

    }
}
