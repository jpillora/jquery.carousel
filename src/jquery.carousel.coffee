# jquery.carousel
# @author jaime pillora

#example usage
# $(...).carousel({ ... opts ... })
# $(...).carousel("left")
# $(...).carousel("right")

#helpers
name = 'carousel'


colors = ['#F07878','#B5B5FF','#0CAA0C','#E278F0']

inherit = (a, b = {}) ->
  F = ->
  F.prototype = a
  $.extend true, new F, b

class Row
  constructor: (@elem, @index, @carousel) ->
    unless @elem.is('[data-carousel-row]')
      console.warn('Is this a carousel row ? ', @elem[0])
    console.log "new row"
    @cols = []
    @elem.children().each (i, e) =>
      col = new Col $(e), i, @, @carousel
      @cols.push col
    #items have been placed
    @elem.remove()

class Col
  constructor: (@elem, @index, @row, @carousel) ->
    console.log "new item #{@row.index}, #{@index}"

    @elem.css
      background: colors.pop()
      width: @carousel.w
      height: @carousel.h
      left: @carousel.w * @index
      top: @carousel.h * @row.index
      position: "absolute"
    
    @carousel.grid.append @elem

class Carousel

  #plugin defaults
  defaults:
    auto: true
    autoOffOnManual: true
    duration: 1000
    pause: 2500
    direction: "right"
    easing: "easeInOutExpo"

  constructor: (@elem, opts) ->
    console.log "new carousel"

    @opts = inherit @defaults
    @update opts
    @init()

  update: (opts) ->
    if $.isPlainObject opts
      $.extend @opts, opts
    console.log "update", @opts

  command: (args) ->
    cmd = args.shift()
    console.log "command", cmd, args
    @[cmd]?.apply @, args

  init: ->
    #calc dimensions
    @w = @elem.width()
    @h = @elem.height()

    @animating = false
    @curr = 0
    @last = null

    #create the 'floor' for all 'slides'
    @grid = $("<div/>").css
      width: @w
      height: @h
      position: "absolute"

    #construct move children into grid
    @rows = []
    @elem.children().each (i, e) =>
      row = new Row $(e), i, @
      @rows.push row

    #place grid on carousel and mask
    @elem.
      data("carousel", @).
      append(@grid).
      css
        position: "relative"
        overflow: "hidden"

    # start if auto
    # @autoAnimate()

    console.log "bound"

  bindButtons: ->
    #bind left and right buttons if given
    userOpts.leftBtn?.click ->
      opts {auto: false} if opts().autoOffOnManual
      left()

    userOpts.rightBtn?.click ->
      opts {auto: false} if opts().autoOffOnManual
      right()

  to: (row, col, callback) ->
    #animate from current to next
    animating = true
    @grid.stop().animate({
      top: -@h*row
      left: -@w*col
    },{
      duration: @opts.duration
      easing: @opts.easing
      complete: =>
        @autoAnimate
        if callback
          callback()
    })
    
  left: ->
  right: ->
  animate: ->
  autoAnimate: ->
    @animating = false

#auto activate with ujs
$ -> $("[data-carousel]").carousel()

$.fn.carousel = ->
  args = Array.prototype.slice.apply arguments
  elems = $(@)
  return if elems.length is 0
  elems.each ->
    c = $(@).data "carousel"
    #update or command on existing
    if c
      if typeof args[0] is 'string'
        c.command args
      else if $.isPlainObject args[0]
        c.update args[0]
      return
    #does not exist, construct
    c = new Carousel $(@), args[0]

console.log name, "plugin added"