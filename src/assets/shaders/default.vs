#version 330 core

uniform mat4 perspective;
uniform mat4 rotation;

layout (location = 0) in vec3 pos;
layout (location = 1) in vec2 texCoord;

out vec4 color;

void main()
{
	color = vec4(texCoord, 1.0, 1.0);
	gl_Position = perspective * rotation * vec4(pos.x, pos.y, pos.z - 500, 1.0);
}
