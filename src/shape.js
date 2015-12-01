
var THREE = require('three.js');
var TWEEN = require('tween.js');
var makeShapes = require('./shapes');

var utl = require('./utility');

var shapes = makeShapes();

var Shape = function(pos, data) {
  THREE.Mesh.call(this);
  this.data = data;
  this.position.set(pos.x, pos.y, pos.z);
  this.position.velocity = new THREE.Vector3();
  // this.rotation.velocity = new THREE.Vector3(Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10);

  this.rotation.z = utl.toRad(45);
  this.rotation.y = utl.toRad(45);
  this.rotation.velocity = new THREE.Vector3();

  // var geometry = new THREE.BoxGeometry(Shape.width, Shape.height, Shape.depth);
  var geometry = shapes.makeDiamond(data.size);

  // var material = new THREE.MeshBasicMaterial( { color: 0x004400 } );
  // var material = new THREE.MeshPhongMaterial( {
    // shading: THREE.FlatShading,
    // emissive: "#dddddd"
  // } );
  // var material = new THREE.MeshLambertMaterial({color: 0xff0000});

  var material = new THREE.MeshPhongMaterial({
    color: 0xDE420B,
    shading: THREE.FlatShading
    //emissive: 0x072534
    // side: THREE.doubleside,
  });
  var mesh = new THREE.Mesh(geometry, material);
  mesh.castShadow = true;
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

Shape.prototype.float = function() {
  this.rotation.velocity = new THREE.Vector3(Math.random() / 100 - 1 / 200, Math.random() / 100 - 1 / 200, Math.random() / 100 - 1 / 200);
  this.position.velocity = new THREE.Vector3(Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10);
};

Shape.prototype.spin = function(delay) {
  delay = delay || 0;
  // var originalRotation = {x: this.rotation.x, y: this.rotation.y, z: this.rotation.z};
  var target = {x: this.rotation.x, y: this.rotation.y - utl.toRad(365), z: this.rotation.z};
  var rotationTween = new TWEEN.Tween(this.rotation)
    .to(target, 500)
    .delay(delay)
    .easing(TWEEN.Easing.Quadratic.InOut);
  // var orgTween = new TWEEN.Tween(this.rotation).to(originalRotation, 500);
  rotationTween.start();
  var scaleOriginal = {x: this.scale.x, y: this.scale.y, z: this.scale.z};
  var scaleTarget = {x: 1.4, y: 1.4, z: 1.4};
  var scaleTween = new TWEEN.Tween(this.scale)
    .to(scaleTarget, 250)
    .delay(delay)
    .easing(TWEEN.Easing.Quadratic.InOut);

  var orgScaleTween = new TWEEN.Tween(this.scale).to(scaleOriginal, 250);
  scaleTween.chain(orgScaleTween).start();
  // new TWEEN.Tween(this.rotation).to({x:0,y:0,z:0}, 2000)
  //   .start();
};

Shape.width = 15;
Shape.height = 15;
Shape.depth = 15;

Shape.prototype.drag = 0.125;

module.exports = Shape;
