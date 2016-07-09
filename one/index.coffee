---
---
HORIZONTAL_ASPECT = 480.0/640.0

perspectiveMatrix = null

window.onload = ->

  canvas = document.getElementById("glcanvas")

  # Initialize the GL context
  gl = null

  # Try to grab the standard context. If it fails, fallback to experimental.
  try
    gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl")

  if gl
    # Only continue if WebGL is available and working
    scene = new Scene(gl)
    setInterval((-> scene.draw()), 15)
  else
    # If we don't have a GL context, give up
    alert 'Unable to initialize WebGL. Your browser may not support it.'
    return

class Scene

  constructor: (@gl) ->
    @square = {buffer: null, vertices: null}
    @shaderProgram = null
    @vertexPositionAttribute = null
    @init()

  init: ->
    # Set clear color to black, fully opaque
    @gl.clearColor(0.0, 0.0, 0.0, 1.0)
    # Enable depth testing
    @gl.enable(@gl.DEPTH_TEST)
    # Near things obscure far things
    @gl.depthFunc(@gl.LEQUAL)
    # Clear the color as well as the depth buffer.
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

    @initShaders()
    @initBuffers()

  draw: ->
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

    perspectiveMatrix = makePerspective(45, 1 / HORIZONTAL_ASPECT, 0.1, 100.0)

    mvMatrix = mvTranslate(loadIdentity(), [-0.0, 0.0, -6.0])

    @gl.vertexAttribPointer(@vertexPositionAttribute, 3, @gl.FLOAT, false, 0, 0)
    @setMatrixUniforms(mvMatrix)
    @gl.drawArrays(@gl.TRIANGLE_STRIP, 0, 4)

  initShaders: ->
    fragmentShader = @getShader('shader-fs')
    vertexShader = @getShader('shader-vs')

    # Create the shader program
    @shaderProgram = @gl.createProgram()
    @gl.attachShader(@shaderProgram, vertexShader)
    @gl.attachShader(@shaderProgram, fragmentShader)
    @gl.linkProgram(@shaderProgram)

    # If creating the shader program failed, alert
    unless @gl.getProgramParameter(@shaderProgram, @gl.LINK_STATUS)
      alert "Unable to initialize the shader program: #{@gl.getProgramInfoLog(@shaderProgram)}"

    @gl.useProgram(@shaderProgram)

    @vertexPositionAttribute = @gl.getAttribLocation(@shaderProgram, "aVertexPosition")
    @gl.enableVertexAttribArray(@vertexPositionAttribute)

  getShader: (elementId) ->
    unless (shaderScript = document.getElementById(elementId))
      return null

    theSource = ""
    currentChild = shaderScript.firstChild

    while currentChild
      if currentChild.nodeType == currentChild.TEXT_NODE
        theSource += currentChild.textContent
      currentChild = currentChild.nextSibling

    if shaderScript.type == "x-shader/x-fragment"
      shader = @gl.createShader(@gl.FRAGMENT_SHADER)
    else if shaderScript.type == "x-shader/x-vertex"
      shader = @gl.createShader(@gl.VERTEX_SHADER)
    else
      # Unknown shader type
      return null

    # Send the source to the shader object
    @gl.shaderSource(shader, theSource)

    # Compile the shader program
    @gl.compileShader(shader)

    # See if it compiled successfully
    unless @gl.getShaderParameter(shader, @gl.COMPILE_STATUS)
      alert("An error occurred compiling the shaders: #{@gl.getShaderInfoLog(shader)}")
      return null

    return shader

  initBuffers: ->
    # Create a buffer for the square's vertices.
    @square.buffer = @gl.createBuffer()

    # Select the squareVerticesBuffer as the one to apply vertex
    # operations to from here out.
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @square.buffer);

    # Now create an array of vertices for the square. Note that the Z
    # coordinate is always 0 here.
    @square.vertices = [
      1.0,  1.0,  0.0,
      -1.0, 1.0,  0.0,
      1.0,  -1.0, 0.0,
      -1.0, -1.0, 0.0
    ]

    @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@square.vertices), @gl.STATIC_DRAW)

  setMatrixUniforms: (mvMatrix) ->
    pUniform = @gl.getUniformLocation(@shaderProgram, "uPMatrix")
    @gl.uniformMatrix4fv(pUniform, false, new Float32Array(perspectiveMatrix.flatten()))

    mvUniform = @gl.getUniformLocation(@shaderProgram, "uMVMatrix")
    @gl.uniformMatrix4fv(mvUniform, false, new Float32Array(mvMatrix.flatten()))


# Matrix utility functions

loadIdentity = ->
  Matrix.I(4)

multMatrix = (mvMatrix, m) ->
  mvMatrix.x(m)

mvTranslate = (mvMatrix, v) ->
  multMatrix(mvMatrix, Matrix.Translation($V([v[0], v[1], v[2]])).ensure4x4())
