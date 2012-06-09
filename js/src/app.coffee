# create app object
RSSReader = Em.Application.create
  ready:->
    @_super()

# create View 
RSSReader.SummaryListView = Em.View.extend
  tagName: 'article' # view tag
  classNames: ['well','summary'] # view class
  
  

# create Model
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

  # # property return count of items
  # itemCount:(->@get 'length').property '@each'

  # # property return readed count
  # readCount:(->
  #   @filterPorperty 'read',true .get 'length'
  # ).property '@each.read'

  # # ...more properties

  # unreadCount:(->
  #   @filterPorperty 'read',false .get 'length'
  # ).property 'each.read'

  # starredCount:(->
  #   @filterPorperty 'starred',true .get 'length'
  # ).property '@each.starred'

  # markAllRead:->
  #   @forEach (item)->
  #     item.set 'read',true
  #     store.toggleRead (item.get 'item_id'),true

  
 # Control how item to be shown
