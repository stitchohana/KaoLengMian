# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**CookM2** — a Godot 4.6 project using GL Compatibility renderer and Jolt Physics (3D). A cooking game called "烤冷面传奇" (Grilled Cold Noodle Legend), inspired by "Shawarma Legend".

## Project Structure

- `cook-m-2/` — Godot project root
- `cook-m-2/project.godot` — Engine configuration
- `.godot/` — Editor cache/imported assets (gitignored)

## Key Config

- **Engine:** Godot 4.6
- **Rendering:** GL Compatibility (`gl_compatibility`)
- **Physics:** Jolt Physics 3D
- **Scripting:** GDScript (no C#)
- **Line endings:** LF (enforced via `.gitattributes`)

## Commands

- **Open project:** Open `cook-m-2/project.godot` in the Godot 4.6 editor
- **Run game:** Press F5 in the Godot editor
- **MCP Debug:** Godot MCP is available via WebSocket port 9080

## Rules

- **DO NOT close the Godot engine** after making modifications. Always leave it running for testing.

## Godot 4.6 GDScript Conventions

- Use `@onready` for node references declared at script top
- Use `snake_case` for variables and functions
- Use PascalCase for node names, signal names, and file names
- Use `extends <type>` at the top of every script
- Connect signals in code (`signal.connect(...)`) rather than through the editor UI
- Leverage `@export` for inspector-exposed variables
- Prefer composition over inheritance: use child nodes and scenes, not deep class trees
- Store small data structures as `.gd` scripts with `extends Resource` rather than raw JSON
