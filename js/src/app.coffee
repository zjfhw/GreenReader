###

Copyright (c) 2012 Jichao Ouyang http://geogeo.github.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#####################
# create app object #
#####################


###
new jQT instance and initialize
  - init theme selector
  - preload images
###

jQT = $.jQTouch
  # theme switcher
  themeSelectionSelector: '#jqt #themes ul'
  # only contain 3 themes for now
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
  # fast touch for better experience , for ios and browser
  # useFastTouch:true
  # preload images in tabbar
  preloadImages:[
    'css/png/glyphicons_020_home.png'
    'css/png/glyphicons_195_circle_info.png'
    'css/png/glyphicons_019_cogwheel.png'
    'css/png/glyphicons_051_eye_open.png'
    'css/png/glyphicons_071_book.png'
    'css/png/glyphicons_049_star.png'
    'css/png/glyphicons_222_share.png'
  ]


###
lawnchair instance for local storage
  - store: for news items
  - subscritionData: for subscription items  
###

# news items
store = Lawnchair
  name:'entries'
  record:'entry'
  ,->
# subscription
subscriptionData=Lawnchair
  name:'subscript'
  record:'entry'
  ,->

###
initialize Emberjs Application

###
RSSReader = Em.Application.create
  ready:->
    @_super()
    RSSReader.getSubscription()
    RSSReader.navbarController.set 'currentPage',mainNavJson

###
Initialize fixture for Tabbar
###
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

###
Find/Get RSS source
``using Google Feed Api``
###
RSSReader.FindFeed = (query)->
  # lodding indicator
  showLoader()
  # guess if it's query or url
  if query and query.substring(0,6).toLowerCase() is 'q=http'
    # load source directly
    # RSSReader.GetItemsFromStore(query.substr(2))
    $.getJSON 'https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&'+query+'&callback=?',(data)->
      hideLoader()
      try
        item = {}
        item.url=data.responseData.feed.feedUrl
        item.title=data.responseData.feed.title
        if RSSReader.subscriptionController.addItem item
          item.key = item.url
          subscriptionData.save item
          
        jQT.goTo '#main-view','flipright'
      catch e
        alert 'wrong url'
     
      
  else
    # Google Feed Find API
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
  # Google Feed Load Api
  $.getJSON 'https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q='+feed+'&callback=?',(data)->
    console.log data.responseData
    if not data.responseData or not data.responseData.feed
      alert 'check your url'
      hideLoader()
    items =  data.responseData.feed.entries

    feedLink = data.responseData.feed.feedUrl
  
    # populate each entry to dataController
    items.map (entry) ->
      item={}
      item.item_id = entry.link
      item.pub_name = data.responseData.feed.title
      item.pub_author = entry.author
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


RSSReader.clearStore = ()->
 
  subscriptionData.all (arr)->
    arr.forEach (entry)->
      console.log entry.key
      Lawnchair
        name:entry.key
        record:'entry'
        ,->
          this.nuke()
  RSSReader.dataController.content.clear()


# Get subscription from local data    
RSSReader.getSubscription = ->
  
  subscriptionData.all (arr)->
    arr.forEach (entry)->
      item = RSSReader.Subscription.create entry
      RSSReader.subscriptionController.addItem item
    console.log 'subscription load form local:', arr.length,arr

###
When Document or Device Ready
###
deviceReady = ->
  if window.device
    console.log 'phonegap ready'
  else
    # Swipe to navigate
    $('.swipe').swipe (evt, info)->
      console.log 'swipe', info.direction
      if info.direction is 'right'
        RSSReader.itemNavController.prev()
      else if info.direction is 'left'
        RSSReader.itemNavController.next()
      
      $scroll = $(this).iscroll()
      $scroll.refresh()
      $scroll.scrollTo(0,0)

    # Swipe to Delete Subscription
    $('.swipeToDelete').swipe (evt, data)->
      details =  if !data then '' else data
      console.log 'swipe', details.direction
      $this = $(this)
      if details.direction is 'right'
        console.log $this.next()
        $this.addClass 'delete'
        $this.next().removeClass 'hide'
      else if details.direction is 'left'
        $this.removeClass 'delete'
        $this.next().addClass 'hide'
  # Query Feed submit event
  $('#search-news').live 'submit', ->
      console.log 'search news', $(this).serialize()
      RSSReader.FindFeed $(this).serialize()
 

  # Create List and Current View and append them to DOM
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

  # Tabbar init for each page
  $('#list-view').live 'pageAnimationEnd', (event,info)->
    if info.direction is 'in'
      RSSReader.navbarController.set 'currentPage',listNavJson
  $('#main-view').live 'pageAnimationEnd', (event,info)->
    if info.direction is 'in'
      RSSReader.navbarController.set 'currentPage',mainNavJson
  $('#current-view').live 'pageAnimationEnd', (event,info)->
    if info.direction is 'in'
      RSSReader.navbarController.set 'currentPage',currentNavJson

# Guess which device you're using
if (navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry)/))
  console.log 'prepair device'
  document.addEventListener("deviceready", deviceReady, false)
else
  $(deviceReady)


# action when pull down trigger
pullDownAction = (scroll)->
  RSSReader.itemController.refreshList(->
    scroll.refresh()
  )

# pull down to refresh initialize
RSSReader.pullinit = ->
  pullDownEl = $('#pullDown')
  pullDownOffset = 51
  $('.pullable').iscroll
    topOffset:pullDownOffset
    onRefresh:->
      # console.log 'refresh'
      if pullDownEl.hasClass 'loading'
        console.log 'remove'
        pullDownEl.removeClass()
        pullDownEl.find('pullDownLabel').html('PullDown to Refresh')
    onScrollMove:->
      # console.log 'move'
      if @y > 5 and !pullDownEl.hasClass 'flip'
        pullDownEl.addClass 'flip'
        pullDownEl.find('.pullDownLabel').html('Release to Refresh')
        @minScrollY=0
      else if @y < 5 and pullDownEl.hasClass 'flip'
        pullDownEl.removeClass 'flip'
        pullDownEl.find('.pullDownLabel').html('Pull down to refresh')
        @minScrollY= -pullDownOffset
    onScrollEnd:->
      # console.log 'pull end'
      if pullDownEl.hasClass 'flip'
        pullDownEl.addClass 'loading'
        pullDownEl.find('.pullDownLabel').html 'Loading...'
        pullDownAction(this) 

  
