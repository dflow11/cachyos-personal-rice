// nullgrid CRT: scanlines + slight vignette. Subtle enough to keep 12px text readable.
precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 c = texture2D(tex, v_texcoord);
    float line = mod(gl_FragCoord.y, 2.0) < 1.0 ? 0.88 : 1.0;   // every other physical row
    vec2 d = v_texcoord - 0.5;
    float vignette = 1.0 - dot(d, d) * 0.25;
    gl_FragColor = vec4(c.rgb * line * vignette, c.a);
}
