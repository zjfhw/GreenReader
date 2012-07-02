> Latest source code is availabel at <https://github.com/geogeo/GreenReader> checkout the ``jqtouch`` Branch plz.

> For **Live Demo** plz visit *using **webkit browser**(Chrome or Safari) *: <http://geogeo.github.com/GreenReader>


## Green Reader
------------------
**Green** is best color for reading*(which I think so, and if you don't like it so much, change the color at will)*, so I pick the color green for the main theme of my App.

And I name it **Green Reader**

## Tech
===============
### 1. [CoffeeScript](http://coffeescript.org)

I like script language like python and ruby, they are simple, easy to read, and powerful.

While javascript is not that kind of script language l like.

So I use CoffeeScript to make writing javascript more **Scripter** like ruby or python

> "It's just JavaScript". The code compiles one-to-one into the equivalent JS


### 2. [Emberjs(former known as SproutCore2.0)](http://emberjs.com)

Apple's MobileMe is build with [SproutCore](http://sproutcore.com/), and emberjs is the core and best part of SproutCore.It's kind of like [Backbonejs](http://backbonejs.com),but I chose ember finally because of The best feature of it is binding, observes, and integration with [handlebars](http://handlebarsjs.com)(for semantic template, it's powerful and popular).And the most magic part of it is: it automatically update the DOM  when the underlying data changes.

### 3. [jQTouch](http://jqtouch.com) and [iScroll](http://cubiq.org/iscroll)

I've been chose jQuery Mobile for UI at first, but it's kind of lame in animation.
So I goes to jqtouch, which using native awesome webkit animation.

### 4. [Google Feed Api](https://developers.google.com/feed/v1/jsondevguide)

I've used YQL for converting feed XML to JSON, but Google Feed Api seems to be a better solution.

> With the Feed API, you can download any public Atom, RSS, or Media RSS feed using only JavaScript

I use this api to find feed and get JSON response of the feed.

### 5. [LawnChair](http://brian.io/lawnchair)

For persistence solution.

> Super micro tiny storage without the nasty SQL: pure and delicious JSON.

### 6. Duh... **jQuery** ;\)


## Something About MVC
-----------------------
Unlike backend MVC framework such as Ruby on Rails which run in server side, handle the user's request from client side

![Rails MVC](http://emberjs.com/images/ember_mvc/railsmvc.png =350x300)

Ember provide MVC framework for frond-end, it run in browser in pour javascript.so it can detect and respond to browser events such as mouse clicks, finger taps, scrolling, key presses, etc. 

![Ember MVC](http://emberjs.com/images/ember_mvc/embermvc.png =350x300)

## Features
----------------
### You can ...
1. Add Feed by keywords or direct URL
1. Pull Down to Refresh List(like app in iOS dose)
1. Swipe left/right to Navigate
2. Swipe to delete
3. Sort News items with 'Read','Unread','Starred','All'
1. Give star to News you like
2. Switch Theme
3. Open News in external browser
4. Manually reset local storage

### It has…
1. iOS style tabbar with count bubble
2. 3 themes - GreenReader default,jqtouch,apple ios
2. Cool Animation in iOS and webkit browser like chrome and safari

``It's available both in iOS and Android(and of course Desktop,its written in pure html5 and js, just open it with Chrome or Safari)``

## How to use
--------------
just open
Video tutorial

YouKu:

- chrome version:<http://v.youku.com/v_show/id_XNDIyNzM2Mjgw.html>
<embed src='http://player.youku.com/player.php/sid/XNDIyNzM2Mjgw/v.swf' quality='high' width='480' height='400' align='middle' allowScriptAccess='sameDomain' type='application/x-shockwave-flash'></embed>

- iOS version(with cool animation): <http://v.youku.com/v_show/id_XNDIyNjcxODUy.html>
<embed src='http://player.youku.com/player.php/sid/XNDIyNjcxODUy/v.swf' quality='high' width='480' height='400' align='middle' allowScriptAccess='sameDomain' type='application/x-shockwave-flash'></embed>

- Android version:<http://v.youku.com/v_show/id_XNDIyNzAyNjgw.html>
<embed src='http://player.youku.com/player.php/sid/XNDIyNzAyNjgw/v.swf' quality='high' width='480' height='400' align='middle' allowScriptAccess='sameDomain' type='application/x-shockwave-flash'></embed>

-------------------------
``For user outside of P.R.China plz visit``

YouTube:

- chrome version: <http://youtu.be/3TQrwKrvNag>
<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/3TQrwKrvNag&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><embed src="http://www.youtube.com/v/3TQrwKrvNag&hl=en&fs=1" type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344"></embed></object>

- iOS version: <http://youtu.be/Wj922fvWYg0>
<iframe width="420" height="315" src="http://www.youtube.com/embed/Wj922fvWYg0" frameborder="0" allowfullscreen></iframe>

- android version:<http://youtu.be/JDhdG8WErkU>
<iframe width="420" height="315" src="http://www.youtube.com/embed/JDhdG8WErkU" frameborder="0" allowfullscreen></iframe>


## Design
-------------
The notes downstair are the original design, but few of them are not implemented yet(google reader login, pull up to load more, social sharing…).

![](http://geogeo.github.com/images/blog/06302012/main-page.jpg =250x250)
![](http://geogeo.github.com/images/blog/06302012/list-page.jpg =250x250)
![](http://geogeo.github.com/images/blog/06302012/detail-page.jpg =250x250)

## Source Structure
-----------------
> javascript source is in js/src which written in coffeescript.
the app.js file is compiled from coffeescript files under js/src , so source comment are only available in coffeescript files in js/src.

- index.html <-- html5 page
- cordova-1.x.x.js <-- phonegap js
- css/
	- style.css <-- custom sytle css
	- png/ <-- glyphicons
	- themes/  <-- themes goes here
	- images/  <-- some image files
- js/ 
	- init.js <-- something that should run before app.js
	- app.js <-- main script, compiled by coffeescript
	- src/ <-- coffeescript source
		- app.coffee <-- something main and extra need to run
		- controller.coffee 
		- view.coffee
		- model.coffee
	- libs/ <-- jquery,jqtouch,lawnchair…everthing should includ in
- bin/ <-- runable binary
	- GreenReader.apk <- for android
	- GreenReader.app <- for Jailbroken iOS device

To compile the source code, you must follow [Phonegap start](http://phonegap.com/start)
then change the origin access to * in cordova.plist or cordova.xml

To compile coffeescript source to app.js, you should install [Nodejs](http://nodejs.org/) and then [coffeescript](http://coffeescript.org/)
