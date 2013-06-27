(function() {
  var Carousel, Item, colors, inherit, log, name;

  name = 'carousel';

  colors = ['#F07878', '#B5B5FF', '#0CAA0C', '#E278F0'];

  log = function() {
    var args;
    if (!window['console']) {
      return;
    }
    args = Array.prototype.slice.call(arguments);
    return console.log.apply(console, args);
  };

  inherit = function(a, b) {
    var F;
    if (b == null) {
      b = {};
    }
    F = function() {};
    F.prototype = a;
    return $.extend(true, new F, b);
  };

  Item = (function() {
    function Item(row, col, elem, car) {
      this.row = row;
      this.col = col;
      this.elem = elem;
      this.car = car;
      this.elem.remove();
    }

    Item.prototype.position = function() {
      this.elem.css({
        background: colors.pop(),
        width: this.car.w,
        height: this.car.h,
        left: this.car.w * this.row,
        top: this.car.h * this.col,
        position: "absolute"
      });
      return this.car.grid.append(this.elem);
    };

    return Item;

  })();

  Carousel = (function() {
    Carousel.prototype.defaults = {
      autoOffOnManual: true,
      duration: 1000,
      pause: 2500,
      rowLength: Infinity,
      wrap: true,
      fixed: true,
      direction: "right",
      easing: "easeInOutExpo"
    };

    function Carousel(elem, opts) {
      this.elem = elem;
      log("new carousel");
      this.r = 0;
      this.c = 0;
      this.opts = inherit(this.defaults);
      this.update(opts);
      this.init();
    }

    Carousel.prototype.update = function(opts) {
      if (!$.isPlainObject(opts)) {
        return;
      }
      $.extend(this.opts, opts);
      return log("update", this.opts);
    };

    Carousel.prototype.command = function(args) {
      var cmd, fn;
      cmd = args.shift();
      log("command", cmd, args);
      fn = this.commands[cmd];
      if (typeof fn !== 'function') {
        log("command '" + cmd + "' does not exist");
        return;
      }
      return fn.apply(this, args);
    };

    Carousel.prototype.init = function() {
      var rows,
        _this = this;
      this.animating = false;
      this.curr = 0;
      this.last = null;
      this.grid = $("<div/>").css({
        position: "absolute",
        width: this.w,
        height: this.h
      });
      this.items = rows = [];
      this.elem.children().each(function(i, e) {
        var col, cols, row;
        row = Math.floor(i / _this.opts.rowLength) || 0;
        col = i % n;
        cols = rows[row] = rows[row] || [];
        return cols[col] = new Item(row, col, $(e), _this);
      });
      this.elem.data("carousel", this).append(this.grid).css({
        position: "relative",
        overflow: "hidden"
      });
      return log("bound");
    };

    Carousel.prototype.currItem = function() {};

    Carousel.prototype.bindButtons = function() {
      var _ref, _ref1;
      if ((_ref = userOpts.leftBtn) != null) {
        _ref.click(function() {
          if (opts().autoOffOnManual) {
            opts({
              auto: false
            });
          }
          return left();
        });
      }
      return (_ref1 = userOpts.rightBtn) != null ? _ref1.click(function() {
        if (opts().autoOffOnManual) {
          opts({
            auto: false
          });
        }
        return right();
      }) : void 0;
    };

    Carousel.prototype.animate = function() {};

    Carousel.prototype.autoAnimate = function() {
      return this.animating = false;
    };

    Carousel.prototype.commands = {
      to: function(row, col, callback) {
        var animating,
          _this = this;
        animating = true;
        return this.grid.stop().animate({
          top: -this.h * row,
          left: -this.w * col
        }, {
          duration: this.opts.duration,
          easing: this.opts.easing,
          complete: function() {
            _this.autoAnimate;
            if (callback) {
              return callback();
            }
          }
        });
      },
      left: function() {},
      right: function() {}
    };

    return Carousel;

  })();

  $.fn.carousel = function() {
    var args, elems;
    args = Array.prototype.slice.apply(arguments);
    elems = $(this);
    if (elems.length === 0) {
      return;
    }
    return elems.each(function() {
      var c;
      c = $(this).data("carousel");
      if (!c) {
        new Carousel($(this), args[0]);
        return;
      }
      if (typeof args[0] === 'string') {
        return c.command(args);
      } else if ($.isPlainObject(args[0])) {
        return c.update(args[0]);
      }
    });
  };

  log(name, "plugin added");

}).call(this);
