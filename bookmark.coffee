@Bookmarks = new Meteor.Collection("bookmarks")

@Bookmarks.validate = (bookmark) ->
  if not bookmark.url
    return false
  if not bookmark.url.match /https?:\/\//
    return false
  if not bookmark.user
    return false
  return true

if Meteor.is_client
  Template.main.user = () ->
    return Session.get "user"

  Template.main.events =
    'click h1' : () ->
      Router.navigate "", true
    'click span.user' : (e) ->
      Router.navigate "/" + $(e.target).html(), true

  Template.login.events =
    'click button' : () ->
      if user = $("#form-user").val()
        Session.set "user", user

  Template.entry.events =
    'click button' : () ->
      bookmark =
        user: Session.get "user"
        url:     $("#form-url").val()
        title:   $("#form-title").val()
        quote:   $("#form-quote").val()
        comment: $("#form-comment").val()
        posted_at: Date.now()

      if not Bookmarks.validate bookmark
        alert 'failed validation'
        return

      entry = Bookmarks.findOne user: bookmark.user, url: bookmark.url
      if entry
        Bookmarks.update { _id: entry._id }, { $set: title: bookmark.title, comment: bookmark.comment, quote: bookmark.quote }
      else
        Bookmarks.insert bookmark

      for elem in ['url', 'title', 'quote', 'comment']
        $("#form-#{elem}").val("")

  Template.bookmark.host = (url) ->
    return url.split("/")[2]

  Template.bookmarks.bookmarks = () ->
    user_filter = Session.get 'user_filter'
    selector = if user_filter then { user: user_filter } else {}
    return Bookmarks.find selector, { sort: { posted_at: -1 } }

  Template.bookmarks.events =
    'click span.navigate' : () ->
      Router.navigate "", true

  Template.bookmarks.user_filter = () ->
    return Session.get 'user_filter'

  BookmarkRouter = Backbone.Router.extend
    routes:
      "" : "timeline"
      ":user" : "bookmarks"
    timeline : () ->
      Session.set 'user_filter', null
    bookmarks : (user) ->
      Session.set 'user_filter', user

  Router = new BookmarkRouter

  Meteor.startup () ->
    Backbone.history.start pushState: true

if Meteor.is_server
  Meteor.startup () ->