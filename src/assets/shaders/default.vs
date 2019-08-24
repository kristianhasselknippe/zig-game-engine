#version 330 core

uniform mat4 mvp;

layout (location = 0) in vec3 pos;
layout (location = 1) in vec2 texCoord;

out vec4 color;

void main()
{
	color = vec4(texCoord, 0.0, 1.0);
	gl_Position = mvp * vec4(pos.x, pos.y, pos.z, 1.0);
}
