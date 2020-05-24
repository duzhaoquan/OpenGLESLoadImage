varying lowp vec2 varyTextCoord;
varying lowp vec4 vertexColor;

uniform sampler2D colorMap;

void main(){

    gl_FragColor = vertexColor * 0.3 + texture2D(colorMap,varyTextCoord) * 0.7;

}
