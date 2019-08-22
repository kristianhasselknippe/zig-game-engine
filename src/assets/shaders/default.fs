#version 330 core

in vec4 color;
in vec3 vPos;

out vec4 FragColor;

void main()
{
	FragColor = vec4(color.xyz, 1.0);
}
