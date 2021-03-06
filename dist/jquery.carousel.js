(function() {
  var Carousel, Col, Row, colors, inherit, name;

  name = 'carousel';

  colors = ['#F07878', '#B5B5FF', '#0CAA0C', '#E278F0'];

  inherit = function(a, b) {
    var F;
    if (b == null) {
      b = {};
    }
    F = function() {};
    F.prototype = a;
    return $.extend(true, new F, b);
  };

  Row = (function() {
    function Row(elem, index, carousel) {
      var _this = this;
      this.elem = elem;
      this.index = index;
      this.carousel = carousel;
      if (!this.elem.is('[data-carousel-row]')) {
        console.warn('Is this a carousel row ? ', this.elem[0]);
      }
      console.log("new row");
      this.cols = [];
      this.elem.children().each(function(i, e) {
        var col;
        col = new Col($(e), i, _this, _this.carousel);
        return _this.cols.push(col);
      });
      this.elem.remove();
    }

    return Row;

  })();

  Col = (function() {
    function Col(elem, index, row, carousel) {
      this.elem = elem;
      this.index = index;
      this.row = row;
      this.carousel = carousel;
      console.log("new item " + this.row.index + ", " + this.index);
      this.elem.css({
        background: colors.pop(),
        width: this.carousel.w,
        height: this.carousel.h,
        left: this.carousel.w * this.index,
        top: this.carousel.h * this.row.index,
        position: "absolute"
      });
      this.carousel.grid.append(this.elem);
    }

    return Col;

  })();

  Carousel = (function() {
    Carousel.prototype.defaults = {
      auto: true,
      autoOffOnManual: true,
      duration: 1000,
      pause: 2500,
      direction: "right",
      easing: "easeInOutExpo"
    };

    function Carousel(elem, opts) {
      this.elem = elem;
      console.log("new carousel");
      this.opts = inherit(this.defaults);
      this.update(opts);
      this.init();
    }

    Carousel.prototype.update = function(opts) {
      if ($.isPlainObject(opts)) {
        $.extend(this.opts, opts);
      }
      return console.log("update", this.opts);
    };

    Carousel.prototype.command = function(args) {
      var cmd, _ref;
      cmd = args.shift();
      console.log("command", cmd, args);
      return (_ref = this[cmd]) != null ? _ref.apply(this, args) : void 0;
    };

    Carousel.prototype.init = function() {
      var _this = this;
      this.w = this.elem.width();
      this.h = this.elem.height();
      this.animating = false;
      this.curr = 0;
      this.last = null;
      this.grid = $("<div/>").css({
        width: this.w,
        height: this.h,
        position: "absolute"
      });
      this.rows = [];
      this.elem.children().each(function(i, e) {
        var row;
        row = new Row($(e), i, _this);
        return _this.rows.push(row);
      });
      this.elem.data("carousel", this).append(this.grid).css({
        position: "relative",
        overflow: "hidden"
      });
      return console.log("bound");
    };

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

    Carousel.prototype.to = function(row, col, callback) {
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
    };

    Carousel.prototype.left = function() {};

    Carousel.prototype.right = function() {};

    Carousel.prototype.animate = function() {};

    Carousel.prototype.autoAnimate = function() {
      return this.animating = false;
    };

    return Carousel;

  })();

  $(function() {
    return $("[data-carousel]").carousel();
  });

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
      if (c) {
        if (typeof args[0] === 'string') {
          c.command(args);
        } else if ($.isPlainObject(args[0])) {
          c.update(args[0]);
        }
        return;
      }
      return c = new Carousel($(this), args[0]);
    });
  };

  console.log(name, "plugin added");

}).call(this);
