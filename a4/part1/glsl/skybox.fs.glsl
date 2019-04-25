// UNIFORMS
uniform samplerCube skybox;
varying vec3 coord;

void main() {
	gl_FragColor = textureCube(skybox, coord);
}