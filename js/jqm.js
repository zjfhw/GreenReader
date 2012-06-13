var App = RSSReader;


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
App.NavbarView = App.MobileBaseView.extend({
    'data-role': 'navbar'
});
App.ContentView = App.MobileBaseView.extend({
    'data-role': 'content'
});

App.FooterView = App.ToolbarBaseView.extend({
    'data-role': 'footer'
});
App.ListItemView = Em.View.extend({
    tagName: 'li',
});

// App.ListView = App.MobileBaseView.extend({
//     // attributeBindings: ['data-role'],
//     'data-role':'listview',
//     tagName: 'ul',
//   change:function(){
//   console.log('change',this)}
//     // itemViewClass: App.ListItemView,
// });

App.ListView = Em.CollectionView.extend({
  classNames:['plastic','view'],
    tagName: 'ul',
    itemViewClass: App.ListItemView,

    // Observe the attached content array's length and refresh the listview on the next RunLoop tick.
    // contentLengthDidChange: function(){
    //     console.log('listview changed');
    //     var _self = this;
    //     Em.run.next(function() {
    //         _self.$().listview('refresh');
    //     });
    // }.observes('content.length')

});

App.Button = Em.Button.extend({
    // Simple marker for consistency with the App.ViewName convention. jQuery Mobile automatically styles buttons.
});

// App Classes

App.listController = Em.ArrayProxy.create({
    content: App.sampleFixture,

    addMore: function() {
        var content = this.get('content');
        content.pushObject(Em.Object.create({
            title: 'New Item',
            description: 'Another Item',
            thumbnail: 'http://jquerymobile.com/demos/1.0/docs/lists/images/album-bb.jpg'
        }));
    }
});

App.MyView = App.ContentView.extend({

});

App.MainView = App.PageView.extend({
  attributeBindings:['data-url'],
   'data-url':'',
  templateName:'main',
  elementId: 'main-view',
  // didInsertElement: function() {
    // $.mobile.changePage(this.$());
    // }
});

App.CurrentView = App.PageView.extend({
attributeBindings:['data-url'],
   'data-url':'current',
    templateName:'current',
    elementId: 'current-view'
});

// $(document).bind('mobileinit', function() {
//     $.mobile.touchOverflowEnabled = true;
// });


$(function(){
    console.log('pageinit');
    var v = App.get('mainView');

    if (!v) {
        console.log('main not created');
        v = App.MainView.create();
        App.set('mainView',v);
        v.appendTo($('#jqt'));
    }
var c = App.get('currentView');

    if (!c) {
        console.log('current not created');
        c = App.CurrentView.create();
        App.set('currentView',c);
        c.appendTo($('#jqt'));
    }
$('#swipeme').swipe(function(evt, info) {
    console.log(info.direction);

                });
});

