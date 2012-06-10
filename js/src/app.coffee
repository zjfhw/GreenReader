#####################
# create app object #
#####################

RSSReader.reopen
  ready:->
    @_super()
    # get content from rss source
    RSSReader.GetItemsFromSource()

###############
# create View #
###############

# - Summary List
RSSReader.SummaryListView = RSSReader.ListView.extend
  # tagName: 'article' # view tag
  # classNames: ['well','summary'] # view class 
  # css class binding to read and starred
  classNameBindings: ['read','starred']
  read:(->
    read = @get('content').get 'read'
  ).property('RSSReader.itemController.@each.read')

  starred:(->
    starred = @get('content').get 'starred'
  ).property 'RSSReader.itemController.@each.starred'

# - Header
RSSReader.HeaderView.reopen
  refresh:->
    RSSReader.GetItemsFromSource()

# - NavBar
RSSReader.NavbarView.reopen
  # property binding
  itemCountBinding:'RSSReader.dataController.itemCount'
  unreadCountBinding:'RSSReader.dataController.unreadCount'
  starredCountBinding:'RSSReader.dataController.starredCount'
  readCountBinding:'RSSReader.dataController.readCount'

  # Actions
  showAll:->
    RSSReader.itemController.clearFilter()

  showUnread:->
    RSSReader.itemController.filterBy 'read',false

  showRead:->
    RSSReader.itemController.filterBy 'read',true
    
  showStarred:->
    RSSReader.itemController.filterBy 'starred',true

# - entry detail view

RSSReader.EntryItemView = RSSReader.PageView.extend
  active:(->
    true
    ).property('RSSReader.itemNavController.currentItem')
  contentBinding: 'RSSReader.itemNavController.currentItem'
  toggleRead: 

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
      true
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

  # user can filt items by 'read unread starred'...
  filterBy: (key,value)->
    @set 'content', RSSReader.dataController.filterProperty key,value

  # reset
  clearFilter:->
    @set 'content', RSSReader.dataController.get 'content'
  
  # default is show items unread
  showDefault:->
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
RSSReader.ItemNavController = Em.Object.create
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

  toggleStar:(star) ->
    if star is undefined
      star = !@currentItem.get 'starred'
    @currentItem.set 'starred',star
    key = @currentItem.get 'item_id'

  next:->
    currentIndex = RSSReader.itemController.content.indexOf @get 'currentItem'
    nextItem = RSSReader.itemController.content[currentIndex+1]
    if nextItem
      @select nextItem
  prev:->
    currentIndex = RSSReader.itemController.content.indexOf @get 'currentItem'
    prevItem = RSSReader.itemController.content[currentIndex+1]
    if prevItem
      @select prevItem
  

#############################
# Get Items from rss source #
#############################

RSSReader.GetItemsFromSource = ->
  # feed source
  feed = 'http://cn.engadget.com/tag/breaking+news/rss.xml'
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
      if entry.description
          item.short_desc = entry.description.substr(0, 128) + "..."
      item.pub_date = new Date entry.pubDate
      item.read = false
      item.key = item.item_id

      RSSReader.dataController.addItem RSSReader.Item.create item

    RSSReader.itemController.showDefault()
    



