var THREE = require('three.js');

module.exports = function() {

  var size = 10;
  var box = new THREE.BoxGeometry(size, size, size);
  var star = (function() {
    var points = [],
    amt = 8;
    for (var i = 0; i < amt; i++) {
      var pct = i / amt;
      var theta = pct * Math.PI * 2;
      var amp = !(i % 2) ? 0.5 : 0.25;
      var x = size * Math.cos(theta) * amp;
      var y = size * Math.sin(theta) * amp;
      points.push(new THREE.Vector2(x, y));
    }

    var shape = new THREE.Shape(points).extrude({
      curveSegments: 0,
      steps: 1,
      amount: size / 2,
      bevelEnabled: false
    });

    for (i = 0; i < shape.vertices.length; i++) {
      shape.vertices[i].z -= size * 0.25;
    }


    return shape;
  })();

  var diamond = (function() {
    var a = new THREE.CylinderGeometry(0, size / 2, size / 2, 4, 1);
    var b = new THREE.CylinderGeometry(size / 2, 0, size / 2, 4, 1);
    for (var i = 0; i < a.vertices.length; i++) {
      a.vertices[i].y += size * 0.25;
      b.vertices[i].y -= size * 0.25;
    }
    a.merge(b);
    return a;
  })();

  return {
    diamond: diamond,
    star: star,
    box: box
  };

};
