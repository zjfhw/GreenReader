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

  currentListBinding:'RSSReader.itemController.currentList'
  itemCountBinding:'RSSReader.dataController.itemCount'
  unreadCountBinding:'RSSReader.dataController.unreadCount'
  starredCountBinding:'RSSReader.dataController.starredCount'
  readCountBinding:'RSSReader.dataController.readCount'
  url:null
  title:null
  icon:null
  countName:null
  count:(->
    # console.log @get('countName'), RSSReader.itemController.get @get 'countName'
    @get @get 'countName'
  ).property 'countName'
  enabled:(->
    cn = @get 'countName'
    if cn
      if  @get('currentList') is 'showDefault'
        return 'unreadCount' is @get 'countName'
      else
        str=cn.replace('Count','')
        return @get('currentList') is 'show'+ str.charAt(0).toUpperCase()+str.substr(1)
    else
      return false
  ).property 'currentList'
  action:null

RSSReader.Subscription = Em.Object.extend
  url:null
  title:null
  icon:null
  