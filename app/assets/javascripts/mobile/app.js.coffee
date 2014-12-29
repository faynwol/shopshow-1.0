#= require 'spin'
@MobileApp = {}

MobileApp.loading = ->
  spinner = new Spinner().spin()
  loading = spinner.el
  $('body').append loading
  loading