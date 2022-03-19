#version 430

#include "../fragments/fs_common_inputs.glsl"

// We output a single color to the color buffer
layout(location = 0) out vec4 frag_color;

////////////////////////////////////////////////////////////////
/////////////// Instance Level Uniforms ////////////////////////
////////////////////////////////////////////////////////////////

// Represents a collection of attributes that would define a material
// For instance, you can think of this like material settings in 
// Unity
struct Material {
	sampler2D Diffuse;
	float     Shininess;
	sampler1D ToonLUT;
};
// Create a uniform for the material
uniform Material u_Material;


//Toon 
//uniform sampler1D s_ToonTerm;


////////////////////////////////////////////////////////////////
///////////// Application Level Uniforms ///////////////////////
////////////////////////////////////////////////////////////////

#include "../fragments/multiple_point_lights.glsl"

////////////////////////////////////////////////////////////////
/////////////// Frame Level Uniforms ///////////////////////////
////////////////////////////////////////////////////////////////

#include "../fragments/frame_uniforms.glsl"
#include "../fragments/color_correction.glsl"

// https://learnopengl.com/Advanced-Lighting/Advanced-Lighting
void main() {
	// Normalize our input normal
	vec3 normal = normalize(inNormal);

	// Use the lighting calculation that we included from our partial file
	vec3 lightAccumulation = CalcAllLightContribution(inWorldPos, normal, u_CamPos.xyz, u_Material.Shininess);

	// Get the albedo from the diffuse / albedo map
	vec4 textureColor = texture(u_Material.Diffuse, inUV);

	// combine for the final result
	vec3 result = lightAccumulation  * inColor * textureColor.rgb;

	 if ( IsFlagSet(FLAG_DISABLE_ALL) )
	 {
	frag_color = vec4(ColorCorrect(textureColor.rgb), textureColor.a);
	}

	else if ( IsFlagSet(FLAG_ENABLE_AMBIENT))
	{
	frag_color = vec4(ColorCorrect(textureColor.rgb * CalcAmbient()), textureColor.a);
	}

	else if ( IsFlagSet(FLAG_ENABLE_SPECULAR))
	{
	frag_color = vec4(ColorCorrect ( CalcSpecular( inWorldPos, normal, u_CamPos.xyz, u_Material.Shininess) * textureColor.rgb), textureColor.a );
	}

	else if ( IsFlagSet(FLAG_ENABLE_ALL))
	{

	float gray = (result.r + result.g + result.b) / 3.0;

	vec3 grayScale = vec3(gray, gray, gray);

	frag_color = vec4(grayScale, textureColor.a);

	//Credits to TM_ on StackOverflow
	//https://stackoverflow.com/questions/31729326/glsl-grayscale-shader-removes-transparency 


	}

	
	else if ( IsFlagSet(FLAG_DIFFUSE_RAMP))
	{

		vec3 diff = CalcDiffuse(inWorldPos, normal, u_CamPos.xyz)  * textureColor.rgb;


		result.r = texture(u_Material.ToonLUT, diff.r).r;
		result.g = texture(u_Material.ToonLUT, diff.g).g;
		result.b = texture(u_Material.ToonLUT, diff.b).b;

		frag_color = vec4(ColorCorrect(result), textureColor.a);
	}
	
	else if ( IsFlagSet(FLAG_SPECULAR_RAMP))
	{

	vec3 spec = CalcSpecular( inWorldPos, normal, u_CamPos.xyz, u_Material.Shininess) * textureColor.rgb;

		result.r = texture(u_Material.ToonLUT, spec.r).r;
		result.g = texture(u_Material.ToonLUT, spec.g).g;
		result.b = texture(u_Material.ToonLUT, spec.b).b;

	frag_color = vec4(ColorCorrect(result), textureColor.a);

	}


	else{
	frag_color = vec4(ColorCorrect(result), textureColor.a);
	}
}