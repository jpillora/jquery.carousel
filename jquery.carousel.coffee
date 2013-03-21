# jquery.carousel
# @author jaime pillora

#example usage
# $(...).carousel({ ... opts ... })
# $(...).carousel("left")
# $(...).carousel("right")

#plugin defaults
defaults =
  auto: true
  autoOffOnManual: true
  duration: 1500
  pause: 2500
  direction: "right"
  easing: "swing"

command = (elem, command) ->
  publics = elem.data("carousel")
  # commands
  if command is "left"
    publics.left() 
  else if command is "right"
    publics.right()
  else 
    publics.opts(command)

#plugin def
carousel = (elem, userOpts = {}) ->

  #already setup
  if elem.data("carousel-initialised") is true
    command elem, userOpts
    return

  es = $.map elem.children().toArray(), (e) -> $(e)
  window.es = es
  e = null
  w = elem.width()
  h = elem.height()
  l = es.length
  animating = false
  curr = 0
  last = null
  publics = {}
  inner = $("<div/>").css 
    position: "absolute"

  elem.
    data("carousel-initialised", true).
    data("carousel-opts", defaults).
    data("carousel", publics).
    append(inner).
    css
      position: "relative"
      overflow: "hidden"

  for i in [0..l] by 1
    $(es[i]).css
      width: w
      height: h
      left: w * i
      position: "absolute"

    inner.append es[i]

  #get this elems options
  opts = (userOptions) ->
    options = elem.data "carousel-opts"
    if userOptions and $.isPlainObject userOptions
      options = elem.data "carousel-opts", $.extend options, userOptions
    options

  #set user opts
  opts userOpts

  #bind left and right buttons if given
  userOpts.leftBtn?.click ->
    opts {auto: false} if opts().autoOffOnManual
    left()

  userOpts.rightBtn?.click ->
    opts {auto: false} if opts().autoOffOnManual
    right()

  innerAnimate = (dir) ->

    return if animating
    #reset wrapper
    inner.css(left: 0)
    #position current and next slides
    next = curr - dir
    next = 0 if next is l
    next = l-1 if next is -1

    es[curr].show().css { left: 0 }
    es[next].show().css { left: w*-dir }

    last = curr
    curr = next

    #animate from current to next
    animating = true
    inner.stop().animate { left:w*dir }, opts().duration, opts().easing, autoAnimate
    
  left = -> innerAnimate 1
  right = -> innerAnimate -1

  animate = ->
    setTimeout ->
      left() if opts().direction is "left"
      right() if opts().direction is "right"
    , opts().pause

  autoAnimate = ->
    es[last].hide() if last isnt null
    animating = false
    animate() if opts().auto

  #store in element
  publics.left = left
  publics.right = right
  publics.opts = opts

  # start if auto
  $ autoAnimate

  console.log "bound"
  return elem

#auto activate with ujs
$ -> $("[data-carousel]").carousel()

$.fn.carousel = (opts) ->
  elems = $(@)
  return if elems.length is 0
  elems.each -> 
    carousel $(@), opts

console.log "jquery.carousel plugin added"