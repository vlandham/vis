
var THREE = require('three.js');
var TWEEN = require('tween.js');


var Shape = function(data) {
  THREE.Mesh.call(this);
  this.data = data;
  this.position.velocity = new THREE.Vector3(Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10);
  // this.rotation.velocity = new THREE.Vector3(Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10);
  this.rotation.velocity = new THREE.Vector3(Math.random() / 100 - 1 / 200, Math.random() / 100 - 1 / 200, Math.random() / 100 - 1 / 200);

  var geometry = new THREE.BoxGeometry(Shape.width, Shape.height, Shape.depth);
  var material = new THREE.MeshBasicMaterial( { color: 0x004400 } );
  // var material = new THREE.MeshPhongMaterial( {
  //   shading: THREE.FlatShading,
  //   // emissive: "#dddddd"
  // } );
  var mesh = new THREE.Mesh(geometry, material);
  // var that = this;
  // this.tween.onUpdate(function(t) {
  //   that.position.x  = t.x;
  //   that.position.y  = t.y;
  // });

  this.add(mesh);
};

Shape.prototype = Object.create(THREE.Mesh.prototype);

Shape.prototype.float = function() {
  this.position.x += this.position.velocity.x;
  this.position.y += this.position.velocity.y;
  this.position.z += this.position.velocity.z;
  this.rotation.x += this.rotation.velocity.x;
  this.rotation.y += this.rotation.velocity.y;
  this.rotation.z += this.rotation.velocity.z;
};

Shape.prototype.update = function() {
  this.float();
  return this;
};

Shape.prototype.spin = function() {
  var target = {x: 10, y: 20, z: 0};
  // this.tween = new TWEEN.Tween(this.position).to(target, 2000);
  // this.tween.start();
  new TWEEN.Tween(this.position).to(target, 2000)
    .start();
  new TWEEN.Tween(this.rotation).to({x:0,y:0,z:0}, 2000)
    .start();
};

Shape.width = 15;
Shape.height = 15;
Shape.depth = 15;

Shape.prototype.drag = 0.125;

module.exports = Shape;
