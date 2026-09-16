// nullgrid night: warm shift, blue cut. Roughly 3400K.
precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 c = texture2D(tex, v_texcoord);
    gl_FragColor = vec4(c.r * 1.0, c.g * 0.86, c.b * 0.66, c.a);
}
