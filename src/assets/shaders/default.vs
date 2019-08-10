#version 330 core

uniform mat4 perspective;

layout (location = 0) in vec3 aPos;

void main()
{
	gl_Position = perspective * vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
