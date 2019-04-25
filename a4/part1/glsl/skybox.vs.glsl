varying vec3 coord;


void main() {

	coord = position;
	gl_Position = projectionMatrix * viewMatrix * vec4((position + cameraPosition), 1.0);
}