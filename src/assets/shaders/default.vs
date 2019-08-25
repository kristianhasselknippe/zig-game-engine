#version 330 core

uniform mat4 projection;
uniform mat4 translation;

layout (location = 0) in vec3 pos;
layout (location = 1) in vec2 texCoord;

out vec4 color;

void main()
{
	color = vec4(texCoord, 0.0, 1.0);
	gl_Position = translation * projection * vec4(pos.xy, -300, 1.0);
}
