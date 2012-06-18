/*
 * iscroll-wrapper for jQquery.
 * http://sanraul.com/projects/jqloader/
 * 
 * Copyright (c) 2011 Raul Sanchez (http://www.sanraul.com)
 * 
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 */
(function($){
    $.fn.iscroll = function(options){
		if(this.data('iScrollReady') == null){
			var that = this;
      var options =  $.extend({}, options);
 
      console.log(options)
			arguments.callee.object  = new iScroll(this.get(0), options);
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

App = RSSReader;

// Base classes for jQueryMobile Support
// In a 'real' implementation, this should be broken out into its own Ember.js module/extension.
App.MobileBaseView = Em.View.extend({
  attributeBindings:['data-role']
});

App.PageView = App.MobileBaseView.extend({
  'data-role': 'page'
});

App.ToolbarBaseView = App.MobileBaseView.extend({
  attributeBindings:['data-position'],
  'data-position': function() {
    if (this.get('isFullScreen')) {
      return 'fullscreen'
    }

    if (this.get('isFixed')) {
      return 'fixed'
    }
    return ''
  }.property('isFixed', 'isFullScreen').cacheable(),

  isFixed: true,
  isFullsScreen: false
});

App.HeaderView = App.ToolbarBaseView.extend({
  classNames:['toolbar'] 
});
// App.NavbarView = App.MobileBaseView.extend({
//   'data-role': 'navbar'
// });
App.ContentView = App.MobileBaseView.extend({
  'data-role': 'content'
});

App.FooterView = App.ToolbarBaseView.extend({
  'data-role': 'footer'
});
App.ListItemView = Em.View.extend({
  tagName: 'li'
});

// App.ListView = App.MobileBaseView.extend({
//     // attributeBindings: ['data-role'],
//     'data-role':'listview',
//     tagName: 'ul',
//   change:function(){
//   console.log('change',this)}
//     // itemViewClass: App.ListItemView,
// });


App.Button = Em.Button.extend({
  // Simple marker for consistency with the App.ViewName convention. jQuery Mobile automatically styles buttons.
});

App.MyView = App.ContentView.extend({

});
App.ListView = App.PageView.extend({
  // attributeBindings:['data-url'],
  // 'data-url':'',
  templateName:'listview',
  elementId: 'list-view',
  // didInsertElement: function() {
  // $.mobile.changePage(this.$());
  // }
})

App.CurrentView = App.PageView.extend({
  attributeBindings:['data-url'],
  'data-url':'current',
  templateName:'current',
  elementId: 'current-view'
});

// $(document).bind('mobileinit', function() {
//     $.mobile.touchOverflowEnabled = true;
// });
