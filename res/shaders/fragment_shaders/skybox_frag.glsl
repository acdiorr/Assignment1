#version 440

layout(location = 0) in vec3 inNormal;

uniform layout (binding=0) samplerCube s_Environment;

out vec4 frag_color;

#include "../fragments/color_correction.glsl"

void main() {
    vec3 norm = normalize(inNormal);

    frag_color = vec4(ColorCorrect(texture(s_Environment, norm).rgb), 1.0);

    if ( IsFlagSet(FLAG_ENABLE_ALL))
	{

	float gray = (texture(s_Environment, norm).r + texture(s_Environment, norm).g + texture(s_Environment, norm).b) / 3.0;

	vec3 grayScale = vec3(gray, gray, gray);

	frag_color = vec4(grayScale, 1.0);

	}

}