# init Data

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
    console.log @get('currentList') ,@get 'action'
    @get('currentList') is @get 'action'
    # cn = @get 'action'
    # if cn
    #   if  @get('currentList') is 'showDefault'
    #     console.log @get 'countName'
    #     return 'unreadCount' is @get 'countName'
    #   else
    #     str=cn.replace('Count','')
    #     console.log @get('currentList') ,'show'+ str.charAt(0).toUpperCase()+str.substr(1)
    #     return @get('currentList') is 'show'+ str.charAt(0).toUpperCase()+str.substr(1)
    # else
    #   return false
  ).property 'currentList'
  action:null

RSSReader.Subscription = Em.Object.extend
  url:null
  title:null
  icon:null
  
