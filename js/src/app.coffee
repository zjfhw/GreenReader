#####################
# create app object #
#####################

# local storage
# new lawnchair ->
jQT = $.jQTouch
  touchSelector:[
    '.swipe'
    '.swipeToDelete'
    'a'
  ]
  themeSelectionSelector: '#jqt #themes ul'
  themeIncluded: [
    {title: 'Default', href:'css/themes/artspot/theme.css'}
    {
      title: 'jQTouch'
      href: 'css/themes/jqt/theme.css'
    }
    {
      title: 'Apple'
      href: 'css/themes/apple/theme.css'
    }
  ]
  # useFastTouch:true
  preloadImages:[
    'css/png/glyphicons_020_home.png'
    'css/png/glyphicons_195_circle_info.png'
    'css/png/glyphicons_019_cogwheel.png'
    'css/png/glyphicons_051_eye_open.png'
    'css/png/glyphicons_071_book.png'
    'css/png/glyphicons_049_star.png'
    'css/png/glyphicons_222_share.png'
  ]
store = Lawnchair
  name:'entries'
  record:'entry'
  ,->

subscriptionData=Lawnchair
  name:'subscript'
  record:'entry'
  ,->
# app
RSSReader = Em.Application.create
  ready:->
    @_super()
    # get content from rss source
    # RSSReader.GetItemsFromStore('showDefault')
    RSSReader.getSubscription()
    RSSReader.navbarController.set 'currentPage',mainNavJson
    # RSSReader.pageinit()
    jQT.initbars()


# init Data
mainNavJson=[
  {
    url:'#main-view'
    title:'Home'
    icon:'css/png/glyphicons_020_home.png'
  },
  {
    url:'#about-view'
    title:'About'
    icon:'css/png/glyphicons_195_circle_info.png'
  },
  # {
  #   url:'#search-view'
  #   title:'Search'
  #   icon:'css/png/glyphicons_027_search.png'
  # },
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
    url:'#'
    title:'Mark as Unread'
    icon:'css/png/glyphicons_052_eye_close.png'
    action:'toggleUnread'
  },
  {
    url:'#'
    title:'Star'
    icon:'css/png/glyphicons_049_star.png'
    action:'toggleStar'
  },
  # {
  #   url:'#'
  #   title:'Share'
  #   icon:'css/png/glyphicons_326_share.png'
  #   action:"share"
  # },
  {
    url:'#'
    title:'Read in Browser'
    icon:'css/png/glyphicons_222_share.png'
    action:"inBrowser"
   }
]  
    # RSSReader.initPullToRefresh()



#############################
# Get Items from rss source #
#############################
RSSReader.FindFeed = (query)->
  showLoader()
  if query.substring(0,6) is 'q=http'
    RSSReader.GetItemsFromStore(query.substr(2))
    hideLoader()
    jQT.goTo 'main-view','flip'
  else
    $.getJSON 'https://ajax.googleapis.com/ajax/services/feed/find?v=1.0&'+query+'&callback=?',(data)->
      console.log 'query' , data,data.responseData.entries
      RSSReader.queryResultController.addItem data.responseData.entries
      hideLoader()

RSSReader.GetItemsFromStore = (feed,currentList, callback)->
  showLoader()
  store = Lawnchair
    name:feed
    record:'entry'
    ,->
  items = store.all (arr)->
    arr.forEach (entry)->
      item = RSSReader.Item.create entry
      RSSReader.dataController.addItem item
    console.log 'entries load form local:', arr.length
  # feed source
  if not feed
    alert 'no url'
    hideLoader()
  # feed = encodeURIComponent feed
  # Feed parser that supports CORS and returns data as a JSON string
  # select * from xml where url='http://cn.engadget.com/tag/breaking+news/rss.xml'
  # feedPipeURL = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%3D'"
  # feedPipeURL += feed + "'&format=json"
  
  console.log 'getting sourc as json','https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q='+feed+'&callback=?'

  $.getJSON 'https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q='+feed+'&callback=?',(data)->
    console.log data.responseData
    if not data.responseData or not data.responseData.feed
      alert 'check your url'
      hideLoader()
    items =  data.responseData.feed.entries

    feedLink = data.responseData.feed.feedUrl

    # map each entry to dataController
    items.map (entry) ->
      item={}
      item.item_id = entry.link
      item.pub_name = data.responseData.feed.title
      item.pub_author = entry.creator
      item.title = entry.title
      item.feed_link = feedLink
      item.content = entry.content
      # if entry.origLink
      #   item.item_link = entry.origLink
      # else
      item.item_link = entry.link
      # Ensure the summary is less than 128 characters
      # console.log entry.description
      # if entry.description
      item.short_desc = entry.contentSnippet
      # $('<p>'+entry.description+'</p>').text().substr(0, 128) + "..."
      # console.log new Date(entry.publishedDate)
      item.pub_date = new Date(entry.publishedDate)
      item.read = false
      item.key = item.item_id

      if RSSReader.dataController.addItem RSSReader.Item.create item
        store.save item
    if !currentList
      currentList="showDefault"
    # showList
    RSSReader.itemController[currentList]()
    # execute callback function
    hideLoader()
    if callback
      callback()     
    
RSSReader.clearStore = (key,callback)->
  Lawnchair {name:key},->
    this.nuke()
  if callback
    callback()
    
RSSReader.getSubscription = ->
  items = subscriptionData.all (arr)->
    arr.forEach (entry)->
      item = RSSReader.Subscription.create entry
      RSSReader.subscriptionController.addItem item
    console.log 'subscription load form local:', arr.length
## on Document Ready
# RSSReader.pageinit = ->
$(->
  
  $('#search-news').live 'submit', ->
    console.log 'search news', $(this).serialize()
    RSSReader.FindFeed $(this).serialize()
    # RSSReader.FindFeed
  $('.swipe').swipe (evt, info)->
    console.log 'swipe', info.direction
    if info.direction is 'right'
      RSSReader.itemNavController.prev()
    else if info.direction is 'left'
      RSSReader.itemNavController.next()
    
    $scroll = $(this).iscroll()
    $scroll.refresh()
    $scroll.scrollTo(0,0)
    

  $('.swipeToDelete').swipe (evt, info)->
    console.log 'swipe', info.direction
    $this = $(this)
    if info.direction is 'right'
      console.log $this.next()
      $this.addClass 'delete'
      $this.next().removeClass 'hide'
    else if info.direction is 'left'
      $this.removeClass 'delete'
      $this.next().addClass 'hide'
  # jQT.initbars()
  # console.log 'pageinit'
  v = RSSReader.get 'listView'

  if !v
    console.log 'list not created'
    v = RSSReader.ListView.create()
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
      RSSReader.navbarController.set 'currentPage',listNavJson
      # Em.run.next ->
      #   jQT.initTabbar()
      # jQT.initTabbar()
  $('#main-view').live 'pageAnimationEnd', (event,info)->
    if info.direction is 'in'
      RSSReader.navbarController.set 'currentPage',mainNavJson
      # Em.run.next ->
        # jQT.initTabbar()
      # jQT.initTabbar()
  $('#current-view').live 'pageAnimationEnd', (event,info)->
    if info.direction is 'in'
      RSSReader.navbarController.set 'currentPage',currentNavJson
      # Em.run.next ->
        # jQT.initTabbar()
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

