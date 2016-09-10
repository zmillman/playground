---
---
COLORS = {
  red: 0xCC2929
  white: 0xFFFFFF
}

window.Paper = class Paper

  # Subdivide the faces in a geometry
  #
  # @param geometry [THREE.Geometry]
  # @param plane [THREE.Plane] the plane to divide on
  @crease: (geometry, plane) ->
    newGeometry = new THREE.Geometry()
    for face in geometry.faces
      edgeAB = new THREE.Line3(geometry.vertices[face.a], geometry.vertices[face.b])
      edgeBC = new THREE.Line3(geometry.vertices[face.b], geometry.vertices[face.c])
      edgeCA = new THREE.Line3(geometry.vertices[face.c], geometry.vertices[face.a])
      intersectionAB = plane.intersectLine(edgeAB)
      intersectionBC = plane.intersectLine(edgeBC)
      intersectionCA = plane.intersectLine(edgeCA)

      newA = newGeometry.vertices.push(geometry.vertices[face.a].clone()) - 1
      newB = newGeometry.vertices.push(geometry.vertices[face.b].clone()) - 1
      newC = newGeometry.vertices.push(geometry.vertices[face.c].clone()) - 1
      if intersectionAB || intersectionBC || intersectionCA
        # TODO: Handle intersection at edge endpoints
        intersectionAB ||= edgeAB.at(0.5)
        intersectionBC ||= edgeBC.at(0.5)
        intersectionCA ||= edgeCA.at(0.5)
        newAB = newGeometry.vertices.push(intersectionAB) - 1
        newBC = newGeometry.vertices.push(intersectionBC) - 1
        newCA = newGeometry.vertices.push(intersectionCA) - 1
        newGeometry.faces.push(new THREE.Face3(newA, newAB, newCA))
        newGeometry.faces.push(new THREE.Face3(newB, newBC, newAB))
        newGeometry.faces.push(new THREE.Face3(newC, newCA, newBC))
        newGeometry.faces.push(new THREE.Face3(newAB, newBC, newCA))
      else
        newGeometry.faces.push(new THREE.Face3(newA, newB, newC))

    newGeometry.mergeVertices()
    newGeometry.computeBoundingSphere()
    return newGeometry

  constructor: (baseGeometry) ->
    geometry = new THREE.Geometry()
    frontGeometry = baseGeometry.clone()
    backGeometry = baseGeometry.clone()
    geometry.merge(frontGeometry, frontGeometry.matrix, 0)
    geometry.merge(backGeometry, backGeometry.matrix, 1)
    geometry.mergeVertices()

    material = new THREE.MultiMaterial([
      new THREE.MeshBasicMaterial({color: COLORS.red, side: THREE.FrontSide})
      new THREE.MeshBasicMaterial({color: COLORS.white, side: THREE.BackSide})
    ])

    @objects = [
      new THREE.Mesh(geometry, material)
      # new THREE.Mesh(geometry, material)
    ]
