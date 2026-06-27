shader_type canvas_item;

uniform float outline_width = 0.1;          // 轮廓宽度（相对值）
uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void vertex() {
	// 顶点向外扩大
	VERTEX = VERTEX * (1.0 + outline_width);
}

void fragment() {
	// 获取纹理实际像素尺寸
	ivec2 tex_size = textureSize(TEXTURE, 0);
	vec2 half_size = vec2(tex_size) * 0.5;   // 原始矩形的半宽高

	// 关键修正：将当前片元的坐标还原到放大前的原始坐标
	vec2 original_pos = VERTEX / (1.0 + outline_width);

	// 判断还原后的坐标是否在原始矩形内部
	if (abs(original_pos.x) < half_size.x && abs(original_pos.y) < half_size.y) {
		// 原图区域：将原始坐标映射到 UV 并采样纹理
		vec2 uv = (original_pos + half_size) / (2.0 * half_size);
		COLOR = texture(TEXTURE, uv);
	} else {
		// 扩展区域：使用自定义颜色（或其他效果）
		COLOR = outline_color;
	}
}