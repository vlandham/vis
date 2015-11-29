
var d3 = require('d3');
var THREE = require('three.js');
var TWEEN = require('tween.js');


var Pic = function(data) {
  THREE.Mesh.call(this);
  this.data = data;
  this.position.velocity = new THREE.Vector3(Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10);
  // this.rotation.velocity = new THREE.Vector3(Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10);
  this.rotation.velocity = new THREE.Vector3(Math.random() / 100 - 1 / 200, Math.random() / 100 - 1 / 200, Math.random() / 100 - 1 / 200);

  var geometry = new THREE.BoxGeometry(Pic.width, Pic.height, Pic.depth);
  // var material = new THREE.MeshBasicMaterial( { color: 0x004400 } );
  var material = new THREE.MeshPhongMaterial( {
    map: THREE.ImageUtils.loadTexture(data.img_url),
    // shading: THREE.FlatShading,
    // emissive: "#dddddd"
  } );
  var mesh = new THREE.Mesh(geometry, material);
  // var that = this;
  // this.tween.onUpdate(function(t) {
  //   that.position.x  = t.x;
  //   that.position.y  = t.y;
  // });

  this.add(mesh);
};

Pic.prototype = Object.create(THREE.Mesh.prototype);

Pic.prototype.float = function() {
  this.position.x += this.position.velocity.x;
  this.position.y += this.position.velocity.y;
  this.position.z += this.position.velocity.z;
  this.rotation.x += this.rotation.velocity.x;
  this.rotation.y += this.rotation.velocity.y;
  this.rotation.z += this.rotation.velocity.z;
};

Pic.prototype.update = function() {
  this.float();
  return this;
};

Pic.prototype.startGrid = function() {
  var target = {x: 10, y: 20, z: 0};
  // this.tween = new TWEEN.Tween(this.position).to(target, 2000);
  // this.tween.start();
  new TWEEN.Tween(this.position).to(target, 2000)
    .start();
  new TWEEN.Tween(this.rotation).to({x:0,y:0,z:0}, 2000)
    .start();
};

Pic.width = 15;
Pic.height = 15;
Pic.depth = 3;

Pic.prototype.drag = 0.125;


module.exports = function createGrid() {
  var width = 20;
  var height = 20;

  var data = [];
  var pics = [];
  var dispatch;

  function prepareData(rdata) {
    rdata.forEach(function(d) {
      d.img_url = "data/img/im2.png";
    });

    return rdata;
  }

  var chart = function(scene, rdata) {
    dispatch.addEventListener('grid', gridup);
    data = prepareData(rdata);
    data.forEach(function(i) {
      var pic = new Pic(i);
      pics.push(pic);
      scene.add(pic);
    });
  };

  chart.update = function() {
    pics.forEach(function(pic){
      pic.update();
    });
    TWEEN.update();
  };

  function gridup() {
    pics.forEach(function(pic){
      pic.startGrid();
    });
  }

  chart.width = function(_) {
    if (!arguments.length) {
      return width;
    }
    width = _;
    return chart;
  };

  chart.height = function(_) {
    if (!arguments.length) {
      return height;
    }
    width = _;
    return chart;
  };

  chart.dispatch = function(_) {
    if (!arguments.length) {
      return dispatch;
    }
    dispatch = _;
    return chart;
  };

  return chart;
};
