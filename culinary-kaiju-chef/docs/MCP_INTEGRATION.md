# MCP Integration (Godot Project)

## Overview
This project includes three MCP-related toolchains:

1. coding-solo/godot-mcp (Node.js MCP server)  
2. ee0pdt/Godot-MCP (in-editor Godot addon, WebSocket based)  
3. 3ddelano/gdai-mcp-plugin-godot (external Godot control plugin demo project)  

They serve different layers. You normally only enable 1 + 2 together; (3) is optional for extended visual/context automation.

---
## 1. coding-solo/godot-mcp (Node server)
Path: `_mcp_tools/coding-solo-godot-mcp`

Build already present. To run standalone:
```
node C:/Users/fello/Desktop/game/culinary-kaiju-chef/_mcp_tools/coding-solo-godot-mcp/build/index.js --project C:/Users/fello/Desktop/game/culinary-kaiju-chef
```
Add to your MCP client config (example Cline):
```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["C:/Users/fello/Desktop/game/culinary-kaiju-chef/_mcp_tools/coding-solo-godot-mcp/build/index.js", "--project", "C:/Users/fello/Desktop/game/culinary-kaiju-chef"],
      "disabled": false,
      "autoApprove": ["launch_editor","run_project","create_scene","add_node","save_scene"]
    }
  }
}
```

## 2. ee0pdt/Godot-MCP Addon
Already copied into `addons/godot_mcp`. Enable in Godot:  
`Project > Project Settings > Plugins > Godot MCP > Enable`.

This exposes a WebSocket MCP endpoint (check Output panel for port). Point an MCP client at that port if it supports direct WS.

## 3. 3ddelano/gdai-mcp-plugin-godot
Currently stored as reference project under `_mcp_tools/gdai-mcp-plugin-godot`. You can run that Godot project separately if you want its richer control + screenshot automation.

Site / install docs: https://gdaimcp.com/docs/installation

If you later want to embed it: extract its actual addon (when upstream publishes plugin structure) into `addons/` but DO NOT commit secret keys.

---
## Recommended Workflow
1. Start Node MCP server (coding-solo) to allow AI to create/modify scenes & scripts.
2. Open Godot Editor and enable ee0pdt addon for real-time node/script commands via WebSocket.
3. (Optional) Run the gdai project for advanced contextual operations or screenshot capture.
4. Use EventBus + data resources; avoid direct scene tree mutation outside sanctioned tool functions.

---
## Safety / Discipline
- Never auto-commit secret files produced by external plugins.
- Keep object pooling and data-driven resources; AI tools should NOT reintroduce queue_free patterns.
- Large refactors: branch first, run minimal scene load test via MCP run command.

---
## Quick Test Commands (Node server)
(Names may vary depending on server tooling version.)
- launch_editor
- run_project
- list_projects
- analyze_project
- create_scene
- add_node
- save_scene

If a command fails, check the console for path or permission issues.

---
## Future
- Unify upgrade selection UI via MCP-driven prototyping.
- Add build/export automation tool hook (NOT yet needed at core loop stage).
