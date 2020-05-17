attribute vec4 position;
attribute vec2 textCoordinate;
varying lowp vec2 varyTextCoord;
uniform mat4 rotateMatrix;

void main()
{
//    varyTextCoord = vec2(textCoordinate.x,1.0-textCoordinate.y);
    varyTextCoord = textCoordinate;
    gl_Position = position;
//    gl_Position = position * rotateMatrix;
}
