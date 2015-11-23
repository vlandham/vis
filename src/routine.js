

var THREE = require('three.js');
var shapes = require('./shapes')();

var emissive = ["rgb(100, 75, 35)", "rgb(65, 41, 17)", "rgb(65, 41, 17)", "rgb(37, 37, 37)"];
var colors = ["rgb(200, 143, 72)", "rgb(132, 82, 34)", "rgb(254, 228, 162)", "rgb(75, 75, 75)"];
colors.index = 0;
var Component = function() {
  THREE.Mesh.call(this);
  var material = new THREE.MeshPhongMaterial({
    shading: THREE.FlatShading,
    emissive: emissive[colors.index],
    shininess: 0,
    color: colors[colors.index]
  });

  colors.index = (colors.index + 1) % colors.length;
  for (var i = 0; i < Component.Geometries.length; i++) {
    var geometry = Component.Geometries[i];
    // console.log(geometry);
    var mesh = new THREE.Mesh(geometry, material);
    mesh.genus = Component.Genus;
    this.add(mesh);
  }
  this.state = {
    rotation: new THREE.Vector3(0, 0, 0),
    scale: new THREE.Vector3(1, 1, 1)
  };
};
Component.Geometries = [shapes.box, shapes.star, shapes.diamond];
Component.Genus = {
  0: "box",
  1: "star",
  2: "diamond"
};
Component.Limits = {
  box: {
    scale: 0.5
  },
  star: {
    scale: 1
  },
  diamond: {
    scale: 1
  }
};
Component.Threshold = 1e-4;
Component.prototype = Object.create(THREE.Mesh.prototype);
Component.prototype.index = 0;
Component.prototype.length = 3;
Component.prototype.drag = 0.125;
Component.prototype.reset = function() {
  for (var i = 0; i < this.children.length; i++) {
    var object = this.children[i];
    object.rotation.set(0, 0, 0);
    object.scale.set(Component.Threshold, Component.Threshold, Component.Threshold);
  }
  this.children[this.index].rotation.set(0, 0, 0);
  this.children[this.index].scale.set(Component.Threshold, Component.Threshold, Component.Threshold);
  return this;
};
Component.prototype.update = function() {
  // var current = this.children[this.index];
  for (var i = 0; i < this.children.length; i++) {
    var object = this.children[i];
    if (i === this.index) {
      object.rotation.x += (this.state.rotation.x - object.rotation.x) * this.drag;
      object.rotation.y += (this.state.rotation.y - object.rotation.y) * this.drag;
      object.rotation.z += (this.state.rotation.z - object.rotation.z) * this.drag;
      object.scale.x += (this.state.scale.x - object.scale.x) * this.drag;
      object.scale.y += (this.state.scale.y - object.scale.y) * this.drag;
      object.scale.z += (this.state.scale.z - object.scale.z) * this.drag;
      continue;
    }
    if (object.rotation.x > Component.Threshold) {
      object.rotation.x -= object.rotation.x * this.drag;
    }
    if (object.rotation.y > Component.Threshold) {
      object.rotation.y -= object.rotation.y * this.drag;
    }
    if (object.rotation.z > Component.Threshold) {
      object.rotation.z -= object.rotation.z * this.drag;
    }
    if (object.scale.x > Component.Threshold) {
      object.scale.x -= object.scale.x * this.drag;
    }
    if (object.scale.x > Component.Threshold) {
      object.scale.y -= object.scale.y * this.drag;
    }
    if (object.scale.x > Component.Threshold) {
      object.scale.z -= object.scale.z * this.drag;
    }
    object.visible = object.scale.x > 0 && object.scale.y > 0 && object.scale.z > 0;
  }
  return this;
};

Component.prototype.reconfigure = function(base, index) {
  this.index = index !== undefined ? index : Math.floor(Math.random() * this.children.length);
  var genus = Component.Genus[this.index];
  var limit = Component.Limits[genus];
  var xr, yr, zr;
  xr = Math.sin(Math.random() * Math.PI) + base;
  yr = Math.sin(Math.random() * Math.PI) + base;
  zr = Math.random() * 0.5 + base;
  this.state.scale.x = xr * limit.scale;
  this.state.scale.y = yr * limit.scale;
  this.state.scale.z = zr * limit.scale;
  this.state.rotation.x += Math.floor(Math.random() * 4) * Math.PI / 2 - Math.PI;
  this.state.rotation.y += Math.floor(Math.random() * 4) * Math.PI / 2 - Math.PI;
  this.state.rotation.z += Math.floor(Math.random() * 4) * Math.PI / 2 - Math.PI;
  return this;
};

var Routine = THREE.Routine = function() {
  THREE.Object3D.call(this);
  for (var i = 0; i < this.length; i++) {
    var component = new Component(this);
    this.add(component);
  }
};

Routine.Component = Component;
Routine.prototype = Object.create(THREE.Object3D.prototype);
Routine.prototype.length = 5;
Routine.prototype.update = function() {
  for (var i = 0; i < this.children.length; i++) {
    this.children[i].update();
  }
  return this;
};

Routine.prototype.reconfigure = function(forced) {
  var base = 0.0625,
  length = this.children.length;
  for (var i = 0; i < length; i++) {
    var component = this.children[i];
    component.reconfigure(base + Math.random() * 0.1 - 0.05, i < 1 ? Math.floor(Math.random() * Component.Geometries.length) : 0);
    if (!!forced) {
      component.reset();
    }
  }
  return this;
};

module.exports = Routine;
