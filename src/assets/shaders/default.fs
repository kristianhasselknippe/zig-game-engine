#version 330 core

in vec4 color;
in vec3 worldPos;
in vec2 texCoordOut;

out vec4 FragColor;

void main()
{
  FragColor = vec4(texCoordOut.xy, 1.0, 1.0);
}
