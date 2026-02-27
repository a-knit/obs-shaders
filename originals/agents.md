# Agent Guide: Converting `originals` Shaders to `src`

This file defines how coding agents should convert legacy/original `.glsl` shaders in `originals/` into OBS-ready shaders in `src/`.

## Goal

Given an original shader (usually Shadertoy-style), produce a functionally equivalent OBS shader in `src/` using this repo's conventions.

## Known example mappings

- `originals/color_shake.glsl` -> `src/color_shake.glsl`
- `originals/glitch_2.glsl` -> `src/glitch_2.glsl`
- `originals/quake.glsl` -> `src/quake.glsl`
- `originals/rgb_rotate.glsl` -> `src/rgb_rotate.glsl`
- `originals/sobel_filter_original.glsl` -> `src/sobel_filter.glsl`
- `originals/cartoon/buffer.glsl` + `originals/cartoon/image.glsl` -> `src/cartoon.glsl`

Use these as reference patterns before introducing new conversion styles.

## Core conversion rules

1. Keep `mainImage(out vec4 fragColor, in vec2 fragCoord)` as the effect body.
2. Replace Shadertoy inputs with OBS equivalents:
- `iTime` -> `builtin_elapsed_time`
- `texture(iChannel0, uv)` -> `image.Sample(builtin_texture_sampler, uv)`
- `iResolution.xy` -> usually `builtin_uv_size.xy`
3. UV convention in this repo for most converted files:
- If original has `vec2 uv = fragCoord.xy / iResolution.xy;`, convert to `vec2 uv = fragCoord.xy;`
- In `render(float2 uv)`, pass normalized UV to `mainImage(output, uv)`
4. Add a `render` entrypoint when missing:

```glsl
float4 render(float2 uv) {
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}
```

5. Preserve shader logic and constants unless compatibility requires changes.
6. Keep source attribution comments when available, e.g. `// original - <url>`.
7. Move global float state into `mainImage` locals when converting.
- Prefer local `float` declarations inside `mainImage` rather than mutable/global shader-scope floats.
- Example: see `originals/rainbow_melt.glsl` -> `src/rainbow_melt.glsl`, where globals like `edgeWidth`, `caAmountBase`, `glAmount`, `glStrength`, and `colorOffsetStrength` are defined locally in `mainImage`, and derived values like `caAmount` are computed there.

## Pixel-size and resolution-sensitive code

When original code uses pixel offsets like `vec2(1,1) / iResolution.xy`, convert to:

```glsl
vec2 pixelSize = vec2(1,1) / builtin_uv_size.xy;
```

This is required for kernels/edge filters (see `sobel_filter` and `cartoon`).

## Multi-pass to single-pass rule (`originals/cartoon`)

`originals/cartoon` includes multiple files from a multi-pass setup.

- Treat `image.glsl` as the final pass logic.
- Pull only required helpers/constants from other pass files (for cartoon, `buffer.glsl` is not copied directly).
- Merge into one OBS shader file (`src/cartoon.glsl`) that samples only from `image` via `builtin_texture_sampler`.

For the existing cartoon conversion, the final shader keeps:
- `posterize(...)` helper from `image.glsl`
- edge kernel and neighborhood loop logic
- OBS replacements for time/texture/resolution
- single `render(...)` wrapper

## Practical checklist for agents

- Find matching converted file in `src/` first; follow its style.
- Do mechanical replacements (`iTime`, `iResolution`, `iChannel0`) first.
- Normalize UV handling to this repo's pattern.
- Move global float declarations into `mainImage` locals when possible (see `rainbow_melt`).
- Add/verify `render(float2 uv)` wrapper.
- Confirm all texture reads use `image.Sample(builtin_texture_sampler, ...)`.
- Confirm no remaining `iTime`, `iResolution`, `iChannel*`, or `texture(...)` unless intentionally retained.
- For directory-based originals (multi-file), merge relevant logic into one `src/<name>.glsl` output.
