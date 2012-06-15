#####################
# create app object #
#####################

# local storage
# new lawnchair ->

nimei='entries'
store = Lawnchair
  name:nimei
  record:'entry'
  ,->
 
pp = Lawnchair
  name:'piaopiao'
  record:'entry'
  ,->
    @save({entry:'meide'})
# app
RSSReader.reopen
  ready:->
    @_super()
    # get content from rss source
    
    RSSReader.GetItemsFromStore('showDefault')
    RSSReader.navbarController.mainPage()
    # RSSReader.pageinit()
    jQT.initbars()
    
  
    # RSSReader.initPullToRefresh()
mainNavJson=[
  {
    id:'#settings'
    title:'Settings'
    icon:''
    count:3
  }
  {
    id:'#main'
    title:'Main'
    icon:''
    count:4
   }
]
################
# create Model #
################
RSSReader.Item = Em.Object.extend
  read: false # read flag
  starred: false # starred flag
  item_id: null 
  title: null
  short_desc: null # rss news short description
  content: null # full Content of news
  pub_name:null # name of publisher
  pub_author:null
  pub_date: new Date(0),
  feed_link: null # rss source link
  item_link:null # news item source link

# Footer Nav Button
RSSReader.NavButton = Em.Object.extend
  url:null
  title:null
  icon:null
  count:null
#
# create Controller
#
# Data Controller: Opertations of rss data

RSSReader.dataController = Em.ArrayController.create
  content: []
  
  # add item to controller if it's not exists already
  addItem:(item) ->
    exists = @filterProperty('item_id',item.item_id).length
    if exists is 0
      length = @get ('length')
      idx = @binarySearch (Date.parse (item.get 'pub_date')),0,length
      @insertAt idx,item
      return true
    else
      false
      
  binarySearch:(value,low,high) ->
    if low is high
      return low
    mid = low + Math.floor (high-low)/2
    midValue = Date.parse @objectAt(mid).get 'pub_date'
    if value < midValue
      return @binarySearch value,mid+1,high
    else if value > midValue
      return @binarySearch value,low,mid
    mid

  # property return read count
  itemCount:(->@get 'length').property '@each'

  readCount:(->
    @filterProperty('read',true).get 'length'
  ).property '@each.read'

  # property return unread count

  unreadCount:(->
    @filterProperty('read',false).get 'length'
  ).property '@each.read'

  # property return starred count
  starredCount:(->
    @filterProperty('starred',true).get 'length'
  ).property '@each.starred'

  # mark all items as read
  # markAllRead:->
  #   @forEach (item)->
  #     item.set 'read',true
  #     store.toggleRead (item.get 'item_id'),true

  
################
#items filter #
################

RSSReader.itemController = Em.ArrayController.create
  content: []
  currentList:'showDefault'

  refreshList:(callbackFn)->
    console.log('currentList',@get 'currentList') 
    RSSReader.GetItemsFromStore @get('currentList'), callbackFn 
  # user can filt items by 'read unread starred'...
  filterBy: (key,value)->
    @set 'content', RSSReader.dataController.filterProperty key,value

  # reset
  clearFilter:->
    @set 'content', RSSReader.dataController.get 'content'
  
  # default is show items unread
  showDefault:->
    @filterBy 'read',false

  showAll:->
    clearFilter()
  showRead:->
    @filterBy 'read',true
  showStarred:->
    @filterBy 'starred',true
  showUnread:->
    @filterBy 'read',false
  markAllRead:->
    @forEach (item) ->
      item.set 'read',true

  # property return count of items
  itemCount:(->@get 'length').property '@each'

  # property return readed count
  readCount:(->
    @filterProperty('read',true).get 'length'
  ).property '@each.read'

  # ...more properties

  unreadCount:(->
    @filterProperty('read',false).get 'length'
  ).property '@each.read'

  starredCount:(->
    @filterProperty('starred',true).get 'length'
  ).property '@each.starred'


# Item Nav Controller
RSSReader.itemNavController = Em.Object.create
  currentItem: null
  hasPrev: false
  hasNext: false

  select:(item) ->
    if item
      @set 'currentItem',item
      @toggleRead true
      currentIndex = RSSReader.itemController.content.indexOf @get 'currentItem'
      @set 'hasNext', currentIndex+1 < RSSReader.itemController.get 'itemCount'
      @set 'hasPrev', currentIndex isnt 0
    else
      @set 'hasPrev',false
      @set 'hasNext',false
  toggleRead:(read) ->
    if read is undefined
      read = !@currentItem.get 'read'
    @currentItem.set 'read',read
    key = @currentItem.get 'item_id'
    store.get key,(entry)->
      entry.read = read
      store.save entry

  toggleStar:(star) ->
    if star is undefined
      star = !@currentItem.get 'starred'
    @currentItem.set 'starred',star
    key = @currentItem.get 'item_id'
    store.get key,(entry)->
      entry.starred = star
      store.save entry
  next:->
    currentIndex = RSSReader.itemController.content.indexOf @get 'currentItem'
    nextItem = RSSReader.itemController.content[currentIndex+1]
    if nextItem
      @select nextItem
  prev:->
    currentIndex = RSSReader.itemController.content.indexOf @get 'currentItem'
    prevItem = RSSReader.itemController.content[currentIndex-1]
    if prevItem
      @select prevItem

RSSReader.navbarController = Em.ArrayController.create
  content:[]
  mainPage:->
    # c = @get('content')
    # c.clear()
    @insertAt 0, RSSReader.NavButton.create btn for btn in mainNavJson
  arrayDidChange:->
    console.log 'navbar add',@get 'content'
  
  # subsPage:->
    

###############
# create View #
###############

# - Summary List
RSSReader.SummaryListView = RSSReader.ListView.extend
  contentBinding : 'RSSReader.itemController.content'
  templateName: 'main'
  didInsertElement:->
    console.log 'main insert'
    Em.run.next(->
      RSSReader.pullinit())
  # tagName: 'article' # view tag
  # classNames: ['well','summary'] # view class 
  # css class binding to read and starred
  
RSSReader.ListItemView.reopen
  templateName: 'current'
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
# - NavBar
RSSReader.FooterNavBarView = Em.View.extend
  contentBinding:'RSSReader.navbarController.content'
  # templateName:'navbar'
  # content:[{id:'nimei',title:'zahuishi'}]
  click:->
    console.log 'nimeia'
RSSReader.NavbarView.reopen
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

RSSReader.EntryItemView = RSSReader.ContentView.extend
  active:(->
    true
    ).property('RSSReader.itemNavController.currentItem')
  contentBinding: 'RSSReader.itemNavController.currentItem'
  viewDidChange:(->
    console.log 'view change'
    jQT.setPageHeight()
  ).observes 'content'

RSSReader.EntryFooterView = RSSReader.FooterView.extend
  'data-position':'fixed'
  contentBinding: 'RSSReader.itemNavController.currentItem'
  toggleRead: ->
    RSSReader.itemNavController.toggleRead()
  toggleStar:->
    RSSReader.itemNavController.toggleStar()
  starClass:(->
    currentItem = RSSReader.itemNavController.get 'currentItem'
    if currentItem and currentItem.get 'starred'
      return 'starred'
    'star-empty'
  ).property 'RSSReader.itemNavController.currentItem.starred'
  readClass:(->
    currentItem = RSSReader.itemNavController.get 'currentItem'
    if currentItem and currentItem.get 'read'
      return 'read'
    'unread'
  ).property 'RSSReader.itemNavController.currentItem.read'
  nextpage:->
    RSSReader.itemNavController.next()
  prevpage:->
    RSSReader.itemNavController.prev()
  nextDisable:(->
    !RSSReader.itemNavController.get 'hasNext'
  ).property 'RSSReader.itemNavController.currentItem.next'
  prevDisable:(->
    !RSSReader.itemNavController.get 'hasPrev'
  ).property 'RSSReader.itemNavController.currentItem.prev' 

#############################
# Get Items from rss source #
#############################
RSSReader.GetItemsFromStore = (currentList, callback)->
  items = store.all (arr)->
    arr.forEach (entry)->
      item = RSSReader.Item.create entry
      RSSReader.dataController.addItem item
    console.log 'entries load form local:', arr.length
  # feed source
  feed = 'http://cn.engadget.com/rss.xml'
  feed = encodeURIComponent feed
  # Feed parser that supports CORS and returns data as a JSON string
  # select * from xml where url='http://cn.engadget.com/tag/breaking+news/rss.xml'
  feedPipeURL = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%3D'"
  feedPipeURL += feed + "'&format=json"

  console.log 'getting sourc as json',feedPipeURL

  $.getJSON feedPipeURL,(data)->
    console.log data.query.results
    items = data.query.results.rss.channel.item

    feedLink = data.query.results.rss.channel.link

    # map each entry to dataController
    items.map (entry) ->
      item={}
      item.item_id = entry.guid.content
      item.pub_name = data.query.results.rss.channel.title
      item.pub_author = entry.author
      item.title = entry.title
      item.feed_link = feedLink
      item.content = entry.description
      if entry.origLink
        item.item_link = entry.origLink
      else
        item.item_link = entry.link
      # Ensure the summary is less than 128 characters
      # console.log entry.description
      if entry.description
          item.short_desc = $(entry.description).text().substr(0, 128) + "..."
      item.pub_date = new Date entry.pubDate
      item.read = false
      item.key = item.item_id

      if RSSReader.dataController.addItem RSSReader.Item.create item
        store.save item
    if !currentList
      currentList="showDefault"
    # showList
    RSSReader.itemController[currentList]()
    # execute callback function
    if callback
      callback()
## on Document Ready
# RSSReader.pageinit = ->
$(->
  
  $('.swipe').swipe (evt, info)->
    console.log 'tap', info.direction
    if info.direction is 'right'
      RSSReader.itemNavController.prev()
    else if info.direction is 'left'
      RSSReader.itemNavController.next()
  # jQT.initbars()
  # console.log 'pageinit'
  v = RSSReader.get 'mainView'

  if !v
    console.log 'main not created'
    v = App.MainView.create()
    RSSReader.set 'mainView',v
    v.appendTo $('#jqt')
  c = RSSReader.get 'currentView'

  if !c
    console.log 'current not created'
    c = RSSReader.CurrentView.create()
    RSSReader.set('currentView',c)
    c.appendTo $('#jqt')
 
 
)

pullDownAction = (scroll)->
  RSSReader.itemController.refreshList(->
    scroll.refresh()
    # console.log 'asdf'
  )

# pull down to refresh initialize
RSSReader.pullinit = ->
  # console.log 'jqtbars ready',jQT.barsReady
  # console.log 'mainview ready'
  pullDownEl = $('#pullDown')
  pullDownOffset = 51
  # pullUpEl = document.getElementById('pullUp');	
  # pullUpOffset = 
  # console.log 'pull start', $('#main-view_wrapper_0').data()
  # console.log 'wrapper data', $('#main-view_wrapper_0').data('iscroll')
  $('#main-view_wrapper_0').iscroll
    topOffset:51
    onRefresh:->
      # console.log 'refresh'
      if pullDownEl.hasClass 'loading'
        # console.log 'remove'
        pullDownEl.removeClass()
        pullDownEl.find('pullDownLabel').html('PullDown to Refresh')
    onScrollMove:->
      # console.log 'move'
      if @y > 5 and !pullDownEl.hasClass 'flip'
        pullDownEl.addClass 'flip'
        pullDownEl.find('.pullDownLabel').html('Release to Refresh')
        @minScrollY=0
      else if @y < 5 and !pullDownEl.hasClass 'flip'
        pullDownEl.removeClass 'flip'
        pullDownEl.find('.pullDownLabel').html('Pull down to refresh')
        @minScrollY= -pullDownOffset
    onScrollEnd:->
      # console.log 'pull end'
      if pullDownEl.hasClass 'flip'
        pullDownEl.addClass 'loading'
        pullDownEl.find('.pullDownLabel').html 'Loading...'
        pullDownAction(this) 
