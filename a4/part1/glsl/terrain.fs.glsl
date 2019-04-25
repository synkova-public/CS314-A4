//VARYING VAR
varying vec3 Normal_V;
varying vec3 Position_V;
varying vec4 PositionFromLight_V;
varying vec2 Texcoord_V;
varying vec4 shadowCoord;

//UNIFORM VAR
uniform vec3 lightColorUniform;
uniform vec3 ambientColorUniform;
uniform vec3 lightDirectionUniform;

uniform float kAmbientUniform;
uniform float kDiffuseUniform;
uniform float kSpecularUniform;

uniform float shininessUniform;

uniform sampler2D colorMap;
uniform sampler2D normalMap;
uniform sampler2D aoMap;
uniform sampler2D shadowMap;

// PART D)
// Use this instead of directly sampling the shadowmap, as the float
// value is packed into 4 bytes as WebGL 1.0 (OpenGL ES 2.0) doesn't
// support floating point bufffers for the packing see depth.fs.glsl
float getShadowMapDepth(vec2 texCoord)
{
	vec4 v = texture2D(shadowMap, texCoord);
	const vec4 bitShift = vec4(1.0, 1.0/256.0, 1.0/(256.0 * 256.0), 1.0/(256.0*256.0*256.0));
	return dot(v, bitShift);
}

void main() {
	// PART B) TANGENT SPACE NORMAL
	vec3 N_1 = normalize(texture2D(normalMap, Texcoord_V).xyz * 2.0 - 1.0);

	vec3 up = vec3(0.0, 1.0, 0.0);

	vec4 shadowCoord_w_div = shadowCoord / shadowCoord.w;

	float depth = getShadowMapDepth(shadowCoord_w_div.xy);



	// PRE-CALCS
	vec3 N = normalize(Normal_V);
	vec3 L = normalize(vec3(viewMatrix * vec4(lightDirectionUniform, 0.0)));
	vec3 V = normalize(-Position_V);
	vec3 H = normalize(V + L);


	vec3 T = normalize(cross(N, up));
	vec3 B = normalize(cross(N, T));

	mat3 TBN = mat3(T, B, N);

	vec3 L_tangent = normalize(L * TBN);
	vec3 V_tangent = normalize(V * TBN);
	vec3 H_tangent = normalize(V_tangent + L_tangent);


    
	// AMBIENT
	vec3 light_AMB =  texture2D(aoMap, Texcoord_V).xyz * kAmbientUniform;

	// DIFFUSE
	vec3 diffuse = kDiffuseUniform * texture2D(colorMap, Texcoord_V).xyz;
	vec3 light_DFF = diffuse * max(0.0, dot(N_1, L_tangent));

	// SPECULAR
	vec3 specular = kSpecularUniform * lightColorUniform;
	vec3 light_SPC = specular * pow(max(0.0, dot(H_tangent, N_1)), shininessUniform);

	// TOTAL
	vec3 TOTAL = light_AMB + light_DFF  + light_SPC;

	// SHADOW
	// Fill in attenuation for shadow here


	float bias = 0.00001;
	float shadow = 1.0;
	shadow = depth < shadowCoord_w_div.z+bias ? 0.4 : 1.0 ;
	
	gl_FragColor = shadow * vec4(TOTAL, 1.0);
}
