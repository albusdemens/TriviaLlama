# TriviaLlama

In this Roblox demo, every time the character jumps over a cube, new Ollama-generated text is displayed.

## Getting Started

The system uses a bridge architecture:

1. A Node.js server acts as a bridge between Roblox and Ollama
2. When the character jumps over the cube in Roblox, it triggers an HTTP request to the bridge
3. The bridge forwards the request to the Ollama API
4. Ollama generates text which is sent back through the bridge to Roblox
5. The cube displays the newly generated text

### Prerequisites

- [Roblox Studio](https://www.roblox.com/create)
- [Rojo](https://rojo.space/)
- [Node.js](https://nodejs.org/en/)
- [Ollama](https://ollama.com/)

### Setup

Commands to run the Node.js server:

```bash
npm install express axios cors
node ollama-bridge/ollama-bridge.js
```

Command to run the Roblox client:

```bash
rojo serve
```
