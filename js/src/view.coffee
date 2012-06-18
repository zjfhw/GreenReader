
###############
# create View #
###############


RSSReader.SubscriptionView = Em.CollectionView.extend
  contentBinding: 'RSSReader.subscriptionController.content'
  tageName:'ul'
  itemViewClass:Em.View.extend
    tagName:'li'
    click:->
      console.log 'click', this
      # GetItemsFromStore()
RSSReader.AddSubscriptionView = Em.View.extend
  add:->
    console.log this
    # RSSReader.subscriptionController.addItem
RSSReader.FooterNavBarView = Em.CollectionView.extend
  contentBinding:'RSSReader.navbarController.content'
  # templateName:'navbar'
  # content:[{id:'nimei',title:'zahuishi'}]
  tagName:'ul'
  itemViewClass:Em.View.extend
    # classNameBindings:['enabled']
    enabled:true# ->
      # cl=@get('content').get 'currentList'
      # enable = cl is 'show'+@get('content').get 'title'
    tagName:'li'
    click:->
      # @get('content').set 'currentList',@get('content').get 'action'
      console.log @get('content').get 'currentList'
      RSSReader.itemController[@get('content').get 'action']()
      
  
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
  itemViewClass: RSSReader.ListItemView

 # Observe the attached content array's length and refresh the listview on the next RunLoop tick.
  contentLengthDidChange:(->
    console.log('listview changed',this)
    _self = this
    Em.run.next( ->
      jQT.setPageHeight()
    )
  ).observes('content.length')
  contentBinding : 'RSSReader.itemController.content'
  # templateName: 'listview'
  didInsertElement:->
    console.log 'main insert'
    Em.run.next(->
      RSSReader.pullinit())
  # tagName: 'article' # view tag
  # classNames: ['well','summary'] # view class 
  # css class binding to read and starred
  
RSSReader.ListItemView.reopen
  # templateName: 'current'
  classNameBindings: ['read','starred']
  read:(->
    read = @get('content').get 'read'
  ).property('RSSReader.itemController.@each.read')

  starred:(->
    starred = @get('content').get 'starred'
  ).property 'RSSReader.itemController.@each.starred'

  click:(evt)->
    console.log 'select', @get 'content'
    content = @get 'content'
    RSSReader.itemNavController.select content
    jQT.goTo '#current-view','slideleft'
    # $.mobile.changePage '#current-view',{transition:'slide'}
  dateFromNow:(->
    moment(@get('content').get 'pub_date').fromNow()
  ).property 'RSSReader.itemController.@each.pub_date'
# - Header
RSSReader.HeaderView.reopen
  refresh:()->
    RSSReader.GetItemsFromStore()
    # callback()

# - item's NavBar view
RSSReader.NavbarView = Em.View.extend
  
  # property binding
  currentListBinding:'RSSReader.itemController.currentList'
  itemCountBinding:'RSSReader.dataController.itemCount'
  unreadCountBinding:'RSSReader.dataController.unreadCount'
  starredCountBinding:'RSSReader.dataController.starredCount'
  readCountBinding:'RSSReader.dataController.readCount'
  
  # Actions
  showAll:->
    RSSReader.itemController.clearFilter()
    @set 'currentList','showAll'
  showUnread:->
    RSSReader.itemController.filterBy 'read',false
    @set 'currentList','showUnread'

  showRead:->
    RSSReader.itemController.filterBy 'read',true
    @set 'currentList','showRead'
  showStarred:->
    RSSReader.itemController.filterBy 'starred',true
    @set 'currentList','showStarred'

# - entry detail view
RSSReader.EntryItemView = Em.View.extend
  contentBinding: 'RSSReader.itemNavController.currentItem'
  viewDidChange:(->
    console.log 'view change'
    jQT.setPageHeight()
    # TODO reset iscroll
    # jQT.refresh_iScroll
    ).observes 'content'

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
