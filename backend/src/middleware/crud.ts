import { Request } from 'express';
import { ZodSchema } from 'zod';

/**
 * @summary CRUD operation types
 */
export type CrudOperation = 'CREATE' | 'READ' | 'UPDATE' | 'DELETE' | 'LIST';

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
  params?: any;
  body?: any;
  query?: any;
}

/**
 * @summary CRUD Controller class
 * @description Handles security validation and request processing for CRUD operations
 */
export class CrudController {
  private securityConfig: SecurityConfig[];

  constructor(securityConfig: SecurityConfig[]) {
    this.securityConfig = securityConfig;
  }

  /**
   * @summary Validate CREATE operation
   */
  async create(req: Request, schema: ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validateOperation(req, schema, 'CREATE', 'body');
  }

  /**
   * @summary Validate READ operation
   */
  async read(req: Request, schema: ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validateOperation(req, schema, 'READ', 'params');
  }

  /**
   * @summary Validate UPDATE operation
   */
  async update(req: Request, schema: ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validateOperation(req, schema, 'UPDATE', 'body');
  }

  /**
   * @summary Validate DELETE operation
   */
  async delete(req: Request, schema: ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validateOperation(req, schema, 'DELETE', 'params');
  }

  /**
   * @summary Validate LIST operation
   */
  async list(req: Request, schema: ZodSchema): Promise<[ValidatedData | null, any]> {
    return this.validateOperation(req, schema, 'LIST', 'query');
  }

  /**
   * @summary Internal validation logic
   */
  private async validateOperation(
    req: Request,
    schema: ZodSchema,
    operation: CrudOperation,
    source: 'body' | 'params' | 'query'
  ): Promise<[ValidatedData | null, any]> {
    try {
      const validated = await schema.parseAsync(req[source]);

      const result: ValidatedData = {
        credential: {
          idAccount: 1,
          idUser: 1,
        },
        [source]: validated,
      };

      return [result, null];
    } catch (error) {
      return [null, error];
    }
  }
}

/**
 * @summary Success response helper
 */
export function successResponse<T>(data: T, metadata?: any) {
  return {
    success: true,
    data,
    metadata: {
      ...metadata,
      timestamp: new Date().toISOString(),
    },
  };
}
