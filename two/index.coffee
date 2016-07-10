---
---
scene = new THREE.Scene()
camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )

renderer = new THREE.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )
document.body.appendChild( renderer.domElement )

cube = new THREE.Mesh(
  new THREE.BoxGeometry( 1, 1, 1 )
  new THREE.MeshLambertMaterial({ color: 0xCC2929 })
)
scene.add cube

sphere = new THREE.Mesh(
  new THREE.SphereGeometry(1, 16, 16)
  new THREE.MeshLambertMaterial({color: 0xF2F2EB})
)
sphere.position.x = 2
scene.add sphere

pointLight = new THREE.PointLight(0xFFFFFF)
pointLight.position.x = 10
pointLight.position.y = 50
pointLight.position.z = 130
scene.add pointLight

camera.position.z = 5

render = ->
  requestAnimationFrame( render )

  cube.rotation.x += 0.1
  cube.rotation.y += 0.1

  renderer.render( scene, camera )

render()
