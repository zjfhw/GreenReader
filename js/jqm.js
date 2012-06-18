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


// $(document).bind('mobileinit', function() {
//     $.mobile.touchOverflowEnabled = true;
// });
