(function() {
var colorjs, root, _;
root = this;
if (typeof exports !== 'undefined') {
  colorjs = module.exports;
  _ = require('underscore');
} else {
  colorjs = root.colorjs = {};
  _ = root._;
}
colorjs.VERSION = '0.1.0';
(function() {
  var strutils;
  strutils = colorjs.strutils = {};
  strutils.trim = function(str) {
    return str.replace(/^\s+|\s+$/g, "");
  };
  strutils.codepoints = function(str) {
    var i, _ref, _results;
    _results = [];
    for (i = 0, _ref = str.length; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
      _results.push(str.charCodeAt(i));
    }
    return _results;
  };
}).call(this);

(function() {
  var abs, atan2, cos, interpolate, mathutils, mod, sin, sqrt, tau;
  mathutils = colorjs.mathutils = {};
  sqrt = Math.sqrt, cos = Math.cos, sin = Math.sin, atan2 = Math.atan2, abs = Math.abs;
  tau = Math.PI * 2;
  mathutils.sgn = function(x) {
    return (x > 0) - (x < 0);
  };
  mathutils.mod = mod = function(x, y) {
    var js_mod;
    if (!((js_mod = x % y) && (x > 0 ^ y > 0))) {
      return js_mod;
    } else {
      return js_mod + y;
    }
  };
  mathutils.radians = function(x) {
    return x * tau / 360;
  };
  mathutils.degrees = function(x) {
    return x * 360 / tau;
  };
  mathutils.rectangular = function(_arg) {
    var a, r;
    r = _arg[0], a = _arg[1];
    return [r * cos(a), r * sin(a)];
  };
  mathutils.polar = function(_arg) {
    var x, y;
    x = _arg[0], y = _arg[1];
    return [sqrt(x * x + y * y), atan2(y, x)];
  };
  mathutils.interpolate = interpolate = function(x_0, x_1, fraction) {
    return (1 - fraction) * x_0 + fraction * x_1;
  };
  mathutils.circular_interpolate = function(a_0, a_1, max_a, fraction) {
    var _ref;
    _ref = [mod(a_0, max_a), mod(a_1, max_a)], a_0 = _ref[0], a_1 = _ref[1];
    if (abs(a_1 - a_0) <= max_a / 2) {
      return interpolate(a_0, a_1, fraction);
    } else {
      return (interpolate(a_0, a_1, fraction) + max_a / 2) % max_a;
    }
  };
}).call(this);

(function() {
  var mod;
  mod = colorjs.mathutils.mod;
  _.mixin({
    sum: function(list) {
      return _.reduce(list, (function(total, x) {
        return total + x;
      }), 0);
    },
    rotate: function(list, n) {
      var list0, m, output, _ref;
      if (n == null) {
        n = 1;
      }
      n = mod(n, list.length);
      m = list.length - n;
      (list0 = Array.prototype.slice.call(list, 0, m)).unshift(n, 0);
      (_ref = (output = Array.prototype.slice.call(list, m))).splice.apply(_ref, list0);
      return output;
    }
  });
}).call(this);

(function() {
  var Matrix3, matrix3;
  matrix3 = colorjs.matrix3 = {};
  Matrix3 = (function() {
    var rjust;
    function Matrix3(matrix) {
      this.matrix = _.flatten(matrix);
      if (this.matrix.length !== 9) {
        throw new Error('A 3 by 3 Matrix must have 9 entries');
      }
      this.shape = [3, 3];
    }
    Matrix3.prototype.determinant = function() {
      var M00, M01, M02, M10, M11, M12, M20, M21, M22, _ref;
      if (this._determinant != null) {
        return this._determinant;
      }
      _ref = this.matrix, M00 = _ref[0], M01 = _ref[1], M02 = _ref[2], M10 = _ref[3], M11 = _ref[4], M12 = _ref[5], M20 = _ref[6], M21 = _ref[7], M22 = _ref[8];
      return this._determinant = M00 * (M22 * M11 - M21 * M12) + M10 * (M21 * M02 - M22 * M01) + M20 * (M12 * M01 - M11 * M02);
    };
    Matrix3.prototype.inverse = function() {
      var M00, M01, M02, M10, M11, M12, M20, M21, M22, c, _ref;
      c = 1 / this.determinant();
      _ref = this.matrix, M00 = _ref[0], M01 = _ref[1], M02 = _ref[2], M10 = _ref[3], M11 = _ref[4], M12 = _ref[5], M20 = _ref[6], M21 = _ref[7], M22 = _ref[8];
      return new Matrix3([(M22 * M11 - M21 * M12) * c, (M21 * M02 - M22 * M01) * c, (M12 * M01 - M11 * M02) * c, (M20 * M12 - M22 * M10) * c, (M22 * M00 - M20 * M02) * c, (M10 * M02 - M12 * M00) * c, (M21 * M10 - M20 * M11) * c, (M20 * M01 - M21 * M00) * c, (M11 * M00 - M10 * M01) * c]);
    };
    Matrix3.prototype.rows = function() {
      return [this.matrix.slice(0, 3), this.matrix.slice(3, 6), this.matrix.slice(6, 9)];
    };
    Matrix3.prototype.flat = function() {
      return this.matrix;
    };
    Matrix3.prototype.transpose = function() {
      return new Matrix3(_.zip.apply(_, this.rows()));
    };
    Matrix3.prototype.linear_transform = function() {
      var M00, M01, M02, M10, M11, M12, M20, M21, M22, _ref;
      if (this._lt != null) {
        return this._lt;
      }
      _ref = this.matrix, M00 = _ref[0], M01 = _ref[1], M02 = _ref[2], M10 = _ref[3], M11 = _ref[4], M12 = _ref[5], M20 = _ref[6], M21 = _ref[7], M22 = _ref[8];
      return this._lt = function(_arg) {
        var v0, v1, v2;
        v0 = _arg[0], v1 = _arg[1], v2 = _arg[2];
        return [M00 * v0 + M01 * v1 + M02 * v2, M10 * v0 + M11 * v1 + M12 * v2, M20 * v0 + M21 * v1 + M22 * v2];
      };
    };
    Matrix3.prototype._matrix_multiply = function(other) {
      var M00, M01, M02, M10, M11, M12, M20, M21, M22, N00, N01, N02, N10, N11, N12, N20, N21, N22, _ref, _ref2;
      _ref = this.matrix, M00 = _ref[0], M01 = _ref[1], M02 = _ref[2], M10 = _ref[3], M11 = _ref[4], M12 = _ref[5], M20 = _ref[6], M21 = _ref[7], M22 = _ref[8];
      _ref2 = other.matrix, N00 = _ref2[0], N01 = _ref2[1], N02 = _ref2[2], N10 = _ref2[3], N11 = _ref2[4], N12 = _ref2[5], N20 = _ref2[6], N21 = _ref2[7], N22 = _ref2[8];
      return new Matrix3([M00 * N00 + M01 * N10 + M02 * N20, M00 * N01 + M01 * N11 + M02 * N21, M00 * N02 + M01 * N12 + M02 * N22, M10 * N00 + M11 * N10 + M12 * N20, M10 * N01 + M11 * N11 + M12 * N21, M10 * N02 + M11 * N12 + M12 * N22, M20 * N00 + M21 * N10 + M22 * N20, M20 * N01 + M21 * N11 + M22 * N21, M20 * N02 + M21 * N12 + M22 * N22]);
    };
    Matrix3.prototype.dot = function(other) {
      var _ref, _ref2;
      if (((_ref = other.shape) != null ? _ref[0] : void 0) === 3 && ((_ref2 = other.shape) != null ? _ref2[1] : void 0) === 3 && (other.matrix != null)) {
        return this._matrix_multiply(other);
      } else if (other.length === 3) {
        return this.linear_transform()(other);
      }
      throw new Error("Don't know how to dot with this object.");
    };
    Matrix3.prototype.elementwise = function(other, operation) {
      var elem, i;
      return new Matrix3((function() {
        var _len, _ref, _results;
        _ref = this.matrix;
        _results = [];
        for (i = 0, _len = _ref.length; i < _len; i++) {
          elem = _ref[i];
          _results.push(operation(elem, other.matrix[i]));
        }
        return _results;
      }).call(this));
    };
    Matrix3.prototype.multiply_elements = function(other) {
      return this.elementwise(other, function(x, y) {
        return x * y;
      });
    };
    Matrix3.prototype.add = function(other) {
      return this.elementwise(other, function(x, y) {
        return x + y;
      });
    };
    Matrix3.prototype.scalar_multiply = function(a) {
      var x;
      return new Matrix3((function() {
        var _i, _len, _ref, _results;
        _ref = this.matrix;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          x = _ref[_i];
          _results.push(x * a);
        }
        return _results;
      }).call(this));
    };
    rjust = function(str, len, pad) {
      var diff;
      if (pad == null) {
        pad = ' ';
      }
      diff = len - str.length;
      if (diff <= 0) {
        return str;
      } else {
        return Array(diff).concat(str).join(pad);
      }
    };
    Matrix3.prototype.toString = function(precision) {
      var entry_width, fixed, printed_rows, row, rows, s, x;
      precision != null ? precision : precision = 3;
      fixed = (function() {
        var _i, _len, _ref, _results;
        _ref = this.matrix;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          x = _ref[_i];
          _results.push(x.toFixed(precision));
        }
        return _results;
      }).call(this);
      entry_width = _.max((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = fixed.length; _i < _len; _i++) {
          s = fixed[_i];
          _results.push(s.length);
        }
        return _results;
      })());
      fixed = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = fixed.length; _i < _len; _i++) {
          x = fixed[_i];
          _results.push(rjust(x, entry_width));
        }
        return _results;
      })();
      rows = [fixed.slice(0, 3), fixed.slice(3, 6), fixed.slice(6, 9)];
      printed_rows = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = rows.length; _i < _len; _i++) {
          row = rows[_i];
          _results.push('[' + row.join(', ') + ']');
        }
        return _results;
      })();
      return "[" + (printed_rows.join(',\n ')) + "]";
    };
    Matrix3.identity = function() {
      return new this([1, 0, 0, 0, 1, 0, 0, 0, 1]);
    };
    Matrix3.zeros = function() {
      return new this([0, 0, 0, 0, 0, 0, 0, 0, 0]);
    };
    Matrix3.ones = function() {
      return new this([1, 1, 1, 1, 1, 1, 1, 1, 1]);
    };
    return Matrix3;
  })();
  matrix3.Matrix3 = Matrix3;
}).call(this);

(function() {
  var cie, standard_whitepoints;
  cie = colorjs.cie = {};
  standard_whitepoints = cie.standard_whitepoints = {
    A: [109.850, 100, 35.585],
    B: [99.090, 100, 85.324],
    C: [98.074, 100, 118.232],
    E: [100, 100, 100],
    D50: [96.422, 100, 82.521],
    D55: [95.682, 100, 92.149],
    D65: [95.047, 100, 108.883],
    D75: [94.972, 100, 122.638],
    F2: [99.186, 100, 67.393],
    F7: [95.041, 100, 108.747],
    F11: [100.962, 100, 64.350]
  };
  cie.normalize_chromaticity = function(c) {
    var c_x, c_y, x, _i, _len, _ref, _results;
    if (!(_.isArray(c) && ((_ref = c.length) === 2 || _ref === 3))) {
      throw new Error('Unrecognized chromaticity');
    }
    if (c.length === 2) {
      c_x = c[0], c_y = c[1];
      if (!((0 <= c_x && c_x <= 1) && (0 <= c_y && c_y <= 1) && c_x + c_y <= 1)) {
        throw new Error('Invalid (x, y) chromaticity coordinates');
      }
      return [c_x, c_y, 1 - c_x - c_y];
    } else if (c.length === 3) {
      _results = [];
      for (_i = 0, _len = c.length; _i < _len; _i++) {
        x = c[_i];
        _results.push(x / _.sum(c));
      }
      return _results;
    }
  };
  cie.normalize_whitepoint = function(white) {
    var comp, w_x, w_y, w_z, _i, _len, _ref, _results;
    if (!(white != null)) {
      white = standard_whitepoints.D65;
    } else if (white in standard_whitepoints) {
      white = standard_whitepoints[white];
    } else if (_.isArray(white)) {
      if ((_ref = white.length) !== 2 && _ref !== 3) {
        throw new Error('Unrecognized whitepoint');
      }
      if (white.length === 2) {
        w_x = white[0], w_y = white[1];
        if (!((0 <= w_x && w_x <= 1) && (0 <= w_y && w_y <= 1) && w_x + w_y <= 1)) {
          throw new Error('Invalid (x, y) chromaticity coords for whitepoint');
        }
        white = [w_x, w_y, 1 - w_x - w_y];
      }
    } else {
      throw new Error('Unrecognized whitepoint');
    }
    w_x = white[0], w_y = white[1], w_z = white[2];
    _results = [];
    for (_i = 0, _len = white.length; _i < _len; _i++) {
      comp = white[_i];
      _results.push(comp * 100 / w_y);
    }
    return _results;
  };
}).call(this);

(function() {
  var Matrix3, ProPhoto_gamma, RGB_matrix_from_primaries, RGB_spaces_parameters, max, normalize_chromaticity, normalize_whitepoint, pow, rgb, round, sRGB_gamma, standard_whitepoints, zero_pad, _ref;
  rgb = colorjs.rgb = {};
  max = Math.max, pow = Math.pow, round = Math.round;
  _ref = colorjs.cie, standard_whitepoints = _ref.standard_whitepoints, normalize_chromaticity = _ref.normalize_chromaticity, normalize_whitepoint = _ref.normalize_whitepoint;
  Matrix3 = colorjs.matrix3.Matrix3;
  RGB_matrix_from_primaries = function(_arg) {
    var b, c_b, c_g, c_r, g, primaries, r, white, x, x_b, x_g, x_r, y_b, y_g, y_r, z_b, z_g, z_r, _ref, _ref2;
    r = _arg.r, g = _arg.g, b = _arg.b, white = _arg.white;
    primaries = (new Matrix3((function() {
      var _i, _len, _ref, _results;
      _ref = [r, g, b];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        x = _ref[_i];
        _results.push(normalize_chromaticity(x));
      }
      return _results;
    })())).transpose();
    _ref = primaries.flat(), x_r = _ref[0], x_g = _ref[1], x_b = _ref[2], y_r = _ref[3], y_g = _ref[4], y_b = _ref[5], z_r = _ref[6], z_g = _ref[7], z_b = _ref[8];
    white = normalize_whitepoint(white);
    _ref2 = primaries.inverse().dot(white), c_r = _ref2[0], c_g = _ref2[1], c_b = _ref2[2];
    return (new Matrix3([c_r * x_r, c_g * x_g, c_b * x_b, c_r * y_r, c_g * y_g, c_b * y_b, c_r * z_r, c_g * z_g, c_b * z_b])).inverse();
  };
  sRGB_gamma = [
    function(x) {
      if (x <= .0031308) {
        return 12.92 * x;
      } else {
        return 1.055 * pow(x, 1 / 2.4) - .055;
      }
    }, function(x_) {
      if (x_ <= .04045) {
        return x_ / 12.92;
      } else {
        return pow((x_ + .055) / 1.055, 2.4);
      }
    }
  ];
  ProPhoto_gamma = [
    function(x) {
      if (x < .001953125) {
        return 16 * x;
      } else {
        return pow(x, 1 / 1.8);
      }
    }, function(x_) {
      if (x_ < 16 * .001953125) {
        return x / 16;
      } else {
        return pow(x, 1.8);
      }
    }
  ];
  RGB_spaces_parameters = {
    'sRGB': {
      r: [.64, .33],
      g: [.30, .60],
      b: [.15, .06],
      gamma: sRGB_gamma
    },
    'Adobe RGB': {
      r: [.64, .33],
      g: [.21, .71],
      b: [.15, .06],
      gamma: 2.2
    },
    'Apple RGB': {
      r: [.625, .340],
      g: [.280, .595],
      b: [.155, .070],
      gamma: 1.8
    },
    'ProPhoto RGB': {
      r: [.7347, .2653],
      g: [.1596, .8404],
      b: [.0366, .0001],
      white: 'D50',
      gamma: ProPhoto_gamma
    },
    'Wide Gamut RGB': {
      r: [.7347, .2653],
      g: [.1152, .8264],
      b: [.1566, .0177],
      gamma: 563 / 256
    },
    'ColorMatch RGB': {
      r: [.630, .340],
      g: [.295, .605],
      b: [.150, .075],
      white: 'D50',
      gamma: 1.8
    }
  };
  rgb.Converter = function(params) {
    var decoding_gamma, encoding_gamma, from_XYZ, from_XYZ_linear, g, gamma_decode, gamma_encode, in_gamut, matrix, to_XYZ, to_XYZ_linear, _ref;
    params != null ? params : params = 'sRGB';
    if (_.isString(params)) {
      params = RGB_spaces_parameters[params];
      if (params == null) {
        throw new Error('Unrecognized name for RGB space');
      }
    }
    params = _(params).defaults({
      r: [.64, .33],
      g: [.30, .60],
      b: [.15, .06],
      white: 'D65',
      gamma: 2.2
    });
    g = params.gamma;
    if (_.isNumber(g)) {
      _ref = [g, 1 / g], decoding_gamma = _ref[0], encoding_gamma = _ref[1];
      gamma_encode = function(x) {
        return pow(x, encoding_gamma);
      };
      gamma_decode = function(x) {
        return pow(x, decoding_gamma);
      };
    } else if (g.length === 2 && _.isFunction(g[0]) && _.isFunction(g[1])) {
      gamma_encode = g[0], gamma_decode = g[1];
    } else {
      throw new Error('Unrecognized gamma');
    }
    matrix = RGB_matrix_from_primaries(params);
    from_XYZ_linear = matrix.linear_transform();
    to_XYZ_linear = matrix.inverse().linear_transform();
    from_XYZ = function(XYZ) {
      var component, _i, _len, _ref, _results;
      _ref = from_XYZ_linear(XYZ);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        component = _ref[_i];
        _results.push(gamma_encode(component));
      }
      return _results;
    };
    to_XYZ = function(RGB) {
      var component;
      return to_XYZ_linear((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = RGB.length; _i < _len; _i++) {
          component = RGB[_i];
          _results.push(gamma_decode(component));
        }
        return _results;
      })());
    };
    in_gamut = function(XYZ) {
      var comp;
      return _.every((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = XYZ.length; _i < _len; _i++) {
          comp = XYZ[_i];
          _results.push(0 <= comp);
        }
        return _results;
      })()) && _.every((function() {
        var _i, _len, _ref, _results;
        _ref = from_XYZ_linear(XYZ);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          comp = _ref[_i];
          _results.push((0 <= comp && comp <= 1));
        }
        return _results;
      })());
    };
    return {
      from_XYZ: from_XYZ,
      to_XYZ: to_XYZ,
      from_XYZ_linear: from_XYZ_linear,
      to_XYZ_linear: to_XYZ_linear,
      in_gamut: in_gamut
    };
  };
  zero_pad = function(str, len) {
    return Array(max(len - str.length, 0) + 1).join('0') + str;
  };
  rgb.to_hex = function(_arg) {
    var B, G, R;
    R = _arg[0], G = _arg[1], B = _arg[2];
    if (!((0 <= R && R <= 1) && (0 <= G && G <= 1) && (0 <= B && B <= 1))) {
      throw new Error('Bad Input: R, G, and B must be in range [0, 1]');
    }
    return '#' + zero_pad(((round(0xff * R) << 16) + (round(0xff * G) << 8) + (round(0xff * B))).toString(16), 6);
  };
  rgb.from_hex = function(hex) {
    var RGB;
    if (!/^#?[0-9a-fA-F]{6}$/.test(hex)) {
      throw new Error('Bad Input: Must be of form "666FAD" or "#DEFACE"');
    }
    RGB = parseInt(hex.substr(-6), 16);
    return [(RGB >> 16) / 0xff, (RGB >> 8 & 0xff) / 0xff, (RGB & 0xff) / 0xff];
  };
}).call(this);

(function() {
  var abs, hsl, hsv, max, min, mod, polar, rectangular, _ref;
  hsl = colorjs.hsl = {};
  hsv = colorjs.hsv = {};
  _ref = colorjs.mathutils, mod = _ref.mod, polar = _ref.polar, rectangular = _ref.rectangular;
  abs = Math.abs, max = Math.max, min = Math.min;
  mod = colorjs.mathutils.mod;
  hsl.converter = (function() {
    var from_RGB, to_RGB;
    from_RGB = function(_arg) {
      var B, C, G, H, L, M, R, S, m, _ref;
      R = _arg[0], G = _arg[1], B = _arg[2];
      if (!((0 <= R && R <= 1) && (0 <= G && G <= 1) && (0 <= B && B <= 1))) {
        throw new Error('Bad Input: R, G, and B must be in range [0, 1]');
      }
      _ref = [max(R, G, B), min(R, G, B)], M = _ref[0], m = _ref[1];
      C = M - m;
      H = C === 0 ? null : M === R ? (G - B) / C : M === G ? (B - R) / C + 2 : (R - G) / C + 4;
      H = (H % 6) * 60;
      L = (M + m) / 2;
      S = C === 0 ? 0 : C / (1 - abs(2 * L - 1));
      return [H, S, L];
    };
    to_RGB = function(_arg) {
      var B, C, G, H, L, R, S, X;
      H = _arg[0], S = _arg[1], L = _arg[2];
      if (!((0 <= L && L <= 1) && (0 <= S && S <= 1))) {
        throw new Error('Bad Input: L and S must be in range [0, 1]');
      }
      if (S === 0) {
        return [L, L, L];
      }
      if (typeof H !== 'number') {
        throw new Error('Bad Input: If S is non-zero, H must have a value.');
      }
      H = mod(H, 360) / 60;
      C = 2 * S * (L < 1 / 2 ? L : 1 - L);
      X = C * (1 - abs(H % 2 - 1));
      R = G = B = L - C / 2;
      H = ~~H;
      R += [C, X, 0, 0, X, C][H];
      G += [X, C, C, X, 0, 0][H];
      B += [0, 0, X, C, C, X][H];
      return [R, G, B];
    };
    return {
      from_RGB: from_RGB,
      to_RGB: to_RGB
    };
  })();
  hsv.converter = (function() {
    var from_RGB, to_RGB;
    from_RGB = function(_arg) {
      var B, C, G, H, R, S, V;
      R = _arg[0], G = _arg[1], B = _arg[2];
      if (!((0 <= R && R <= 1) && (0 <= G && G <= 1) && (0 <= B && B <= 1))) {
        throw new Error('Bad Input: R, G, and B must be in range [0, 1]');
      }
      V = max(R, G, B);
      C = V - min(R, G, B);
      H = C === 0 ? null : M === R ? (G - B) / C : M === G ? (B - R) / C + 2 : (R - G) / C + 4;
      H = (H % 6) * 60;
      S = C === 0 ? 0 : C / V;
      return [H, S, V];
    };
    to_RGB = function(_arg) {
      var B, C, G, H, R, S, V, X;
      H = _arg[0], S = _arg[1], V = _arg[2];
      if (!((0 <= V && V <= 1) && (0 <= S && S <= 1))) {
        throw new Error('Bad Input: V and S must be in range [0, 1]');
      }
      if (S === 0) {
        return [V, V, V];
      }
      if (typeof H !== 'number') {
        throw new Error('Bad Input: If S is non-zero, H must have a value.');
      }
      H = (H % 360) / 60;
      C = V * S;
      X = C * (1 - abs(H % 2 - 1));
      R = G = B = V - C;
      H = ~~H;
      R += [C, X, 0, 0, X, C][H];
      G += [X, C, C, X, 0, 0][H];
      B += [0, 0, X, C, C, X][H];
      return [R, G, B];
    };
    return {
      from_RGB: from_RGB,
      to_RGB: to_RGB
    };
  })();
}).call(this);

(function() {
  var cielab, normalize_whitepoint, pow;
  cielab = colorjs.cielab = {};
  normalize_whitepoint = colorjs.cie.normalize_whitepoint;
  pow = Math.pow;
  cielab.Converter = function(white) {
    var Xw, Yw, Zw, d, f, from_XYZ, g, to_XYZ;
    if (white == null) {
      white = 'D65';
    }
    white = normalize_whitepoint(white);
    Xw = white[0], Yw = white[1], Zw = white[2];
    d = 6 / 29;
    f = function(t) {
      if (t > d * d * d) {
        return pow(t, 1 / 3);
      } else {
        return t / 3 / d / d + 4 / 29;
      }
    };
    g = function(t) {
      if (t > d) {
        return t * t * t;
      } else {
        return 3 * d * d * (t - 4 / 29);
      }
    };
    from_XYZ = function(_arg) {
      var L_star, X, Y, Z, a_star, b_star, fY;
      X = _arg[0], Y = _arg[1], Z = _arg[2];
      fY = f(Y / Yw);
      L_star = 116 * fY - 16;
      a_star = 500 * (f(X / Xw) - fY);
      b_star = 200 * (fY - f(Z / Zw));
      return [L_star, a_star, b_star];
    };
    to_XYZ = function(_arg) {
      var L_star, X, Y, Z, a_star, b_star, temp;
      L_star = _arg[0], a_star = _arg[1], b_star = _arg[2];
      temp = (L_star + 16) / 116;
      X = Xw * g(temp + a_star / 500);
      Y = Yw * g(temp);
      Z = Zw * g(temp - b_star / 200);
      return [X, Y, Z];
    };
    return {
      from_XYZ: from_XYZ,
      to_XYZ: to_XYZ
    };
  };
}).call(this);

(function() {
  var Matrix3, abs, atan2, ciecam, circular_interpolate, cos, exp, floor, hue_comp_re, interpolate, mod, pow, round, sgn, sin, sqrt, standard_whitepoints, tau, unique_hues_H, unique_hues_e, unique_hues_h, unique_hues_s, _ref;
  ciecam = colorjs.ciecam = {};
  atan2 = Math.atan2, sin = Math.sin, cos = Math.cos, exp = Math.exp, abs = Math.abs, sqrt = Math.sqrt, pow = Math.pow, round = Math.round, floor = Math.floor;
  tau = Math.PI * 2;
  _ref = colorjs.mathutils, sgn = _ref.sgn, mod = _ref.mod, interpolate = _ref.interpolate, circular_interpolate = _ref.circular_interpolate;
  Matrix3 = colorjs.matrix3.Matrix3;
  standard_whitepoints = colorjs.cie.standard_whitepoints;
  ciecam.Converter = function(params) {
    var A_w, CAT02_to_HPE, CAT02_to_XYZ, D, D_B, D_G, D_R, F, F_L, HPE_to_CAT02, L_A, M_CAT02, M_HPE, N_bb, N_c, N_cb, RGB_aw, RGB_cw, RGB_w, XYZ_to_CAT02, XYZ_w, Y_b, Y_w, achromatic_response, adapted_response, adapted_responses, c, component, corresponding_colors, forward_model, k, n, reverse_adapted_response, reverse_adapted_responses, reverse_corresponding_colors, reverse_model, surround, z, _ref;
    params = _(params || {}).defaults({
      whitepoint: 'D65',
      adapting_luminance: 40,
      background_luminance: 20,
      surround: 'average',
      discounting: false
    });
    M_CAT02 = new Matrix3([.7328, .4296, -.1624, -.7036, 1.6975, .0061, .0030, .0136, .9834]);
    M_HPE = new Matrix3([.38971, .68898, -.07868, -.22981, 1.18340, .04641, .00000, .00000, 1.00000]);
    XYZ_to_CAT02 = M_CAT02.linear_transform();
    CAT02_to_XYZ = M_CAT02.inverse().linear_transform();
    CAT02_to_HPE = M_HPE.dot(M_CAT02.inverse()).linear_transform();
    HPE_to_CAT02 = M_CAT02.dot(M_HPE.inverse()).linear_transform();
    XYZ_w = standard_whitepoints[params.whitepoint] || params.whitepoint;
    if (!_.isArray(XYZ_w)) {
      throw new Error('Invalid whitepoint');
    }
    L_A = params.adapting_luminance;
    Y_b = params.background_luminance;
    Y_w = XYZ_w[1];
    surround = (function() {
      if (_.isNumber(params.surround)) {
        return params.surround;
      } else {
        switch (params.surround) {
          case 'dark':
            return 0;
          case 'dim':
            return 1;
          case 'average':
            return 2;
          default:
            return new Error('Invalid surround');
        }
      }
    })();
    if (surround < 1) {
      c = interpolate(.525, .59, surround);
      N_c = F = interpolate(.8, .9, surround);
    } else {
      c = interpolate(.59, .69, surround - 1);
      N_c = F = interpolate(.9, 1.0, surround - 1);
    }
    k = 1 / (5 * L_A + 1);
    F_L = .2 * pow(k, 4) * 5 * L_A + .1 * pow(1 - pow(k, 4), 2) * pow(5 * L_A, 1 / 3);
    n = Y_b / Y_w;
    N_bb = N_cb = .725 * pow(1 / n, .2);
    z = 1.48 + sqrt(n);
    if (params.discounting) {
      D = 1;
    }
    D != null ? D : D = F * (1 - 1 / 3.6 * exp(-(L_A + 42) / 92));
    RGB_w = XYZ_to_CAT02(XYZ_w);
    _ref = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = RGB_w.length; _i < _len; _i++) {
        component = RGB_w[_i];
        _results.push(interpolate(1, 100 / component, D));
      }
      return _results;
    })(), D_R = _ref[0], D_G = _ref[1], D_B = _ref[2];
    corresponding_colors = function(XYZ) {
      var B, G, R, _ref;
      _ref = XYZ_to_CAT02(XYZ), R = _ref[0], G = _ref[1], B = _ref[2];
      return [D_R * R, D_G * G, D_B * B];
    };
    reverse_corresponding_colors = function(_arg) {
      var B_c, G_c, R_c;
      R_c = _arg[0], G_c = _arg[1], B_c = _arg[2];
      return CAT02_to_XYZ([R_c / D_R, G_c / D_G, B_c / D_B]);
    };
    adapted_response = function(HPE_component) {
      var x;
      x = pow(F_L * abs(HPE_component) / 100, .42);
      return sgn(HPE_component) * 400 * x / (27.13 + x) + .1;
    };
    adapted_responses = function(RGB_c) {
      var component, _i, _len, _ref, _results;
      _ref = CAT02_to_HPE(RGB_c);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        component = _ref[_i];
        _results.push(adapted_response(component));
      }
      return _results;
    };
    reverse_adapted_response = function(adapted_component) {
      var x;
      x = adapted_component - .1;
      return sgn(x) * 100 / F_L * pow(27.13 * abs(x) / (400 - abs(x)), 1 / .42);
    };
    reverse_adapted_responses = function(RGB_a) {
      var component;
      return HPE_to_CAT02((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = RGB_a.length; _i < _len; _i++) {
          component = RGB_a[_i];
          _results.push(reverse_adapted_response(component));
        }
        return _results;
      })());
    };
    achromatic_response = function(_arg) {
      var B_a, G_a, R_a;
      R_a = _arg[0], G_a = _arg[1], B_a = _arg[2];
      return (R_a * 2 + G_a + B_a / 20 - .305) * N_bb;
    };
    RGB_cw = corresponding_colors(XYZ_w);
    RGB_aw = adapted_responses(RGB_cw);
    A_w = achromatic_response(RGB_aw);
    forward_model = function(XYZ) {
      var A, B_a, C, G_a, J, M, Q, RGB_a, RGB_c, R_a, a, b, e_t, h, h_rad, s, t, _ref;
      RGB_c = corresponding_colors(XYZ);
      _ref = RGB_a = adapted_responses(RGB_c), R_a = _ref[0], G_a = _ref[1], B_a = _ref[2];
      a = R_a - G_a * 12 / 11 + B_a / 11;
      b = (R_a + G_a - 2 * B_a) / 9;
      h_rad = atan2(b, a);
      h = mod(h_rad * 360 / tau, 360);
      e_t = 1 / 4 * (cos(h_rad + 2) + 3.8);
      A = achromatic_response(RGB_a);
      J = 100 * pow(A / A_w, c * z);
      t = 5e4 / 13 * N_c * N_cb * e_t * sqrt(a * a + b * b) / (R_a + G_a + 21 / 20 * B_a);
      C = pow(t, .9) * sqrt(J / 100) * pow(1.64 - pow(.29, n), .73);
      Q = 4 / c * sqrt(J / 100) * (A_w + 4) * pow(F_L, .25);
      M = C * pow(F_L, .25);
      s = 100 * sqrt(M / Q);
      return {
        J: J,
        C: C,
        h: h,
        Q: Q,
        M: M,
        s: s
      };
    };
    reverse_model = function(inputs) {
      var A, C, J, M, Q, RGB_a, RGB_c, XYZ, a, b, cos_h, e_t, h, h_rad, p_1, p_2, q_1, q_2, q_3, s, sin_h, t;
      Q = inputs.Q, M = inputs.M, J = inputs.J, C = inputs.C, s = inputs.s, h = inputs.h;
      if (!(((J != null) + (Q != null) === 1) && ((M != null) + (C != null) + (s != null) === 1) && (h != null))) {
        throw new Error('Need exactly three model inputs');
      }
      h = mod(h, 360);
      h_rad = h * tau / 360;
      J != null ? J : J = 6.25 * pow(c * Q / ((A_w + 4) * pow(F_L, .25)), 2);
      Q != null ? Q : Q = 4 / c * sqrt(J / 100) * (A_w + 4) * pow(F_L, .25);
      C != null ? C : C = M != null ? M / pow(F_L, .25) : pow(s / 100, 2) * Q / pow(F_L, .25);
      M != null ? M : M = C * pow(F_L, .25);
      s != null ? s : s = 100 * sqrt(M / Q);
      t = pow(C / (sqrt(J / 100) * pow(1.64 - pow(.29, n), .73)), 10 / 9);
      e_t = 1 / 4 * (cos(h_rad + 2) + 3.8);
      A = A_w * pow(J / 100, 1 / c / z);
      p_1 = 5e4 / 13 * N_c * N_cb * e_t / t;
      p_2 = A / N_bb + .305;
      q_1 = p_2 * 61 / 20 * 460 / 1403;
      q_2 = 61 / 20 * 220 / 1403;
      q_3 = 21 / 20 * 6300 / 1403 - 27 / 1403;
      sin_h = sin(h_rad);
      cos_h = cos(h_rad);
      if (t === 0) {
        a = b = 0;
      } else if (abs(sin_h) >= abs(cos_h)) {
        b = q_1 / (p_1 / sin_h + q_2 * cos_h / sin_h + q_3);
        a = b * cos_h / sin_h;
      } else {
        a = q_1 / (p_1 / cos_h + q_2 + q_3 * sin_h / cos_h);
        b = a * sin_h / cos_h;
      }
      RGB_a = [20 / 61 * p_2 + 451 / 1403 * a + 288 / 1403 * b, 20 / 61 * p_2 - 891 / 1403 * a - 261 / 1403 * b, 20 / 61 * p_2 - 220 / 1403 * a - 6300 / 1403 * b];
      RGB_c = reverse_adapted_responses(RGB_a);
      XYZ = reverse_corresponding_colors(RGB_c);
      return {
        J: J,
        C: C,
        h: h,
        Q: Q,
        M: M,
        s: s,
        XYZ: XYZ
      };
    };
    return {
      forward_model: forward_model,
      reverse_model: reverse_model
    };
  };
  unique_hues_s = ['R', 'Y', 'G', 'B', 'R'];
  unique_hues_h = [20.14, 90.00, 164.25, 237.53, 380.14];
  unique_hues_e = [.8, .7, 1.0, 1.2, .8];
  unique_hues_H = [0, 100, 200, 300, 400];
  ciecam.hue_quad = function(h) {
    var H_j, dist_j, dist_k, j;
    h = mod(h, 360);
    if (h < 20.14) {
      h += 360;
    }
    j = 0;
    while (!(unique_hues_h[j + 1] >= h)) {
      j++;
    }
    dist_j = (h - unique_hues_h[j]) / unique_hues_e[j];
    dist_k = (unique_hues_h[j + 1] - h) / unique_hues_e[j + 1];
    H_j = unique_hues_H[j];
    return H_j + 100 * dist_j / (dist_j + dist_k);
  };
  ciecam.inverse_hue_quad = function(H) {
    var amt, e_j, e_k, h, h_j, h_k, j, _ref, _ref2;
    H = mod(H, 400);
    j = floor(H / 100);
    amt = H % 100;
    _ref = unique_hues_e.slice(j, (j + 1 + 1) || 9e9), e_j = _ref[0], e_k = _ref[1];
    _ref2 = unique_hues_h.slice(j, (j + 1 + 1) || 9e9), h_j = _ref2[0], h_k = _ref2[1];
    h = (amt * (e_k * h_j - e_j * h_k) - 100 * h_j * e_k) / (amt * (e_k - e_j) - 100 * e_k);
    return mod(h, 360);
  };
  ciecam.hue_comp = function(H) {
    var amt, j, s_j, s_k, _ref;
    H = mod(round(H), 400);
    j = floor(H / 100);
    amt = H % 100;
    _ref = unique_hues_s.slice(j, (j + 1 + 1) || 9e9), s_j = _ref[0], s_k = _ref[1];
    if (amt === 0) {
      return "100" + s_j;
    } else {
      return "" + amt + s_k + " " + (100 - amt) + s_j;
    }
  };
  hue_comp_re = (function() {
    var cardinal_hue, num_and_sym, number, space, symbol;
    number = '([0-9]+(?:[.][0-9]*)?)';
    symbol = '([RYGB])';
    space = '[ ]*';
    num_and_sym = number + space + symbol;
    cardinal_hue = '100(?:[.]0*)?' + space + symbol;
    return new RegExp(cardinal_hue + '|' + num_and_sym + space + num_and_sym);
  })();
  ciecam.parse_hue_comp = function(comp) {
    var amt_j, amt_k, j, k, s_j, s_k, s_uniq, whole_match, _ref, _ref2, _ref3, _ref4, _ref5;
    _ref = comp.match(hue_comp_re), whole_match = _ref[0], s_uniq = _ref[1], amt_j = _ref[2], s_j = _ref[3], amt_k = _ref[4], s_k = _ref[5];
    if (whole_match == null) {
      throw new Error('Unrecognized hue composition');
    }
    if (s_uniq != null) {
      return unique_hues_s.indexOf(s_uniq) * 100;
    }
    _ref2 = [unique_hues_s.indexOf(s_j), unique_hues_s.indexOf(s_k)], j = _ref2[0], k = _ref2[1];
    if ((_ref3 = abs(j - k)) === 0 || _ref3 === 2) {
      throw new Error('Hues must be neighbors');
    }
    if ((k + 1) % 4 === j) {
      _ref4 = [k, j, amt_k, amt_j], j = _ref4[0], k = _ref4[1], amt_j = _ref4[2], amt_k = _ref4[3];
    }
    _ref5 = [parseFloat(amt_j), parseFloat(amt_k)], amt_j = _ref5[0], amt_k = _ref5[1];
    if (abs(amt_j + amt_k - 100) > 1) {
      throw new Error('Hue comp must sum to 100');
    }
    return 100 * j + amt_k;
  };
}).call(this);

(function() {
  var ciecam, codepoints, disp_CIECAM, gamut, mod, polar, pow, rectangular, rgb, sRGB, tau, _ref;
  gamut = colorjs.gamut = {};
  pow = Math.pow;
  _ref = colorjs.mathutils, mod = _ref.mod, polar = _ref.polar, rectangular = _ref.rectangular;
  codepoints = colorjs.strutils.codepoints;
  ciecam = colorjs.ciecam;
  rgb = colorjs.rgb;
  tau = Math.PI * 2;
  sRGB = rgb.Converter('sRGB');
  disp_CIECAM = ciecam.Converter({
    adapting_luminance: 200,
    discounting: true
  });
  gamut.bring_into_sRGB = (function() {
    var iterations;
    iterations = 30;
    return function(XYZ) {
      var C, J, h, i, orig, prev_test, test_XYZ, this_test, _ref;
      if (XYZ.J != null) {
        J = XYZ.J, C = XYZ.C, h = XYZ.h;
        XYZ = disp_CIECAM.reverse_model({
          J: J,
          C: C,
          h: h
        }).XYZ;
      } else {
        _ref = disp_CIECAM.forward_model(XYZ), J = _ref.J, C = _ref.C, h = _ref.h;
      }
      orig = {
        J: J,
        C: C,
        h: h
      };
      if (sRGB.in_gamut(XYZ)) {
        return XYZ;
      }
      prev_test = 0;
      for (i = 1; (1 <= iterations ? i <= iterations : i >= iterations); (1 <= iterations ? i += 1 : i -= 1)) {
        this_test = prev_test + pow(1 / 2, i);
        test_XYZ = disp_CIECAM.reverse_model({
          J: J,
          C: C * this_test,
          h: h
        }).XYZ;
        if (sRGB.in_gamut(test_XYZ)) {
          prev_test = this_test;
          XYZ = test_XYZ;
        }
      }
      return XYZ;
    };
  })();
  gamut.boundary = (function() {
    var circular_distance, decode_pt, distance, edges, encode_pt, horizontal, precision, vertical, vertices;
    precision = 8;
    encode_pt = function(rgb) {
      var x;
      return String.fromCharCode.apply(String, (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = rgb.length; _i < _len; _i++) {
          x = rgb[_i];
          _results.push(x + 0x30);
        }
        return _results;
      })());
    };
    decode_pt = function(pt_str) {
      var x, _i, _len, _ref, _results;
      _ref = codepoints(pt_str);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        x = _ref[_i];
        _results.push(x - 0x30);
      }
      return _results;
    };
    vertices = (function() {
      var V, add_vertex, i, j, n, p;
      V = {};
      p = precision;
      add_vertex = function(_arg) {
        var C, J, a_C, b, b_C, g, h, point, r, xyz, _ref, _ref2;
        r = _arg[0], g = _arg[1], b = _arg[2];
        xyz = sRGB.to_XYZ([r / p, g / p, b / p]);
        _ref = disp_CIECAM.forward_model(xyz), J = _ref.J, C = _ref.C, h = _ref.h;
        h = tau / 360 * h;
        _ref2 = rectangular([C, h]), a_C = _ref2[0], b_C = _ref2[1];
        point = encode_pt([r, g, b]);
        return V[point] = [J, C, h, a_C, b_C];
      };
      for (i = 0; (0 <= precision ? i <= precision : i >= precision); (0 <= precision ? i += 1 : i -= 1)) {
        for (j = 0; (0 <= precision ? j <= precision : j >= precision); (0 <= precision ? j += 1 : j -= 1)) {
          for (n = 0; n < 3; n++) {
            add_vertex(_([i, j, 0]).rotate(n));
            add_vertex(_([i, j, p]).rotate(n));
          }
        }
      }
      return V;
    })();
    edges = (function() {
      var E, add_edge, add_edges, i, j, lower_vertices, n, p, upper_vertices, v;
      E = {};
      p = precision;
      add_edge = function(rgb1, rgb2) {
        var C1, C2, J1, J2, h1, h2, v1, v2, _ref, _ref2, _ref3;
        if (_.min(rgb1.concat(rgb2)) >= 0 && _.max(rgb1.concat(rgb2)) <= p) {
          _ref = [encode_pt(rgb1), encode_pt(rgb2)].sort(), v1 = _ref[0], v2 = _ref[1];
          _ref2 = vertices[v1], J1 = _ref2[0], C1 = _ref2[1], h1 = _ref2[2];
          _ref3 = vertices[v2], J2 = _ref3[0], C2 = _ref3[1], h2 = _ref3[2];
          return E[v1 + v2] = [v1, J1, h1, v2, J2, h2];
        }
      };
      add_edges = function(_arg) {
        var v1, v2, v3, v4;
        v1 = _arg[0], v2 = _arg[1], v3 = _arg[2], v4 = _arg[3];
        add_edge(v1, v2);
        add_edge(v1, v3);
        return add_edge(v1, v4);
      };
      for (i = 0; (0 <= precision ? i <= precision : i >= precision); (0 <= precision ? i += 1 : i -= 1)) {
        for (j = 0; (0 <= precision ? j <= precision : j >= precision); (0 <= precision ? j += 1 : j -= 1)) {
          lower_vertices = [[i, j, 0], [i - 1, j, 0], [i, j - 1, 0], [i - 1, j - 1, 0]];
          upper_vertices = [[i, j, p], [i - 1, j, p], [i, j - 1, p], [i - 1, j - 1, p]];
          for (n = 0; n < 3; n++) {
            add_edges((function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = upper_vertices.length; _i < _len; _i++) {
                v = upper_vertices[_i];
                _results.push(_(v).rotate(n));
              }
              return _results;
            })());
            add_edges((function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = lower_vertices.length; _i < _len; _i++) {
                v = lower_vertices[_i];
                _results.push(_(v).rotate(n));
              }
              return _results;
            })());
          }
        }
      }
      return E;
    })();
    distance = function(p_0, p_1, x) {
      return (x - p_0) / (p_1 - p_0);
    };
    circular_distance = function(a_0, a_1, max_a, x) {
      var shift_amount, y, _ref, _ref2;
      _ref = [mod(a_0, max_a), mod(a_1, max_a)], a_0 = _ref[0], a_1 = _ref[1];
      shift_amount = -(a_1 + a_0) / 2;
      if (abs(a_1 - a_0) <= max_a / 2) {
        shift_amount += max_a / 2;
      }
      _ref2 = (function() {
        var _i, _len, _ref, _results;
        _ref = [a_0, a_1, x];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          y = _ref[_i];
          _results.push(mod(y + shift_amount, max_a));
        }
        return _results;
      })(), a_0 = _ref2[0], a_1 = _ref2[1], x = _ref2[2];
      return distance(a_0, a_1, x);
    };
    horizontal = function(J) {
      var C1, C2, Cx, J1, J2, a_C1, a_C2, a_Cx, b_C1, b_C2, b_Cx, dist, edge, h1, h2, hx, output, v1, v2, _ref, _ref2, _ref3, _ref4;
      if (J == null) {
        J = 50;
      }
      output = [];
      for (edge in edges) {
        _ref = edges[edge], v1 = _ref[0], J1 = _ref[1], h1 = _ref[2], v2 = _ref[3], J2 = _ref[4], h2 = _ref[5];
        dist = distance(J1, J2, J);
        if (!((0 <= dist && dist <= 1))) {
          continue;
        }
        _ref2 = vertices[v1], J1 = _ref2[0], C1 = _ref2[1], h1 = _ref2[2], a_C1 = _ref2[3], b_C1 = _ref2[4];
        _ref3 = vertices[v2], J2 = _ref3[0], C2 = _ref3[1], h2 = _ref3[2], a_C2 = _ref3[3], b_C2 = _ref3[4];
        a_Cx = interpolate(a_C1, a_C2, dist);
        b_Cx = interpolate(b_C1, b_C2, dist);
        _ref4 = polar([a_Cx, b_Cx]), Cx = _ref4[0], hx = _ref4[1];
        hx = mod(hx, tau);
        output.push([a_Cx, b_Cx, hx]);
      }
      output.sort(function(a, b) {
        return a[2] - b[2];
      });
      return output;
    };
    vertical = function(h) {
      var C1, C2, Cx, J1, J2, Jx, a_C1, a_C2, b_C1, b_C2, dist, edge, h1, h2, output, v1, v2, _ref, _ref2, _ref3;
      if (h == null) {
        h = 0;
      }
      output = [[0, 0], [100, 0]];
      for (edge in edges) {
        _ref = edges[edge], v1 = _ref[0], J1 = _ref[1], h1 = _ref[2], v2 = _ref[3], J2 = _ref[4], h2 = _ref[5];
        h = tau / 360 * h;
        dist = circular_distance(h1, h2, tau, h);
        if (!((0 <= dist && dist <= 1))) {
          continue;
        }
        _ref2 = vertices[v1], J1 = _ref2[0], C1 = _ref2[1], h1 = _ref2[2], a_C1 = _ref2[3], b_C1 = _ref2[4];
        _ref3 = vertices[v2], J2 = _ref3[0], C2 = _ref3[1], h2 = _ref3[2], a_C2 = _ref3[3], b_C2 = _ref3[4];
        Jx = interpolate(J1, J2, dist);
        Cx = interpolate(C1, C2, dist);
        output.push([Jx, Cx]);
      }
      output.sort(function(a, b) {
        return a[0] - b[0];
      });
      return output;
    };
    return {
      horizontal: horizontal,
      vertical: vertical
    };
  })();
}).call(this);

}).call(this);