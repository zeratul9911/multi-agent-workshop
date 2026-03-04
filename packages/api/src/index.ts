import type { HealthResponse } from "@playground/shared";
import { Hono } from "hono";

const app = new Hono();

app.get("/health", (c) => {
	const response: HealthResponse = {
		status: "ok",
		timestamp: Date.now(),
	};
	return c.json(response);
});

const port = Number(process.env.PORT) || 3000;
console.log(`API running on port ${port}`);

export default {
	port,
	fetch: app.fetch,
};
