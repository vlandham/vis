
/*jshint -W058 */

var THREE = require('three.js');
// require('./TrackballControls');
require('./OrbitControls');
require('./post/EffectComposer');
require('./post/RenderPass');
require('./post/DotScreenShader');
require('./post/RGBShiftShader');

var createSpin = require('./spin');

module.exports = function() {

  var s = {};

  // var OFFSCREEN = new THREE.Vector2(-2, -2);
  // var clock = new THREE.Clock;
  // var mouse = (new THREE.Vector2).copy(OFFSCREEN);
  // var dispatch = new THREE.EventDispatcher();
  // mouse.stop = debounce(function() {
  //   mouse.moving = false
  // }, 1e3);
  var width = window.innerWidth;
  var height = window.innerHeight;
  var scene = new THREE.Scene();


  var clock = new THREE.Clock();

  var dispatch;

  var spin = createSpin()
    .dispatch(dispatch)
    .width(width)
    .height(height);

  // var camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 );
  // var raycaster = new THREE.Raycaster;
  // var camera = new THREE.PerspectiveCamera(60);
  // camera.near = 0.1;
  // camera.far = 250;

  var aspect = window.innerWidth / window.innerHeight;
  var d = 40;
  var camera = new THREE.OrthographicCamera( - d * aspect, d * aspect, d, - d, 1, 1000 );

  camera.position.set( 40, 40, 40 ); // all components equal

  var controls;

  // var light = new THREE.DirectionalLight(0xffffff);
  // var backdrop = new THREE.Plane(new THREE.Vector3(0, 0, 1));


  var renderer = new THREE.WebGLRenderer();
  renderer.shadowMap.enabled = true;
  // var composer;
  renderer.setSize(width,height);

  var el = document.getElementById("canvas");
  el.appendChild( renderer.domElement );

  s.setup = function setup(data) {

    spin.dispatch(dispatch);
    // camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 100 );
    // camera.position.z = 500;


    window.addEventListener('resize', resize);
    // window.addEventListener("mousemove", mousemove, false);
    // window.addEventListener("mouseout", mouseout, false);
    var light = new THREE.DirectionalLight( 0xffffff, 1.0 );
    light.position.set( 0, 1, 0 );
    light.castShadow = true;
    scene.add( light );
    //
    // light = new THREE.DirectionalLight( 0xffffff, 1.0 );
    // light.position.set( 1, 0, 0 );
    // scene.add( light );
    //
    light = new THREE.DirectionalLight( 0xffffff, 1.0 );
    light.castShadow = true;
    light.shadowDarkness = 0.5;
    light.shadowCameraVisible = true;
    light.shadowCameraRight=30
    light.shadowCameraLeft=-30
    light.shadowCameraTop = 30;
    light.shadowCameraBottom = -30;
    light.position.set( 0, 0, 1 );
    scene.add( light );

    var geometry = new THREE.PlaneGeometry( 200, 30, 1 );
    var material = new THREE.MeshBasicMaterial( {color: 0xffffff, side: THREE.DoubleSide} );
    var plane = new THREE.Mesh( geometry, material );
    plane.position.setZ(-15);
    scene.add( plane );
    //
    // light = new THREE.DirectionalLight( 0xffffff, 1.0 );
    // light.position.set(1, -1, 0 );
    // scene.add( light );

    // light = new THREE.AmbientLight( 0x222222 );
    // scene.add( light );
    // light.position.set(0, 1, 1).normalize();
    // var ambientLight = new THREE.AmbientLight( 0x000000 );
    // scene.add(ambientLight);
    // var lights = [];
    // lights[0] = new THREE.PointLight( 0xffffff, 1, 0 );
    // lights[1] = new THREE.PointLight( 0xffffff, 1, 0 );
    // lights[2] = new THREE.PointLight( 0xffffff, 1, 0 );
    //
    // lights[0].position.set( 0, 200, 0 );
    // lights[1].position.set( 100, 200, 100 );
    // lights[2].position.set( -100, -200, -100 );
    // //
    // scene.add( lights[0] );
    // scene.add( lights[1] );
    // scene.add( lights[2] );
    //
    // var sphereSize = 1;
    // var pointLightHelper = new THREE.PointLightHelper( lights[0], sphereSize );
    // scene.add( pointLightHelper );

    renderer.setClearColor(16777215);

    camera.position.z = camera.far / 2;
    camera.zoom = 0.2;
    camera.lookAt(new THREE.Vector3);

    // composer = new THREE.EffectComposer( renderer );
    //
    // composer.addPass( new THREE.RenderPass( scene, camera ) );
    // var effect = new THREE.ShaderPass( THREE.DotScreenShader );
    // effect.uniforms[ 'scale' ].value = 4;
    // composer.addPass( effect );
    // effect.renderToScreen = true;
    // var effect = new THREE.ShaderPass( THREE.RGBShiftShader );
    // effect.uniforms[ 'amount' ].value = 0.0015;
    // effect.renderToScreen = true;
    // composer.addPass( effect );



    controls = new THREE.OrbitControls( camera, renderer.domElement  );
    controls.target.set(0, 0, 0);

    // controls.rotateSpeed = 1.0;
    // controls.zoomSpeed = 1.2;
    // controls.panSpeed = 0.8;

    // controls.noZoom = false;
    // controls.noPan = false;

    // controls.staticMoving = true;
    // controls.dynamicDampingFactor = 0.3;

    // controls.keys = [ 65, 83, 68 ];

    // controls.addEventListener( 'change', loop );

    resize();
    // camera.position.z = 5;

    // var amount = 10;
    //
    // for (var i = 0; i < amount; i++) {
    //     var routine = new Routine;
    //     var h, w, d;
    //     if (i < 6) {
    //         h = camera.far / 2;
    //         w = camera.far / 2;
    //         d = camera.far / 16;
    //         routine.position.set(Math.random() * h - h / 2, Math.random() * w - w / 2, Math.random() * d - d / 2);
    //     } else {
    //         h = camera.far;
    //         w = camera.far;
    //         d = camera.far;
    //         routine.position.set(camera.position.x + Math.random() * h - h / 2, camera.position.y + Math.random() * w - w / 2, camera.position.z + Math.random() * d - d / 2);
    //     }
    //     routine.position.velocity = new THREE.Vector3(Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10, Math.random() / 5 - 1 / 10);
    //     routine.rotation.destination = new THREE.Object3D;
    //     routine.rotation.velocity = new THREE.Vector3(Math.random() / 100 - 1 / 200, Math.random() / 100 - 1 / 200, Math.random() / 100 - 1 / 200);
    //     routine.scale.set(3, 3, 3);
    //     routine.reconfigure(true);
    //     routines.push(routine);
    //     scene.add(routine);
    // }

    loop();
  };

  function loop() {
    var delta = clock.getDelta();
    requestAnimationFrame(loop);


    spin.update();

    // raycaster.setFromCamera(mouse, camera);
    var dist = camera.far / 2;
    dist *= dist;
    // for (var i = 0; i < routines.length; i++) {
    //     var routine = routines[i];
    //     routine.rotation.x += routine.rotation.velocity.x;
    //     routine.rotation.y += routine.rotation.velocity.y;
    //     routine.rotation.z += routine.rotation.velocity.z;
    //     routine.position.x += routine.position.velocity.x;
    //     routine.position.y += routine.position.velocity.y;
    //     routine.position.z += routine.position.velocity.z;
    //     if (routine.position.lengthSq() > dist) {
    //         routine.position.velocity.multiplyScalar(-1);
    //     }
    //     routine.update();
    // }
    // if (clock.getElapsedTime() > 0.5 && !mouse.moving) {
    //     routines[Math.floor(Math.random() * routines.length)].reconfigure();
    //     clock.start();
    //     clock.elapsedTime = 0;
    // }


    // if (mouse.moving) {
    //     var intersections = raycaster.intersectObjects(routines, true);
    //     if (intersections.length > 0) {
    //         if (!intersected || intersected && intersected.object.routine !== intersections[0].object.routine) {
    //             intersected = intersections[0];
    //             intersected.object.routine.reconfigure()
    //         }
    //     } else {
    //         intersected = null
    //     }
    // }

    controls.update(delta);
    renderer.render(scene, camera);
    // composer.render();
}

  function resize() {
    width = window.innerWidth;
    height = window.innerHeight;
    renderer.setSize(width, height);
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
    // controls.handleResize();
  }

  // function mousemove(e) {
  //   mouse.x = 2 * e.clientX / width - 1;
  //   mouse.y = -2 * e.clientY / height + 1;
  //   mouse.moving = true;
  //   // mouse.stop();
  // }
  //
  // function mouseout(e) {
  //   mouse.copy(OFFSCREEN);
  // }
  //
  s.data = function (d) {
    spin(scene, d);
    return s;
  };

  s.dispatch = function(_) {
  if (!arguments.length) {
    return dispatch;
  }
  dispatch = _;
  return s;
};


  return s;
};
