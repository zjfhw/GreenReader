
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
  pub_date: null
  feed_link: null # rss source link
  item_link:null # news item source link

# Footer Nav Button
RSSReader.NavButton = Em.Object.extend

  currentListBinding:'RSSReader.itemController.currentList'
  itemCountBinding:'RSSReader.dataController.itemCount'
  unreadCountBinding:'RSSReader.dataController.unreadCount'
  starredCountBinding:'RSSReader.dataController.starredCount'
  readCountBinding:'RSSReader.dataController.readCount'
  url:null
  title:null
  icon:null
  currentItemBinding:'RSSReader.itemNavController.currentItem'
  countName:null
  count:(->
    # console.log @get('countName'), RSSReader.itemController.get @get 'countName'
    @get @get 'countName'
  ).property 'countName'
  enabled:(->
    console.log @get('currentList') ,@get 'action'
    if @get('currentItem')
      return (@get('currentItem').starred is true and @get('action') is 'toggleStar') or @get('currentList') is @get('action')
    @get('currentList') is @get('action')
  ).property 'currentList'
  action:null
RSSReader.QueryResult = Em.Object.extend
  contentSnippet:null
  link:null
  title:null
  url:null
RSSReader.Subscription = Em.Object.extend
  url:null
  title:null
  icon:null
  
