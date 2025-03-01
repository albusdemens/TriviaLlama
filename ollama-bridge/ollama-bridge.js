// bridge.js - Node.js bridge for connecting Roblox with Ollama
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Route to generate text from Ollama
app.post('/generate-text', async (req, res) => {
    try {
        const { prompt, model } = req.body;
        const modelName = model || 'qwen2:1.5b';

        console.log(`Received request for model: ${modelName}, prompt: "${prompt}"`);

        // First try the newer chat API
        try {
            const response = await axios({
                method: 'post',
                url: 'http://127.0.0.1:11434/api/chat',
                headers: { 'Content-Type': 'application/json' },
                data: {
                    model: modelName,
                    messages: [{ role: "user", content: prompt }]
                },
                timeout: 30000 // 30 second timeout
            });

            console.log('Using chat API');
            if (response.data && response.data.message && response.data.message.content) {
                const text = response.data.message.content;
                console.log(`Response: "${text.substring(0, 50)}..."`);
                return res.json({ success: true, text: text });
            }
        } catch (chatError) {
            console.log('Chat API failed, trying generate API');
            console.error('Chat API error:', chatError.message);
            // If chat API fails, we'll try the generate API next
        }

        // If we get here, try the older generate API
        const generateResponse = await axios({
            method: 'post',
            url: 'http://127.0.0.1:11434/api/generate',
            headers: { 'Content-Type': 'application/json' },
            data: {
                model: modelName,
                prompt: prompt,
                stream: false
            },
            timeout: 30000 // 30 second timeout
        });

        console.log('Using generate API');
        if (generateResponse.data && generateResponse.data.response) {
            const text = generateResponse.data.response;
            console.log(`Response: "${text.substring(0, 50)}..."`);
            return res.json({ success: true, text: text });
        } else {
            console.log('Unexpected response format:', generateResponse.data);
            return res.json({
                success: true,
                text: 'Got response from Ollama but in unexpected format'
            });
        }

    } catch (error) {
        console.error('All Ollama API attempts failed:', error.message);

        if (error.response) {
            console.error('Response status:', error.response.status);
            console.error('Response data:', JSON.stringify(error.response.data));
        }

        res.status(500).json({
            success: false,
            text: `Error from Ollama: ${error.message}`
        });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'OK' });
});

// Start the server
app.listen(port, '0.0.0.0', () => {
    console.log(`Ollama bridge server running at http://0.0.0.0:${port}`);
    console.log(`Ready to receive requests from Roblox`);
    console.log(`Make sure Ollama is running! (ollama serve)`);
});