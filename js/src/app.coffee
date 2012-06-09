#####################
# create app object #
#####################
RSSReader = Em.Application.create
  ready:->
    @_super()

###############
# create View #
###############

# - Summary List
RSSReader.SummaryListView = Em.View.extend
  tagName: 'article' # view tag
  classNames: ['well','summary'] # view class 
  # css class binding to read and starred
  classNameBindings: ['read','starred']
  read:(->
    read = @get('content').get 'read'
  ).property('RSSReader.itemController.@each.read')

  starred:(->
    starred = @get('content').get 'starred'
  ).property 'RSSReader.itemController.@each.starred'

# - NavBar
RSSReader.NavBarView = Em.View.extend
  # property binding
  itemCountBinding:'RSSReader.dataController.itemCount'
  unreadCountBinding:'RSSReader.dataController.unreadCount'
  starredCountBinding:'RSSReader.dataController.starredCount'
  readCountBinding:'RSSReader.dataController.readCount'

  # actions
  showAll:->
    RSSReader.itemController.clearFilter()

  showUnread:->
    RSSReader.itemController.filterBy 'read',false

  showRead:->
    RSSReader.itemController.filterBy 'read',true
    
  showStarred:->
    RSSReader.itemController.filterBy 'starred',true



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
    @filterPorperty 'read',true .get 'length'
  ).property '@each.read'

  # property return unread count

  unreadCount:(->
    @filterPorperty 'read',false .get 'length'
  ).property 'each.read'

  # property return starred count
  starredCount:(->
    @filterPorperty 'starred',true .get 'length'
  ).property '@each.starred'

  # mark all items as read
  # markAllRead:->
  #   @forEach (item)->
  #     item.set 'read',true
  #     store.toggleRead (item.get 'item_id'),true

  
################
# items filter #
################

RSSReader.itemController = Em.ArrayController.create
  content: []

  # user can filter item by 'read unread starred'...
  filterBy: ->
    @set 'content', RSSReader.dataController.filterPorperty key,value

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
    @filterPorperty 'read',true .get 'length'
  ).property '@each.read'

  # ...more properties

  unreadCount:(->
    @filterPorperty 'read',false .get 'length'
  ).property 'each.read'

  starredCount:(->
    @filterPorperty 'starred',true .get 'length'
  ).property '@each.starred'













