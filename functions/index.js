/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { setGlobalOptions } = require("firebase-functions");
const { onRequest } = require("firebase-functions/https");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// Stored securely via `firebase functions:secrets:set OLLAMA_API_KEY`
// Never hardcode the key here or in the Flutter app for web builds.
const OLLAMA_API_KEY = defineSecret("OLLAMA_API_KEY");

const OLLAMA_URL = "https://api.ollama.com/api/chat";

/**
 * Web-only proxy for the Ollama chat API.
 *
 * The Flutter app calls Ollama directly on Android/iOS (no CORS there).
 * On web, browsers block direct cross-origin calls to api.ollama.com, and
 * shipping the API key to the browser would expose it in the Network tab
 * anyway. This function forwards the exact same request server-to-server,
 * where CORS does not apply, and injects the real API key itself.
 */
exports.ollamaProxy = onRequest(
    { secrets: [OLLAMA_API_KEY], cors: true, timeoutSeconds: 120 },
    async (req, res) => {
        if (req.method !== "POST") {
            res.status(405).json({ error: "Only POST is supported" });
            return;
        }

        try {
            const response = await fetch(OLLAMA_URL, {
                method: "POST",
                headers: {
                    "Authorization": `Bearer ${OLLAMA_API_KEY.value()}`,
                    "Content-Type": "application/json",
                },
                // Forward the body exactly as the Flutter app built it
                // (model, messages, tools, format, stream).
                body: JSON.stringify(req.body),
            });

            const data = await response.text();
            res.status(response.status).set("Content-Type", "application/json").send(data);
        } catch (err) {
            logger.error("ollamaProxy failed", err);
            res.status(502).json({ error: "Failed to reach Ollama", details: String(err) });
        }
    }
);