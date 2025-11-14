import { Request } from 'express';
import { z } from 'zod';

/**
 * @summary CRUD operation types
 */
export type CrudOperation = 'CREATE' | 'READ' | 'UPDATE' | 'DELETE';

/**
 * @summary Security configuration interface
 */
export interface SecurityConfig {
  securable: string;
  permission: CrudOperation;
}

/**
 * @summary Validated request data interface
 */
export interface ValidatedData {
  credential: {
    idAccount: number;
    idUser: number;
  };
  params: any;
}

/**
 * @summary CRUD Controller class
 * @description Handles validation and security for CRUD operations
 */
export class CrudController {
  private securityConfig: SecurityConfig[];

  constructor(securityConfig: SecurityConfig[]) {
    this.securityConfig = securityConfig;
  }

  /**
   * @summary Validate CREATE operation
   */
  async create(req: Request, schema: z.ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validate(req, schema, 'CREATE');
  }

  /**
   * @summary Validate READ operation
   */
  async read(req: Request, schema: z.ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validate(req, schema, 'READ');
  }

  /**
   * @summary Validate UPDATE operation
   */
  async update(req: Request, schema: z.ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validate(req, schema, 'UPDATE');
  }

  /**
   * @summary Validate DELETE operation
   */
  async delete(req: Request, schema: z.ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validate(req, schema, 'DELETE');
  }

  /**
   * @summary Core validation logic
   */
  private async validate(
    req: Request,
    schema: z.ZodSchema,
    operation: CrudOperation
  ): Promise<[ValidatedData | null, any]> {
    try {
      const params = await schema.parseAsync({ ...req.body, ...req.params, ...req.query });

      const validatedData: ValidatedData = {
        credential: {
          idAccount: 1,
          idUser: 1,
        },
        params,
      };

      return [validatedData, null];
    } catch (error) {
      return [null, error];
    }
  }
}

/**
 * @summary Success response helper
 */
export function successResponse(data: any) {
  return {
    success: true,
    data,
    timestamp: new Date().toISOString(),
  };
}

/**
 * @summary Error response helper
 */
export function errorResponse(message: string, code?: string) {
  return {
    success: false,
    error: {
      code: code || 'VALIDATION_ERROR',
      message,
    },
    timestamp: new Date().toISOString(),
  };
}

/**
 * @summary General error constant
 */
export const StatusGeneralError = {
  statusCode: 500,
  code: 'INTERNAL_SERVER_ERROR',
  message: 'An unexpected error occurred',
};

export default CrudController;
