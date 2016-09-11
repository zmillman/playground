---
---
COLORS = {
  red: 0xCC2929
  white: 0xFFFFFF
}

window.Paper = class Paper

  # Subdivide the faces in a geometry. This updates the geometry in-place
  #
  # @param geometry [THREE.Geometry]
  # @param plane [THREE.Plane] the plane to divide on
  @crease: (geometry, plane) ->
    for face in geometry.faces by -1
      edgeAB = new THREE.Line3(geometry.vertices[face.a], geometry.vertices[face.b])
      edgeBC = new THREE.Line3(geometry.vertices[face.b], geometry.vertices[face.c])
      edgeCA = new THREE.Line3(geometry.vertices[face.c], geometry.vertices[face.a])
      intersectionAB = plane.intersectLine(edgeAB)
      intersectionBC = plane.intersectLine(edgeBC)
      intersectionCA = plane.intersectLine(edgeCA)

      if intersectionAB || intersectionBC || intersectionCA
        # TODO: Handle intersection at vertices
        intersectionAB ||= edgeAB.at(0.5)
        intersectionBC ||= edgeBC.at(0.5)
        intersectionCA ||= edgeCA.at(0.5)
        ab = geometry.vertices.push(intersectionAB) - 1
        bc = geometry.vertices.push(intersectionBC) - 1
        ca = geometry.vertices.push(intersectionCA) - 1
        # Add a new face for each outer triangle
        geometry.faces.push(new THREE.Face3(face.a, ab, ca, face.normal, face.color, face.materialIndex))
        geometry.faces.push(new THREE.Face3(face.b, bc, ab, face.normal, face.color, face.materialIndex))
        geometry.faces.push(new THREE.Face3(face.c, ca, bc, face.normal, face.color, face.materialIndex))
        # Re-use the existing face for the middle triangle
        face.a = ab
        face.b = bc
        face.c = ca

    geometry.mergeVertices()
    geometry.verticesNeedUpdate = true
    geometry.elementsNeedUpdate = true
    geometry.uvsNeedUpdate = true

  constructor: (size) ->
    @geometry = new THREE.Geometry()
    frontGeometry = new THREE.PlaneGeometry(size, size, 2)
    backGeometry = new THREE.PlaneGeometry(size, size, 2)
    @geometry.merge(frontGeometry, frontGeometry.matrix, 0)
    @geometry.merge(backGeometry, backGeometry.matrix, 1)
    @geometry.mergeVertices()
    # faceVertexUvs are never used and make creasing harder. Easier to remove them
    @geometry.faceVertexUvs = []
    @crease(new THREE.Plane(new THREE.Vector3(1.0, -0.2, 0), size * 0.25))
    @crease(new THREE.Plane(new THREE.Vector3(1.0, -0.2, 0), size * -0.25))
    # @crease(new THREE.Plane(new THREE.Vector3(0.0, -1.0, 0.0), size * -0.25))

    @material = new THREE.MultiMaterial([
      new THREE.MeshBasicMaterial({color: COLORS.red, side: THREE.FrontSide, skinning: true})
      new THREE.MeshPhongMaterial({color: COLORS.white, side: THREE.BackSide, skinning: true})
    ])

    #
    boneCount = 20
    prevBone = new THREE.Bone()
    prevBone.position.x = -0.5 * size
    bones = [prevBone]
    boneLength = size / (boneCount - 1)
    while bones.length < boneCount
      bone = new THREE.Bone()
      prevBone.add(bone)
      bone.position.x = boneLength
      bones.push(bone)
      prevBone = bone
    skeleton = new THREE.Skeleton(bones)

    # Link the corners
    for vertex, i in @geometry.vertices
      x = (vertex.x + 0.5 * size) # distance from left edge
      skinIndex = Math.floor(x / boneLength)
      skinWeight = (x % boneLength) / size
      # skinIndex = Math.floor
      if skinIndex < bones.length - 1
        @geometry.skinIndices.push new THREE.Vector4(skinIndex, skinIndex + 1, 0, 0)
        @geometry.skinWeights.push new THREE.Vector4(1 - skinWeight, skinWeight, 0, 0)
      else
        @geometry.skinIndices.push new THREE.Vector4(skinIndex, 0, 0, 0)
        @geometry.skinWeights.push new THREE.Vector4(1, 0, 0, 0)
      # skinIndex = Math.floor((vertex.x - (0.5 * size)) / size) * boneCount)
        #
        # if  <= bone.position.x
        #     1 - ((vertex.x - topMiddle.position.x) / size)
        #     (vertex.x - bone.position.x) / size
        #     0, 0
        #   )
        # else
        #   @geometry.skinIndices[i] = new THREE.Vector4(1, 2, 0, 0)
        #   @geometry.skinWeights[i] = new THREE.Vector4(
        #     (vertex.x - topMiddle.position.x) / size
        #     1 - ((vertex.x - topRight.position.x) / size)
        #     0, 0
        #   )

    @mesh = new THREE.SkinnedMesh(@geometry, @material)
    @mesh.add(skeleton.bones[0])
    @mesh.bind(skeleton)

  crease: (plane) ->
    Paper.crease(@geometry, plane)
