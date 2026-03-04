import { z } from "zod";

export const HealthResponse = z.object({
	status: z.enum(["ok", "error"]),
	timestamp: z.number(),
});
export type HealthResponse = z.infer<typeof HealthResponse>;

export const ErrorResponse = z.object({
	error: z.string(),
	code: z.string(),
});
export type ErrorResponse = z.infer<typeof ErrorResponse>;
