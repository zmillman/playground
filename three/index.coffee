---
---
scene = new THREE.Scene()
camera = new THREE.PerspectiveCamera( 10, window.innerWidth / window.innerHeight, 0.3, 1000 )

renderer = new THREE.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )
document.body.appendChild( renderer.domElement )

pointLight = new THREE.PointLight(0xFFFFFF)
pointLight.position.x = 10
pointLight.position.y = 50
pointLight.position.z = 130
scene.add pointLight

camera.position.z = 100

size = 8.0
square1 = new THREE.PlaneGeometry(size, size, 1)
square2 = Paper.crease(square1, new THREE.Plane(new THREE.Vector3(1.0, 0, 0), size * 0.25))
square3 = Paper.crease(square2, new THREE.Plane(new THREE.Vector3(1.0, 0, 0), size * 0.1))
square4 = Paper.crease(square3, new THREE.Plane(new THREE.Vector3(1.0, 0, 0), size * -0.25))
# square = Paper.crease(square, new THREE.Plane(new THREE.Vector3(-0.3, -0.3, 0), 0.5))
# square = Paper.crease(square, new THREE.Plane(new THREE.Vector3(-0.3, 0.3, 0), 0.5))

models = (new Paper(square) for square in [square1, square2, square3, square4])
for model, i in models
  for object in model.objects
    object.position.x = (i - ((models.length - 1) / 2)) * 1.5 * size
    scene.add object
    wireframe = new THREE.WireframeHelper(object, 0x00ff00)
    scene.add wireframe

render = ->
  # requestAnimationFrame( render )

  # for model in models
  #   for object in model.objects
  #     # object.rotation.x += 0.02
  #     object.rotation.y += 0.02

  renderer.render( scene, camera )

render()
