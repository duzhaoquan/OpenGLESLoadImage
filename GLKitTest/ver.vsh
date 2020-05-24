attribute vec4 position;
attribute vec4 verColor;
attribute vec2 textCoordinate;
uniform mat4 matrix;
varying lowp vec2 varyTextCoord;
varying lowp vec4 vertexColor;

void main(){


    vertexColor = verColor;
  varyTextCoord = textCoordinate;
    gl_Position = matrix * position;


}
