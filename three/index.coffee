---
---
scene = new THREE.Scene()
camera = new THREE.PerspectiveCamera( 10, window.innerWidth / window.innerHeight, 0.3, 1000 )
renderer = new THREE.WebGLRenderer()

configureRenderer = ->
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
  renderer.setSize( window.innerWidth, window.innerHeight )
configureRenderer()

document.body.appendChild( renderer.domElement )
window.addEventListener 'resize', configureRenderer, false

pointLight = new THREE.PointLight(0xFFFFFF)
pointLight.position.x = 10
pointLight.position.y = 50
pointLight.position.z = 130
scene.add pointLight

camera.position.z = 100

size = 8.0
model1 = new Paper(size)
model2 = new Paper(size)
model3 = new Paper(size)
model4 = new Paper(size)

window.models = models = [model1, model2, model3, model4]
window.skeletonHelpers = skeletonHelpers = []
for model, i in models
  model.mesh.position.x = (i - ((models.length - 1) / 2)) * 1.5 * size
  scene.add model.mesh
  scene.add new THREE.WireframeHelper(model.mesh, 0x00ff00)
  skeletonHelper = new THREE.SkeletonHelper(model.mesh)
  skeletonHelpers.push(skeletonHelper)
  skeletonHelper.material.linewidth = 2
  scene.add( skeletonHelper )

render = ->
  requestAnimationFrame( render )

  for model, i in models
    time = Date.now() / 1000.0
    model.mesh.rotation.x = (time % (2 * Math.PI)) + i * 1.5 * Math.PI / models.length
    for bone in model.mesh.skeleton.bones[1..]
      # bone.rotation.x = Math.sin( time ) * 2 / model.mesh.skeleton.bones.length
      bone.rotation.y = Math.sin( time ) * 2 * Math.PI / (model.mesh.skeleton.bones.length - 1)
      # bone.position.x = 8 - Math.abs(Math.sin( time ) * 4.8 / model.mesh.skeleton.bones.length)

  for skeletonHelper in skeletonHelpers
    skeletonHelper.update()

  renderer.render( scene, camera )

render()
