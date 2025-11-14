/**
 * @summary Test helper functions exports
 * @description Shared test helper utilities for all tests
 */

import { Request, Response } from 'express';

/**
 * @summary Create mock Express request
 */
export function createMockRequest(overrides?: Partial<Request>): Partial<Request> {
  return {
    body: {},
    params: {},
    query: {},
    headers: {},
    ...overrides,
  };
}

/**
 * @summary Create mock Express response
 */
export function createMockResponse(): Partial<Response> {
  const res: Partial<Response> = {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
    send: jest.fn().mockReturnThis(),
  };
  return res;
}

/**
 * @summary Create mock next function
 */
export function createMockNext(): jest.Mock {
  return jest.fn();
}
