import { Request, Response, NextFunction } from 'express';

/**
 * @summary Error response interface
 */
export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: any;
  };
  timestamp: string;
}

/**
 * @summary General error status
 */
export const StatusGeneralError = {
  statusCode: 500,
  message: 'internalServerError',
};

/**
 * @summary Error middleware
 * @description Centralized error handling for the application
 *
 * @param error Error object
 * @param req Express request
 * @param res Express response
 * @param next Express next function
 */
export function errorMiddleware(error: any, req: Request, res: Response, next: NextFunction): void {
  const statusCode = error.statusCode || 500;
  const message = error.message || 'internalServerError';

  const errorResponse: ErrorResponse = {
    success: false,
    error: {
      code: error.code || 'INTERNAL_ERROR',
      message: message,
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    },
    timestamp: new Date().toISOString(),
  };

  console.error('Error:', {
    statusCode,
    message,
    path: req.path,
    method: req.method,
    stack: error.stack,
  });

  res.status(statusCode).json(errorResponse);
}

/**
 * @summary Error response helper
 * @description Creates standardized error response object
 *
 * @param message Error message
 * @param code Error code
 * @param details Additional error details
 * @returns ErrorResponse object
 */
export function errorResponse(
  message: string,
  code: string = 'ERROR',
  details?: any
): ErrorResponse {
  return {
    success: false,
    error: {
      code,
      message,
      details,
    },
    timestamp: new Date().toISOString(),
  };
}
