# jquery.carousel
# @author jaime pillora

#example usage
# $(...).carousel({ ... opts ... })
# $(...).carousel("left")
# $(...).carousel("right")

#helpers
name = 'carousel'

colors = ['#F07878','#B5B5FF','#0CAA0C','#E278F0']

log = ->
  return unless window['console']
  args = Array::slice.call arguments
  console.log.apply console, args

inherit = (a, b = {}) ->
  F = ->
  F.prototype = a
  $.extend true, new F, b

class Item
  constructor: (@row, @col, @elem, @car) ->
    #items have been placed
    @elem.remove()
  
  position:  ->
    @elem.css
      background: colors.pop()
      width: @car.w
      height: @car.h
      left: @car.w * @row
      top: @car.h * @col
      position: "absolute"

    @car.grid.append @elem

class Carousel

  #plugin defaults
  defaults:
    autoOffOnManual: true
    duration: 1000
    pause: 2500
    rowLength: Infinity
    wrap: true
    fixed: true
    direction: "right"
    easing: "easeInOutExpo"

  constructor: (@elem, opts) ->
    log "new carousel"

    @r = 0
    @c = 0
    @opts = inherit @defaults
    @update opts
    @init()

  update: (opts) ->
    return unless $.isPlainObject opts
    $.extend @opts, opts
    log "update", @opts

  command: (args) ->
    cmd = args.shift()
    log "command", cmd, args
    fn = @commands[cmd]
    unless typeof fn is 'function'
      log "command '#{cmd}' does not exist"
      return
    fn.apply @, args

  init: ->
    #calc dimensions

    @animating = false
    @curr = 0
    @last = null

    #create the 'floor' for all 'slides'
    @grid = $("<div/>").css
      position: "absolute"
      width: @w
      height: @h

    #construct move children into grid
    @items = rows = []
    @elem.children().each (i, e) =>
      row = Math.floor(i/@opts.rowLength) or 0
      col = i%n
      cols = rows[row] = rows[row] or []
      cols[col] = new Item row, col, $(e), @

    #place grid on carousel and mask
    @elem.
      data("carousel", @).
      append(@grid).
      css
        position: "relative"
        overflow: "hidden"

    # @w = @elem.width()
    # @h = @elem.height()  
    # @elem.width() if @opts.fixedWidth

    # start if auto
    # @autoAnimate()

    log "bound"

  currItem: ->
    #return item based on r and c

  #setLayout: (arr) -> resets items


  bindButtons: ->
    #bind left and right buttons if given
    userOpts.leftBtn?.click ->
      opts {auto: false} if opts().autoOffOnManual
      left()

    userOpts.rightBtn?.click ->
      opts {auto: false} if opts().autoOffOnManual
      right()

  animate: ->
  autoAnimate: ->
    @animating = false

  commands:
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

$.fn.carousel = ->
  args = Array.prototype.slice.apply arguments
  elems = $(@)
  return if elems.length is 0
  elems.each ->
    c = $(@).data "carousel"
    #does not exist, construct
    unless c
      new Carousel $(@), args[0]
      return

    #update or command on existing
    if typeof args[0] is 'string'
      c.command args
    else if $.isPlainObject args[0]
      c.update args[0]
    

log name, "plugin added"