
var showLoader = function(){
    $('.ui-loader').css('display','block');
}
var hideLoader = function(){
    $('.ui-loader').css('display','none');
}
$(function(){
    $("#jqt").ajaxStart(function() {
        $('.ui-loader').css('display','block');
        console.log("ajaxStart");
    }).ajaxSuccess(function() {
        console.log("ajaxSuccess");
        $('.ui-loader').css('display','none');
    }).ajaxError(function() {
        $('.ui-loader').css('display','none');
        console.log("ajaxError");
    });

});
(function($){
    $.fn.iscroll = function(options){
        console.log(this);
		    if(this.data('iScrollReady') == null){
			      var that = this;
            var options =  $.extend({}, options);
            if(that.data('iscroll') && jQuery.isEmptyObject(options)){
                console.log('hree');
                arguments.callee.object  =that.data('iscroll')
            }
            else{
                if (that.data('iscroll')){
                    that.data('iscroll').options=$.extend(that.data('iscroll').options,options
                                                          );
                    // that.data('iscroll',new iScroll(this.get(0), options));
			              arguments.callee.object  = that.data('iscroll');
                }
                else{
                    arguments.callee.object  = new iScroll(this.get(0), options)
                }
            }
			      // NOTE: for some reason in a complex page the plugin does not register
			      // the size of the element. This will fix that in the meantime.
			      setTimeout(function(scroller){
				        scroller.refresh();
			      }, 1000, arguments.callee.object);
			      this.data('iScrollReady', true);
		    }else{
			      arguments.callee.object.refresh();
		    }
		    return arguments.callee.object;
	  };
})(jQuery);
