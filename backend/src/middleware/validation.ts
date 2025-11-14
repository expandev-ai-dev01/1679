import { Request, Response, NextFunction } from 'express';
import { z, ZodSchema } from 'zod';

/**
 * @summary Request validation middleware factory
 * @description Creates middleware for validating request data against Zod schemas
 *
 * @param schema Zod schema for validation
 * @param source Request property to validate (body, params, query)
 * @returns Express middleware function
 */
export function validationMiddleware(
  schema: ZodSchema,
  source: 'body' | 'params' | 'query' = 'body'
) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validated = await schema.parseAsync(req[source]);
      req[source] = validated;
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'validationFailed',
            details: error.errors,
          },
          timestamp: new Date().toISOString(),
        });
      } else {
        next(error);
      }
    }
  };
}
