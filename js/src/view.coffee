
###############
# create View #
###############

RSSReader.ListView = Em.View.extend
  templateName:'listview'
  elementId: 'list-view'
  didInsertElement:->
    Em.run.next ->
      jQT.initbars()
RSSReader.CurrentView = Em.View.extend
  templateName:'current'
  elementId: 'current-view'

# RSSReader.MainView = Em.View.extend
#   templateName:'mainview'
#   elementId: 'main-view


# RSSReader.SubscriptionItemView = Em.View.extend
#     swipeOptions:
#         direction: Em.OneGestureDirection.Left | Em.OneGestureDirection.Right
#         cancelPeriod: 100
#         swipeThreshold: 10
#     click:->
#       console.log 'click',this
#     swipeEnd:(recognizer)->
#       console.log('recognizer',recognizer.swipeDirection)
      
#       if Em.OneGestureDirection.Left is recognizer.swipeDirection
#         console.log $this.next()
#         $this.addClass 'delete'
#         $this.next().removeClass 'hide'
#       else if Em.OneGestureDirection.Right is recognizer.swipeDirection
#         $this.removeClass 'delete'
#         $this.next().addClass 'hide'
#     tagName:'li'
#     classNames: ['arrow']
    # elementId:(->
    #   @get('content').url
    # ).property 'content'
   
    # getstore:->
    #   console.log this
    #   RSSReader.GetItemsFromStore(@get 'elementId')
    #   RSSReader.subscriptionController.set "currentSubscription",@get 'content'
    #   console.log 'click', @get 'elementId'
    #   jQT.goTo '#list-view', 'cube'
    # delete:->
    #   #console.log 'delete',@get 'elementId'
    #   RSSReader.subscriptionController.removeItem @get 'elementId


RSSReader.SubscriptionView = Em.CollectionView.extend
  contentBinding: 'RSSReader.subscriptionController.content'
  tagName:'ul'
  classNames:['plastic','view']
  itemViewClass:Em.View.extend
    swipeOptions:
        direction: Em.OneGestureDirection.Left | Em.OneGestureDirection.Right
        cancelPeriod: 100
        swipeThreshold: 10
    
    swipeEnd:(recognizer)->
      # console.log('recognizer',recognizer.swipeDirection)
      $this = this.$()
      # console.log this.$().toString()
      # console.log this.$().attr("class")
      if Em.OneGestureDirection.Right is recognizer.swipeDirection
        console.log 'swipe left'
        $this.find('a').addClass 'delete'
        $this.find('small').removeClass 'hide'
      else if Em.OneGestureDirection.Left is recognizer.swipeDirection
        console.log 'swipt right'
        $this.find('a').removeClass 'delete'
        $this.find('small').addClass 'hide'
    tagName:'li'
    classNames: ['arrow']
    getstore:->
      console.log 'getstroe',@get('content').url
      RSSReader.GetItemsFromStore(@get('content').url)
      RSSReader.subscriptionController.set "currentSubscription",@get 'content'
      console.log 'click',@get('content').url
      jQT.goTo '#list-view'
    delete:->
      #console.log 'delete',@get 'elementId'
      RSSReader.subscriptionController.removeItem @get('content').url
  emptyView: Ember.View.extend({
      template: Ember.Handlebars.compile("Your subscription is empty")
    })
  contentLengthDidChange:(->
    console.log('subscription changed',@get 'content')
    # @rerender()
    Em.run.next( ->
      jQT.setPageHeight()
    )
  ).observes('content.length')
      # GetItemsFromStore()
# RSSReader.AddSubscriptionView = Em.View.extend
#   click:->
#     RSSReader.subscriptionController.addItem()
#     jQT.goTo '#main-view','flipleft'

RSSReader.QueryResultView = Em.CollectionView.extend
  contentBinding:'RSSReader.queryResultController.content'
  tagName:'ul'
  classNames:['plastic']
  itemViewClass:Em.View.extend
    tagName:'li'
    click:->
      # console.log this.$()
      RSSReader.subscriptionController.addItem @get 'content'
      jQT.goTo '#main-view','flipleft'
  contentLengthDidChange:(->
    #console.log('subscription changed',this)
    Em.run.next( ->
      jQT.setPageHeight()
    )
  ).observes('content.length')
  
RSSReader.FooterNavBarView = Em.CollectionView.extend
  contentBinding:'RSSReader.navbarController.content'
  # templateName:'navbar'
  # content:[{id:'nimei',title:'zahuishi'}]
  tagName:'ul'
  itemViewClass:Em.View.extend
    # classNameBindings:['enabled']
      # cl=@get('content').get 'currentList'
      # enable = cl is 'show'+@get('content').get 'title'
    tagName:'li'
    didInsertElement:->
      Em.run.once ->
        jQT.initTabbar()
    click:->
      # @get('content').set 'currentList',@get('content').get 'action'
      #console.log @get('content').get('currentList') ,@get('content')
      $content = @get 'content'
      if @get('content').get('action') is 'inBrowser'
        window.location= RSSReader.itemNavController.get('currentItem').item_link
        return
      if RSSReader.itemController[@get('content').get 'action']
        RSSReader.itemController[@get('content').get 'action']()
      else if RSSReader.itemNavController[@get('content').get 'action']
        RSSReader.itemNavController[@get('content').get 'action']()
        #console.log 'in itemNavController'
      
  # contentWithIndices:(->
  #   content.map (i,idx)->
  #     {item:i,index:idx}
  #   ).property '@each'
    # Em.run.next ->
    #   jQT.initTabbar()
  
# - Summary List
RSSReader.SummaryListView = Em.CollectionView.extend
  classNames:['plastic','view']
  tagName: 'ul'
  itemViewClass: Em.View.extend
    classNameBindings: ['read','starred']
    read:(->
      read = @get('content').get 'read'
    ).property('RSSReader.itemController.@each.read')

    starred:(->
      starred = @get('content').get 'starred'
    ).property 'RSSReader.itemController.@each.starred'

    click:(evt)->
      # console.log 'select',this, this.$()
      content = @get 'content'
      RSSReader.itemNavController.select content
      jQT.goTo '#current-view','slideleft'
      # $.mobile.changePage '#current-view',{transition:'slide'}
    dateFromNow:(->
      moment(@get('content').get( 'pub_date')).fromNow()
    ).property 'RSSReader.itemController.@each.pub_date'
    viewDidChange:(->
    #console.log 'view change'
      jQT.setPageHeight()
      # TODO reset iscroll
      # jQT.refresh_iScroll
    ).observes 'content'
    
 # Observe the attached content array's length and refresh the listview on the next RunLoop tick
  contentLengthDidChange:(->
    #console.log('listview changed',this)
    _self = this
    Em.run.next( ->
      jQT.setPageHeight()
    )
  ).observes('content.length')
  contentBinding : 'RSSReader.itemController.content'
  # templateName: 'listview'
  didInsertElement:->
    #console.log 'main insert'
    Em.run.next(->
      RSSReader.pullinit())
  # tagName: 'article' # view tag
  # classNames: ['well','summary'] # view class 
  # css class binding to read and starred
  
# RSSReader.ListItemView = Em.View.extend
#   # templateName: 'current'
  
#   classNameBindings: ['read','starred']
#   read:(->
#     read = @get('content').get 'read'
#   ).property('RSSReader.itemController.@each.read')

#   starred:(->
#     starred = @get('content').get 'starred'
#   ).property 'RSSReader.itemController.@each.starred'

#   click:(evt)->
#     #console.log 'select', @get 'content'
#     content = @get 'content'
#     RSSReader.itemNavController.select content
#     jQT.goTo '#current-view','cube'
#     # $.mobile.changePage '#current-view',{transition:'slide'}
#   dateFromNow:(->
#     #console.log @get('content').get 'pub_date'
#     moment(@get('content').get('pub_date')).fromNow()
#   ).property 'RSSReader.itemController.@each.pub_date'
# - Header
# - item's NavBar view
# RSSReader.NavbarView = Em.View.extend
  
#   # property binding
#   currentListBinding:'RSSReader.itemController.currentList'
#   itemCountBinding:'RSSReader.dataController.itemCount'
#   unreadCountBinding:'RSSReader.dataController.unreadCount'
#   starredCountBinding:'RSSReader.dataController.starredCount'
#   readCountBinding:'RSSReader.dataController.readCount'
  
#   # Actions
#   showAll:->
#     RSSReader.itemController.clearFilter()
#     @set 'currentList','showAll'
#   showUnread:->
#     RSSReader.itemController.filterBy 'read',false
#     @set 'currentList','showUnread'

#   showRead:->
#     RSSReader.itemController.filterBy 'read',true
#     @set 'currentList','showRead'
#   showStarred:->
#     RSSReader.itemController.filterBy 'starred',true
#     @set 'currentList','showStarred'

# - entry detail view
RSSReader.EntryItemView = Em.View.extend
  contentBinding: 'RSSReader.itemNavController.currentItem'
  viewDidChange:(->
    console.log 'view change',@get 'content'
    Em.run.once ->
      jQT.setPageHeight()
    # TODO reset iscroll
    # jQT.refresh_iScroll
  ).observes 'content'
  swipeOptions:
        direction: Em.OneGestureDirection.Left | Em.OneGestureDirection.Right
        cancelPeriod: 100
        swipeThreshold: 10
    
  swipeEnd:(recognizer)->
      if Em.OneGestureDirection.Right is recognizer.swipeDirection
        RSSReader.itemNavController.prev()
      else if Em.OneGestureDirection.Left is recognizer.swipeDirection
        RSSReader.itemNavController.next()
      $scroll = $('.swipe').iscroll()
      $scroll.refresh()
      $scroll.scrollTo(0,0)
# RSSReader.EntryFooterView = RSSReader.FooterView.extend
#   'data-position':'fixed'
#   contentBinding: 'RSSReader.itemNavController.currentItem'
#   toggleRead: ->
#     RSSReader.itemNavController.toggleRead()
#   toggleStar:->
#     RSSReader.itemNavController.toggleStar()
#   starClass:(->
#     currentItem = RSSReader.itemNavController.get 'currentItem'
#     if currentItem and currentItem.get 'starred'
#       return 'starred'
#     'star-empty'
#   ).property 'RSSReader.itemNavController.currentItem.starred'
#   readClass:(->
#     currentItem = RSSReader.itemNavController.get 'currentItem'
#     if currentItem and currentItem.get 'read'
#       return 'read'
#     'unread'
#   ).property 'RSSReader.itemNavController.currentItem.read'
#   nextpage:->
#     RSSReader.itemNavController.next()
#   prevpage:->
#     RSSReader.itemNavController.prev()
#   nextDisable:(->
#     !RSSReader.itemNavController.get 'hasNext'
#   ).property 'RSSReader.itemNavController.currentItem.next'
#   prevDisable:(->
#     !RSSReader.itemNavController.get 'hasPrev'
#   ).property 'RSSReader.itemNavController.currentItem.prev' 
