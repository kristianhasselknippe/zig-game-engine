#version 330 core

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

layout (location = 0) in vec3 pos;
layout (location = 1) in vec2 texCoord;

out vec4 color;
out vec2 texCoordOut;
out vec3 worldPos;

void main()
{
    color = vec4(texCoord.x, texCoord.y, 0.0, 1.0);
    texCoordOut = texCoord;
    gl_Position = projection * view * model * vec4(pos.x, pos.y, pos.z, 1.0);
    worldPos = gl_Position.xyz;
}
