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

subscriptionData=Lawnchair
  name:'subscript'
  record:'entry'
  ,->
# app
RSSReader.reopen
  ready:->
    @_super()
    # get content from rss source
    
    RSSReader.GetItemsFromStore('showDefault')
    RSSReader.navbarController.mainPageTab()
    # RSSReader.pageinit()
    jQT.initbars()
    
  
    # RSSReader.initPullToRefresh()
mainNavJson=[
  {
    url:'#help-view'
    title:'Help'
    icon:'css/png/glyphicons_194_circle_question_mark.png'
  },
  {
    url:'#about-view'
    title:'About'
    icon:'css/png/glyphicons_195_circle_info.png'
  },
  {
    url:'#search-view'
    title:'Search'
    icon:'css/png/glyphicons_027_search.png'
  },
  {
    url:'#settings-view'
    title:'Setting'
    icon:'css/png/glyphicons_019_cogwheel.png'
   }
]
listNavJson=[
  {
    url:'#'
    title:'Unread'
    icon:'css/png/glyphicons_051_eye_open.png'
    countName:'unreadCount'
    action:'showUnread'
  },
  {
    url:'#'
    title:'All'
    icon:'css/png/glyphicons_071_book.png'
    countName:'itemCount'
    action:'showAll'
  },
  {
    url:'#'
    title:'Starred'
    icon:'css/png/glyphicons_049_star.png'
    countName:'starredCount'
    action:'showStarred'
  },
  {
    url:'#'
    title:'Read'
    icon:'css/png/glyphicons_087_log_book.png'
    countName:'readCount'
    action:'showRead'
   }
]
currentNavJson=[
  {
    url:'#list-view'
    title:'Back'
    icon:'css/png/glyphicons_051_eye_open.png'
  },
  {
    url:'#'
    title:'Star'
    icon:'css/png/glyphicons_071_book.png'
  },
  {
    url:'#'
    title:'Share'
    icon:'css/png/glyphicons_049_star.png'
  },
  {
    url:'#'
    title:'Read in Browser'
    icon:'css/png/glyphicons_087_log_book.png'
   }
]


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

RSSReader.getSubscription = ->
  items = subscriptionData.all (arr)->
    arr.forEach (entry)->
      item = RSSReader.Subscription.create entry
      RSSReader.SubscriptionController.addItem item
    console.log 'entries load form local:', arr.length
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
  v = RSSReader.get 'listView'

  if !v
    console.log 'list not created'
    v = App.ListView.create()
    RSSReader.set 'listView',v
    v.appendTo $('#jqt')
  c = RSSReader.get 'currentView'

  if !c
    console.log 'current not created'
    c = RSSReader.CurrentView.create()
    RSSReader.set('currentView',c)
    c.appendTo $('#jqt')

  $('#list-view').live 'pageAnimationEnd', (event,info)->
    if info.direction is 'in'
      RSSReader.navbarController.listPageTab()
      Em.run.next ->
        jQT.initTabbar()
      # jQT.initTabbar()
  $('#main-view').live 'pageAnimationEnd', (event,info)->
    if info.direction is 'in'
      RSSReader.navbarController.mainPageTab()
      Em.run.next ->
        jQT.initTabbar()
      # jQT.initTabbar()
  $('#current-view').live 'pageAnimationEnd', (event,info)->
    if info.direction is 'in'
      RSSReader.navbarController.currentPageTab()
      Em.run.next ->
        jQT.initTabbar()
)

pullDownAction = (scroll)->
  RSSReader.itemController.refreshList(->
    scroll.refresh()
    # console.log 'asdf'
  )

# pull down to refresh initialize
RSSReader.pullinit = ->
  pullDownEl = $('#pullDown')
  pullDownOffset = 51
  $('.pullable').iscroll
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
