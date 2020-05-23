#version 330 core

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

layout (location = 0) in vec3 pos;
//layout (location = 1) in vec3 norm;
//layout (location = 2) in vec2 texCoord;

out vec4 color;

void main()
{
	color = vec4(1.0, 0.0, 0.0, 1.0);
	//mat4 mvp = projection * view * model;
	gl_Position =  /*mvp */ view * vec4(pos.x, pos.y, pos.z, 1.0);
}
