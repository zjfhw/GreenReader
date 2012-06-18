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
    @set 'currentList','showRead'

  showAll:->
    console.log 'show all'
    @clearFilter()
    @set 'currentList','showAll'
  showRead:->
    @filterBy 'read',true
    @set 'currentList','showRead'
  showStarred:->
    @filterBy 'starred',true
    @set 'currentList','showStarred'
  showUnread:->
    @filterBy 'read',false
    @set 'currentList','showUnread'
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
  listPageTab:->
    @clear()
    @pushObject RSSReader.NavButton.create btn for btn in listNavJson
  mainPageTab:->
    @clear()
    @pushObject RSSReader.NavButton.create btn for btn in mainNavJson
  currentPageTab:->
    @clear()
    @pushObject RSSReader.NavButton.create btn for btn in currentNavJson
  # subsPage:->
    
RSSReader.subscriptionController = Em.ArrayController.create
  content: []
  
  # add item to controller if it's not exists already
  addItem:(item) ->
    exists = @filterProperty('url',item.url).length
    if exists is 0
      length = @get ('length')
      @pushObject item
      return true
    else
      false
